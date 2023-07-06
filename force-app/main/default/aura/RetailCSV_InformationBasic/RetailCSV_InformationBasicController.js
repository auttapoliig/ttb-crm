({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.width', component.get('v.width') ? component.get('v.width').toLowerCase() : '');

        component.set('v.fields', [
            'Fna_Avatar_Image__c',
            'Fna_Avatar_Name__c',
            'Nationality__c',
            'RTL_Marital_Details__c',
            'RTL_Marital_Details__r.Marital_Status_Desc__c',
            'RTL_No_of_Children__c',
            'RTL_Occupation_Details__c',
            'RTL_Occupation_Details__r.RTL_Occupation_Desc__c',
            'RTL_Education_Details__c',
            'RTL_Education_Details__r.RTL_Education_Level_Desc__c',
            'Business_Type_Code__c',
            'Business_Type_Description__c',
            'Payroll__c',
            'RMC_Payroll_Company__c',
            'Safebox_Status__c',
            'RTL_Customer_Reference_Id__c',
        ].map(m => {
            return {
                'fieldName': m
            };
        }));

        // get profile name first
        helper.getProfileName(component);
        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    handleProfileName: function (component, event, helper) {
        helper.runInitialize(component, event, helper);
    }
})