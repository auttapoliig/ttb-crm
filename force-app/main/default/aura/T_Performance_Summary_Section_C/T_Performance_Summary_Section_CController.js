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
  },

  isNextButtonHandle: function (component) {
    var channelName = component.get("v.channelName");
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
    const date = new Date();
    var day = date.getDate() - 2 ;
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    var curDoM = moment().daysInMonth();
    var curDay = date.getDate();
    const groupArrayKPI = () => {
      const KPI = component.get("v.targetProductData");
      
      var selectedMonth = component.get("v.selectedMonth");
      var selectedYear = component.get("v.selectedYear");

      var map = new Map();
      
      for (let i = 0; i < KPI.length; i++) {
        var actualMonthTD = 0;
        var actualYearTD = 0;
        var TotaltgYTDValue;
        var percentMTD = 0;
        var TG = 0;
        var BPE = "";
        var actualForRunrate = 0;
        var UnitPercent = "";
        var volume = 1;
        var Capmax = "";
        if (month == parseInt(KPI[i].Month__c) && year == parseInt(KPI[i].Year__c)){
          TotaltgYTDValue = helper.calDecimal(helper, "multiply", (day) ,parseFloat(KPI[i].Target_Unit_Month__c/curDoM));
        } else {
          TotaltgYTDValue =  parseFloat(KPI[i].Target_Unit_Month__c);
        }
        var targetMTDValue = 0;
        if (parseInt(KPI[i].Month__c) == selectedMonth && parseInt(KPI[i].Year__c) == selectedYear) {
          if(KPI[i].hasOwnProperty('Volumn__c')){
            volume = parseFloat(KPI[i].Volumn__c)
          }else { 
            volume = 1;
          } 
          if (selectedMonth == month && selectedYear == year) {
            if(day > 0) {
              targetMTDValue =  helper.calDecimal(helper, "multiply", (day), parseFloat(KPI[i].Target_Unit_Month__c)/curDoM);
              targetMTDValue = parseFloat(targetMTDValue);
            } else {
              targetMTDValue = 0;
            }
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
        }
     	 if(parseInt(KPI[i].Month__c) != selectedMonth && parseInt(KPI[i].Year__c) == selectedYear){
            actualForRunrate = helper.calDecimal(helper, "round", (parseFloat(KPI[i].Actual_Amount__c) / volume) , null);
        }
        var multiplyDayofMonth = 1;
        if (selectedMonth == month && selectedYear == year && day > 0) {
          multiplyDayofMonth = curDoM / (curDay);
        }
        
      	actualYearTD = ((parseFloat(KPI[i].Actual_Amount__c)) / volume)

		    UnitPercent =  helper.calDecimal(helper, "round", parseFloat(actualYearTD), null) /  helper.calDecimal(helper, "round", parseFloat(TotaltgYTDValue), null);
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
                ProductCode: KPI[i].Product_Group_Code__c,
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
            if (result.ProductCode == KPI[i].Product_Group_Code__c) {
              checkproduct = true;
            }
          });
          if (checkproduct) {
            helper.sumProductvalues(
              component,
              KPI[i],
              map.get(KPI[i].Indicator_Level1__c),helper
            );
          } else {
            var arr = {
              Label: KPI[i].Product_Group_Name__c,
              ProductCode: KPI[i].Product_Group_Code__c,
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
      const res = Array.from(map.values());
      return res;
    };
    
    const groupKPI = groupArrayKPI();

    component.set("v.targetProductObjList", groupKPI);
    var params = event.getParam("arguments");
    helper.cssColorChange(component, helper);
    component.set("v.loaded", false);
    if (params) {
      return groupKPI;
    }
  },

  navigateToOneDown: function (component) {
    var selectedYear = component.get("v.selectedYear");
    var selectedMonth = component.get("v.selectedMonth");
    var channelName = component.get("v.channelName");
    var uid = "1";
    var summaryGroupValue = component.get("v.summaryGroupValue");
    if (summaryGroupValue == null || summaryGroupValue == undefined) {
      summaryGroupValue = component.get("v.onedownValue");
    }
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