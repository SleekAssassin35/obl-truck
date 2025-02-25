QBCore = exports['qb-core']:GetCoreObject()
local lvlLimit = Config.CompanySettings.Exp.lvlUpLimit
local capacity = Config.CompanySettings.Garage.GarageCapacity


RegisterServerEvent("gfx:server:CollectMoney")
AddEventHandler("gfx:server:CollectMoney", function(dist)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local maxDist = GetLongestDistance()
    
    if dist > maxDist then print("~r~SERVER: --WARNING IN GFX-TRUCKERJOB, ONE PLAYER USE EXECUTER OR SOMETHING", "Player:",Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname) return end

    local totalMoney = dist * Config.CompanySettings.Payment.distanceMultiplier + Config.CompanySettings.Payment.basePayment
    Player.Functions.AddMoney("cash", math.floor(totalMoney))
end)


QBCore.Functions.CreateCallback("gfx:server:MoneyCheck", function(source, cb, money)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if money ~= 0 then
        if Player.PlayerData.money["cash"] >= money then
            cb("ok")
            Player.Functions.RemoveMoney("cash", money)
            TriggerClientEvent('QBCore:Notify', src, "You have paid $  " .. money, "primary")
        elseif Player.PlayerData.money["bank"] >= money then
            cb("ok")
            Player.Functions.RemoveMoney("bank", money)
            TriggerClientEvent('QBCore:Notify', src, "You have paid $  " .. money, "primary")
        else
            cb("no")
            TriggerClientEvent('QBCore:Notify', src, "You have no money", "error")
        end
    else
        cb("ok")
    end
end)

--withdraw money from company_money
QBCore.Functions.CreateCallback("gfx:server:WithdrawCompanyMoney", function(source, cb, money)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSqlPromise(
        "UPDATE trucker_job SET company_money = company_money - @company_money WHERE citizenid = @citizenid", {
            ["@citizenid"] = Player.PlayerData.citizenid,
            ["@company_money"] = math.floor(money)
        })
    Player.Functions.AddMoney("cash", money)
    ExecuteSqlPromise(
        "SELECT company_money FROM trucker_job WHERE citizenid = @citizenid", {
            ["@citizenid"] = Player.PlayerData.citizenid,
        }, function(result)
            if result and result[1] and result[1].company_money ~= nil then
                cb(result[1].company_money)
            end
        end)
end)


--define function deposit or withdraw money from company_money
QBCore.Functions.CreateCallback("gfx:server:DepositMoney",function(source,cb,money) 
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.money["cash"] >= money then
        Player.Functions.RemoveMoney("cash", money)
        ExecuteSqlPromise(
            "UPDATE trucker_job SET company_money = company_money + @company_money WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@company_money"] = math.floor(money)
            })
        TriggerClientEvent('QBCore:Notify', src, "You have been deposit $  " .. money, "primary")
    elseif Player.PlayerData.money["bank"] >= money then
        Player.Functions.RemoveMoney("bank", money)
        ExecuteSqlPromise(
            "UPDATE trucker_job SET company_money = company_money + @company_money WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@company_money"] = math.floor(money)
            })
        TriggerClientEvent('QBCore:Notify', src, "You have been deposit $  " .. money, "primary")
    else
        TriggerClientEvent('QBCore:Notify', src, "You have no money", "error")
    end

    ExecuteSqlPromise(
        "SELECT company_money FROM trucker_job WHERE citizenid = @citizenid", {
            ["@citizenid"] = Player.PlayerData.citizenid,
        }, function(result)
            if result and result[1] and result[1].company_money ~= nil then
                cb(result[1].company_money)
            end
        end)
    

end)




--save employee in trucker_job tables
RegisterServerEvent("gfx:server:SaveEmployee")
AddEventHandler("gfx:server:SaveEmployee", function(employee)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSqlPromise("SELECT company_employee FROM trucker_job WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid,
    }, function(result)
        if result and result[1] and result[1].company_employee == nil then
            ExecuteSqlPromise("UPDATE trucker_job SET company_employee = @employee WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@employee"] = json.encode({ employee }),
            })
            ExecuteSqlPromise("UPDATE trucker_job SET company_garage_capacity = company_garage_capacity - @capacity WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@capacity"] = 1
            })
        else
            local employees = json.decode(result[1].company_employee)
            table.insert(employees, employee)
            ExecuteSqlPromise("UPDATE trucker_job SET company_employee = @employee WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@employee"] = json.encode(employees),
            })
            ExecuteSqlPromise("UPDATE trucker_job SET company_garage_capacity = company_garage_capacity - @capacity WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@capacity"] = 1
            })
        end
    end)
end)

