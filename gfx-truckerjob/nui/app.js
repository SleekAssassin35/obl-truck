const joblist1 = $(".list1");
const joblist2 = $(".list2");
const employeeListHTML = $(".hire-employee");
const myWorkers = $(".my-workers");
const garagesContain = $(".garages-comp-contain");
const li = document.getElementsByClassName("list").length;
let trailerList = [];
let employeeNames = [];
let employeSurnames = [];
let showWorkerList = [];
let employeelevelMultiplier;
let companyRegisterCost;
let haveMoney;
let isregister;
let dataList = [];
let upgradeGarageCost;

const generateJoblist = (
  model,
  title,
  type,
  distance,
  price,
  startStreet,
  endStreet,
  bool
) => {
  
  const html = `
      <div class="emp-box" data-model=${model} data-title=${title} data-type=${type} data-price=${price} data-distance=${distance} >
        <div class="truck-img-contain">
            <img src="assets/realistic-truck.png" alt="">
                </div>
                  <div class="job-general-infos">
                    <div class="job-infos">
                      <h1> ${title} ( 22 t )</h1>
                      <p>Load Type :  ${type.toUpperCase()} </p>
                        <div class="job-info-locations">
                        
                          <h2>${startStreet}</h2>
                          <img src="assets/location-icon.png" alt="">
                          <h2>${endStreet}</h2>
                          </div>
                        </div>
                      <div class="job-financial-infos">
                    <h1 class="financial-money takejob"> ${price} $ <img src="assets/cursor-pointer.png" alt=""></h1>
                    <p class="financial-kmmoney"> ${(distance / price).toFixed(2)} $ / km </p>
                </div>
            </div>
        </div>
  `;
  //<h2> ${type} </h2>
  if (bool) {
    joblist1.append(html);
  } else {
    joblist2.append(html);
  }
};

const generateEmployeeList = (
  name,
  surname,
  level,
  minincome,
  maxincome,
  employeePrice,
  empID
) => {
  const html = `
  <div class="jobs-box" data-name=${name} data-surname=${surname} data-level=${level} data-minincome=${minincome} data-maxincome=${maxincome} data-employeePrice=${employeePrice} data-employeeid=${empID}>
                                <div class="jobs-boxs-player">
                                    <div class="jobs-player">
                                        <img src="assets/trucker-garage-image.png" alt="">
                                        <div class="jobs-player-buttons">
                                            <button class="player-button -hire-job pageBtn"><p>HIRE $${employeePrice}</p></button>
                                        </div>
                                    </div>
                                </div>
                                <div class="jobs-contain">
                                    <div class="jobs-header">
                                        <h1 class="username">${name}</h1>
                                        <p class="surname">${surname}</p>
                                        <div class="level-progress">
                                            <p>Driver Level: ${level}</p>
                                        
                                        </div>
                                    </div>

                                    <div class="jobs-content">
                                        <div class="jobs-value">
                                            <h1>Worker Infos</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>ID</h2>
                                                    <p>${empID}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Status</h2>
                                                    <p>Active</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="jobs-value">
                                            <h1>Avarage Return</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>Minimun Income</h2>
                                                    <p>${minincome}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Maximum Income</h2>
                                                    <p>${maxincome}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
            `;
  employeeListHTML.append(html);
};

