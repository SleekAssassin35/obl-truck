QBCore = exports['qb-core']:GetCoreObject()

local isJobActive = false
local activeTruck = nil
local activeTrailer = nil
local destination = nil
local targetBlip = nil
local distance = nil
local hesapList = {}
--#region spawnNpc
CreateThread(function()
    for i = 1, #Config.Npc do
            local entity = CreateNpc(Config.Npc[i].model, Config.Npc[i].pos, Config.Npc[i].heading)
            CreateBlipEntity(entity, Config.Npc[i].blipSprite, Config.Npc[i].blipColor, Config.Npc[i].blipText,
            Config.Npc[i].blipShortRange, Config.Npc[i].blipSize)
        end
end)
--#endregion

--#region Interaction
for i = 1, #Config.Npc do
    exports['qb-target']:AddTargetModel(Config.Npc[i].model, {
        options = {
            {
                event = 'gfx:client:StartJob',
                type = 'client',
                icon = "fas fa-trailer",
                label = "Trucker Job",
            },
        },
        distance = 1.5,
    })
end
--#endregion


RegisterNetEvent("gfx:client:StartJob", function()
    if isJobActive then
        QBCore.Functions.Notify("You already have a job", "error")
        CancelJob()
        return
    end
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(comp)
        if comp then
            comp.company_employee = json.decode(comp.company_employee)
            local company_employee = {}
            for index, value in ipairs(comp.company_employee) do
                if value then table.insert(company_employee, value) end
            end
            SendNUIMessage({
                type              = "open:menuWithComp",
                trailerList       = Config.Trailers,
                distanceData      = Hesap(Config.TrailerPos, Config.Destinations),
                paymentData       = Config.CompanySettings.Payment,
                employeeData      = Config.CompanySettings.Employee,
                comp              = comp,
                employee          = company_employee,
                upgradeGarageCost = Config.CompanySettings.Garage.UpgradeGarageCost,
                bool              = true,
            })
            SetNuiFocus(true, true)
        else
            QBCore.Functions.TriggerCallback("gfx:server:CheckPlayerData", function(playerData)
                local havemoney = (playerData.money.bank >= Config.CompanySettings.CompanyRegisterCost) or
                    (playerData.money.cash >= Config.CompanySettings.CompanyRegisterCost)

                SendNUIMessage({
                    type                     = "open:menuWithoutComp",
                    trailerList              = Config.Trailers,
                    distanceData             = Hesap(Config.TrailerPos, Config.Destinations),
                    paymentData              = Config.CompanySettings.Payment,
                    compCost                 = Config.CompanySettings.CompanyRegisterCost,
                    canHaveRegisterCompMoney = havemoney,
                    bool                     = true,
                })
            end)
            SetNuiFocus(true, true)
        end
    end)
end)

RegisterNuiCallback("refresh", function(data, cb)
    local promise = promise:new()
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(comp)
        promise:resolve(comp)
    end)
    cb(Citizen.Await(promise))
end)


-- exit ui
RegisterNuiCallback("exit", function(data)
    SetNuiFocus(data, data);
end)

-- joblist ui callback
RegisterNuiCallback("submit", function(data)
    data.distance = tonumber(data.distance)
    if isJobActive then return QBCore.Functions.Notify("You already have a job", "error") end

    EnterJob(data.model, data.type, data.distance)

    QBCore.Functions.Notify("Take the trailer and deliver it.", "primary", 3000)
end)

-- upgrade garage ui callback
RegisterNuiCallback("upgradeGarage", function()
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(comp)
        if comp.garage_Upgrade_right > 0 then
            TriggerServerEvent("gfx:server:UpgradeGarage")
            QBCore.Functions.Notify("You upgraded your garage", "primary", 3000)
        else
            QBCore.Functions.Notify("You need to level up your company", "error", 3000)
            return
        end
    end)
end)

-- hire employee ui callback
RegisterNuiCallback("employeeHire", function(data, cb) 
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(comp)
        if comp.company_garage_capacity > 0 then 
            local eName = tostring(data.name)
            local eSurname = tostring(data.surname)
            local eLevel = tonumber(data.level)
            local eMinincome = tonumber(data.minincome)
            local eMaxincome = tonumber(data.maxincome)
            local hirePrice = tonumber(data.employeePrice)
            local eID = tonumber(data.employeeID)
            local employee = {
                name = eName,
                surname = eSurname,
                level = eLevel,
                minincome = eMinincome,
                maxincome = eMaxincome,
                status = "active",
                id = eID,
            }
            QBCore.Functions.TriggerCallback("gfx:server:MoneyCheck", function(returnValue)
                if returnValue == "ok" then
                    QBCore.Functions.Notify("You hired a new employee", "primary", 3000)
                    TriggerServerEvent("gfx:server:SaveEmployee", employee)
                else
                    QBCore.Functions.Notify("You don't have enough money", "error", 3000)
                    return
                end
            end, hirePrice)
        else
            QBCore.Functions.Notify("You need to upgrade your garage", "error", 3000)
            return
        end
        cb("ok")
    end)