RegisterServerEvent("gfx:server:CheckCompanyLevel")
AddEventHandler("gfx:server:CheckCompanyLevel", function(xp)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    ExecuteSqlPromise("SELECT comp_exp, company_level FROM trucker_job WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid
    }, function(result)

        local newExp = result[1].comp_exp + math.floor(xp)
        if newExp > lvlLimit then
            newExp = newExp - lvlLimit
            ExecuteSqlPromise("UPDATE trucker_job SET company_level = company_level + 1 WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid
            })
            ExecuteSqlPromise("UPDATE trucker_job SET comp_exp = @newExp WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@newExp"] = newExp
            })
            if result[1].company_level ~= 0 and result[1].company_level % 2 == 0 then
                ExecuteSqlPromise(
                    "UPDATE trucker_job SET garage_Upgrade_right = garage_Upgrade_right + 1 WHERE citizenid = @citizenid",
                    {
                        ["@citizenid"] = Player.PlayerData.citizenid,
                    })
            end
            TriggerClientEvent('QBCore:Notify', src, "Your Company Leveled Up ", "primary")
        else
            ExecuteSqlPromise("UPDATE trucker_job SET comp_exp = @newExp WHERE citizenid = @citizenid", {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@newExp"] = newExp
            })
        end
    end)
end)


--Upgrade garage level and
RegisterServerEvent("gfx:server:UpgradeGarage")
AddEventHandler("gfx:server:UpgradeGarage", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.money["cash"] >= Config.CompanySettings.Garage.UpgradeGarageCost or Player.PlayerData.money["bank"] >= Config.CompanySettings.Garage.UpgradeGarageCost then
    ExecuteSqlPromise(
        "UPDATE trucker_job SET garage_Upgrade_right = garage_Upgrade_right - 1 WHERE citizenid = @citizenid", {
            ["@citizenid"] = Player.PlayerData.citizenid
        })
    ExecuteSqlPromise("UPDATE trucker_job SET company_garage = company_garage +1 WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid,
    })
    ExecuteSqlPromise(
        "UPDATE trucker_job SET company_garage_capacity = company_garage_capacity + @capacity WHERE citizenid = @citizenid",
        {
            ["@citizenid"] = Player.PlayerData.citizenid,
            ["@capacity"] = capacity
        })
    else
        TriggerClientEvent('QBCore:Notify', src, "You have no money", "error")
    end
    end)

