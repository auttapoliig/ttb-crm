({
  drawChart: function (component, event, helper) {
    var rawKPI = component.get("v.kpiValue");
    
    var kpi = Math.floor(rawKPI);    
    var chartObj = component.get("v.chartObj");
    var summaryTeam = component.get("v.summaryTeamData");
    // var chartObj = component.find("chart");
    // if chartobj is not empty, then destory the chart in the view
    // console.log('kpi before:' + rawKPI)
    if (chartObj) {
      chartObj.destroy();
    }
    // console.log("KPI value section B : " + kpi);
    var kpiColor;
    var kpiPercent;
    var hoverText = false;
    if (kpi >= 0 && kpi < 60) {
      kpiColor = "rgb(254, 78, 78)";
    } else if (kpi >= 60 && kpi < 90) {
      kpiColor = "rgb(229, 201, 82)";
    } else if (kpi >= 90 && kpi < 110) {
      kpiColor = "rgb(206, 254, 155)";
    } else if (kpi >= 110 && kpi < 140) {
      kpiColor = "rgb(95, 205, 178)";
    } else if (kpi >= 140) {
      kpiColor = "rgb(55, 159, 255)";
    }
    if (kpi == null || kpi == undefined) {
      kpi = 0;
    }
    if (rawKPI == null || rawKPI == undefined) {
      rawKPI = 0;
    }
    // if(kpi > 0){
      if (kpi > 0 ) {
        hoverText = true
        if (kpi <= 140){
          kpiPercent = 140 - kpi;  
        }else if(kpi > 140){
        // if()
        kpiPercent = 0;
        }
      } else {
        kpiPercent = 1;
      }
    // }

    // console.log( 'KPI : '+ kpi)
    
    
    // if(kpiPercent > 0){
        
    // }
    // console.log("KPI :" + kpi);
    // console.log("KPI percent:" + kpiPercent);
    

    const midText = {
      afterDraw: (chart) => {
        var ctx = chart.ctx;
        var width = chart.width;
        var height = chart.height;
        // console.log("rawKPI value section B : " + rawKPI);

        this.chartFillText(ctx, rawKPI, width, height, helper);
        this.chartFillPercent(ctx, "0.00%", 0.03 * width, 0.9 * height);
        this.chartFillPercent(ctx, "140.00%", 0.83 * width, 0.9 * height);
      }
    };
    // Chart v3 //
    // var option1 = {
    //   type: "doughnut",
    //   data: {
    //     labels: ["%KPI_TOTAL_YTD", ""],
    //     datasets: [
    //       {
    //         data: [kpi, kpiPercent],
    //         backgroundColor: [kpiColor,
    //           'rgb(222, 222, 222)'],
    //         borderColor: "white",
    //         borderWidth: 1
    //       }
    //     ]
    //   },
    //   options: {
    //     maintainAspectRatio: false,
    //     rotation: -90,
    //     cutout: '70%',
    //     circumference: 180,
    //     legend: {
    //       display: false
    //     },
    //     animation: {
    //       animateRotate: true,
    //       animateScale: true
    //     },
    //     responsive: false,
    //     plugins: {
    //       legend: {
    //         display: false
    //       },
    //       tooltip:{
    //         enabled: hoverText
    //       }
    //     }
    //   },
    //   plugins: [midText]
     
    // };
    // Chart v2 //
    var option1 = {
      type: "doughnut",
      data: {
        labels: ["%KPI_TOTAL_YTD", ""],
        datasets: [
          {
            data: [kpi, kpiPercent],
            backgroundColor: [kpiColor],
            borderColor: "White",
            borderWidth: 1
          }
        ]
      },
      options: {
        tooltips:{
          enabled: hoverText
        },
        // events: [hoverText],
        maintainAspectRatio: false,
        rotation: -Math.PI,
        cutoutPercentage: 70,
        circumference: Math.PI,
        legend: {
          display: false
        },
        animation: {
          animateRotate: true,
          animateScale: true
        },
        responsive: false
        // tooltips: {
        //   filter: function (item, data) {
        //     var label = data.labels[item.index];
        //     if (label) return item;
        //   }
        // }
      },
      plugins: [midText]
    };
    // End here //
    // console.log(summaryTeam);
    // var ctx = document.getElementById("chartJSContainer").getContext("2d");
    if(summaryTeam != undefined){
      var el = component.find("chart").getElement();
      var ctx = el.getContext("2d");
      chartObj = new Chart(ctx, option1);
      component.set("v.chartObj", chartObj);
      //store the chart in the attribute
    
      // console.log('is Chart after:' + chartObj)
    }
    

    
  },
  cssClassColor: function (data) {
    var colorClass;
    if (data < 60) {
      colorClass = "KPI1";
    } else if (data >= 60 && data < 90) {
      colorClass = "KPI2";
    } else if (data >= 90 && data < 110) {
      colorClass = "KPI3";
    } else if (data >= 110 && data < 140) {
      colorClass = "KPI4";
    } else if (data >= 140) {
      colorClass = "KPI5";
    }
    return colorClass;
  },

  chartFillText: function (ctx, text, width, height, helper) {
    var font = 20;
    var lineHeight = 15;
	
    text = helper.parseNumber(text);
    var fText = text.toLocaleString(undefined, {maximumFractionDigits: 2}) + "%";

    ctx.textBaseline = "bottom";
    ctx.font = "400 " + font + "px Arial";
    ctx.save();
    var textX = Math.round((width - ctx.measureText(fText).width) / 2),
        textY = height;
    ctx.fillText(fText.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,"), textX, textY);
    ctx.restore();
  },

  chartFillPercent: function (ctx, text, x, y) {
    // var x = 0;
    // var y = 70;
    var font = 9;
    var lineHeight = 15; // this is guess and check as far as I know
    // var rotateDegree = -45;
    ctx.textBaseline = "bottom";
    ctx.font = font + "px Arial";
    ctx.save();
    ctx.translate(x, y);
    // ctx.rotate((rotateDegree/180)*Math.PI);
    // ctx.textAlign = 'center';
    ctx.fillText(text, 0, lineHeight / 2);
    ctx.restore();
  },

  getSummaryTypeValue: function (component, helper) {
    component.set("v.kpiValue", null);
    // console.log(component.get("v.summaryPage"));
    // console.log(component.get("v.summaryPageValue"));
    var selectedYear = component.get("v.selectYear");
    var selectedMonth = component.get("v.selectMonth");
    var summaryPage = component.get("v.summaryPage");
    var summaryPageValue = component.get("v.summaryPageValue");
    var channelName = component.get("v.channelName");
    // console.log('Channel name' + channelName)

    var action = component.get("c.getSummarybyType"); // get function at apex
	action.setBackground(true);
    action.setParams({
      summaryPage: summaryPage,
      summaryPageValue: summaryPageValue,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth,
      channelName: channelName
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      // component.set('v.loading',false);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var calresult = result[0];
        var sumActual = 0;
        // console.log('Sum Actual :'+component.get("v.sumActual"))
        if(component.get("v.sumActual") != null || component.get("v.sumActual") != undefined ){
           var sumActual = component.get("v.sumActual");
        }
        var sumTarget = component.get("v.sumTarget");
        var totalPoint;
        // console.log(result);
        if (result.length > 0) {
          // Cap Max Pending
          // if(sumActual > (calresult.Group1_Cap_Max_Pct__c*sumTarget/100)){
          //   calresult["sumActual"] = (calresult.Group1_Cap_Max_Pct__c*sumTarget/100)
          // }else{
            calresult["sumActual"] = sumActual
          // }
          sumActual = helper.nFormatter(calresult.sumActual, 2)
          component.set("v.Actual_Point_YTD", sumActual);
          totalPoint = calresult.sumActual/sumTarget
          calresult["Group1_cal"] = (totalPoint * (calresult.Group1_weight_pct__c));
          if(isNaN(calresult.Group1_cal) || calresult.Group1_cal == null || calresult.Group1_cal == ""){
            calresult.Group1_cal = 0;
          }
          calresult["Group1_result"] = (calresult.Group1_cal.toFixed(2))/100;
          calresult["Group1_css"] = helper.cssClassColor(
            (calresult.Group1_cal * 100) / (calresult.Group1_weight_pct__c  ? calresult.Group1_weight_pct__c : 100)
          );
          calresult["Group2_result"] =
            calresult.Group2_Value__c.toFixed(2) + "" + calresult.Group2_Unit__c;
          calresult["Group2_css"] = helper.cssClassColor(
            ((calresult.Group2_Value__c - (calresult.Group2_Min__c ? calresult.Group2_Min__c : 0)) * 100) / (calresult.Group2_weight_pct__c ? calresult.Group2_weight_pct__c : 100)
          );
          calresult["Group3_result"] =
             calresult.Group3_Value__c.toFixed(2) + "" + calresult.Group3_Unit__c;
          calresult["Group3_css"] = helper.cssClassColor(
            ((calresult.Group3_Value__c - (calresult.Group3_Min__c ? calresult.Group3_Min__c : 0)) * 100) / (calresult.Group3_weight_pct__c  ? calresult.Group3_weight_pct__c : 100)
          );
          calresult["Group4_result"] =
            calresult.Group4_Value__c.toFixed(2) + "" + calresult.Group4_Unit__c;
            // console.log('Group 4 result' + ((calresult.Group4_Value__c - calresult.Group4_Min__c) * 100) / (calresult.Group4_weight_pct__c  ? calresult.Group4_weight_pct__c : 100))
          calresult["Group4_css"] = helper.cssClassColor(
            ((calresult.Group4_Value__c - (calresult.Group4_Min__c ? calresult.Group4_Min__c : 0)) * 100) / (calresult.Group4_weight_pct__c  ? calresult.Group4_weight_pct__c : 100)
          );
          calresult["Group5_result"] =
            calresult.Group5_Value__c.toFixed(2) + "" + calresult.Group5_Unit__c;
          calresult["Group5_css"] = helper.cssClassColor(
            ((calresult.Group5_Value__c - (calresult.Group5_Min__c ? calresult.Group5_Min__c : 0)) * 100) / (calresult.Group5_weight_pct__c  ? calresult.Group5_weight_pct__c : 100)
          );
          calresult["Group6_result"] =
            calresult.Group6_Value__c.toFixed(2) + "" + calresult.Group6_Unit__c;
          calresult["Group6_css"] = helper.cssClassColor(
            ((calresult.Group6_Value__c - (calresult.Group6_Min__c ? calresult.Group6_Min__c : 0)) * 100) / (calresult.Group6_weight_pct__c  ? calresult.Group6_weight_pct__c : 100)
          );
          calresult["Group7_result"] =
            calresult.Group7_Value__c.toFixed(2) + "" + calresult.Group7_Unit__c;
          calresult["Group7_css"] = helper.cssClassColor(
            ((calresult.Group7_Value__c - (calresult.Group7_Min__c ? calresult.Group7_Min__c : 0)) * 100) / (calresult.Group7_weight_pct__c  ? calresult.Group7_weight_pct__c : 100)
          );
          calresult.Group1_cal = calresult.Group1_cal.toFixed(2);
          //console.log(' calresult.Group1_cal --> '+calresult.Group1_cal)
          //console.log(' calresult.Group1_cal --> '+calresult.Group2_Value__c)
          //console.log(' calresult.Group1_cal --> '+calresult.Group3_Value__c)
          //console.log(' calresult.Group1_cal --> '+calresult.Group4_Value__c)
          calresult["TotalKPIs"] =
          parseFloat((parseFloat(calresult.Group1_cal)*100).toFixed(0)) +
          parseFloat((calresult.Group2_Value__c*100).toFixed(0)) +
          parseFloat((calresult.Group3_Value__c*100).toFixed(0)) +
          parseFloat((calresult.Group4_Value__c*100).toFixed(0));

          component.set("v.kpiValue", ((calresult.TotalKPIs)/100));
        }else{
          // sumActual = helper.nFormatter(sumActual, 2)
          // component.set("v.Actual_Point_YTD", sumActual);
        }
        
        component.set("v.summaryTeamData", calresult);
        component.set("v.loaded", false);
        // console.log(calresult);
        // if(calresult){
          helper.drawChart(component, event, helper);
        // }
      } else if (state === "ERROR") {
        console.log("STATE ERROR");
        console.log("error: ", response.error);
        component.set("v.loaded", false);

      } else {
        component.set("v.loaded", false);

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

  getSummarybyType: function (component, helper) {
    var onedownValue = component.get("v.onedownValue");
    var summaryPage = component.get("v.summaryGroupType");
    var action = component.get("c.getSummaryPagebyType");
    // console.log("Start Get Summary Page By TYPE");
    action.setBackground(true);
    action.setParams({
      onedownValue: onedownValue,
      summaryPage: summaryPage
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // console.log("Result: " + JSON.stringify(result));

        component.set("v.summaryPage", result.summaryPagebyType);
        component.set("v.summaryPageValue", result.summaryPagebyTypeValue);
        helper.getSummaryTypeValue(component, helper);
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
    });
    $A.enqueueAction(action);
  },

  nFormatter: function (num, digits) {
  	if (num < 0) {
    	num = -num;
    	var sign = "-";
  	} else {
    	var sign = "";
  	}
  	const lookup = [
        { value: 1, symbol: "" },
        { value: 1e3, symbol: "k" },
        { value: 1e6, symbol: "M" },
        { value: 1e9, symbol: "B" },
        { value: 1e12, symbol: "T" },
        { value: 1e15, symbol: "P" },
        { value: 1e18, symbol: "E" }
  	];
      const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
      var item = lookup
        .slice()
        .reverse()
        .find(function (item) {
          return num >= item.value;
        });
    
      // Use toFixed() to round the number to the desired number of decimal places
      // and then use replace() to add trailing zeros if necessary
      var result = sign + (item ? (num / item.value).toFixed(digits) : "0");
      if (result.includes(".")) {
        result = result.replace(rx, "$1");
        var parts = result.split(".");
        if (parts.length == 1) {
          result += ".";
          for (var i = 0; i < digits; i++) {
            result += "0";
          }
        } else {
      		var diff = digits - parts[1].length;
      		for (var i = 0; i < diff; i++) {
        		result += "0";
      		}
    	}
  	} else {
    	result += ".";
    	for (var i = 0; i < digits; i++) {
      		result += "0";
    	}
  	}

  	return result + (item ? item.symbol : "");
  },


  showToastError: function (msg) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "error",
      title: "Error",
      message: msg
    });
    toastEvent.fire();
  },
    
    parseNumber: function (num) {
 		 if (typeof num === "string") {
    		num = parseFloat(num);
  		}
  		if (typeof num === "number") {
    		if (num === Math.round(num * 10) / 10) {
                //console.log('Num after parse: '+ num.toFixed(2))
      		return num.toFixed(2);
   			} else {
                //console.log('Num after parse: '+ num.toString())
      			return num.toString();
    		}
      } else {
    		return "Invalid input! Please enter a number.";
  		}
	}
});