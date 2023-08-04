({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    getFieldData: function (component, event, helper) {
        helper.getDescribeFieldResult(component, event, helper);

        helper.getCVSAnalyticsData(component, event, helper);   // RTL_Privilege1__c, TTB_Touch_Flag, RTL_Average_AUM__c
        helper.retryCalloutGetFagPdpa(component,event, helper, 0);   //pdpa, marketDetail

        helper.getSubDebtTransaction(component,helper);
    },

    runCallback: function (component, event, helper, objectInfoField) {
        component.set('v.account', objectInfoField);
        // GenerateField defualt field
        helper.generateField(component, objectInfoField, component.get('v.fields').filter(f => f.fieldName));
        // Special replace field
        helper.onCustomSegment(component, objectInfoField);

        // Call for Segment Coloring
        helper.getSegmentCodition(component,event,helper,objectInfoField);

        // helper.onCustomPrivilege1(component, objectInfoField);
        helper.onCustomAUM(component, objectInfoField);
        helper.onCustomSBOFlag(component, objectInfoField);
        // Custom color field
        helper.onDynamicAdjustField(component, objectInfoField);
        helper.onCustomWRM(component, objectInfoField);

        helper.getSubSegmentData(component, event, helper);

        // Custom MainBank field
        helper.onCustomMainBank(component, objectInfoField);


    },
    getDescribeFieldResult: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.allField').reduce((l, i) => {
                if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
                    l.push(i.fieldName);
                return l;
            }, []),
            "fields_translate": []
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                var dataFields = component.get('v.dataFields');
                Object.keys(objectInfoField).forEach(field => {
                    dataFields[field] = objectInfoField[field];
                });
                component.set('v.dataFields',dataFields);

                // objectInfoField = helper.testHideAllFields(component, event, helper) // for testing only

                helper.runCallback(component, event, helper, objectInfoField);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    onDynamicAdjustField: function (component, objectInfoField) {
        var cmp =  component.get('v.dataFields');
        cmp.FATCA__c.class = objectInfoField['FATCA__c'].value == 'ทำ FATCA (complete)' ? 'greenColor' : 'redColor';
        if(cmp.KYC_Update__c.value.includes('ใกล้หมดอายุ')){
            cmp.KYC_Update__c.class = 'yellowColor';
        }else if(cmp.KYC_Update__c.value == 'กรุณาปรับปรุงข้อมูล'){
            cmp.KYC_Update__c.class = 'redColor';
        }
        component.set('v.dataFields', cmp);

    }, 

    generateField: function (component, objectInfoField, fieldList) {
        var dataField = component.get('v.dataFields');
        dataField.RTL_Customer_Name_TH__c.class = 'blueColor';
        dataField.RTL_Date_Of_Birth__c.class = 'blueColor';
        dataField.RTL_Zodiac__c.class = 'blueColor';
        dataField.Mobile_Number_PE__c.class = 'blueColor';
        dataField.Email_Address_PE__c.class = 'blueColor';
        dataField.RTL_Wealth_RM__c.class = 'blueColor';

    },
    onCustomMainBank: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields');
        if(cmp.RTL_Primary_Banking_All_Free_Benefit__c.isAccessible) {
            var MainBankValue = objectInfoField['RTL_Primary_Banking_All_Free_Benefit__c'].value == true ? 'Yes':'No';
            var MainBankDes = objectInfoField['RTL_Main_Bank_Desc__c'].value == null || objectInfoField['RTL_Main_Bank_Desc__c'].value == '' ? '' : ' [' + objectInfoField['RTL_Main_Bank_Desc__c'].value + ']';
            cmp.RTL_Primary_Banking_All_Free_Benefit__c.value = MainBankValue + MainBankDes;
            cmp.RTL_Primary_Banking_All_Free_Benefit__c.type = 'STRING';
            component.set('v.dataFields',cmp);
        }
    },
    onCustomSegment: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields');
        if(cmp.Core_Banking_Suggested_Segment__c.isAccessible) {
            cmp.Core_Banking_Suggested_Segment__c.label = objectInfoField['Core_Banking_Suggested_Segment__c'].label + ' / ' + objectInfoField['Sub_segment__c'].label;
            cmp.Core_Banking_Suggested_Segment__c.value = objectInfoField['Core_Banking_Suggested_Segment__c'].value ? objectInfoField['Core_Banking_Suggested_Segment__c'].value : '';
            cmp.Core_Banking_Suggested_Segment__c.type = 'STRING';
            component.set('v.dataFields',cmp);
        }
    },
    onCustomAUM: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields');
        if(cmp.RTL_AUM__c.isAccessible) {
            cmp.RTL_AUM__c.label = objectInfoField['RTL_AUM__c'].label + ' (' + objectInfoField['RTL_AUM_Last_Calculated_Date__c'].label + ')';
            cmp.RTL_AUM__c.value = $A.get("$Locale.currency") + (objectInfoField['RTL_AUM__c'].value ? objectInfoField['RTL_AUM__c'].value.toLocaleString('en-US') : '0');
            cmp.RTL_AUM__c.value += objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value ? ' [' + $A.localizationService.formatDate(objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value) + ']' : '';
            cmp.RTL_AUM__c.inlineHelpText = objectInfoField['RTL_AUM_Last_Calculated_Date__c'].inlineHelpText;
            cmp.RTL_AUM__c.type = 'STRING';
            component.set('v.dataFields', cmp);
        }
        
    },
    onCustomSBOFlag: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields');
        if(cmp.RTL_SBO_FLAG__c.isAccessible) {
            cmp.RTL_SBO_FLAG__c.label = objectInfoField['RTL_SBO_FLAG__c'].label + ' / ';
            cmp.RTL_SBO_FLAG__c.label += objectInfoField['RTL_EXIST_NONJU_FLAG__c'].label;
            cmp.RTL_SBO_FLAG__c.value = (objectInfoField['RTL_SBO_FLAG__c'].value ? objectInfoField['RTL_SBO_FLAG__c'].value : '-') + ' / ';
            cmp.RTL_SBO_FLAG__c.value += (objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value ? objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value : '-');
            cmp.RTL_SBO_FLAG__c.type = 'STRING';
            component.set('v.dataFields', cmp);
        }
    },
    onCustomWRM: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields');
        if(cmp.RTL_Wealth_RM__c.isAccessible) {
            cmp.RTL_Wealth_RM__c.value_addon = objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
            cmp.RTL_Wealth_RM__c.value_addon += objectInfoField['Wealth_RM_EMP_Code__c'].value != 'Undefined' ? objectInfoField['Wealth_RM_EMP_Code__c'].value : '';
            cmp.RTL_Wealth_RM__c.value = objectInfoField['RTL_Wealth_RM__c'].value;
            cmp.RTL_Wealth_RM__c.type = 'REFERENCE_ADDON';
            component.set('v.dataFields', cmp);
        }
    },
    retryCalloutGetFagPdpa: function (component, event, helper, round){
		var action = component.get('c.getDescribeFieldFromPDPA');
        var dataField = component.get('v.dataFields');
		action.setParams({
			"accountId": component.get('v.recordId'),
		});

		action.setCallback(this, function(response) {
            component.set('v.isPDPALoading',false);
			if (component.isValid() && response.getState() === 'SUCCESS') {
				var result = response.getReturnValue();
				if(result.wsResponse.isSuccess == 'true'){
                    const replacer = str => ({
                        '\t': '\\t',
                        '\n': '\\n',
                        '\b': '\\b',
                        '\r': '\\r',
                        '\f': '\\f',
                        '\\': '\\\\',
                        '': '\\\\'
                    }[str]);

                    const regEx = new RegExp('\\\\|\t|\n|\b|\r|\f', 'g');
                    result.pdpaDetail.value = result.pdpaDetail.value.replace(regEx, replacer);
                    result.marketDetail.value = result.marketDetail.value.replace(regEx, replacer);
                    dataField.pdpaDetail = result.pdpaDetail;
                    dataField.marketDetail = result.marketDetail;
                    component.set('v.dataFields',dataField)
				}else if(result.wsResponse.errorMessage == 'invalid_token' && round < component.get("v.numberOfRetry")){
					round++;
                    result.pdpaDetail.value = 'Error getting data, retrying... ('+round+')';
                    result.marketDetail.value = 'Error getting data, retrying... ('+round+')';
                    dataField.pdpaDetail = result.pdpaDetail;
                    dataField.marketDetail = result.marketDetail;
                    component.set('v.dataFields',dataField)
					window.setTimeout(
						$A.getCallback(function () {
							helper.retryCalloutGetFagPdpa(component,event, helper, round);
						}), component.get("v.retrySetTimeOut")
					);
				}else{
                    result.pdpaDetail.value = 'Error getting data';
                    result.pdpaDetail.class = 'redErrorFontColor';
                    result.marketDetail.value = 'Error getting data';
                    result.marketDetail.class = 'redErrorFontColor';
                    dataField.pdpaDetail = result.pdpaDetail;
                    dataField.marketDetail = result.marketDetail;
                    component.set('v.dataFields',dataField)
				}
			}else{
                result.pdpaDetail.value = 'Error getting data';
                result.pdpaDetail.class = 'redErrorFontColor';
                result.marketDetail.value = 'Error getting data';
                result.marketDetail.class = 'redErrorFontColor';
                dataField.pdpaDetail = result.pdpaDetail;
                dataField.marketDetail = result.marketDetail;
                component.set('v.dataFields',dataField)
			}
		});
        $A.enqueueAction(action);
	},
    getCVSAnalyticsData: function (component, event, helper) {
        var numberOfRetry = component.get('v.numberOfRetry');
        var round = component.get('v.round');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        var action = component.get('c.getDescribeFieldFromOSC07');
        action.setParams({
            // "rmId": component.get('v.account.TMB_Customer_ID_PE__c').value,
            "accountId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.isOSCLoading',false);
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var dataField = component.get('v.dataFields');
                if (result && result.oscResponse.StatusCode == '200') {
                    dataField.RTL_Privilege1__c = result.RTL_Privilege1__c;

                    if(result.RTL_Average_AUM__c.value != $A.get("$Label.c.Data_Condition_Hidden_Text")) {
                        result.RTL_Average_AUM__c.value =  result.RTL_Average_AUM__c.value ? parseFloat(result.RTL_Average_AUM__c.value) : 0;
                    }
                    dataField.RTL_Average_AUM__c = result.RTL_Average_AUM__c;
                    dataField.TTB_Touch_Flag = result.TTB_Touch_Flag;
                    
                } else if(result.oscResponse.StatusCode == '401' && round < numberOfRetry) {
                    round += 1;
                    if(result.TTB_Touch_Flag.isAccessible) {
                        result.TTB_Touch_Flag.value = 'Error getting data, retrying... ('+round+')';
                    }

                    if(result.RTL_Average_AUM__c.isAccessible) {
                        result.RTL_Average_AUM__c.value = 'Error getting data, retrying... ('+round+')';
                        result.RTL_Average_AUM__c.type = 'STRING';
                    }

                    if(result.RTL_Privilege1__c.isAccessible) {
                        result.RTL_Privilege1__c.value = 'Error getting data, retrying... ('+round+')';
                    }

                    dataField.TTB_Touch_Flag = result.TTB_Touch_Flag;
                    dataField.RTL_Average_AUM__c = result.RTL_Average_AUM__c;
                    dataField.RTL_Privilege1__c = result.RTL_Privilege1__c;
                    component.set('v.round', round);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.getCVSAnalyticsData(component,event,helper);
                        }), retrySetTimeOut
                    );
                } else{
                    result.TTB_Touch_Flag.value = 'Error getting data';
                    result.TTB_Touch_Flag.class = 'redErrorFontColor';
                    result.RTL_Average_AUM__c.value = 'Error getting data';
                    result.RTL_Average_AUM__c.class = 'redErrorFontColor';
                    result.RTL_Average_AUM__c.type = 'STRING';
                    result.RTL_Privilege1__c.value = 'Error getting data';
                    result.RTL_Privilege1__c.class = 'redErrorFontColor';
                    dataField.RTL_Average_AUM__c = result.RTL_Average_AUM__c;
                    dataField.RTL_Privilege1__c = result.RTL_Privilege1__c;
                    dataField.TTB_Touch_Flag = result.TTB_Touch_Flag;
                }
                component.set('v.dataFields', dataField);

            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        // if (component.get('v.account.TMB_Customer_ID_PE__c').value)
        $A.enqueueAction(action);
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
    getSegmentCodition : function(component,event,helper,objectInfoField){
        //get from custom metadata type
        var action = component.get("c.getSetUpFormat");
        action.setParams({"formatName":"segment_coloring"});
        action.setCallback(this,function(response){
            var retReult = JSON.parse( response.getReturnValue() );
            // var vField = component.get('v.fields');
            var dataField = component.get('v.dataFields');
            var param2 = objectInfoField.Segment_crm__c != undefined && objectInfoField.Segment_crm__c.value != ""? objectInfoField.Segment_crm__c.value : "";
            var param3 = objectInfoField.RTL_Privilege1__c != undefined && objectInfoField.RTL_Privilege1__c.value != "" ? objectInfoField.RTL_Privilege1__c.value.substr(0,2) :  "";
            var cssClass = '';
            var state = response.getState();

            for(var i in retReult.Condition){
                if( retReult.Condition[i].Segment_crm__c == param2 ){
                    if( retReult.Condition[i].RTL_Privilege1__c.length > 0 ){
                        if( retReult.Condition[i].RTL_Privilege1__c.indexOf( param3) >= 0 ){
                            cssClass = retReult.Condition[i].class;
                            break;
                        }
                        // else do notting
                    }else{ // there are not check Privilege1
                         cssClass = retReult.Condition[i].class;
                        break;
                    }
                }
            }

            dataField.Core_Banking_Suggested_Segment__c.class = cssClass;
            component.set('v.dataFields', dataField);            

        });
        $A.enqueueAction(action);
    },

    getSubDebtTransaction : function(component,helper){
        var action = component.get('c.getSubDebtTransaction');
        action.setParams({
            "accountId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var dataFields = component.get('v.dataFields');
                dataFields.subDebtTran = response.getReturnValue();
                component.set('v.dataFields',dataFields);
                
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    getSubSegmentData : function(component, event, helper){
        var dataField = component.get('v.dataFields');
        if(dataField.Core_Banking_Suggested_Segment__c.isAccessible) {
            var action = component.get('c.getSubSegmentDesc');
            action.setParams({
                "recordId" : component.get('v.recordId'),
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
    
                    var subSegmentDesc = response.getReturnValue();  
                    
                    dataField.Core_Banking_Suggested_Segment__c.value +=  (subSegmentDesc ? '/ ' + subSegmentDesc : '');
    
                    component.set('v.dataFields', dataField);
                } else {
                    var errors = response.getError();
                    errors.forEach(error => console.log(error.message));
                    helper.stopSpinner(component);
                }
            });
            $A.enqueueAction(action);    
        }
        
    },
})