-- calculate employee income
function CalculateEmployeeIncome()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local src = Player.PlayerData.source
                ExecuteSqlPromise("SELECT company_employee FROM trucker_job WHERE citizenid = @citizenid", {
                    ["@citizenid"] = Player.PlayerData.citizenid,
                }, function(result)
                    if result and result[1] and result[1].company_employee ~= nil and result[1].company_employee ~= '[]' then
                        local employees = json.decode(result[1].company_employee)

                        local activeEmployees = {} -- Aktif moddaki işçileri saklayacak tablo

                        -- Aktif işçileri seçme
                        for _, employee in ipairs(employees) do
                            if employee.status == "active" then
                                table.insert(activeEmployees, employee) --soldaki veri girilecek liste sağdaki veri
                            end
                        end

                        -- Eğer en az bir aktif işçi varsa gelir hesapla
                        if #activeEmployees > 0 then
                            local selectedEmployee = activeEmployees[math.random(1, #activeEmployees)]
                            local income = math.random(selectedEmployee.minincome, selectedEmployee.maxincome)
                            TriggerClientEvent('QBCore:Notify', src,"Your employee " ..selectedEmployee.name .. " " ..selectedEmployee.surname.." completed a job and earned, $ " .. income, "primary", 5000)
                            ExecuteSqlPromise(
                                "UPDATE trucker_job SET company_money = company_money + @employee_income, company_jobs_done = company_jobs_done + 1 WHERE citizenid = @citizenid",
                                {
                                    ["@citizenid"] = Player.PlayerData.citizenid,
                                    ["@employee_income"] = math.floor(income)
                                })
                        end
                    end
                end)
            end
        end
    end
end

-- calculate employee salary
function CalculateEmployeeSalary()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local src = Player.PlayerData.source
                ExecuteSqlPromise("SELECT company_employee FROM trucker_job WHERE citizenid = @citizenid", {
                    ["@citizenid"] = Player.PlayerData.citizenid,
                }, function(result)
                    if result and result[1] and result[1].company_employee ~= nil and result[1].company_employee ~= '[]' then
                        local employees = json.decode(result[1].company_employee)
                        local activeEmployees = {} -- Aktif moddaki işçileri saklayacak tablo

                        -- Aktif işçileri seçme
                        for _, employee in ipairs(employees) do
                            if employee.status == "active" then
                                table.insert(activeEmployees, employee)
                            end
                        end

                        -- Eğer en az bir aktif işçi varsa maaş hesapla
                        if #activeEmployees > 0 then
                            local selectedEmployee = activeEmployees[math.random(1, #activeEmployees)]
                            local salary = selectedEmployee.level * Config.CompanySettings.Employee.salary
                            
                            ExecuteSqlPromise("SELECT company_money FROM trucker_job WHERE citizenid = @citizenid", {
                                ["@citizenid"] = Player.PlayerData.citizenid,
                            }, function(comp_money)
                                if comp_money and comp_money[1] and comp_money[1].company_money ~= nil then
                                    if comp_money[1].company_money >= salary then
                                        ExecuteSqlPromise(
                                            "UPDATE trucker_job SET company_money = company_money - @employee_salary WHERE citizenid = @citizenid",
                                            {
                                                ["@citizenid"] = Player.PlayerData.citizenid,
                                                ["@employee_salary"] = math.floor(salary)
                                            })
                                        TriggerClientEvent('QBCore:Notify', src,"Salary paid to employee " ..selectedEmployee.name.." " ..selectedEmployee.surname .. ", $ " .. salary, "primary", 5000)

                                    else
                                        selectedEmployee.status = "passive"
                                        ExecuteSqlPromise(
                                            "UPDATE trucker_job SET company_employee = @company_employee WHERE citizenid = @citizenid",
                                        {
                                            ["@citizenid"] = Player.PlayerData.citizenid,
                                            ["@company_employee"] = json.encode(employees)
                                        })
                                    end
                                end
                            end)
                        
                        end
                    end
                end)
            end
        end
    end
end

RegisterServerEvent("gfx:server:TurnActiveEmployee")
AddEventHandler("gfx:server:TurnActiveEmployee", function(dataTable)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSqlPromise("SELECT company_employee FROM trucker_job WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid,
    }, function(result)
        if result and result[1] and result[1].company_employee ~= nil and result[1].company_employee ~= '[]' then
            ExecuteSqlPromise(
                "UPDATE trucker_job SET company_employee = @company_employee WHERE citizenid = @citizenid",
            {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@company_employee"] = json.encode(dataTable)
            })
        end
    end)
end)

RegisterServerEvent("gfx:server:FireEmployee")
AddEventHandler("gfx:server:FireEmployee", function(dataTable)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSqlPromise("SELECT company_employee FROM trucker_job WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid,
    }, function(result)
        if result and result[1] and result[1].company_employee ~= nil and result[1].company_employee ~= '[]' then
            ExecuteSqlPromise(
                "UPDATE trucker_job SET company_employee = @company_employee, company_garage_capacity = company_garage_capacity + 1  WHERE citizenid = @citizenid",
            {
                ["@citizenid"] = Player.PlayerData.citizenid,
                ["@company_employee"] = json.encode(dataTable),
            })
        end
    end)
end)





QBCore.Functions.CreateCallback("gfx:server:CheckPlayerData",function(source,cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    cb(Player.PlayerData)
end)



--define callback function for all trucker_job tables
QBCore.Functions.CreateCallback("gfx:server:CheckAll", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = ExecuteSqlPromise("SELECT * FROM trucker_job WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid
    })
    if result[1] then
        cb(result[1])
    else
        cb(false)
    end
end)

--add company money end of the job
RegisterServerEvent("gfx:server:AddCompanyMoney")
AddEventHandler("gfx:server:AddCompanyMoney", function(distance)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local maxDist = GetLongestDistance()
    
    if distance > maxDist then print("~r~SERVER: --WARNING IN GFX-TRUCKERJOB, ONE PLAYER USE EXECUTER OR SOMETHING", "Player:",Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname) return end

    local totalMoney = distance * Config.CompanySettings.Payment.distanceMultiplier + Config.CompanySettings.Payment.basePayment
    ExecuteSqlPromise("UPDATE trucker_job SET company_money = company_money + @company_money, company_jobs_done = company_jobs_done + 1  WHERE citizenid = @citizenid", {
        ["@citizenid"] = Player.PlayerData.citizenid,
        ["@company_money"] = math.floor(totalMoney)
    })
    
end)

function GetLongestDistance()
    local startPos = vector3(Config.TrailerPos.x, Config.TrailerPos.y, Config.TrailerPos.z)
    local maxDist = 0
    for i = 1, #Config.Destinations do
        local endPos = Config.Destinations[i]
        local dist = #(endPos - startPos)
        if dist > maxDist then
            maxDist = dist
        end
    end
    return maxDist
end

-- save player company name in trucker_job tables
QBCore.Functions.CreateCallback("gfx:server:CheckCompName", function(source, cb, compName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSqlPromise("INSERT INTO trucker_job (citizenid, company_name) VALUES(@citizenid,@company_name)", {
        ["@citizenid"] = Player.PlayerData.citizenid,
        ["@company_name"] = compName
    })
    cb(compName)
end)



-- refactor ExecuteSql function by promise
function ExecuteSqlPromise(query, parameters, cb)
    local promise = promise:new()

    if Config.SQLScript == "oxmysql" then
        exports.oxmysql:execute(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    elseif Config.SQLScript == "ghmattimysql" then
        exports.ghmattimysql:execute(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    elseif Config.SQLScript == "mysql-async" then
        MySQL.Async.fetchAll(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    end
    return Citizen.Await(promise)
end

CreateThread(function()
    while true do
        Citizen.Wait(1000  * Config.CompanySettings.Employee.employeeIncomeTimeout)
        CalculateEmployeeIncome()
    end
end)
CreateThread(function()
    if Config.CompanySettings.Employee.employeeSalaryTimeout ~= 0 then
        while true do
        Citizen.Wait(1000  * Config.CompanySettings.Employee.employeeSalaryTimeout)
        CalculateEmployeeSalary()
        end
    end
end)

-- RegisterCommand("para", function (source) --testing code
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     Player.Functions.RemoveMoney("cash", 1000)
-- end, true)

