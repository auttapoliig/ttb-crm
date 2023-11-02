({
    onInit : function(component, event, helper) {
        var pageRef = component.get('v.pageReference');
        
        component.set('v.campaignMemberId', pageRef.state.c__campaignMemberId ? pageRef.state.c__campaignMemberId : '');
        component.set('v.leadId', pageRef.state.c__leadId ? pageRef.state.c__leadId : '');
        component.set('v.isLoading', false);
        var proNum = pageRef.state.c__productNumber;
        var CampaignProduct = ['RTL_Campaign_Product_'+proNum+'__c'];
        // var FieldSection = ['RTL_W2L_Co_Borrower_1_Age__c',
        //                      'RTL_W2L_Loan_Request_Type__c',
        //                      'RTL_W2L_Co_Borrower_1_Occupation__c',
        //                      'RTL_W2L_Developer_Name__c',
        //                      'RTL_W2L_Co_Borrower_1_Income__c',
        //                      'RTL_W2L_Source_Collateral_Type__c',
        //                      'RTL_W2L_Co1_Other_Income__c',
        //                      'RTL_W2L_Transfer_Period__c',
        //                      'RTL_W2L_Co1_Income_OT__c',
        //                      'RTL_W2L_Occupation__c',
        //                      'RTL_W2L_Co1_Income_Rental__c',
        //                      'RTL_W2L_Salary__c',
        //                      'RTL_W2L_Co1_Income_Bonus__c',
        //                      'RTL_W2L_Other_Income__c',
        //                      'RTL_W2L_Co1_Percent_Shareholder__c',
        //                      'RTL_W2L_Income_OT__c',
        //                      'RTL_W2L_Co1_Capital__c',
        //                      'RTL_W2L_Income_Rental__c',
        //                      'RTL_W2L_Co1_Car_Loan__c',
        //                      'RTL_W2L_Income_Bonus__c',
        //                      'RTL_W2L_Co1_Personal_Loan__c',
        //                      'RTL_W2L_Percent_Shareholder__c',
        //                      'RTL_W2L_Co1_CC_Loan__c',
        //                      'RTL_W2L_Capital__c',
        //                      'RTL_W2L_Co1_Cash_OD_Loan__c',
        //                      'RTL_W2L_Car_Loan__c',
        //                      'RTL_W2L_Co1_Other_Loan__c',
        //                      'RTL_W2L_Personal_Loan__c',
        //                      'RTL_W2L_Co_Borrower_2_Age__c',
        //                      'RTL_W2L_CC_Loan__c',
        //                      'RTL_W2L_Co_Borrower_2_Occupation__c',
        //                      'RTL_W2L_Cash_OD_Loan__c',
        //                      'RTL_W2L_Co_Borrower_2_Income__c',
        //                      'RTL_W2L_Other_Loan__c',
        //                      'RTL_W2L_Co2_Other_Income__c',
        //                      'RTL_W2L_Buying_Amount__c',
        //                      'RTL_W2L_Co2_Income_OT__c',
        //                      'RTL_W2L_Calculated_Amount__c',
        //                      'RTL_W2L_Co2_Income_Rental__c',
        //                      'RTL_W2L_Calculated_Loan_Period__c',
        //                      'RTL_W2L_Co2_Income_Bonus__c',
        //                      'RTL_W2L_Calculated_No_of_Installments__c',
        //                      'RTL_W2L_Co2_Percent_Shareholder__c',
        //                      'RTL_Email_Address__c',
        //                      'RTL_W2L_Co2_Capital__c',
        //                      'RTL_MORTGAGE_FEE__c',
        //                      'RTL_W2L_Co2_Car_Loan__c',
        //                      'RTL_FIRE_INSURANCE_FEE__c',
        //                      'RTL_W2L_Co2_Personal_Loan__c',
        //                      'RTL_APPRAISAL_FEE__c',
        //                      'RTL_W2L_Co2_CC_Loan__c',
        //                      'RTL_INTERESTS__c',
        //                      'RTL_W2L_Co2_Cash_OD_Loan__c',
        //                      'RTL_W2L_Has_Co_Borrower_Text__c',
        //                      'RTL_W2L_Co2_Other_Loan__c'];

        var FieldSection = ['RTL_W2L_Occupation__c',
                            'RTL_W2L_Co_Borrower_1_Age__c',
                            'RTL_W2L_Salary__c',
                            'RTL_W2L_Co_Borrower_1_Occupation__c',
                            'RTL_W2L_Calculated_Amount__c',
                            'RTL_W2L_Co_Borrower_1_Income__c',
                            'RTL_W2L_Source_Collateral_Type__c',
                            'RTL_W2L_Co1_Other_Income__c',
                            'RTL_W2L_Loan_Request_Type__c',
                            'RTL_W2L_Co1_Income_OT__c',
                            'RTL_W2L_Developer_Name__c',
                            'RTL_W2L_Co1_Income_Rental__c',
                            'RTL_W2L_Transfer_Period__c',
                            'RTL_W2L_Co1_Income_Bonus__c',
                            'RTL_W2L_Other_Income__c',
                            'RTL_W2L_Co1_Percent_Shareholder__c',
                            'RTL_W2L_Income_OT__c',
                            'RTL_W2L_Co1_Capital__c',
                            'RTL_W2L_Income_Rental__c',
                            'RTL_W2L_Co1_Car_Loan__c',
                            'RTL_W2L_Income_Bonus__c',
                            'RTL_W2L_Co1_Personal_Loan__c',
                            'RTL_W2L_Percent_Shareholder__c',
                            'RTL_W2L_Co1_CC_Loan__c',
                            'RTL_W2L_Capital__c',
                            'RTL_W2L_Co1_Cash_OD_Loan__c',
                            'RTL_W2L_Car_Loan__c',
                            'RTL_W2L_Co1_Other_Loan__c',
                            'RTL_W2L_Personal_Loan__c',
                            'RTL_W2L_Co_Borrower_2_Age__c',
                            'RTL_W2L_CC_Loan__c',
                            'RTL_W2L_Co_Borrower_2_Occupation__c',
                            'RTL_W2L_Cash_OD_Loan__c',
                            'RTL_W2L_Co_Borrower_2_Income__c',
                            'RTL_W2L_Other_Loan__c',
                            'RTL_W2L_Co2_Other_Income__c',
                            'RTL_W2L_Buying_Amount__c',
                            'RTL_W2L_Co2_Income_OT__c',
                            'RTL_W2L_Calculated_Loan_Period__c',
                            'RTL_W2L_Co2_Income_Rental__c',
                            'RTL_W2L_Calculated_No_of_Installments__c',
                            'RTL_W2L_Co2_Income_Bonus__c',
                            'RTL_Email_Address__c',
                            'RTL_W2L_Co2_Percent_Shareholder__c',
                            'RTL_MORTGAGE_FEE__c',
                            'RTL_W2L_Co2_Capital__c',
                            'RTL_FIRE_INSURANCE_FEE__c',
                            'RTL_W2L_Co2_Car_Loan__c',
                            'RTL_APPRAISAL_FEE__c',
                            'RTL_W2L_Co2_Personal_Loan__c',
                            'RTL_INTERESTS__c',
                            'RTL_W2L_Co2_CC_Loan__c',
                            'RTL_W2L_Has_Co_Borrower_Text__c',
                            'RTL_W2L_Co2_Cash_OD_Loan__c',
                            'RTL_W2L_Co2_Other_Loan__c'];
        component.set('v.fields',FieldSection);
        component.set('v.CampaignProduct',CampaignProduct);

        helper.setTabDetail(component, event, helper);
    },
    
    close : function(component){
        var workspaceAPI = component.find('workspace');
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})