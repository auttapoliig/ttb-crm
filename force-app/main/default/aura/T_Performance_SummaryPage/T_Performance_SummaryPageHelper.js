({
  getUserType: function (component, helper) {
    // component.set("v.loaded", true);
    var summaryPage = component.get("v.summaryPage");
    var summaryPageValue = component.get("v.onedownValue");
    var channelName = component.get("v.channelName");
    // console.log('Channel Name: '+ channelName);
    var action = component.get("c.getSummaryPage");
    action.setParams({
      summaryPage: summaryPage,
      summaryPageValue: summaryPageValue,
      channelName: channelName
    })
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var summaryPage = result.summaryPage;
        var summaryPageValue = result.summaryPageValue;
        var channelValue = result.channelValue;
        var getActual = result.getActual;
        var getActualValue = result.getActualValue;
        var level = result.level;
        var queryField = result.queryField;
        var onedownValue = result.onedownValue;
        component.set("v.queryField", queryField);
        component.set("v.level", level);
          
          
        component.set("v.getActual", getActual);
        component.set("v.getActualValue", getActualValue);
        component.set("v.summaryPage", summaryPage);
        component.set("v.summaryPageValue", summaryPageValue);
        component.set("v.channelName", channelValue);
        component.set("v.onedownSummaryValue", onedownValue);
        var defaultMonth = component.get("v.selectMonth");
        var defalutYear = component.get("v.selectYear");
        component.set("v.defaultMonth", defaultMonth);
        component.set("v.defaultYear", defalutYear);

        // console.log('queryField--> '+component.get("v.queryField"));
        // console.log('level--> '+component.get("v.level"));
        // console.log('getActual--> '+component.get("v.getActual"));
        // console.log('getActualValue--> '+component.get("v.getActualValue"));
        
        // component.set("v.loaded", true);
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
          helper.getTarget(component).then((result) => {
          //   console.log("debug summaryTeamData length", STaP.length);
          //   component.set("v.summaryTeamData", STaP);
    
          component.set("v.targetMapData", result);
         // ==================SEND DATA TO SECTION C==================
            var sectionC = component.find("sectionC");
            sectionC.isNextButtonHandle(component, helper);
            var KPI = sectionC.validateData(component, event, helper);
            component.set("v.sectionCData",KPI)
         // ==================SEND DATA TO SECTION B==================
            var sectionB = component.find("sectionB");
            sectionB.validateData(component, helper);
    
          });
        });
      } else if (state === "ERROR") {
        component.set("v.loading", false);

      } else {
        component.set("v.loading", false);
      }
    });
    $A.enqueueAction(action);
  },

  getSummaryLabel: function (component, helper) {
    
    var summaryPage = component.get("v.summaryPage");
    var summaryPageValue =component.get("v.onedownValue")
    var action = component.get("c.getSummaryLabel");
    action.setParams({
      summaryPage: summaryPage,
      summaryPageValue: summaryPageValue
    })
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.summaryLabel", result);
        // console.log('Summary Label: ' + result)
        helper.setFocusedTabLabel(component);
      } else if (state === "ERROR") {
        console.log("STATE ERROR");
        console.log("error: ", response.error);
        component.set("v.loading", false);
        helper.setFocusedTabLabel(component);
      } else {
        // console.log(
        //   "Unknown problem, state: " +
        //     state +
        //     ", error: " +
        //     JSON.stringify(response.error)
        // );
        component.set("v.loading", false);

      }
    });
    $A.enqueueAction(action);
  },

  getTarget: function (component, helper) {
    return new Promise(function (resolve, reject) {
    var getActual = component.get("v.getActual");
    var getActualValue =component.get("v.getActualValue")
    var selectedYear = component.get("v.selectYear");
    var selectedMonth = component.get("v.selectMonth");
    var action = component.get("c.getTarget");
    
    action.setParams({
      summaryPage: getActual,
      summaryPageValue: getActualValue,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth
    })
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // console.log(result);
        resolve(result);
      } else if (state === "ERROR") {
        console.log("STATE ERROR");
        console.log("error: ", response.error);
        component.set("v.loading", false);
        reject('test');
      } else {
        console.log('State error ',response.error)
        // console.log(
        //   "Unknown problem, state: " +
        //     state +
        //     ", error: " +
        //     JSON.stringify(response.error)
        // ); 
        component.set("v.loading", false);
        reject('test');
      }
    });
        
    //action.setBackground(true);
    $A.enqueueAction(action);
    
    });
  },

  setFocusedTabLabel: function (component) {
    // console.log('Summary Page: '+ component.get('v.pageLabel'));
    var pageLabel = component.get("v.summaryLabel");
    if(pageLabel == undefined){
      pageLabel = ''
    }else{
      pageLabel = "(" + pageLabel + ")";
    }
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .getTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.setTabLabel({
          tabId: focusedTabId,
          label: "Summary " + pageLabel
          //  +'('+ branchCode + ')'
        });
        workspaceAPI.setTabIcon({
          tabId: focusedTabId,
          icon: "custom:custom48",
          iconAlt: "Approval"
        });
      })
      .catch(function (error) {
        // console.log(error);
      });
  },

  getProductSummary: function (component, helper, lastRecord, recordsStack) {
    // console.log("Start getProductSummary");
    // console.log(component.get("v.summaryPage"));
    // console.log(component.get("v.summaryPageValue"));
    var selectedYear = component.get("v.selectYear");
    var selectedMonth = component.get("v.selectMonth");
    var summaryPage = component.get("v.summaryPage");
    var summaryPageValue = component.get("v.summaryPageValue");
    var level = component.get("v.level");
    var queryField = component.get("v.queryField");
    return new Promise(function (resolve, reject) {
      if (recordsStack == null) {
        recordsStack = [];
      }
      var action = component.get("c.getTargetProductByTeam"); // get function at apex

      action.setParams({
        summaryPage: summaryPage,
        summaryPageValue: summaryPageValue,
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        lastRecord: lastRecord,
        level: level,
        queryField: queryField
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        // component.set('v.loading',false);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          // console.log('result'+JSON.stringify(result))
          if (result.targetProdList.resultRecords.length > 0 && recordsStack != null) {
            recordsStack = recordsStack.concat(result.targetProdList.resultRecords);
          }
          if (!result.targetProdList.isEndRecord) {
            result.targetProdList.resultRecords = []; //reset result
            resolve(
              helper.getProductSummary(
                component,
                helper,
                result.targetProdList.lastRecordId,
                recordsStack
              )
            );
          } else {
          resolve(result);          
          }
        } else {
          var errors = response.getError();
          var message = "Unknown error"; // Default error message
          // Retrieve the error message sent by the server
          if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
          }
          // helper.showToastError(
          //   message
          // );
          // Display the message
          var sectionC = component.find("sectionC");
          sectionC.stopLoaded(component);
          var sectionB = component.find("sectionB");
          sectionB.stopLoaded(component);
          reject(message);
          /* reject(message); */
        }
      });

      $A.enqueueAction(action);
    });
  },

  // getSummaryTeam: function (component, helper, lastRecord, recordsStack) {
  //   // console.log("Start getSummaryTeam");

  //   // console.log(component.get("v.summaryPage"));
  //   // console.log(component.get("v.summaryPageValue"));
    
  //   var selectedYear = component.get("v.selectYear");
  //   var selectedMonth = component.get("v.selectMonth");
  //   var summaryPage = component.get("v.summaryPage");
  //   var summaryPageValue = component.get("v.summaryPageValue");
  //   var prodList = component.get("v.prodList");
  //   return new Promise(function (reslove, reject) {
  //     if (recordsStack == null) {
  //       recordsStack = [];
  //     }
  //     var action = component.get("c.getSummaryTeamandProduct"); // get function at apex

  //     action.setParams({
  //       prodList : prodList,
  //       summaryPage: summaryPage,
  //       summaryPageValue: summaryPageValue,
  //       selectedYear: selectedYear,
  //       selectedMonth: selectedMonth,
  //       lastRecord: lastRecord
  //     });
  //     action.setCallback(this, function (response) {
  //       var state = response.getState();
  //       // component.set('v.loading',false);
  //       if (state === "SUCCESS") {
  //         var result = response.getReturnValue();
  //         if (result.resultRecords.length > 0 && recordsStack != null) {
  //           recordsStack = recordsStack.concat(result.resultRecords);
  //         }
  //         if (!result.isEndRecord) {
  //           result.resultRecords = []; //reset result
  //           reslove(
  //             helper.getSummaryTeam(
  //               component,
  //               helper,
  //               result.lastRecordId,
  //               recordsStack
  //             )
  //           );
  //         } else {
  //           reslove(recordsStack);
  //         }
  //       } else {
  //         var errors = response.getError();
  //         var message = "Unknown error"; // Default error message
  //         // Retrieve the error message sent by the server
  //         if (errors && Array.isArray(errors) && errors.length > 0) {
  //           message = errors[0].message;
  //         }
  //         // helper.showToastError(
  //         //   "Chunk query performance failed, Message: " + message
  //         // );
  //         // Display the message
  //         reject(message);
  //         /* reject(message); */
  //       }
  //     });

  //     $A.enqueueAction(action);
  //   });
  // },

  getWatermarkHTML: function (component) {
    var action = component.get("c.getWatermarkHTML");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var watermarkHTML = response.getReturnValue();
        // console.log('watermarkHTML: ', watermarkHTML);

        var imgEncode = btoa(
          "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
            "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" +
            watermarkHTML +
            "</text></svg>"
        );
        var bg = 'url("data:image/svg+xml;base64,' + imgEncode + '")';

        // console.log("watermarkHTML: ", bg);
        component.set("v.waterMarkImage", bg);
      } else if (state === "ERROR") {
        // console.log("STATE ERROR");
        // console.log("error: ", response.error);
      } else {
        // console.log(
        //   "Unknown problem, state: " +
        //     state +
        //     ", error: " +
        //     JSON.stringify(response.error)
        // );
      }
    });
    $A.enqueueAction(action);
  },

  handleMonthList: function (component, event, helper, selectYear) {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
    var yyyy = today.getFullYear();
    today = mm + "/" + dd + "/" + yyyy;

    var defaultYear = mm == 0 ? (yyyy - 1).toString() : yyyy.toString();

    var month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    var monthList = [];
    // console.log("selectYear" + selectYear);
    // console.log("defaultYear" + defaultYear);
    if (selectYear == defaultYear) {
      try {
        month.forEach((month, index) => {
          var item = {
            label: month,
            value: index > 8 ? (index + 1).toString() : "0" + (index + 1)
          };
          monthList.push(item);
        });
      } catch (e) {
        if (e !== "Break") throw e;
      }
    } else {
      month.forEach((month, index) => {
        var item = {
          label: month,
          value: index > 8 ? (index + 1).toString() : "0" + (index + 1)
        };
        monthList.push(item);
      });
    }
    // console.log(JSON.stringify(monthList));
    // console.log('handleYear:',value);
    // console.log('monthList:',monthList);
    // component.set("v.monthList", monthList);
    component.set("v.selectYear", selectYear);
    // if (selectYear != defaultYear) {
    //   component.set("v.selectMonth", "01");
    // }else {
    //   component.set("v.selectMonth", "01");
    // }

    /* component.set('v.isShow',false); */
  },

  prepareData: function (component, event, helper) {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
    var yyyy = today.getFullYear();
    today = mm + "/" + dd + "/" + yyyy;

    var defaultMonth = mm.toString().padStart(2, "0");
    var defaultYear = yyyy.toString();
    var odMonth = component.get("v.selectMonth");
    var OdYaer = component.get("v.selectYear");

    // console.log('Month from one down : '+ odMonth);
    // console.log('OdYaer from one down : '+ OdYaer);
    if(odMonth == null && OdYaer == null){
      component.set("v.selectMonth", defaultMonth);
      component.set("v.selectYear", defaultYear);
      component.set("v.defaultMonth", defaultMonth);
      component.set("v.defaultYear", defaultYear);
    }


    var year = [(yyyy - 1).toString(), yyyy.toString()];
    var yearList = [];
    year.forEach((year, index) => {
      var item = {
        label: year,
        value: year
      };
      yearList.push(item);
    });
    // console.log("yearList:", yearList);
    component.set("v.yearList", yearList);

    var month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    var monthList = [];

    try {
      month.forEach((month, index) => {
        var item = {
          label: month,
          value: index > 8 ? (index + 1).toString() : "0" + (index + 1)
        };
        monthList.push(item);
      });
    } catch (e) {
      if (e !== "Break") throw e;
    }

    // console.log('monthList:',monthList);
    component.set("v.monthList", monthList);
    // component.set("v.loaded", false);
  },

  showToastError: function (msg) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "error",
      title: "Error",
      message: msg
    });
    toastEvent.fire();
  }
});