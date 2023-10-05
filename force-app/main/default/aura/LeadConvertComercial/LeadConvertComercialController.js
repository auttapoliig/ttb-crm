({
    onInit : function(cmp, event, helper) {
        var stateRef = cmp.get("v.pageReference").state;
        cmp.set("v.recordId", stateRef.c__recordId);
        var surveyId = stateRef.c__surveyId ? stateRef.c__surveyId : '';
        if(surveyId != ''){
            // console.log('surveyId' + surveyId);
            cmp.set("v.surveyId",surveyId);
        }
        if(stateRef.c__mode == 'false' || stateRef.c__mode == false){
            cmp.set("v.isEdit",false);
            cmp.set("v.isCanEditOfferResult", true);     
        }   
        helper.init(cmp, false, false);  
        if(stateRef.c__mode != 'false' && stateRef.c__mode != false){
            helper.validateLead(cmp);    
        }   
    },

    save : function(cmp, event, helper) {
        cmp.set("v.isError", false);
        var isValidate = false;
        var leadInfo = cmp.get("v.leadInfo");
        // console.log('Status : ' + leadInfo.Status);
        // if(leadInfo.Status == 'Contacted'){
        //     if(helper.validateLogACall(cmp) && helper.validateproduct(cmp)){
        //         isValidate = true;
        //     }
        // }else{
        //     isValidate = true;
        // }
        // if(isValidate){
            if(helper.validateBeforeSave(cmp)){
                var campaignProducts = cmp.get("v.campaignProducts");
                // console.log(JSON.stringify(campaignProducts));
                if(cmp.get("v.containInterest")){
                    helper.save(cmp, true);
                }else{
                    helper.save(cmp, false);
                }
            }
        // }
    },

    // validateLead : function(cmp, event, helper) {
    //     cmp.set("v.isError", false);
    //     var leadInfo = cmp.get("v.leadInfo");
    //     if(leadInfo.Interest_Result__c == 'Yes'){
    //         helper.validateLead(cmp);
    //     }
    //     else if(leadInfo.Interest_Result__c == 'None' || leadInfo.Interest_Result__c == null)
    //     {
    //         var covertOppty = cmp.find('covertOppty');

    //         $A.util.addClass(covertOppty, "slds-has-error");

    //         cmp.set("v.isError", true);
    //         //var error = ['Convert to Opportunity: You must enter a value'];
    //         cmp.set("v.errorList", 'Convert to Opportunity: You must enter a value');
    //     }
    // },

    convert : function(cmp, event, helper) {
        cmp.set("v.isError", false);
        if(helper.validateBeforeSave(cmp) && helper.validateBeforeConvert(cmp)){
            helper.save(cmp, true);
        }
    },

    closeFocusedTab : function(cmp, event, helper) {
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    handleToggle: function (cmp, event, helper) {
        cmp.set('v.activeSectionName', ['A', 'B', 'C']);
    },

    openNewSubTab : function(cmp, event, helper) {
        var address = event.srcElement.name;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": address
        });
        navEvt.fire();
    },

    onchangeContactStatus : function(cmp, event, helper) {
        var leadInfo = cmp.get("v.leadInfo");
        var isCanEditOfferResult = true;
        var campaignProducts = cmp.get("v.campaignProducts");
        var crossSellProducts = cmp.get("v.crossSellProducts");
        var requiredExpectedDate = false;
        if(leadInfo.Status == 'Contact' || leadInfo.Status == 'Contacted'){
            cmp.set("v.requireOfferResult",true);
        }else{
            cmp.set("v.requireOfferResult",false);
        }
        if(leadInfo.Status == 'Contact' || leadInfo.Status == 'Contacted' || leadInfo.Status == 'Call Back')
        {
            isCanEditOfferResult = false;
        }else{
            campaignProducts.forEach(item => {
                item['COM_Offer_Result__c'] = 'None';
                item['COM_Other_Reason__c'] = '';
            })
        }

        if(leadInfo.Status !== 'Uncontact'){
            leadInfo.RTL_Uncontact_reason__c = null;
        }
        else{
            var uncontactReasonPicklist = cmp.get("v.uncontactReasonPicklist");
            if(helper.isNotBlank(uncontactReasonPicklist) && uncontactReasonPicklist.length > 0){
                leadInfo.RTL_Uncontact_reason__c = uncontactReasonPicklist[0].value;
            }
        }

        helper.validateLogACall(cmp,leadInfo.Status);
        var errorlist = cmp.get("v.errorList");
        var errmsg = 'Lead must have at least 1 recommended product. (โปรดระบุ Product ที่ลูกค้าสนใจ อย่างน้อย 1 Product)';
        if((leadInfo.Status == 'Contact' || leadInfo.Status == 'Contacted') && (campaignProducts.length == 0 && crossSellProducts.length == 0)){
                cmp.set("v.isError", true);
                cmp.set("v.isAllowedToConvert", false);
                errorlist.push(errmsg);
                cmp.set("v.errorList", errorlist);
        }else{
            errorlist = errorlist.filter(e => e !== errmsg);
            cmp.set("v.errorList", errorlist);
        }
        if((leadInfo.Status != 'Contact' && leadInfo.Status != 'Contacted')){
            cmp.set("v.isError", false);
            cmp.set("v.isAllowedToConvert", true);
        }
        if((leadInfo.Status == 'Contacted' || leadInfo.Status == 'Call Back') && crossSellProducts.length != 0){
            requiredExpectedDate = true;
        }
        cmp.set("v.requiredExpectedDate", requiredExpectedDate);
        cmp.set("v.leadInfo", leadInfo);
        cmp.set("v.campaignProducts", campaignProducts);
        cmp.set("v.isCanEditOfferResult", isCanEditOfferResult);


    },

    onChangeCampaignOfferResult : function(cmp, event, helper) {
        var crossSellProducts = cmp.get("v.crossSellProducts");
        var productId = event.getSource().get("v.name");
        var products = cmp.get("v.campaignProducts");
        var unqualReasonPicklist = cmp.get("v.unqualReasonPicklist");
        var subUnqualReasonPicklist = cmp.get("v.subUnqualReasonPicklist");
        var requiredExpectedDate = false;
        var mode = cmp.get("v.isEdit");
        products.forEach(product => {
            // console.log('products:',products);
            if(product.Id === productId){
                product['COM_Unqualified_Reason__c'] = null;
                product['COM_Sub_Unqualified_Reason__c'] = null;
                product['unqualifiedReasonPicklist'] = [];
                product['subUnqualifiedReasonPicklist'] = [];
                // console.log('onChangeCampaignOfferResult :: Set product value for ' + product['Name'])
                product = helper.setProductPicklistByValue(product, unqualReasonPicklist, subUnqualReasonPicklist,mode);
            }
            if(product.COM_Offer_Result__c == 'Interested')
            {
                requiredExpectedDate = true;
            }
        })

        cmp.set("v.campaignProducts", products);
        // console.log('CrossSell length ' + (crossSellProducts.length));
        if(crossSellProducts.length == 0){
            cmp.set("v.requiredExpectedDate", requiredExpectedDate);
        }
    },

    onChangeCampaignUnqualReason : function(cmp, event, helper) {
        var productId = event.getSource().get("v.name");
        var products = cmp.get("v.campaignProducts");
        var unqualReasonPicklist = cmp.get("v.unqualReasonPicklist");
        var subUnqualReasonPicklist = cmp.get("v.subUnqualReasonPicklist");
        var mode = cmp.get("v.isEdit");

        products.forEach(product => {
            if(product.Id === productId){
                product['COM_Sub_Unqualified_Reason__c'] = null;
                product['subUnqualifiedReasonPicklist'] = [];
                // console.log('onChangeCampaignUnqualReason :: Set product value for ' + product['Name'])

                product = helper.setProductPicklistByValue(product, unqualReasonPicklist, subUnqualReasonPicklist, mode);
            }
        })
        cmp.set("v.campaignProducts", products);
    },

    addCrossSellProduct : function(cmp, event, helper) {
        cmp.set("v.isEditCrossSell", false);
        cmp.set("v.selectedCrossSellId", null);
        cmp.set("v.activeCrossSellModal", true);
        var leadInfo = cmp.get("v.leadInfo");
        if(leadInfo.Status == 'Contacted'){
            cmp.set("v.requiredExpectedDate", true);
        }
        $A.util.addClass(cmp.find("backdrop"), 'slds-backdrop_open');
        $A.util.addClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
    },

    editCrossSellProduct : function(cmp, event, helper) {
        var productId = event.srcElement.name;
        cmp.set("v.isEditCrossSell", true);
        cmp.set("v.selectedCrossSellId", productId);
        cmp.set("v.activeCrossSellModal", true);
        $A.util.addClass(cmp.find("backdrop"), 'slds-backdrop_open');
        $A.util.addClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
    },

    handleSaveCrossSell : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("backdrop"), 'slds-backdrop_open');
        cmp.set("v.activeCrossSellModal", false);
        helper.init(cmp, false, true);
    },

    handleSaveAndNewCrossSell : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("backdrop"), 'slds-backdrop_open');
        cmp.set("v.activeCrossSellModal", false);
        helper.init(cmp, true, true);
    },

    handleCloseCrossSellModal : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("backdrop"), 'slds-backdrop_open');
        cmp.set("v.activeCrossSellModal", false);
    },

    onChangeIntResult : function(cmp, event, helper){
        cmp.set("v.isError", false);

        var covertOppty = cmp.find('covertOppty');
        $A.util.removeClass(covertOppty, "slds-has-error"); // remove red border
        $A.util.addClass(covertOppty, "hide-error-message"); 

        var leadInfo = cmp.get('v.leadInfo');
        var intResult = event.getSource().get("v.value");
        leadInfo.Interest_Result__c = intResult;
        cmp.set('v.leadInfo',leadInfo);
        // console.log('leadInfo:',JSON.stringify(leadInfo));

    }
})