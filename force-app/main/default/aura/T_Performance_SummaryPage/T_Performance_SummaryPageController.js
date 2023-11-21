({
  onInit: function (component, event, helper) {
    // console.log(component.get("v.summaryPage"));
    // console.log(component.get("v.onedownValue"));
    helper.getSummaryLabel(component, helper);
    helper.getWatermarkHTML(component);
    helper.prepareData(component);
    helper.getUserType(component, helper);
  },
  print: function (){
    window.print();
  },

  showHandle: function (component, event, helper) {
    var sectionC = component.find("sectionC");
    sectionC.handleLoaded(component);
    var sectionB = component.find("sectionB");
    sectionB.handleLoaded(component);
    var defaultMonth = component.get("v.selectMonth");
    var defalutYear = component.get("v.selectYear");
    component.set("v.defaultMonth", defaultMonth);
    component.set("v.defaultYear", defalutYear);
      
    helper.getTarget(component, helper).then((result) => {
     	//var sectionC = component.find("sectionC");
        //var KPI = sectionC.testValidateData(component, event, helper);
        
        var sectionB = component.find("sectionB");
        sectionB.testValidateData(component, helper);
        
        
    })
     
    helper.getProductSummary(component, helper, null, null).then((SbT) => {
      SbT.targetProdList.resultRecords.sort(function(a, b) {
        if (a.Rank__c === b.Rank__c) {
          return b.Month__c.localeCompare(a.Month__c);
        } else {
          return a.Rank__c - b.Rank__c;
        }
      });
      // console.log("debug targetProductData",  SbT.targetProdList.resultRecords);
      component.set("v.targetProductData",  SbT.targetProdList.resultRecords);
      component.set("v.isData", SbT.isData);
      helper.getTarget(component, helper).then((result) => {
      // component.set("v.prodList", SbT.prodList);
      // helper.getSummaryTeam(component, helper, null, null).then((STaP) => {
      //   console.log("debug summaryTeamData length", STaP.length);
      //   component.set("v.summaryTeamData", STaP);
      component.set("v.targetMapData", result);
     // ==================SEND DATA TO SECTION C==================
        var sectionC = component.find("sectionC");
        var KPI = sectionC.validateData(component, event, helper);
        component.set("v.sectionCData",KPI)
     // ==================SEND DATA TO SECTION B==================
        //var sectionB = component.find("sectionB");
        sectionB.validateData(component, helper);

    })
    });
    
  },

  handleYear: function (component, event, helper) {
    var value = event.getSource().get("v.value");
    // console.log("handleYear:", value);
    helper.handleMonthList(component, event, helper, value);

    $A.util.removeClass(component.find("year"), "slds-has-error"); // remove red border
    $A.util.addClass(component.find("year"), "hide-error-message");
  },

  handleMonth: function (component, event, helper) {
    var value = event.getSource().get("v.value");
    // console.log("handleMonth:", value);
    component.set("v.selectMonth", value);

    /*    component.set('v.isShow',false); */
    $A.util.removeClass(component.find("month"), "slds-has-error"); // remove red border
    $A.util.addClass(component.find("month"), "hide-error-message");
  },

  getTeamKPI: function (component, helper) {
    return new Promise(function (resolve, reject) {
      helper
        .chunkQuery(component, helper, pointChunkQueryWrapper, [])
        .then((resultRecords) => {
          resolve(resultRecords);
        })
        .catch((error) => {
          reject(error);
        });
    });
  }
});