//open menu withoout comp
window.addEventListener("message", (e) => {
  const data = e.data;
  if (data.type == "open:menuWithoutComp") {
    Display(data.bool);
    $(".gfxtrucker-createcomp-contain").css("display", "none");
    $(".gfxtrucker-main-contents").css("display", "flex");
    $(".compSection").css("display", "none");
    $(".content-jobs").css("display", "none");
    $(".content-employess").css("display", "none");
    const { distanceMultiplier, basePayment } = data.paymentData;
    haveMoney = data.canHaveRegisterCompMoney;

    TakeData(
      data.trailerList,
      data.distanceData,
      distanceMultiplier,
      basePayment
    );
    isregister = false;
    BtnDisable(isregister);

    if (!haveMoney) {
      $(".sidebar-create-button").css("cursor", "not-allowed");
      $(".sidebar-create-button").prop("disabled", true);
    }else
    {
      $(".sidebar-create-button").css("cursor", "pointer");
      $(".sidebar-create-button").prop("disabled", false);
    }
    $(".sidebar-create-button").find("p").text(`Register Company ($${data.compCost})`);
    $(".compSection").css("display", "none");
    
    $(document).on("click", ".sidebar-create-button" , () => {
      $(".gfxtrucker-main-contents").css("display", "none"); //main menuyu kapat
      registerMenu();
    });
  }
});

//open ui and take data with comp
window.addEventListener("message", (e) => {
  const data = e.data;
  if (data.type == "open:menuWithComp") {
    Display(data.bool);
    $(".gfxtrucker-main-contents").css("display", "flex");
    $(".compSection").css("display", "block");
    $(".gfxtrucker-createcomp-contain").css("display", "none");
    $(".sidebar-create-button").css("display", "none");
    $(".content-employess").css("display", "none");
    $(".content-jobs").css("display", "none");
    const {
      company_money,
      company_level,
      comp_exp,
      company_garage,
      company_name,
      company_garage_capacity,
      garage_Upgrade_right,
      company_jobs_done,
    } = data.comp;
    const { distanceMultiplier, basePayment } = data.paymentData;
    const { levelPerMoney, surnames, names } = data.employeeData;     

    let compName = document.querySelectorAll(".cmpName");
    compName.forEach((element) => {
      element.textContent = company_name;
    });
    BtnDisable(true);
    $(".compInfoGarageLevel").text(company_garage);
    $("#compInfoMoney").text(`$ ${company_money}`); //para

    try {
      $(".compInfoEmployeeCount").text(data.employee.length); //çalışanların sayısı
    } catch (error) {
      $(".compInfoEmployeeCount").text(0);
    }

    $(".compInfoTrucks").text(company_jobs_done); // jobs done
    
    if (data.employee == undefined && data.employee == null) data.employee = [];
     showWorkerList = data.employee;
     ShowMyWorkers(showWorkerList);
     $(".drivers").empty();
    DriversList(showWorkerList);
    upgradeGarageCost = data.upgradeGarageCost;
    CompAndGarageInfo(showWorkerList.length, company_garage_capacity, company_garage, company_level, garage_Upgrade_right, comp_exp, company_name, upgradeGarageCost, company_jobs_done );

    TakeData(
      data.trailerList,
      data.distanceData,
      distanceMultiplier,
      basePayment
    );

    generateEmployee(names, surnames, levelPerMoney, company_level);
  }
});

function TakeData(array, distList, distanceMultiplier, basePayment) {
  for (const i in array) {
    model = array[i].model;
    type = array[i].type[Math.floor(Math.random() * array[i].type.length)]; 
    trailerList[i] = { model, type };
  }
  addJobList(trailerList, distList, distanceMultiplier, basePayment);
}

// listeye ekleme ve ekrana yazdırma
function addJobList(list, distList, priceMultiplier, basePayment) {
  let random = getRandomInt(10, 20);
  for (let i = 0; i < list.length; i++) {
    if (i % 2 == 0) {
      if ($(".emp-box").length < random) {
        //listelerin uzunluğu randomdan küçükse
        let locationData =
          distList[Math.floor(Math.random() * distList.length)];
        let dist = locationData.distance;
        let startStreet = locationData.startStreet;
        let endStreet = locationData.endStreet;
        
        let price = calculatePrice(dist, priceMultiplier, basePayment).toFixed(0); // toFixed(2) virgülden sonra 2 basamak

        let index = getRandomInt(0, list.length);
        generateJoblist(
          list[index].model.model,
          list[index].model.title,
          list[index].type,
          dist,
          price,
          startStreet,
          endStreet,
          true
        );
      }
    } else {
      if ($(".emp-box").length < random) {
        //listelerin uzunluğu randomdan küçükse
        let locationData =
          distList[Math.floor(Math.random() * distList.length)];
        let dist = locationData.distance;
        let startStreet = locationData.startStreet;
        let endStreet = locationData.endStreet;

        let price = calculatePrice(dist, priceMultiplier, basePayment).toFixed(0); // toFixed(2) virgülden sonra 2 basamak

        let index = getRandomInt(0, list.length);
        generateJoblist(
          list[index].model.model,
          list[index].model.title,
          list[index].type,
          dist,
          price,
          startStreet,
          endStreet,
          false
        );
      }
    }
  }
}

