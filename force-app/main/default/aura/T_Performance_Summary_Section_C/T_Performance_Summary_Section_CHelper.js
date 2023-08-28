({
  groupBy: function (xs, key) {
    return xs.reduce(function (rv, x) {
      (rv[x[key]] = rv[x[key]] || []).push(x);
      return rv;
    }, {});
  },

  //   setFill: function (el, perc) {
  //     var color;

  //     if (perc < 20) {
  //       color = "#F8D7CF";
  //     } else if (perc < 40) {
  //       color = "#FCE5D3";
  //     } else if (perc < 60) {
  //       color = "#F9EED6";
  //     } else if (perc < 80) {
  //       color = "#C4E4E0";
  //     } else if (perc <= 100) {
  //       color = "#C3CCD0";
  //     }

  //     $(el)
  //       .css("background", +color)
  //       .css("background", +color)
  //       .css("background", +color)
  //       .css("background", +color)
  //       .css("background", +color);
  //   },

  showToastError: function (msg) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "error",
      title: "Error",
      message: msg
    });
    toastEvent.fire();
  },

  // calculatedSummary : function (component, quadrant, product) {
  //   const KPI = component.get('v.targetProductData');
  //   const STP = component.get('v.summaryTeamData');
  //   KPI.filter
  //   var sum = 0;
  //   console.log(KPI[0])

  //   for(var i = 0; i < 5;i++){
  //     sum += KPI[i].Target_Unit_Year__c
  //   }
  //   console.log(sum);
  // },
  sumProductvalues: function (
    component,
    data,
    allIndicatorList,
    helper
  ) {
    allIndicatorList.productList.forEach((result) => {
      const date = new Date();
      var day = date.getDate() - 2;
      var month = date.getMonth() + 1;
      var year = date.getFullYear();
      var curDoM = moment().daysInMonth();
      var curDay = date.getDate();
      var selectedMonth = component.get("v.selectedMonth");
      var selectedYear = component.get("v.selectedYear");
      var multiplyDayofMonth = 1;
      var runrateDay = 1;
      var actualMonthTD = 0;
      var actualYearTD = 0;
      // var actualYTDCapmax = 0;
      // var actualMonthTDwithRV = 0;
      // var actualMonthTDwithRVrunrate = 0;
      var runrate = 0;
      var BPE;
      // var PointPercent = 0;
      var UnitPercent = 0;
      var percentMTD = 0;
      var volume = 1;
      var Capmax = "";
      // console.log('Current day of month : ' + curDoM);
      if(day > 0){
        if (selectedMonth == month && selectedYear == year) {
          multiplyDayofMonth = day / curDoM;
          runrateDay = curDoM / (curDay);   
        }
      }
      if (result.ProductCode == data.Product_Group_Code__c) {
      // if (result.Label == data.Product_Group_Name__c) {
        
          
          if (parseInt(data.Month__c) == selectedMonth && parseInt(data.Year__c) == selectedYear) {
            if(data.hasOwnProperty('Volumn__c')){
              volume = parseFloat(data.Volumn__c);
            }else { 
              volume = 1;
            }
            
            actualMonthTD = parseFloat(data.Actual_Amount__c) / (result.UNIT.volume ? result.UNIT.volume : 1);
            result.UNIT.actualMTD = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.actualMTD), (actualMonthTD ? actualMonthTD : 0));
            result.UNIT.tgCurrYearValue = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.tgCurrYearValue), parseFloat(data.Target_Unit_Year__c));
            
          if(data.hasOwnProperty('Branch_Point_Engine__c')){
            BPE = parseFloat(data.Branch_Point_Engine__c);
              
          }else {
            BPE = "";
          }
          if(data.hasOwnProperty('Cap_Max_Pct__c')){
            result.POINTs.Capmax = parseFloat(data.Cap_Max_Pct__c);
            
          }else {
            result.POINTs.Capmax = "";
          }
              result.POINTs.RV = BPE;
              //  console.log("Branch Point Engine : " + BPE)
        }
        if(parseInt(data.Month__c) != selectedMonth && parseInt(data.Year__c) == selectedYear){
            result.POINTs.actualForRunrate = helper.calDecimal(helper, 'plus', (parseFloat(result.POINTs.actualForRunrate)), (parseFloat(data.Actual_Amount__c) / (result.UNIT.volume ? result.UNIT.volume : 1)));
        }
        actualYearTD = parseFloat(data.Actual_Amount__c) / (result.UNIT.volume ? result.UNIT.volume : 1);
        result.UNIT.actualYTD = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.actualYTD), actualYearTD);
        if(day > 0){
          result.UNIT.runrate = helper.calDecimal(helper, "multiply", helper.calDecimal(helper, "round", parseFloat(result.UNIT.actualMTD), null), runrateDay);
        }else{
          result.UNIT.runrate = helper.calDecimal(helper, "round", parseFloat(result.UNIT.actualMTD), null)
        }
        
      
        
        if (parseInt(data.Month__c) == selectedMonth && parseInt(data.Year__c) == selectedYear) {
          // console.log('result.UNIT.tgYTDValue: '+result.UNIT.tgYTDValue + ',  Target_Unit_Month__c: '+(multiplyDayofMonth * parseFloat(data.Target_Unit_Month__c)))
          if (selectedMonth == month && selectedYear == year) {
                        //console.log('result.UNIT.tgYTDValue: '+result.UNIT.tgYTDValue + ',  Target_Unit_Month__c: '+(multiplyDayofMonth * parseFloat(data.Target_Unit_Month__c)))

                        result.UNIT.tgYTDValue = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.tgYTDValue), (helper.calDecimal(helper, "multiply", (day) ,(parseFloat(data.Target_Unit_Month__c)))));
          }
          // result.UNIT.tgYTDValue = helper.calDecimal(helper, "round", (parseFloat(result.UNIT.tgYTDValue)), null);
        } else {
          result.UNIT.tgYTDValue =  helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.tgYTDValue), parseFloat(data.Target_Unit_Month__c));
          // console.log('Added TG_YTD '+ result.UNIT.tgYTDValue)
        }
        
        
        if(BPE != ""){ 
          // if(Capmax != ""){
          //             actualYTDCapmax = (actualYearTD * (result.POINTs.RV ? result.POINTs.RV : 1) > (result.UNIT.tgYTDValue * (result.POINTs.RV ? result.POINTs.RV : 1) * Capmax/100)) ? (result.UNIT.tgYTDValue * (result.POINTs.RV ? result.POINTs.RV : 1)* (Capmax/100)) : (actualYearTD * (result.POINTs.RV ? result.POINTs.RV : 1));
          // }       
          // result.POINTs.actualYTD += actualYTDCapmax\
          
          //if(result.UNIT.tgYTDValue != 0 && result.UNIT.tgYTDValue != ""){
          //  result.POINTs.tgYTDValue = (result.UNIT.tgYTDValue) * (result.POINTs.RV != "" ? result.POINTs.RV : 1);
          //}else{
          //  result.POINTs.tgYTDValue = "";  
          //}
          
          // PointPercent = result.POINTs.actualYTD / result.POINTs.tgYTDValue;
          // if(result.POINTs.tgYTDValue == 0 ||result.POINTs.tgYTDValue == ""){
          //   PointPercent = "";
          // }
        }
       
        // result.POINTs.percent = PointPercent;
        // result.POINTs.percentColor = "KPI0";
        UnitPercent = helper.calDecimal(helper, "round", (parseFloat(result.UNIT.actualYTD)), null) / helper.calDecimal(helper, "round", (parseFloat(result.UNIT.tgYTDValue)), null);
        if(result.UNIT.tgYTDValue == 0 || result.UNIT.tgYTDValue == 0){
          UnitPercent = "";
        }
        result.UNIT.percent = UnitPercent;
        result.UNIT.percentColor = "KPI0";
        if (parseInt(data.Month__c) == selectedMonth && parseInt(data.Year__c) == selectedYear) {
          if (selectedMonth == month && selectedYear == year && day > 0) {
            result.UNIT.tgMTDValue = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.tgMTDValue), (multiplyDayofMonth * parseFloat(data.Target_Unit_Month__c)));
            // result.UNIT.tgMTDValue = helper.calDecimal(helper, "round", (parseFloat(result.UNIT.tgMTDValue)) , null);
          } 
          else {
            result.UNIT.tgMTDValue = helper.calDecimal(helper, 'plus', parseFloat(result.UNIT.tgMTDValue),parseFloat(data.Target_Unit_Month__c));
          }
        }
        
        // actualMonthTDwithRV = (result.UNIT.actualMTD ? result.UNIT.actualMTD : 0) * (result.POINTs.RV ? result.POINTs.RV : 1);

        // actualMonthTDwithRVrunrate = actualMonthTDwithRV * runrateDay;

        // runrate = ((result.POINTs.actualYTD - actualMonthTDwithRV) + actualMonthTDwithRVrunrate) / (result.UNIT.tgYTDValue * (result.POINTs.RV ? result.POINTs.RV : 1));
        // if(result.UNIT.tgYTDValue == 0 || result.UNIT.tgYTDValue == "" || BPE == "" || runrate < 0 ){
        //   runrate = "";
        // }

        percentMTD = (helper.calDecimal(helper, "round", parseFloat(result.UNIT.actualMTD), null)) / (helper.calDecimal(helper, "round", parseFloat(result.UNIT.tgMTDValue), null));
        if(result.UNIT.tgMTDValue == 0 || result.UNIT.tgMTDValue == ""){
          percentMTD = "";
        }
        
        result.UNIT.percentMTD = percentMTD;
        // result.POINTs.percentMTD = runrate;
        // result.POINTs.percentMTDColor = "KPI0";
        result.UNIT.percentMTDColor = "KPI0";
        
      }
    });
    return allIndicatorList;
  },

  cssColorChange: function (component, helper) {
    function cssClassColor (value) {
      var colorClass;
      // console.log(value) 
      // console.log(!isNaN(value) && !(value === ""))
      if(!isNaN(value) && !(value === "") && value != Infinity){
        let data = value*100;
        if (data >= 0 && data < 60 || data < 0 ) {
        colorClass = "KPI1";
        } else if (data >= 60 && data < 90) {
          colorClass = "KPI2";
        } else if (data >= 90 && data < 110) {
          colorClass = "KPI3";
        } else if (data >= 110 && data < 140) {
          colorClass = "KPI4";
        } else if (data >= 140) {
          colorClass = "KPI5";
        }else{
          colorClass = "KPI0";
        }
      }else{
        colorClass = "KPI0";
      }
      // console.log('Value: '+data +'  ColorCode: '+ colorClass);
      return colorClass;
    }
    var KPI = component.get("v.targetProductObjList");
    var actualMap = component.get("v.targetMapData");
    // console.log(actualMap);
    const date = new Date();
    var day = date.getDate() - 2;
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    var curDoM = moment().daysInMonth();
    var curDay = date.getDate();
    var selectedMonth = component.get("v.selectedMonth");
    var selectedYear = component.get("v.selectedYear");
    for (var i = 0; i < KPI.length; i++) {
      for (var j = 0; j < KPI[i].productList.length; j++) {
        var multiplyDayofMonth = 1;
        if (selectedMonth == month && selectedYear == year && day > 0) {
          multiplyDayofMonth = curDoM / (curDay);
        }
        var UnitPercent = "";
        var PointPercent = "";
        var PointRunrate = "";
          // console.log('Debug actual map section C',actualMap ? true : false,actualMap)
        if(actualMap){
          if(actualMap.mapProductWithActual.hasOwnProperty(KPI[i].productList[j].ProductCode)){
            
            KPI[i].productList[j].UNIT.actualYTD = helper.calDecimal(helper, "round", (actualMap.mapProductWithActual[KPI[i].productList[j].ProductCode]), null);
            UnitPercent = (parseFloat(KPI[i].productList[j].UNIT.actualYTD)).toFixed(2) / helper.calDecimal(helper, "round", ((parseFloat(KPI[i].productList[j].UNIT.tgYTDValue))), null);
            if(parseFloat(KPI[i].productList[j].UNIT.tgYTDValue) == 0 || parseFloat(KPI[i].productList[j].UNIT.tgYTDValue) == ""){
              UnitPercent = "";
            }
            KPI[i].productList[j].UNIT.percent = UnitPercent
          }
          if(actualMap.mapProductWithActualMTD){
            if(actualMap.mapProductWithActualMTD.hasOwnProperty(KPI[i].productList[j].ProductCode)){
              KPI[i].productList[j].UNIT.actualMTD = helper.calDecimal(helper, "round", (actualMap.mapProductWithActualMTD[KPI[i].productList[j].ProductCode]), null);

              PointPercent = ((parseFloat(KPI[i].productList[j].UNIT.actualMTD)).toFixed(2)) / helper.calDecimal(helper, "round", ((parseFloat(KPI[i].productList[j].UNIT.tgMTDValue))), null);
              if(parseFloat(KPI[i].productList[j].UNIT.tgMTDValue) == 0 || parseFloat(KPI[i].productList[j].UNIT.tgMTDValue) == ""){
                PointPercent = "";
              }
              KPI[i].productList[j].UNIT.percentMTD = PointPercent;
              KPI[i].productList[j].UNIT.runrate = helper.calDecimal(helper, "multiply", ((parseFloat(KPI[i].productList[j].UNIT.actualMTD))), multiplyDayofMonth);
            }
          }
          if(actualMap.mapActualWithRunrate){
            if(actualMap.mapActualWithRunrate.hasOwnProperty(KPI[i].productList[j].ProductCode)){
              KPI[i].productList[j].POINTs.actualForRunrate = (actualMap.mapActualWithRunrate[KPI[i].productList[j].ProductCode]);
            }
          }
        }
        // console.log(KPI[i].productList[j].UNIT.tgYTDValue.toFixed(2))
        var targetRV = helper.calDecimal(helper, "multiply", (helper.calDecimal(helper, "round", (parseFloat(KPI[i].productList[j].UNIT.tgYTDValue)), null)) , parseFloat(KPI[i].productList[j].POINTs.RV));
        KPI[i].productList[j].POINTs.tgYTDValue =  helper.calDecimal(helper, "round", parseFloat(targetRV), null);
        var actualRV = helper.calDecimal(helper, "round",  (parseFloat(KPI[i].productList[j].UNIT.actualYTD)), null) * parseFloat(KPI[i].productList[j].POINTs.RV);
        if(KPI[i].productList[j].POINTs.Capmax != "" && KPI[i].productList[j].POINTs.tgYTDValue != ""){
            // console.log('targetRV : '+ targetRV + ' ' + (KPI[i].productList[j].POINTs.Capmax / 100))
          if(actualRV > (KPI[i].productList[j].POINTs.tgYTDValue * (KPI[i].productList[j].POINTs.Capmax / 100))){
            KPI[i].productList[j].POINTs.actualYTD = helper.calDecimal(helper, "multiply", helper.calDecimal(helper, "round", parseFloat(targetRV), null), (KPI[i].productList[j].POINTs.Capmax / 100));
          }else{
            KPI[i].productList[j].POINTs.actualYTD = actualRV;
          }
        }else{
          KPI[i].productList[j].POINTs.actualYTD = actualRV;
        }
        
        if(KPI[i].productList[j].POINTs.tgYTDValue == 0){
          KPI[i].productList[j].POINTs.tgYTDValue = "";
        }
        if(KPI[i].productList[j].UNIT.tgYTDValue == 0){
          KPI[i].productList[j].UNIT.tgYTDValue = "";
        }
        if(KPI[i].productList[j].UNIT.tgMTDValue == 0){
          KPI[i].productList[j].UNIT.tgMTDValue = "";
        }
        if(KPI[i].productList[j].UNIT.actualYTD < 0){
          KPI[i].productList[j].POINTs.actualYTD = 0;
        }
        if(KPI[i].productList[j].POINTs.RV == ""){
          KPI[i].productList[j].POINTs.tgYTDValue = "";
          KPI[i].productList[j].POINTs.actualYTD = "";
          KPI[i].productList[j].POINTs.percent = "";
          KPI[i].productList[j].POINTs.percentMTD = "";
          KPI[i].productList[j].POINTs.RawActualYTD = "";
        }else{
          KPI[i].productList[j].POINTs.percent =  helper.calDecimal(helper, "round", ((parseFloat(KPI[i].productList[j].POINTs.actualYTD))),null) /  helper.calDecimal(helper, "round", ((parseFloat(KPI[i].productList[j].POINTs.tgYTDValue))), null);
          let ac = KPI[i].productList[j].POINTs.actualForRunrate;
          let targetRunrate = "";
          if(KPI[i].productList[j].UNIT.tgYTDValue){
             targetRunrate =  helper.calDecimal(helper, "round", parseFloat(KPI[i].productList[j].UNIT.tgYTDValue), null);
          }
          let runrate = (parseFloat((KPI[i].productList[j].UNIT.runrate)));
          runrate =  parseFloat(runrate);
          let actualRunrate = helper.calDecimal(helper, 'plus', ac, runrate);
          if(targetRunrate != 0 && targetRunrate !=""){
            PointRunrate = actualRunrate/targetRunrate;
          }
          // console.log('PointRunrate : '+PointRunrate)
          // console.log('Actual before runrate: '+ ac)
          // console.log('targetRunrate: '+ targetRunrate)
          // console.log('actualRunrate: '+ actualRunrate)
          if(parseFloat(KPI[i].productList[j].UNIT.tgYTDValue) == 0 || parseFloat(KPI[i].productList[j].UNIT.tgYTDValue) == "" || PointRunrate < 0){
            PointRunrate = "";
          }
          // console.log( PointRunrate + ' ' + KPI[i].productList[j].POINTs.Capmax)
          if(KPI[i].productList[j].POINTs.Capmax){
            KPI[i].productList[j].POINTs.percentMTD = (PointRunrate*100) > KPI[i].productList[j].POINTs.Capmax ? (KPI[i].productList[j].POINTs.Capmax)/100 : PointRunrate;
          }else{
            KPI[i].productList[j].POINTs.percentMTD = PointRunrate;
          }
          // console.log('Percent Runrate: '+ PointRunrate)
        }
		if(KPI[i].productList[j].UNIT.runrate < 0){
          KPI[i].productList[j].UNIT.runrate = "";
        }
        var percent = KPI[i].productList[j].UNIT.percent;
        var percentColor = cssClassColor(percent)
        KPI[i].productList[j].UNIT.percentColor = percentColor;
        
        var percentMTD = KPI[i].productList[j].UNIT.percentMTD;
        var percentMTDColor = cssClassColor(percentMTD)
        KPI[i].productList[j].UNIT.percentMTDColor = percentMTDColor;

        var percentP = KPI[i].productList[j].POINTs.percent;
        var percentPColor = cssClassColor(percentP)
        KPI[i].productList[j].POINTs.percentColor = percentPColor;
        
        var percentMTDP = KPI[i].productList[j].POINTs.percentMTD;
        var percentMTDPColor = cssClassColor(percentMTDP);
        KPI[i].productList[j].POINTs.percentMTDColor = percentMTDPColor;
      }
    }
   	// console.log(KPI);
    component.set("v.targetProductObjList", KPI);
  },

  isNextButtonHandle: function (component) {
    var channelName = component.get("v.channelName");
    // console.log('channelName--> '+channelName)
    var onedownValue = component.get("v.onedownValue");
    var summaryPage = component.get("v.summaryGroupType");
    var selectedYear = component.get("v.selectedYear");
    var selectedMonth = component.get("v.selectedMonth");
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
        console.log('Is next button :' +  result);
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

  calDecimal : function (helper,operator,val1,val2) {
    // Number.prototype.countDecimals = function () {
    //     if(Math.floor(this.valueOf()) === this.valueOf()) return 0;
    //     return this.toString().split(".")[1].length || 0; 
    // }
    var val1_dec = helper.countDecimals(val1);
    var val2_dec = helper.countDecimals(val2);

    val1_dec = val1_dec > 10 ? 10 : val1_dec;
    val2_dec = val2_dec > 10 ? 10 : val2_dec;

    var val_engine;
    if(val2_dec > val1_dec) {
        val_engine = Math.pow(10,val2_dec);
    } else {
        val_engine = Math.pow(10,val1_dec);
    }

    var val1_engine = Math.pow(10,val1_dec);
    var val2_engine = Math.pow(10,val2_dec);
    if(operator == 'plus') {
        var plus = Math.round(val1*val_engine) + Math.round(val2*val_engine);
        return plus/val_engine;
    } else if(operator == 'multiply') {
        var mul = (val1*val1_engine)*(val2*val2_engine)
        var dev = Math.pow(10,(val1_dec+val2_dec));
        return (mul/dev);
    } else if(operator == 'round') {
        if(val1) {
            var round = Math.round((val1*1000)/10)/100;
            return round;
        }
        // var dev = val1_engine;
    }

    return 0;

    // var mul = (val1*val1_engine)*(val2*val2_engine)
    // var dev = Math.pow(10,(val1_dec+val2_dec));
    // return (mul/dev);
  },

  countDecimals : function(dec) {
    if(dec) {
        if(Math.floor(dec.valueOf()) === dec.valueOf()) return 0;
        return dec.toString().split(".")[1].length || 0; 
    }
    return 0;
  },

});