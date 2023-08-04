({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.isOSCLoading', true);
        component.set('v.isPDPALoading', true);

        component.set('v.allField', [
            'RTL_Customer_Name_TH__c',
            'Customer_Name_PE_Eng__c',
            'RTL_Gender_View__c',
            'ID_Type_PE__c',
            'NID__c',
            'RTL_CitizenID_Expiration_Date__c',
            'RTL_Date_Of_Birth__c',
            'RTL_Birthday__c',
            'RTL_Zodiac__c',
            'Mobile_Number_PE__c',
            'Email_Address_PE__c',
            'FATCA__c',
            'Account_Type__c',
            'Core_Banking_Suggested_Segment__c',
            'Market_Consent__c',
            'RTL_SBO_FLAG__c',
            'VIP_Status__c',
            'RTL_Wealth_RM__c',
            'TMB_Customer_ID_PE__c',
            'RTL_AUM__c',
            'Payroll__c',
            'RMC_Payroll_Company__c',
            'RTL_Customer_Reference_Id__c',
            'RTL_Do_Not_Contact__c',
            'KYC_Update__c',
            'IAL__c',
            'KYC_flag__c',
            'E_KYC__c',
            'Action_Box__c',
            'Sub_segment__c',
            'RTL_AUM_Last_Calculated_Date__c',
            'RTL_EXIST_NONJU_FLAG__c',
            'RTL_Check_WM_RM_as_PWA__c',
            'Wealth_RM_EMP_Code__c',
            'RTL_Benefit_Status__c',
            'Segment_crm__c',
            'RTL_Primary_Banking_All_Free_Benefit__c',
            'RTL_Main_Bank_Desc__c',
        ].map(m=> {
            return {
                'fieldName': m
            };
        }));

       
        component.set('v.numberOfRetry',$A.get("$Label.c.Number_Of_Retry_Times"));
        component.set('v.retrySetTimeOut',$A.get("$Label.c.Retry_SetTimeOut"));
        component.set('v.round',0);

        // Add field to query account
        // helper.getDescribeFieldResult(component, event, helper);
        helper.getFieldData(component, event, helper);

        // Dynamic custom color field to be green or red
        // if equal value to be ture(green) or not(red)
        component.set('v.customColorField', {
            'FATCA__c': {
                condition: 'equal',
                value: 'ทำ FATCA (complete)',
            }
        });

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    onHandlerAccount: function (component, event, helper) {

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