({
    setDefaultDate: function (component, event, helper) {
        const toDay = new Date();
        var monthLst = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        ];
        component.set('v.selectedMonth', monthLst[component.get('v.selectedMonthInt') -1]);
        var selectedmonth = component.get('v.selectedMonth');

        component.set('v.yearList', [toDay.getFullYear() - 1, toDay.getFullYear()]);

        component.set('v.monthList', monthLst);
    },

    getProductTarget2: function (component, event, helper) {
        return new Promise(function (resolve, reject) {
            component.set("v.loading", true);
            var selectedYear = component.get('v.selectedYear');
            var selectedMonth = component.get('v.selectedMonth');
            var monthList = component.get('v.monthList');
            var selectedMonthNumber = (monthList.indexOf(selectedMonth) + 1).toString().padStart(2, '0');
            var period = component.get('v.selectedPeriod');
            var summaryGroupType = component.get('v.summaryGroupType');
            var summaryGroupValue = component.get('v.summaryGroupValue');
            var action = component.get('c.getProductTargetTeam2');// get function at apex
            action.setParams({
                "selectedYear": selectedYear,
                "selectedMonth": selectedMonthNumber,
                "period": period,
                "summaryGroupType": summaryGroupType,
                "summaryGroupValue": summaryGroupValue, // ytd / mtd
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.teamList', result.teamList);
                        var teamdata = result.teamList;
                        component.set('v.teamLabelList', teamdata);
                        var defaultSelectedTeam = [];
                        result.teamList.forEach(team => {
                            defaultSelectedTeam.push(team.label);
                        });
                        component.set('v.selectedTeam', defaultSelectedTeam);
                        component.set("v.loading", false);
                        resolve(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server    
                    component.set("v.loading", false);
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.showToastError('Error : ' + message);

                }
            
            });
            $A.enqueueAction(action);
        });
    },

    getWatermarkHTML: function (component, helper) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var watermarkHTML = response.getReturnValue();
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
                component.set('v.waterMarkImage', bg);
            } else if (state === 'ERROR') {
                console.log('error: ', response.error);
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get watermark HTML, Message: ' + message);
                component.set('v.loading', false)
            } else {
                console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get watermark HTML, Message: ' + message);
                component.set('v.loading', false)
            }
        });
        $A.enqueueAction(action);
    },
    showToastError: function (msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error",
            "message": msg
        });
        toastEvent.fire();
    },

    checkPctCssClass : function(pct) {
        if(pct != null && pct != undefined) {
            if(pct < 60) {
                return 'kpiLv1';
            }else if (pct < 90) {
                return 'kpiLv2';
            }else if (pct < 110) {
                return 'kpiLv3';
            }else if (pct < 140) {
                return 'kpiLv4';
            }else {
                return 'kpiLv5';
            }
        }
        return '';
    },

    makeData: function (component, event, helper) {
        helper.getProductTarget2(component,event,helper).then((productTargetData) =>{
            var productList = productTargetData.productList;
            var selectedYear = component.get('v.selectedYear');
            var selectedMonth = component.get('v.selectedMonth');
            var monthList = component.get('v.monthList');
            var selectedMonthNumber = (monthList.indexOf(selectedMonth) + 1).toString().padStart(2, '0');
            var summaryPage = component.get('v.summaryGroupType');
            var period = component.get('v.selectedPeriod');
            var tgYear = selectedYear.substring(selectedYear.length - 2);
            var tgType;
            if (period == 'YTD') {
                tgType = "YTD";
            } else if (period == 'MTD') {
                tgType = "MTD";
            }
            const subColumnLabel = ["TG_Y" + tgYear, "TG_" + tgType, "ACT_" + tgType, "%"];
            component.set('v.subColumnLabel', subColumnLabel);

            const date = new Date();
            const dateMonth = (date.getMonth()+1).toString().padStart(2, "0");
            const dateDay = date.getDate().toString().padStart(2, "0");
            const dateYear = date.getFullYear().toString();
            const dateLast = new Date(dateYear, dateMonth, 0);
            const dateLastDay = dateLast.getDate().toString().padStart(2, "0");
            const daysInMonth = dateLast.getDate();
            var useField;
            switch (summaryPage) {
                case 'Retail':
                    useField = 'Group_Channel__c';
                    break;
                case 'Group of channel':
                    useField = 'Channel_Name__c';
                    break;
                case 'Channel':
                    useField = 'Region_Code__c';
                    break;
                case 'Region':
                    useField = 'Zone_Code__c';
                    break;
                case 'Zone':
                    useField = 'Branch_Team_Code__c';
                    break;
            } 
            var teamdata = component.get('v.teamList');
            component.set('v.useField',useField);
            var kpiObjList = []
            var allProductList = '';
            var newTeamList = teamdata;
            
            var lv1 = [];
            var mapSelectedTarget = new Map();
            var hasSelectedTarget = false;
            productList.forEach(product => {
                var targetProrate = null;
                var tgYear = null;
                var actualValue = product.Actual_Amount__c ? parseFloat(product.Actual_Amount__c) : 0;

                if(product.Month__c == selectedMonthNumber && product.Year__c == selectedYear) {
                    hasSelectedTarget = true;
                    tgYear = product.Target_Unit_Year__c;
                    if(product.Volumn__c) {
                        mapSelectedTarget.set(product.Product_Group_Name__c+product[useField],product);
                    }
                }
                if (product.Month__c == dateMonth && product.Year__c == dateYear) {
                    if (dateDay - 2 >0 && product.Target_Unit_Month__c) {
                        targetProrate = helper.calDecimal(helper,'multiply',(product.Target_Unit_Month__c/daysInMonth),(dateDay-2));
                    }
                } else {
                    targetProrate = product.Target_Unit_Month__c;
                }
                    var defaultTeamList = [];
                    var pct = null;
                    if(targetProrate != undefined && targetProrate != null) {
                        pct = ((actualValue)/targetProrate)*100;
                    }
                    newTeamList.forEach(team => {
                        var defaultTgCurrYearValue = null;
                        var defaultTgYTDValue = null;
                        var defaultPct = null;
                        var defaultAct = null;
                        if (team.label == product[useField] ) {
                            defaultTgCurrYearValue = tgYear != undefined && tgYear != null ? tgYear : defaultTgCurrYearValue;
                            defaultTgYTDValue = targetProrate != undefined && targetProrate != null ? targetProrate : defaultTgYTDValue;
                            defaultAct = actualValue;
                            defaultPct = pct ? pct : defaultPct;

                        }
                        var kpiTeam = {
                            label: team.label,
                            tgCurrYearValue: defaultTgCurrYearValue,
                            tgYTDValue: defaultTgYTDValue,
                            actualYTD: defaultAct,
                            percent: defaultPct,
                            percentCssColor: helper.checkPctCssClass(defaultPct)
                        }
                        defaultTeamList.push(kpiTeam)
                    });
                    var defaultProductObj = {
                        label: product.Product_Group_Name__c,
                        total: {
                            tgCurrYearValue: tgYear,
                            tgYTDValue: targetProrate, //edit*****
                            actualYTD: actualValue,
                            percent: pct ? pct : null,
                            percentCssColor: helper.checkPctCssClass(pct)
                        },
                        kpiTeamList: defaultTeamList
                    }
                    
                    var idxKpiObj = kpiObjList.findIndex(el => el.quadrant == product.Indicator_Level1__c);
                    if (idxKpiObj >= 0) {
                        var currKPIObj = kpiObjList[idxKpiObj];

                        var idxProductObj = currKPIObj.productList.findIndex(el => el.label == product.Product_Group_Name__c);
                        if (idxProductObj >= 0) {
                            var KPITeamlist = kpiObjList[idxKpiObj].productList[idxProductObj];
                            var idxTeamlist = KPITeamlist.kpiTeamList.findIndex(el => el.label == product[useField]);
                            if (idxTeamlist >= 0) {
                                var tgCurrYearValue = kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgCurrYearValue;
                                if (tgCurrYearValue == null || tgCurrYearValue == undefined) {
                                    kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgCurrYearValue = tgYear;
                                } else if (product.Target_Unit_Year__c) {
                                    if(tgYear != null && tgYear != undefined) {
                                        kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgCurrYearValue = helper.calDecimal(helper,'plus',kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgCurrYearValue,tgYear);
                                    }
                                }
                                if (kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgYTDValue == null) {
                                    kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgYTDValue = targetProrate;
                                } else if (targetProrate) {
                                    kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgYTDValue = helper.calDecimal(helper,'plus',kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgYTDValue,targetProrate)
                                }

                                if (kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].actualYTD == null) {
                                    kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].actualYTD = actualValue;
                                } else if(actualValue) {
                                    kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].actualYTD = helper.calDecimal(helper,'plus',kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].actualYTD,actualValue);
                                }

                                var totalActual = kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].actualYTD;
                                var totalTarget = kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].tgYTDValue;
                                var pct = (totalActual/totalTarget)*100;
                                
                                
                                kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].percent = pct ? pct : null;

                                kpiObjList[idxKpiObj].productList[idxProductObj].kpiTeamList[idxTeamlist].percentCssColor = helper.checkPctCssClass(pct);
                            }
                        } else {
                            kpiObjList[idxKpiObj].productList.push(defaultProductObj);
                        }
                    }
                    else {
                        lv1.push(product.Indicator_Level1__c);
                        var kpiObj = {
                            quadrant: product.Indicator_Level1__c,
                            productList: [defaultProductObj]
                        }
                        kpiObjList.push(kpiObj);
                    }
            });
            helper.calVolumn(helper, kpiObjList, mapSelectedTarget);

            component.set('v.hasSelectedTarget',hasSelectedTarget);
            component.set('v.kpiObjList', kpiObjList);   
        });

    },

    calVolumn : function(helper, kpiObjList, mapSelectedTarget) {
        kpiObjList.forEach(kpiObj => {
            kpiObj.productList.forEach((eachProduct) => {
                eachProduct.total.actualYTD = 0;
                eachProduct.total.tgYTDValue = null;
                eachProduct.total.tgCurrYearValue = null;

                eachProduct.kpiTeamList.forEach((eachTeam) => {
                    var targetObj = mapSelectedTarget.get(eachProduct.label+eachTeam.label);
                    if(targetObj && targetObj.Volumn__c) {
                        eachTeam.actualYTD = helper.calDecimal(helper,'round',eachTeam.actualYTD,null)/targetObj.Volumn__c;
                    }

                    eachTeam.actualYTD = helper.calDecimal(helper,'round',eachTeam.actualYTD,null);
                    if(!eachTeam.actualYTD) {
                        eachTeam.actualYTD = 0;
                    }
                    eachTeam.tgYTDValue = eachTeam.tgYTDValue ? helper.calDecimal(helper,'round',eachTeam.tgYTDValue,null) : null; // if 0 or blank => blank
                    eachTeam.tgCurrYearValue = helper.calDecimal(helper,'round',eachTeam.tgCurrYearValue,null); // show as actual data

                    if(eachTeam.actualYTD != null && eachTeam.actualYTD != undefined) {
                        if(eachProduct.total.actualYTD == null || eachProduct.total.actualYTD == undefined) {
                            eachProduct.total.actualYTD = eachTeam.actualYTD;
                        } else {
                            eachProduct.total.actualYTD += eachTeam.actualYTD;
                        }
                    }
                    eachTeam.percent = null;

                    if(eachTeam.tgYTDValue != null && eachTeam.tgYTDValue != undefined) {
                        if(eachProduct.total.tgYTDValue == null || eachProduct.total.tgYTDValue == undefined) {
                            eachProduct.total.tgYTDValue = eachTeam.tgYTDValue;
                        } else {
                            eachProduct.total.tgYTDValue += eachTeam.tgYTDValue;
                        }
                    }

                    if(eachTeam.tgCurrYearValue != null && eachTeam.tgCurrYearValue != undefined) {
                        if(eachProduct.total.tgCurrYearValue == null || eachProduct.total.tgCurrYearValue == undefined) {
                            eachProduct.total.tgCurrYearValue = eachTeam.tgCurrYearValue;
                        } else {
                            eachProduct.total.tgCurrYearValue += eachTeam.tgCurrYearValue;
                        }
                    }

                    if(eachTeam.tgYTDValue) {
                        eachTeam.percent = (eachTeam.actualYTD/eachTeam.tgYTDValue)*100;
                    }
                    eachTeam.percentCssColor = helper.checkPctCssClass(eachTeam.percent);
                    // }
                })
                eachProduct.total.percent = null;
                if(eachProduct.total.tgYTDValue) {
                    eachProduct.total.percent = (helper.calDecimal(helper,'round',eachProduct.total.actualYTD,null)/helper.calDecimal(helper,'round',eachProduct.total.tgYTDValue,null))*100;
                }
                eachProduct.total.percentCssColor = helper.checkPctCssClass(eachProduct.total.percent);
            })
        });
    },

    countDecimals : function(dec) {
        if(dec) {
            if(Math.floor(dec.valueOf()) === dec.valueOf()) return 0;
            return dec.toString().split(".")[1].length || 0; 
        }
        return 0;
    },

    calDecimal : function (helper,operator,val1,val2) {
        // *** This function was created to fix math decimal issues in javascript
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
            var plus = Math.round(val1*val_engine)+Math.round(val2*val_engine);
            return plus/val_engine;
        } else if(operator == 'multiply') {
            var mul = (val1*val1_engine)*(val2*val2_engine)
            var dev = Math.pow(10,(val1_dec+val2_dec));
            return (mul/dev);
        } else if(operator == 'round') {
            if(val1 != undefined && val1 != null) {
                var round = Math.round((val1*1000)/10)/100;
                return round;
            }
        }

        return null;
    },
   
})