//calculate job price
function calculatePrice(distance, distanceMultiplier, basePayment) {
  let price = distance * distanceMultiplier + basePayment;
  return price;
}

//make employee list
function generateEmployee(name, surname, levelMultiplier, companyLevel) {
  for (const i in name) {
    employeeNames[i] = name[i];
    employeSurnames[i] = surname[i];
  }
  employeelevelMultiplier = levelMultiplier;
  let i = 0;
  let randomindex = getRandomInt(3, 9);
  while (i < randomindex) {
    const randomName =
      employeeNames[Math.floor(Math.random() * employeeNames.length)];
    const randomSurname =
      employeSurnames[Math.floor(Math.random() * employeSurnames.length)];
    let randomLevel = getRandomInt(1, 6);
    let minincome = randomLevel * employeelevelMultiplier;
    let maxincome = minincome * 2;
    let employeePrice;
    let empID = getRandomInt(1, 999999);
    employeePrice = getRandomInt(minincome, maxincome);
    if(companyLevel < 6 && randomLevel >= 4 ){
      continue;
    }

    generateEmployeeList(
      randomName,
      randomSurname,
      randomLevel,
      minincome,
      maxincome,
      employeePrice,
      empID
    );
    i++;
  }
}


 $(document).on("click", "#workers", () => {
    myWorkers.empty();  
    ShowMyWorkers(showWorkerList); 
});
//show  employee list
function ShowMyWorkers(list) {
  for (const i in list) {
    let html
    if(list[i] == null && list[i] == undefined){
      continue;
    }else{

    if(list[i].status == "passive"){
      html = `
      <div class="jobs-box" data-name=${list[i].name} data-surname=${list[i].surname} data-level=${list[i].level} data-status=${list[i].status} data-minincome=${list[i].minincome} data-maxincome=${list[i].maxincome}  data-employeeid=${list[i].id}>
                                <div class="jobs-boxs-player">
                                    <div class="jobs-player">
                                        <img src="assets/trucker-garage-image.png" alt="">
                                        <div class="jobs-player-buttons">
                                            <button class="player-button -stop-job">
                                                <p>START</p>
                                            </button>
                                            <button class="player-button -kickjob-job">
                                                <p>KICK JOB</p>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="jobs-contain">
                                    <div class="jobs-header">
                                        <h1 class="username">${list[i].name}</h1>
                                        <p class="surname">${list[i].surname}</p>
                                        <div class="level-progress">
                                            <p>Driver Level: ${list[i].level}</p>
                                        
                                        </div>
                                    </div>

                                    <div class="jobs-content">
                                        <div class="jobs-value">
                                            <h1>Worker Infos</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>ID</h2>
                                                    <p>${list[i].id}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Status</h2>
                                                    <p>${list[i].status.toUpperCase()}</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="jobs-value">
                                            <h1>Avarage Return</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>Minimum Income</h2>
                                                    <p>${list[i].minincome}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Maximum Income</h2>
                                                    <p>${list[i].maxincome}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
      `;
    }else{
       html = `
       <div class="jobs-box" data-name=${list[i].name} data-surname=${list[i].surname} data-level=${list[i].level} data-status=${list[i].status} data-minincome=${list[i].minincome} data-maxincome=${list[i].maxincome}  data-employeeid=${list[i].id}>
                                <div class="jobs-boxs-player">
                                    <div class="jobs-player">
                                        <img src="assets/trucker-garage-image.png" alt="">
                                        <div class="jobs-player-buttons">
                                            <button class="player-button -stop-job">
                                                <p>STOP</p>
                                            </button>
                                            <button class="player-button -kickjob-job">
                                                <p>KICK JOB</p>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="jobs-contain">
                                    <div class="jobs-header">
                                        <h1 class="username">${list[i].name}</h1>
                                        <p class="surname">${list[i].surname}</p>
                                        <div class="level-progress">
                                            <p>Driver Level: ${list[i].level}</p>
                                        
                                        </div>
                                    </div>

                                    <div class="jobs-content">
                                        <div class="jobs-value">
                                            <h1>Worker Infos</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>ID</h2>
                                                    <p>${list[i].id}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Status</h2>
                                                    <p>${list[i].status.toUpperCase()}</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="jobs-value">
                                            <h1>Avarage Return</h1>
                                            <div class="value-contain">
                                                <div class="value-boxs">
                                                    <h2>Minimum Income</h2>
                                                    <p>${list[i].minincome}</p>
                                                </div>
                                                <div class="value-boxs">
                                                    <h2>Maximum Income</h2>
                                                    <p>${list[i].maxincome}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
      `;
    }
  } 

  myWorkers.append(html);
}
}


