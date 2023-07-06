({
  scriptsLoaded: function (component, event, helper) {
    component.set("v.scriptLoaded", true);
    
  },

  validateData: function (component, event, helper) {
    component.set("v.loaded", true);
    // console.log("Validate Section B");
    // console.log(component.get("v.KPI"));
    
    var KPI = component.get("v.KPI");
    var sumActual = 0;
    var sumTarget = 0;
    // console.log(typeof KPI[0].productList[0].POINTs.actualYTD)
    for (var i = 0; i < KPI.length; i++) {
      for (var j = 0; j < KPI[i].productList.length; j++) {
      	if(!isNaN(KPI[i].productList[j].POINTs.tgYTDValue) && !KPI[i].productList[j].POINTs.tgYTDValue == ""){
            sumTarget = parseFloat(sumTarget) + parseFloat(KPI[i].productList[j].POINTs.tgYTDValue);
            // console.log('tgYTDValue :'+KPI[i].productList[j].POINTs.tgYTDValue);
            // console.log('SumTarget :'+sumTarget);
          }
        if (!isNaN(KPI[i].productList[j].POINTs.actualYTD) && !KPI[i].productList[j].POINTs.actualYTD =="") {
          	sumActual = parseFloat(sumActual) + parseFloat(KPI[i].productList[j].POINTs.actualYTD); 
        } 
      }
    }
    component.set("v.sumActual", sumActual);
    component.set("v.sumTarget", sumTarget);
    sumActual = helper.nFormatter(sumActual, 2)
    sumTarget = helper.nFormatter(sumTarget, 2)
    component.set("v.Actual_Point_YTD", sumActual);
    component.set("v.Target_Point_YTD", sumTarget);
    // console.log('SumTarget :'+sumTarget);
    //component.set('v.loaded',false);
    helper.getSummarybyType(component, helper)
  },

  handleLoaded : function(component, event, helper){
    component.set('v.loaded', true);
  },
  stopLoaded : function(component, event, helper){
    component.set('v.loaded', false);
  },
    
   testValidateData: function (component, event, helper) {
    component.set("v.loaded", true);
    //helper.getSummarybyType(component, helper)
    var onedownValue = component.get("v.onedownValue");
    var summaryPage = component.get("v.summaryGroupType");
    var action = component.get("c.getSummaryPagebyType");
    // console.log("Start Get Summary Page By TYPE");
    action.setBackground(true);
    action.setParams({
      onedownValue: onedownValue,
      summaryPage: summaryPage
    });
    	// console.log("Start Get Summary Page By TYPE");
      action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            // console.log("Result: " + JSON.stringify(result));
    
            component.set("v.summaryPage", result.summaryPagebyType);
            component.set("v.summaryPageValue", result.summaryPagebyTypeValue);
            //helper.getSummaryTypeValue(component, helper);
            //
            var selectedYear = component.get("v.selectYear");
            var selectedMonth = component.get("v.selectMonth");
            var summaryPage = component.get("v.summaryPage");
            var summaryPageValue = component.get("v.summaryPageValue");
            var channelName = component.get("v.channelName");
            var action = component.get("c.testtest"); // get function at apex
       
              action.setCallback(this, function (response) {});
              $A.enqueueAction(action);
          } else if (state === "ERROR") {
            console.log("STATE ERROR");
            // console.log("error: ", response.error);
          } else {
            // console.log(
            //   "Unknown problem, state: " +
            //     state +
            //     ", error: " +
            //     JSON.stringify(response.error)
            // );
          }
      })
      $A.enqueueAction(action);
  },
});