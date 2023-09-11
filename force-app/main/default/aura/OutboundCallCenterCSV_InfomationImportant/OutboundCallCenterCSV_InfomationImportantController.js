({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields', [
            'Customer_Type__c',
            'RTL_Relationship_Duration_Years__c',
            'RTL_Privilege1__c',
            'RTL_Most_Operating_Branch__c',
            'RTL_Number_of_Benefit__c',
            'RTL_Assigned_BRC__c',
            'RTL_AUM__c',
            'RTL_Wealth_RM__c',
            'RTL_Benefit_Validity_Period__c',
            'RTL_WA_Name__c',
            'RTL_Average_AUM__c',
            'RTL_Commercial_RM__c',
            'RTL_Calculated_WB_PB_Amount__c',
            'FATCA__c',
            'Core_Banking_Suggested_Segment__c',
            'Sub_segment__c',
            'RTL_AUM_Last_Calculated_Date__c',
            'TMB_Customer_ID_PE__c',
            'RTL_Benefit_Status__c',
            'RTL_WA_Emp_ID__c',
            'Wealth_RM_EMP_Code__c',
            'RTL_Commercial_RM_Emp_ID__c',
            'RTL_PB_Customer__c',
            'RTL_WB_Customer__c',
            'RTL_BRC_Type__c',
            'RTL_BRC_Updated_Date__c',
            'RTL_Check_WM_RM_as_PWA__c',
        ]);

        helper.getDescribeFieldResult(component, event, helper);
        helper.getProfileName(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },

    handleRefreshfield: function (component, event, helper) {
        var recordId = event.getParam('recordId');
        var fieldUpdate = event.getParam('fieldUpdate');
        var dataFields = component.get('v.dataFields');
        var currRecordId = component.get('v.recordId');
        if (fieldUpdate && currRecordId && recordId == currRecordId.substring(0,15)) {
            helper.startSpinner(component);
            Object.keys(fieldUpdate).forEach(fieldName => {
                if (dataFields[fieldName] && dataFields[fieldName].value != fieldUpdate[fieldName]) {
                    dataFields[fieldName].value = fieldUpdate[fieldName];
                }
            });
            component.set('v.dataFields',dataFields);
            helper.stopSpinner(component);
        }
    },
})