//switch status
$(document).on("click",".-stop-job",function switchStatusFunction() {

  let worker =  $(this).parent().parent().parent().parent()
for (const i in showWorkerList) {
  if(showWorkerList[i].id == worker.data("employeeid")){
  if (showWorkerList[i].status == "active") {
      showWorkerList[i].status = "passive";
      myWorkers.empty();
      ShowMyWorkers(showWorkerList)
    } else {
      showWorkerList[i].status = "active";
      myWorkers.empty();
      ShowMyWorkers(showWorkerList)
    }
  }
}
  $.post(
    "https://gfx-truckerjob/switchStatus",
    JSON.stringify({ data: showWorkerList })
  );
});

// fire employee
$(document).on("click",".-kickjob-job",function fireEmployee() {
  let worker =  $(this).parent().parent().parent().parent()

showWorkerList.filter((item, index) =>{
  if(item !== null && item !== undefined){
    if(item.id == worker.data("employeeid")){
      delete showWorkerList[index];
    }
  }
})
myWorkers.empty();
ShowMyWorkers(showWorkerList)

$.post(
    "https://gfx-truckerjob/fireEmployee",
    JSON.stringify({ data: showWorkerList })
  );
});


//comp section drivers lists
function DriversList(list) {
for (const i in list) {
  if(list[i] !== null && list[i] !== undefined){
    let html = `
    <div class="driver" data-name =${list[i].name} data-surname=${list[i].surname} data-level=${list[i].level} >
        <img src="assets/emoployes-icon.png" alt="">
        <div class="texts">
          <h1>${list[i].name} ${list[i].surname}</h1>
          <p>${list[i].level} Level</p>
        </div>
    </div>
    `;
    $(".drivers").append(html);
  }
}}

