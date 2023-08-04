({
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    getDescribeFieldResult: function (component, event, helper) {
        
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields'),
            "fields_translate": []
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                helper.generateField(component, objectInfoField,helper);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    generateField : function(component,objectInfoField,helper) {
        let result = objectInfoField;
        let fields = component.get('v.fields');
        for (const i of fields){
            result[i].isAccessible = result[i].isAccessible? result[i].isAccessible : false ;
            result[i].type = result[i].type;
            result[i].label = result[i].label;
            result[i].value = result[i].value ? result[i].value : '';
            result[i].inlineHelpText = result[i].inlineHelpText ? result[i].inlineHelpText : '';

            if (result[i].isAccessible == false){
                result[i].type = 'STRING';
            };
        };
        
        /* Customer_Type__c */
        result['Customer_Type__c'].label += ' / ' + result['Core_Banking_Suggested_Segment__c'].label + ' (' + result['Sub_segment__c'].label +')';
        if (result['Customer_Type__c'].isAccessible == true){
            result['Customer_Type__c'].value = result['Customer_Type__c'].value ? result['Customer_Type__c'].value  : '-';
            result['Customer_Type__c'].value += ' / ';
            result['Customer_Type__c'].value += result['Core_Banking_Suggested_Segment__c'].value ? result['Core_Banking_Suggested_Segment__c'].value : '-';
            helper.getSubSegmentData(component, helper,result);
        };

        /* RTL_Privilege1__c */
        result['RTL_Privilege1__c'].label += ' / ' + result['RTL_Benefit_Status__c'].label;
        if (result['RTL_Privilege1__c'].isAccessible == true){
            result['RTL_Privilege1__c'].value = result['RTL_Privilege1__c'].value ? result['RTL_Privilege1__c'].value :'-';
            result['RTL_Privilege1__c'].value += ' / ';
            result['RTL_Privilege1__c'].value += result['RTL_Benefit_Status__c'].value ? result['RTL_Benefit_Status__c'].value : (result['RTL_Privilege1__c'].value ? 'ไม่ได้รับสิทธิประโยชน์' :'-');
        };

        /* RTL_Most_Operating_Branch__c */
        result['RTL_Most_Operating_Branch__c'].label += ' (' + result['RTL_BRC_Type__c'].label + ')';
        if (result['RTL_Most_Operating_Branch__c'].isAccessible == true){
            result['RTL_Most_Operating_Branch__c'].value = result['RTL_Most_Operating_Branch__c'].value ? result['RTL_Most_Operating_Branch__c'].value : '';
            result['RTL_Most_Operating_Branch__c'].value_addon = result['RTL_BRC_Type__c'].value ? result['RTL_BRC_Type__c'].value : '-';
            result['RTL_Most_Operating_Branch__c'].inlineHelpText = result['RTL_BRC_Type__c'].inlineHelpText;
            result['RTL_Most_Operating_Branch__c'].isAccessible = result['RTL_Most_Operating_Branch__c'] ? true : false ;
            result['RTL_Most_Operating_Branch__c'].type = 'REFERENCE_ADDON'
        };

        /* RTL_Assigned_BRC__c */
        result['RTL_Assigned_BRC__c'].label += ' (' + result['RTL_BRC_Updated_Date__c'].label + ')';
        if (result['RTL_Assigned_BRC__c'].isAccessible == true){
            result['RTL_Assigned_BRC__c'].value_addon = result['RTL_BRC_Updated_Date__c'].value ? $A.localizationService.formatDateTime((result['RTL_BRC_Updated_Date__c'].value),'dd/MM/yyyy') : '-';
            result['RTL_Assigned_BRC__c'].inlineHelpText = result['RTL_BRC_Updated_Date__c'].inlineHelpText;
            result['RTL_Assigned_BRC__c'].isAccessible = result['RTL_Assigned_BRC__c'] ? true : false ;
            result['RTL_Assigned_BRC__c'].type = 'REFERENCE_ADDON'
        };

        /* RTL_AUM__c */
        result['RTL_AUM__c'].label = result['RTL_AUM__c'].label + ' (' + result['RTL_AUM_Last_Calculated_Date__c'].label + ')';
        if (result['RTL_AUM__c'].isAccessible == true){
            result['RTL_AUM__c'].value = $A.get("$Locale.currency") + (result['RTL_AUM__c'].value ? result['RTL_AUM__c'].value.toLocaleString('en-US', {
                style: 'decimal',
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }) : '0.00');
            result['RTL_AUM__c'].value += result['RTL_AUM_Last_Calculated_Date__c'].value ? ' [' + $A.localizationService.formatDateTime((result['RTL_AUM_Last_Calculated_Date__c'].value),'dd/MM/yyyy') + ']' : '';
            result['RTL_AUM__c'].type = 'STRING';
        };

        /* RTL_Wealth_RM__c */
        if (result['RTL_Wealth_RM__c'].isAccessible == true){
            result['RTL_Wealth_RM__c'].value_addon = result['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? result['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
            result['RTL_Wealth_RM__c'].value_addon += result['Wealth_RM_EMP_Code__c'].value != 'Undefined' ? result['Wealth_RM_EMP_Code__c'].value : '';
            result['RTL_Wealth_RM__c'].type = 'REFERENCE_ADDON';
        };

        /* RTL_Commercial_RM__c */
        if (result['RTL_Commercial_RM__c'].isAccessible == true){
            result['RTL_Commercial_RM__c'].value_addon = result['RTL_Commercial_RM_Emp_ID__c'].value;
            result['RTL_Commercial_RM__c'].type = 'REFERENCE_ADDON';
        };

        component.set('v.fields',result);
    },
    getSubSegmentData : function(component, helper,result){
        var action = component.get('c.getSubSegmentDesc');
        action.setParams({
            "recordId" : component.get('v.recordId'),
            "profileName" : component.get('v.profileName'),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {

                var subSegmentDesc = response.getReturnValue();  
                result['Customer_Type__c'].value += (subSegmentDesc ? ' (' + subSegmentDesc + ')' : '');
                component.set('v.fields', result);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    getProfileName: function (component, event, helper) {
            var action = component.get('c.getProfileName');
            action.setParams({
                "userId": component.get('v.userId'),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.profileName', result); 
                }
                else if(state === 'ERROR') {
                    console.error('error: getProfileName');
                } else {
                    console.error('Unknown problem, state.');
                }
            });
            $A.enqueueAction(action);
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                // console.log('watermarkHTML: ', watermarkHTML);

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
})