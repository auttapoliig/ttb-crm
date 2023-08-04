({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        component.set('v.recordId', id);

        component.set('v.fields', ['RTL_Preferred_Contact_Channel__c',
            'RTL_Alternative_Contact_Channel__c',
            'C_Home_phone_PE__c',
            'RTL_Alternative_Number__c',
            'Mobile_Number_PE__c',
            'Email_Address_PE__c',
            'RTL_Office_Phone_Number__c',
            'RTL_Email_2__c',
            'Fax']);
        helper.getInitialData(component);
        helper.getDescribeFieldResultAndValue(component, event, helper);
    },
    updateAccount: function (component, event, helper) {
        helper.startSpinner(component);

        var fieldValueMap = new Map();
        component.get('v.fields').forEach(field => {
            if (component.get(`v.dataFields.${field}.isAccessible`) == true) {
                if (component.get(`v.fieldValueMap.${field}`) != null) {
                    let value = component.get(`v.fieldValueMap.${field}`);
                    fieldValueMap.set(field, value);
                }
            }
        });
        fieldValueMap.set('Id', component.get('v.recordId'));

        helper.updateAccountData(component, fieldValueMap);
    },
    fieldChangeHandle: function (component, event, helper) {
        var fieldName = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');

        var fieldValueMap = component.get('v.fieldValueMap');
        if (fieldName in fieldValueMap && fieldValueMap[fieldName] == value) {
            delete fieldValueMap[fieldName];
        } else {
            fieldValueMap[fieldName] = value;
        }

        component.set('v.fieldValueMap', fieldValueMap);
    },
    onClose: function (component, event, helper) {
        helper.closeTab(component);
    },
})