end)


--switch employee status ui callback
RegisterNuiCallback("switchStatus", function(data)
    TriggerServerEvent("gfx:server:TurnActiveEmployee", data.data)
end)
--fire employee ui callback
RegisterNuiCallback("fireEmployee", function(data)
    TriggerServerEvent("gfx:server:FireEmployee", data.data)
end)




-- comp name save
RegisterNuiCallback("compName", function(data, cb)
    QBCore.Functions.TriggerCallback("gfx:server:MoneyCheck", function(registerValue)
        if registerValue == "ok" then
            QBCore.Functions.TriggerCallback("gfx:server:CheckCompName", function(returnValue)
                cb(returnValue)
            end, data.name)
            QBCore.Functions.Notify("You registered " .. data.name .. " company", "primary", 3000)
        end
    end, Config.CompanySettings.CompanyRegisterCost)
end)

-- depositMoney to company account
RegisterNuiCallback("depositMoney", function(data, cb)
    local amount = tonumber(data.money)

    QBCore.Functions.TriggerCallback("gfx:server:DepositMoney", function(returnMoney)
        cb(returnMoney)
    end, amount)
end)

-- withdrawMoney from company account
RegisterNuiCallback("withdrawMoney", function(data, cb)
    if data and data.money and data.money == nil and data.money == "" then
        QBCore.Functions.Notify("You must enter a amount", "error", 3000)
        return
    end
    local amount = tonumber(data.money)
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(comp)
        if comp.company_money >= amount then
            QBCore.Functions.TriggerCallback("gfx:server:WithdrawCompanyMoney", function(returnValue)
                cb(returnValue)
            end, amount)
        else
            QBCore.Functions.Notify("You don't have enough money company account", "error", 3000)
            return
        end
    end)
end)

-- cancel job
function CancelJob()
    Citizen.CreateThread(function()
        local start = GetGameTimer()
        while GetGameTimer() - start < 10000 do
            AddTextEntry("press_canceljob", "Press ~INPUT_CONTEXT~ to cancel Job")
            DisplayHelpTextThisFrame("press_canceljob")
            if IsControlJustPressed(0, 38) then
                local coords = Config.trucks.truckPos
                ClearAreaOfVehicles(coords.x, coords.y, coords.z, 50.0, false, false, false, false, false)
                DeleteCheckpoint(CheckPoint)
                RemoveBlip(targetBlip)
                DeleteEntity(activeTrailer)
                SetEntityAsNoLongerNeeded(activeTrailer)
                Wait(500)
                activeTrailer = nil
                targetBlip = nil
                isJobActive = false
                QBCore.Functions.Notify("Job canceled", "error", 3000)
                return
            end
            Wait(0)
        end
    end)
end

-- job start
function EnterJob(model, type, dist)
    QBCore.Functions.TriggerCallback("gfx:server:MoneyCheck", function(returnValue)
        if returnValue == "ok" then
            destination = CheckDistList(dist)
            isJobActive = true
            distance = dist
            targetBlip = CreateBlipCoords(destination.x, destination.y, destination.z, 1, 5, "Destination", false)

            SpawnTruck()
            SpawnTrailer(model, type)
            Check(type, destination)
        end
    end, Config.CompanySettings.Payment.deposit)
end

--#region Spawn Truck
function SpawnTruck()
    local i = math.random(1, #Config.trucks.model)
    local model = Config.trucks.model[i]
    local coords = Config.trucks.truckPos
    ClearAreaOfVehicles(coords.x, coords.y, coords.z, 50.0, false, false, false, false, false)
    if activeTruck ~= nil then
        SetEntityAsNoLongerNeeded(activeTruck)
        DeleteEntity(activeTruck)
        activeTruck = nil
    end
    LoadModel(model)
    activeTruck = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetVehicleNumberPlateText(activeTruck, "GFX" .. tostring(math.random(1000, 9999)))
    exports['wd-uikit']:closeMenu()
    SetEntityAsMissionEntity(activeTruck, true, true)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(activeTruck))
    CurrentPlate = QBCore.Functions.GetPlate(activeTruck)
end

--#endregion

--#region SpawnTrailer
function SpawnTrailer(model, type)
    local coords = Config.TrailerPos
    ClearAreaOfVehicles(coords.x, coords.y, coords.z, 50.0, false, false, false, false, false)
    LoadModel(model)
    activeTrailer = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetEntityAsMissionEntity(activeTrailer, true, true)
