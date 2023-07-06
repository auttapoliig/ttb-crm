({
  onInit: function (component, helper) {
    const date = new Date();
    var curyear = date.getFullYear();
    curyear = curyear.toString().slice(2, 4);
    const subColumnLabel = [
      "TG_Y" + curyear,
      "TG_YTD",
      "ACT_YTD",
      "%YTD",
      "TG_MTD",
      "ACT_MTD",
      "%MTD",
      "runrate_MTD",
      "RV",
      "TG_YTD",
      "ACT_YTD",
      "%YTD",
      "%runrate_YTD"
    ];

    component.set("v.subColumnLabel", subColumnLabel);
    // component.set('v.teamList',teamList);
  },

  isNextButtonHandle: function (component) {
    var channelName = component.get("v.channelName");
    // console.log('channelName--> '+channelName)
    var onedownValue = component.get("v.onedownValue");
    var summaryPage = component.get("v.summaryGroupType");
    var selectedYear = component.get("v.selectedYear");
    var selectedMonth = component.get("v.selectedMonth");
    if(onedownValue == null || onedownValue == undefined){
      onedownValue = component.get("v.summaryGroupValue");
    }
    var action = component.get("c.isNextButton");
    action.setParams({
      channelName: channelName,
      zoneValue: onedownValue,
      currentLevel: summaryPage,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.isNext", result);
        // console.log('Is next button :' +  result);
      } else if (state === "ERROR") {
        console.log("STATE ERROR");
      } else {
        console.log(
          "Unknown problem, state: " +
            state +
            ", error: " +
            JSON.stringify(response.error)
        );
      }
    });
    $A.enqueueAction(action);
  },

  validateData: function (component, event, helper) {
    component.set("v.loaded", true);

    var selectedYear = component.get("v.selectedYear");
    var curyear = selectedYear.toString().slice(2, 4);
    const subColumnLabel = [
      "TG_Y" + curyear,
      "TG_YTD",
      "ACT_YTD",
      "%YTD",
      "TG_MTD",
      "ACT_MTD",
      "%MTD",
      "runrate_MTD",
      "RV",
      "TG_YTD",
      "ACT_YTD",
      "%YTD",
      "%runrate_YTD"
    ];

    component.set("v.subColumnLabel", subColumnLabel);
    // const group = helper.groupBy(KPI, 'Indicator_Level1__c')
    // const JSONGroup = JSON.parse(group);
    // const STP = component.get("v.summaryTeamData");
    // console.log(STP);
    // var mapProductGroupWithCode = new Map();
    // var mapTotalAmountByMonth = new Map();
    // var mapCodeWithTotalAmount = new Map();
    // var mapProductwithTotalAmount = new Map();
    // var mapProductwithCapMax = new Map();
    const date = new Date();
    var day = date.getDate() - 2 ;
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    var curDoM = moment().daysInMonth();
    var curDay = date.getDate();
    const groupArrayKPI = () => {
      const KPI = component.get("v.targetProductData");
      // const KPI1 = component.get("v.targetMapData");
      // console.log(KPI);
      
      var selectedMonth = component.get("v.selectedMonth");
      var selectedYear = component.get("v.selectedYear");
      // console.log('selectedMonth validateData' +selectedMonth)
      // console.log('selectedYear validateData' +selectedYear)

      var map = new Map();
      
      for (let i = 0; i < KPI.length; i++) {
        var actualMonthTD = 0;
        // var actualMonthTDwithRV = 0;
        // var actualMonthTDwithRVrunrate = 0;
        var actualYearTD = 0;
        // var actualYTDCapmax = 0;
        var TotaltgYTDValue;
        var percentMTD = 0;
        var TG = 0;
        var BPE = "";
        // var runrate = "";
        // var PointPercent = "";
        var actualForRunrate = 0;
        var UnitPercent = "";
        var volume = 1;
        var Capmax = "";
        if (month == parseInt(KPI[i].Month__c) && year == parseInt(KPI[i].Year__c)){
          // console.log('Before prorate: '+ parseFloat(KPI[i].Target_Unit_Month__c))
          TotaltgYTDValue = helper.calDecimal(helper, "multiply", (day) ,parseFloat(KPI[i].Target_Unit_Month__c/curDoM));
        // TotaltgYTDValue =  helper.calDecimal(helper, "round", parseFloat(TotaltgYTDValue), null);
          // console.log('After prorate: '+ parseFloat(KPI[i].Target_Unit_Month__c/curDoM))
        } else {
          TotaltgYTDValue =  parseFloat(KPI[i].Target_Unit_Month__c);
          // console.log('1st TG_YTD '+ TotaltgYTDValue)
        }
        var targetMTDValue = 0;
        if (parseInt(KPI[i].Month__c) == selectedMonth && parseInt(KPI[i].Year__c) == selectedYear) {
          if(KPI[i].hasOwnProperty('Volumn__c')){
            volume = parseFloat(KPI[i].Volumn__c)
          }else { 
            volume = 1;
          } 
          if (selectedMonth == month && selectedYear == year) {
            targetMTDValue =  helper.calDecimal(helper, "multiply", (day), parseFloat(KPI[i].Target_Unit_Month__c)/curDoM);
            targetMTDValue = parseFloat(targetMTDValue);
          } else {
            targetMTDValue = parseFloat(KPI[i].Target_Unit_Month__c);
            
          }
         
          
          TG = KPI[i].Target_Unit_Year__c;
          
          actualMonthTD = parseFloat(KPI[i].Actual_Amount__c) / volume;
          if(KPI[i].hasOwnProperty('Branch_Point_Engine__c')){
            BPE = parseFloat(KPI[i].Branch_Point_Engine__c)
          }else { 
            BPE = "";
          }
          if(KPI[i].hasOwnProperty('Cap_Max_Pct__c')){
            Capmax = parseFloat(KPI[i].Cap_Max_Pct__c);
          }else {
            Capmax = "";
          }
            // console.log("Branch Point Engine : " + BPE)
        }
     	 if(parseInt(KPI[i].Month__c) != selectedMonth && parseInt(KPI[i].Year__c) == selectedYear){
            actualForRunrate = helper.calDecimal(helper, "round", (parseFloat(KPI[i].Actual_Amount__c) / volume) , null);
        }
        var multiplyDayofMonth = 1;
        if (selectedMonth == month && selectedYear == year && day > 0) {
          multiplyDayofMonth = curDoM / (curDay);
        }
        
        // actualYearTD = helper.calDecimal(helper, "round", ((parseFloat(KPI[i].Actual_Amount__c)) / volume) , null);
      	actualYearTD = ((parseFloat(KPI[i].Actual_Amount__c)) / volume)
      	// console.log(actualYearTD);
        //if(actualYearTD == null){
        //  actualYearTD = 0;      
        //}
        // if(BPE != "" && Capmax != ""){
        //   actualYTDCapmax = (actualYearTD * (BPE ? BPE : 1) > (TotaltgYTDValue * (BPE ? BPE : 1) * Capmax/100)) ? (TotaltgYTDValue * (BPE ? BPE : 1)* (Capmax/100)) : (actualYearTD * (BPE ? BPE : 1));
        // }
        
        // actualMonthTDwithRV = (actualMonthTD ? actualMonthTD : 0) * (BPE ? BPE : 1)

        // actualMonthTDwithRVrunrate = actualMonthTDwithRV * multiplyDayofMonth

        // runrate = ((actualYTDCapmax - (actualMonthTDwithRV ? actualMonthTDwithRV : 0)) + (actualMonthTDwithRVrunrate ? actualMonthTDwithRVrunrate : 0))/(TotaltgYTDValue * (BPE ? BPE : 1));
        // if(TotaltgYTDValue == 0 || TotaltgYTDValue == "" || BPE == "" || runrate < 0){
        //   runrate = "";
        // }
        
        // PointPercent = actualYTDCapmax / (TotaltgYTDValue * (BPE ? BPE : 1));
        // if(TotaltgYTDValue == 0 || TotaltgYTDValue == "" || BPE == ""){
        //   PointPercent = "";
        // }
        // 
		UnitPercent =  helper.calDecimal(helper, "round", parseFloat(actualYearTD), null) /  helper.calDecimal(helper, "round", parseFloat(TotaltgYTDValue), null);
        //UnitPercent = parseFloat(actualYearTD).toFixed(2) / parseFloat(TotaltgYTDValue).toFixed(2);
        if(TotaltgYTDValue == 0 || TotaltgYTDValue == ""){
          UnitPercent = "";
        }

        percentMTD = (actualMonthTD ? helper.calDecimal(helper, "round", parseFloat(actualMonthTD), null) : 0) / helper.calDecimal(helper, "round", parseFloat(targetMTDValue), null)
        if(targetMTDValue == 0 || targetMTDValue == ""){
          percentMTD = "";
        }

        if (!map.has(KPI[i].Indicator_Level1__c)) {
          map.set(KPI[i].Indicator_Level1__c, {
            quadrant: KPI[i].Indicator_Level1__c,
            productList: [
              {
                Label: KPI[i].Product_Group_Name__c,
                UNIT: {
                  volume: volume,
                  tgCurrYearValue: TG,
                  tgYTDValue: TotaltgYTDValue,
                  actualYTD: actualYearTD,
                  percent: UnitPercent,
                  percentColor: "KPI0",
                  tgMTDValue: targetMTDValue,
                  actualMTD: actualMonthTD ? actualMonthTD : 0,
                  percentMTD: percentMTD,
                  percentMTDColor: "KPI0",
                  runrate:
                  helper.calDecimal(helper, "multiply", (actualMonthTD ? actualMonthTD : 0), multiplyDayofMonth)
                },
                POINTs: {
                  Capmax : Capmax,
                  RV: BPE,
                  tgYTDValue: "",
                  actualYTD: "",
                  percent: "",
                  percentColor: "KPI0",
                  actualForRunrate: actualForRunrate,
                  percentMTD: "" ,
                  percentMTDColor: "KPI0"
                }
              }
            ]
          });
        } else {
          var checkproduct = false;
          map.get(KPI[i].Indicator_Level1__c).productList.forEach((result) => {
            if (result.Label == KPI[i].Product_Group_Name__c) {
              checkproduct = true;
            }
          });
          if (checkproduct) {
            // console.log(KPI[i].Product_Group_Name__c +' Actual Amont:'+ KPI[i].Actual_Amount__c)
            helper.sumProductvalues(
              component,
              KPI[i],
              map.get(KPI[i].Indicator_Level1__c),helper
            );
            // map.get(KPI[i].Indicator_Level1__c) = newMap;
            // console.log(newMap);
          } else {
            var arr = {
              Label: KPI[i].Product_Group_Name__c,
              UNIT: {
                volume: volume,
                tgCurrYearValue: TG,
                tgYTDValue: TotaltgYTDValue,
                actualYTD: actualYearTD,
                percent: UnitPercent,
                percentColor: "KPI0",
                tgMTDValue: targetMTDValue,
                actualMTD: actualMonthTD ? actualMonthTD : 0,
                percentMTD: percentMTD,
                percentMTDColor: "KPI0",
                runrate:
                helper.calDecimal(helper, "multiply", (actualMonthTD ? actualMonthTD : 0), multiplyDayofMonth)
              },
              POINTs: {
                Capmax : Capmax,
                RV: BPE,
                tgYTDValue: "",
                actualYTD: "",
                percent: "",
                percentColor: "KPI0",
                actualForRunrate: actualForRunrate,
                percentMTD: "" ,
                percentMTDColor: "KPI0"
              }
            };
            map.get(KPI[i].Indicator_Level1__c).productList.push(arr);
          }
        }
      }
      // console.log('Count loop :' + count)
      const res = Array.from(map.values());
      return res;
    };
    
    // console.log(groupArrayKPI());
    const groupKPI = groupArrayKPI();
    // const groupSTP = STP;
    //  const groupSort = helper.groupBy(groupArray(KPI), 'quadant');
    // console.log(groupKPI);

    component.set("v.targetProductObjList", groupKPI);
    var params = event.getParam("arguments");
    helper.cssColorChange(component, helper);
    // var returnGroupKPI = component.get("v.targetProductObjList");
    // console.log(params);
    component.set("v.loaded", false);
    if (params) {
      return groupKPI;
    }
    // component.set("v.summaryTeamObjList", groupSTP);
    // helper.calculatedSummary(component);
  },

  navigateToOneDown: function (component) {
    // console.log(
    //   component.get("v.summaryGroupType") +
    //     " " +
    //     component.get("v.summaryGroupValue")
    // );
    var selectedYear = component.get("v.selectedYear");
    var selectedMonth = component.get("v.selectedMonth");
    var channelName = component.get("v.channelName");
    // console.log("selectYear" + selectedYear);
    // console.log("selectMonth" + selectedMonth);
    var uid = "1";
    var summaryGroupValue = component.get("v.summaryGroupValue");
    if (summaryGroupValue == null || summaryGroupValue == undefined) {
      summaryGroupValue = component.get("v.onedownValue");
    }
    // const test = summaryGroupValue;
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      var focusedTabId = response.tabId;
      workspaceAPI
        .openSubtab({
          parentTabId: focusedTabId,
          pageReference: {
            type: "standard__component",
            attributes: {
              componentName: "c__T_Performance_Onedown"
            },
            state: {
              uid: uid,
              c__summaryGroupType: component.get("v.toOnedown"),
              c__summaryGroupValue: summaryGroupValue,
              c__selectedYear: selectedYear,
              c__selectedMonthInt: selectedMonth,
              c__channelName: channelName

            }
          }
        })
        .then(function (subtabId) {
          workspaceAPI.setTabIcon({
            tabId: subtabId,
            icon: "custom:custom48",
            iconAlt: "Approval"
          });
          workspaceAPI.setTabLabel({
            tabId: subtabId,
            label: "OneDown" + "(" + summaryGroupValue + ")"
          });
        })
        .catch(function (error) {
          // console.log(error);
        });
    });

    // console.log(test);
    // var evt = $A.get("e.force:navigateToComponent");
    // evt.setParams({
    //   componentDef: "c:T_Performance_Onedown",
    //   componentAttributes: {
    //     summaryGroupType: component.get("v.summaryGroupType"),
    //     summaryGroupValue: test
    //   }
    // });
    // evt.fire();
  },

  handleMouseOver: function (component, event, helper) {
    var index = event.target.id;

    if (index) {
      var splitIdx = index.split("_");
      if (splitIdx.length > 0) {
        component.set("v.hoveringId", splitIdx[0]);
      }
    }
  },
  handleMouseOut: function (component, event, helper) {
    component.set("v.hoveringId", null);
  },

  handleLoaded: function (component, event, helper) {
    component.set("v.loaded", true);
  },
  stopLoaded : function(component, event, helper){
    component.set('v.loaded', false);
  },

testValidateData: function (component, event, helper) {
    component.set("v.loaded", true);
  },
});