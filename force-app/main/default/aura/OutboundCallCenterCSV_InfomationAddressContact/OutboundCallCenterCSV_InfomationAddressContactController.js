({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields', [
            'RTL_Primary_Address__c',
            'RTL_Registered_Address__c',
            'RTL_Office_Address__c',
            'RTL_Alternative_Number__c',
            'C_Home_phone_PE__c',
            'RTL_Office_Phone_Number__c',
            'Fax'
        ]);
        helper.getDescribeFieldResult(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },

    handleRefreshfield: function (component, event, helper) {
        var recordId = event.getParam('recordId');
        var fieldUpdate = event.getParam('fieldUpdate');
        var dataFields = component.get('v.fields');
        var currRecordId = component.get('v.recordId');
        if (fieldUpdate && currRecordId && recordId == currRecordId.substring(0,15)) {
            helper.startSpinner(component);
            Object.keys(fieldUpdate).forEach(fieldName => {
                if (dataFields[fieldName] && dataFields[fieldName].value != fieldUpdate[fieldName]) {
                    dataFields[fieldName].value = fieldUpdate[fieldName];
                }
            });
            component.set('v.fields',dataFields);
            helper.stopSpinner(component);
        }
    },
})