end

--#endregion


function CalculateDistance(startPos, targetPos)
    local point = #(Vector4ToV3(startPos) - Vector4ToV3(targetPos))
    return point
end

--#endregion

--#region Hesap
function Hesap(pos, array)
    for i = 1, #array do
        hesapList[i] = {}
        hesapList[i].distance = CalculateDistance(pos, array[i])
        hesapList[i].startStreet = GetStreetAndZone(pos)
        hesapList[i].endStreet = GetStreetAndZone(array[i])
    end
    return hesapList
end

function GetStreetAndZone(coords)
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local area = GetLabelText(tostring(GetNameOfZone(coords.x, coords.y, coords.z)))
    local playerStreetsLocation = area
    if not zone then zone = "UNKNOWN" end
    if currentStreetName ~= nil and currentStreetName ~= "" then
        playerStreetsLocation = currentStreetName --.. ", " .. area
    else
        playerStreetsLocation = area
    end
    return playerStreetsLocation
end

function CheckDistList(dist)
    for i = 1, #Config.Destinations do
        
        if dist == CalculateDistance(Config.TrailerPos, Config.Destinations[i]) then
            return Config.Destinations[i]
        end
    end
end

--#endregion


--#region FinishJob
function FinishJob(type)
    Wait(500)
    DeleteCheckpoint(CheckPoint)
    RemoveBlip(targetBlip)
    SetEntityAsNoLongerNeeded(activeTrailer)
    DeleteEntity(activeTrailer)
    activeTrailer = nil
    targetBlip = nil
    isJobActive = false
    QBCore.Functions.TriggerCallback("gfx:server:CheckAll", function(haveComp)
        if haveComp then
            AddExperiance(type)
            QBCore.Functions.Notify("Fee stored Company Account", "primary", 3000)
            TriggerServerEvent("gfx:server:AddCompanyMoney", distance)
        else
            TriggerServerEvent("gfx:server:CollectMoney", distance)
            QBCore.Functions.Notify("Job finished", "primary", 3000)
        end
    end)
    GiveBackTruck()
end

--#endregion