//comp section garage infos
function CompAndGarageInfo(workerCount, garageCapacity, garageLevel, compLvl, lvlupright, exp, name, upgradeCost, jobsDone ) { //,upgradeCost
  if(workerCount == undefined && workerCount == null) workerCount = 0;

let garageHtml = `
<div class="garage"  data-workerCount=${workerCount} data-garageCapacity=${garageCapacity} data-garageLevel=${garageLevel} data-lvlupright=${lvlupright} data-upgrade=${upgradeCost}>
    <div class="garage-info">
      <h1 class="-garage-infos-title">GARAGE INFO</h1>
        <p class="-garage-infos-desc">WORKERS EMPLOYED: ${workerCount} </p>
        <p class="-garage-infos-desc">EMPTY SLOT: ${garageCapacity} </p>
        <p class="-garage-infos-desc">RIGHT TO LEVEL UP: ${lvlupright} </p>
        <p class="-garage-infos-desc">GARAGE UPGRADE COST: $${upgradeCost}</p>
        
        <div class="lvl-contain">
            <div class="lvl">
                <p> ${garageLevel} LEVEL</p>
            </div>
            <button class="upgrade">
                <p>UPGRADE GARAGE </p>
            </button>
        </div>
    </div>
</div>
`;

let compHtml = `
<div class="garage" data-complevel=${compLvl} data-exp=${exp} data-name=${name} data-jobsDone=${jobsDone}>
  <div class="garage-info">
    <h1 class="-garage-infos-title">COMPANY INFO</h1>
      <p class="-garage-infos-desc">COMPANY NAME:  ${name} </p>
      <p class="-garage-infos-desc">COMPANY EXP: ${exp}  </p>
      <p class="-garage-infos-desc">JOBS DONE: ${jobsDone} </p>
      <div style="justify-content: center !important;" class="lvl-contain">
      <div style="height: 100%;" class="lvl">
      <p> ${compLvl} LEVEL</p>
      </div>
    </div>
   </div>
</div>
`;
$(".compInfoTrucks").text(jobsDone); // jobs done
garagesContain.empty();
garagesContain.append(garageHtml);
garagesContain.append(compHtml);
}

//upgrade garage
$(document).on("click",".upgrade", function () {
  $.post("https://gfx-truckerjob/refresh",
  JSON.stringify({}),
  function(data){
    $.post("https://gfx-truckerjob/upgradeGarage", JSON.stringify({}))
    
    showWorkerList = JSON.parse(data.company_employee)
    CompAndGarageInfo(showWorkerList.length, data.company_garage_capacity, data.company_garage, data.company_level, data.garage_Upgrade_right, data.comp_exp, data.company_name, upgradeGarageCost, data.company_jobs_done );
    
    $(".drivers").empty();
    DriversList(showWorkerList);
  });
});
  

//open/close display
function Display(bilgi) {
  var body = document.querySelector("body");
  if (bilgi == true) {
    body.style.display = "flex";
  } else {
    body.style.display = "none";
  }
}


//sayfalar arası geçiş
  $(document).on("click",".pageBtn",  function () {
    LoadPages($(this).attr("id"));

    $.post("https://gfx-truckerjob/refresh",
    JSON.stringify({}),
    function(data){
      showWorkerList = JSON.parse(data.company_employee)
      CompAndGarageInfo(showWorkerList.length, data.company_garage_capacity, data.company_garage, data.company_level, data.garage_Upgrade_right, data.comp_exp, data.company_name, upgradeGarageCost, data.company_jobs_done );
     
     
      myWorkers.empty();
      ShowMyWorkers(showWorkerList);
      $(".drivers").empty();
      DriversList(showWorkerList);

  });
});


function LoadPages(page) {
  switch (page) {
    case "home":
      $(".compSection").css("display", "block");
      $(".content-jobs").css("display", "none");
      $(".content-employess").css("display", "none");
      break;
    case "jobs":
      $(".compSection").css("display", "none");
      $(".content-jobs").css("display", "none");
      $(".content-employess").css("display", "flex");
      break;
    case "workers":
      $(".compSection").css("display", "none");
      $(".content-jobs").css("display", "flex");
      $(".content-employess").css("display", "none");
      break;
    case "trucks":
      $(".compSection").css("display", "none");
      $(".content-jobs").css("display", "none");
      $(".content-employess").css("display", "none");
      break;
  }
}

//exit ui
$(document).on("keydown", function (event) {
  if (event.keyCode == 27) {
    $.post(
      "https://gfx-truckerjob/exit",
      JSON.stringify({ bool: false }.bool),
      Display(false)
    );
    $(".garages-comp-contain").empty();
    $(".drivers").empty();
  }
});

