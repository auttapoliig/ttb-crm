({
    upsert : function(cmp, type) {
        cmp.set("v.activeSpinner", true);
        var product = {};
        product['Id'] = cmp.get("v.productId");
        product['Name'] = cmp.find("Name").get("v.value");
        product['Opportunity_Type__c'] = cmp.find("Opportunity_Type__c").get("v.value");
        product['Product__c'] = cmp.find("Product__c").get("v.value");
        product['Amount__c'] = cmp.find("Amount__c").get("v.value");
        product['Lead__c'] = cmp.find("Lead__c").get("v.value");
        product['Opportunity__c'] = cmp.find("Opportunity__c").get("v.value");
        product['Project_Code__c'] = cmp.find("Project_Code__c").get("v.value");
        product['Max_Offer_Amount__c'] = cmp.find("Max_Offer_Amount__c").get("v.value");
        product['Max_Tenor__c'] = cmp.find("Max_Tenor__c").get("v.value");
        product['Max_Tenor_Unit__c'] = cmp.find("Max_Tenor_Unit__c").get("v.value");
        product['Max_Installment__c'] = cmp.find("Max_Installment__c").get("v.value");
        product['Rate__c'] = cmp.find("Rate__c").get("v.value");
        product['Fee__c'] = cmp.find("Fee__c").get("v.value");
        product['Offer_start_date__c'] = cmp.find("Offer_start_date__c").get("v.value");
        product['Offer_end_date__c'] = cmp.find("Offer_end_date__c").get("v.value");
        product['Offer_Last_update_date__c'] = cmp.find("Offer_Last_update_date__c").get("v.value");
        product['Merchant_Unique_ID__c'] = cmp.find("Merchant_Unique_ID__c").get("v.value");
        product['Remark__c'] = cmp.find("Remark__c").get("v.value");
        product['Status__c'] = cmp.find("Status__c").get("v.value");
        product['Request_Amount__c'] = cmp.find("Request_Amount__c").get("v.value");
        product['Request_Fee_Baht__c'] = cmp.find("Request_Fee_Baht__c").get("v.value");
        product['Request_Tenor__c'] = cmp.find("Request_Tenor__c").get("v.value");
        product['Request_Tenor_Unit__c'] = cmp.find("Request_Tenor_Unit__c").get("v.value");
        product['Request_Installment__c'] = cmp.find("Request_Installment__c").get("v.value");
        product['Request_Date__c'] = cmp.find("Request_Date__c").get("v.value");
        product['Request_Last_update_date__c'] = cmp.find("Request_Last_update_date__c").get("v.value");
        product['Cross_Sell__c'] = true;
        product['COM_Offer_Result__c'] = 'Interested';
        var action = cmp.get("c.upsertCrossSellProduct");
        action.setParams({ 
            productJSON : JSON.stringify(product)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if(rtnValue.success){
                    if(type === 'save'){
                        var compEvent = cmp.getEvent("saveEvent");
                        compEvent.fire();
                    }
                    else if(type === 'save & new'){
                        var compEvent = cmp.getEvent("saveAndNewEvent");
                        compEvent.fire();
                    }
                    cmp.set("v.isError", false);
                }
                else{
                    cmp.set("v.isError", true);
                    cmp.set("v.error", rtnValue.message);
                }
            }
            else if (state === "ERROR") {
                cmp.set("v.isError", true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        cmp.set("v.error", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    cmp.set("v.error", 'Something went wrong. Please reload page or try again later.');
                }
            }
            cmp.set("v.activeSpinner", false);
        });

        $A.enqueueAction(action);
    },

    validateInput: function(cmp){
        var allValid = true;
        if(this.isBlank(cmp.find("Opportunity_Type__c").get("v.value"))){
            $A.util.addClass(cmp.find('Opportunity_Type__c'), "slds-has-error");
            allValid = false;
        }
        else{
            $A.util.removeClass(cmp.find('Opportunity_Type__c'), "slds-has-error");
        }
        if(this.isBlank(cmp.find("Product__c").get("v.value"))){
            $A.util.addClass(cmp.find('Product__c'), "slds-has-error");
            allValid = false;
        }
        else{
            $A.util.removeClass(cmp.find('Product__c'), "slds-has-error");
        }
        if(this.isBlank(cmp.find("Lead__c").get("v.value"))){
            $A.util.addClass(cmp.find('Lead__c'), "slds-has-error");
            allValid = false;
        }
        else{
            $A.util.removeClass(cmp.find('Lead__c'), "slds-has-error");
        }
        if(allValid){
            return true;
        }
        return false;
    },

    isBlank: function(value){
        if(value === null || value === undefined || value === '' || value === '--None--'){
            return true;
        }
        return false;
    }
})