--#region GiveBackTruck
function GiveBackTruck()
    CreateThread(function()
        local condition = true
        local coords = Config.trucks.truckPos
        CreateCheckpoint(3, coords.x, coords.y, coords.z, coords.x, coords.y, coords.z, 3.0, 0, 0, 255, 0, 0)
        local blip = CreateBlipCoords(coords.x, coords.y, coords.z, 1, 5, "Turn Back", false)
        local player = PlayerPedId()
        while condition do
            if isJobActive then
                RemoveBlip(blip)
                break
            end
            local sleep = 1
            local pcoord = GetEntityCoords(player)
            DrawMarker(39, coords.x, coords.y, coords.z + 3, 0.0, 0.0, 0.0, 0.0, 0.0,
                0, 3.0, 5.0, 3.0, 0, 255, 255, 255, true, true, false, false, false, false, false)
            if #(Vector4ToV3(pcoord) - Vector4ToV3(coords)) < 10 and GetVehiclePedIsIn(player, true) then
                DrawText3D(coords.x, coords.y, coords.z + 1.0, 1.0, "Press [E] to give back the truck")
                DrawMarker(39, coords.x, coords.y, coords.z + 3, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0, 3.0, 5.0, 3.0, 0, 255, 0, 255, true, true, false, false, false, false, false)
                if IsControlJustPressed(0, 38) then
                    local vehicle = GetVehiclePedIsIn(player, true)
                    if vehicle then
                        DeleteEntity(vehicle)
                        RemoveBlip(blip)
                        condition = false
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

--#endregion

--#region AttachTrailer
function AttachTrailer()
    local player                     = PlayerPedId()
    local truckCoords                = GetEntityCoords(activeTruck)
    local trailerCoords              = GetEntityCoords(activeTrailer)
    local truckSpeed                 = GetEntitySpeed(activeTruck) * 3.6
    local dimensionMin, dimensionMax = GetModelDimensions(GetEntityModel(activeTruck))
    local trunkpos                   = GetOffsetFromEntityInWorldCoords(activeTruck, 0.0, (dimensionMin.y), 0.0)
    local distance                   = #(trailerCoords - trunkpos)
    if distance < 10 and IsPedInVehicle(player, activeTruck, false) and not IsVehicleAttachedToTrailer(activeTruck) and truckSpeed <= 2 then
       
        DrawText3D(trailerCoords.x, trailerCoords.y, trailerCoords.z + 1.0, 1.0, "Press [E] to attach the trailer")
        if IsControlJustPressed(0, 38) then
            AttachVehicleToTrailer(activeTruck, activeTrailer, 5.0)
        end
    end
end

--#endregion


--#region Exp system
function AddExperiance(type)
    local xp = Config.CompanySettings.Exp.typeExp[type] +
        ((Config.CompanySettings.Exp.distanceExp * distance) + Config.CompanySettings.Exp.baseExp)
    TriggerServerEvent("gfx:server:CheckCompanyLevel", xp)
end

--#endregion

--#region Check
function Check(type, dist)
    CreateThread(function()
        while isJobActive do
            local sleep = 1
            local player = PlayerPedId()
            local truckCoords = GetEntityCoords(activeTruck)
            local trailerCoords = GetEntityCoords(activeTrailer)
            if #(trailerCoords - dist) < 8 and not IsVehicleAttachedToTrailer(activeTruck) then
                FinishJob(type)
            elseif #(trailerCoords - dist) < 9 and IsVehicleAttachedToTrailer(activeTruck) then
                AddTextEntry("press_detach_trailer", "Long press ~INPUT_VEH_HEADLIGHT~ to detach the trailer")
                DisplayHelpTextThisFrame("press_detach_trailer")
                DrawMarker(39, dist.x, dist.y, dist.z + 3, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0, 3.0, 5.0, 3.0, 0, 255, 0, 255, true, true, false, false, false, false, false)
            else
                DrawMarker(39, dist.x, dist.y, dist.z + 3, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0, 3.0, 5.0, 3.0, 255, 255, 255, 255, true, true, false, false, false, false, false)
            end

            if not IsPedInVehicle(player, activeTruck, false) then
                DrawMarker(2, truckCoords.x, truckCoords.y, truckCoords.z + 6.0, 0.0, 0.0, 0.0, 180.0, 0.0,
                    0, 3.0, 3.0, 3.0, 255, 255, 255, 255, true, true, false, false, false, false,
                    false)
            end

            if not IsVehicleAttachedToTrailer(activeTruck) then
                DrawMarker(2, trailerCoords.x, trailerCoords.y, trailerCoords.z + 6.0, 0.0, 0.0, 0.0, 180.0, 0.0,
                    0, 3.0, 3.0, 3.0, 255, 255, 255, 255, true, true, false, false, false, false,
                    false)
            end
            AttachTrailer()
            Wait(sleep)
        end
    end)
end

--#region  When Script restart all variables set to default
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if activeTruck ~= nil and activeTrailer ~= nil then
        SetEntityAsNoLongerNeeded(activeTruck)
        SetEntityAsNoLongerNeeded(activeTrailer)
        DeleteEntity(activeTruck)
        DeleteEntity(activeTrailer)
        activeTruck = nil
        activeTrailer = nil
    end
end)
--#endregion

--region Randomchoice
function Randomchoice(table)
    return table[math.random(1, #table)]
end

--#endregion

--#region LoadModel
function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
    end
end

--#endregion


--#region Vector4 convert
function Vector4ToV3(coord)
    return vec3(coord.x, coord.y, coord.z)
end

--#endregion


--region CreateBlipCoords
function CreateBlipCoords(coordx, coordy, coordz, sprite, color, text, isShortRange, blipSize)
    isShortRange = isShortRange ~= nil and isShortRange or true
    blipSize = blipSize ~= nil and blipSize or 1.0
    local blip = AddBlipForCoord(coordx, coordy, coordz)
    SetBlipAsShortRange(blip, isShortRange)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipRoute(blip, true)
    SetBlipScale(blip, blipSize)
    SetBlipRouteColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

--#endregion


--#region CreateBlipEntity
function CreateBlipEntity(entity, sprite, color, text, isShortRange, blipSize)
    isShortRange = isShortRange ~= nil and isShortRange or true
    blipSize = blipSize ~= nil and blipSize or 1.0
    local blip = AddBlipForEntity(entity)
    SetBlipAsShortRange(blip, isShortRange)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, blipSize)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

--#endregion


--#region Npc Freeze
function CreateNpc(npcHash, npcCoord, h)
    local model = GetHashKey(npcHash)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local h = h ~= nil and h or math.random(0, 359) + .0

    local npc = CreatePed(4, model, npcCoord.x, npcCoord.y, npcCoord.z, h, false, true)
    SetPedCanBeTargetted(npc, false)
    SetPedCanPlayAmbientAnims(npc, true)
    SetPedCanRagdollFromPlayerImpact(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetModelAsNoLongerNeeded(model)
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedCanRagdoll(npc, false)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetPedCanPlayInjuredAnims(npc, false)
    SetPedGeneratesDeadBodyEvents(npc, true)
    return npc
end

--#endregion



--#region drawtext
function DrawText3D(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

--#endregion