//submit selected trailer
$(document).on("click", ".takejob", function () {
  const span = $(this).parent().parent().parent();
  const model = span.data("model");
  const type = span.data("type");
  const distance = span.data("distance");
  const price = span.data("price");
  $.post(
    "https://gfx-truckerjob/submit",
    JSON.stringify({
      model: model,
      type: type,
      distance: distance,
      price: price,
    })
  );
  Display(false);
  $.post("https://gfx-truckerjob/exit", JSON.stringify({ bool: false }.bool));
  $(".list1").empty();
  $(".list2").empty();
});

//submit selected employee
$(document).on("click", ".-hire-job", function () {
  const span = $(this).parent().parent().parent().parent();
  const name = span.data("name");
  const surname = span.data("surname");
  const level = span.data("level");
  const minincome = span.data("minincome");
  const maxincome = span.data("maxincome");
  const employeePrice = span.data("employeeprice");
  const employeeIDD = span.data("employeeid");
  $.post(
    "https://gfx-truckerjob/employeeHire",
    JSON.stringify({
      name: name,
      surname: surname,
      level: level,
      minincome: minincome,
      maxincome: maxincome,
      employeePrice: employeePrice,
      employeeID: employeeIDD,
    }),function(data){
      showWorkerList.push({
        name: name,
        surname: surname,
        level: level,
        minincome: minincome,
        maxincome: maxincome,
        id: employeeIDD,
        status: "active",})});
      myWorkers.empty();
      ShowMyWorkers(showWorkerList);
      span.remove();
});




//generate random number min max
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

//deposit money
$(document).on("click", "#depositMoney", (e) => {
  const moneyInput = Number($("#moneyInput").val());
  if (isNaN(moneyInput)) return;
  e.preventDefault();
  if (moneyInput <= 0) return;
  let money = moneyInput;
  $.post(
    "https://gfx-truckerjob/depositMoney",
    JSON.stringify({ money: money }),
    function (data) {
      $("#compInfoMoney").text(`$ ${data}`);
    }
  );
  $("#moneyInput").val("");
});

//withdraw money
$(document).on("click", "#withdrawMoney", (e) => {
  const moneyInput = Number($("#moneyInput").val());
  if (isNaN(moneyInput)) return;
  e.preventDefault();
  if (moneyInput <= 0) return;
  let money = moneyInput;
  $.post(
    "https://gfx-truckerjob/withdrawMoney",
    JSON.stringify({ money: money }),
    function (data) {
      $("#compInfoMoney").text(`$ ${data}`);
    }
  );
  $("#moneyInput").val("");
});

//register menu
function registerMenu() {
  $(".gfxtrucker-createcomp-contain").css("display", "flex");
  $(".createcomp-create-button").click(function () {
    if ($(".compNameInput").val().trim().length <= 0) return;
    $.post(
      "https://gfx-truckerjob/compName",
      JSON.stringify({ name: $(".compNameInput").val().trim() }),
      function (data) {
        $(".sidebar-compname").text(data);
      }
    );
    isregister = true;
    BtnDisable(isregister);
    $(".gfxtrucker-createcomp-contain").css("display", "none");
    $(".gfxtrucker-main-contents").css("display", "flex");
    $(".sidebar-create-button").css("display", "none");
    
    $.post(
      "https://gfx-truckerjob/exit",
      JSON.stringify({ bool: false }.bool),
      Display(false)
    );
  });
}
function BtnDisable(bool) {
  if (bool == false) {
    $(".pageBtn").each(function () {
      if (this.id != "jobs") {
        $(this).css("cursor", "not-allowed");
        $(this).prop("disabled", true);
      }
    });
  } else {
    $(".pageBtn").each(function () {
      $(this).css("cursor", "pointer");
      $(this).prop("disabled", false);
    });
  }
}
