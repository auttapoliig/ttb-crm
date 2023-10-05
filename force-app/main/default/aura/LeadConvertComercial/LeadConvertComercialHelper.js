({
    init: function(cmp, isOpenCrossSell, isfetchCrossSell){
        cmp.set("v.activeSpinner", true);
        cmp.set("v.isError", false);
        // console.log('RecordId : ' + cmp.get("v.recordId"));
        var action = cmp.get('c.getInitInfo');
        action.setParams({
            leadId: cmp.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var rtnValue = response.getReturnValue();
                // console.log('Init:',rtnValue);
                if(!isfetchCrossSell){
                    cmp.set("v.contactStatusPicklist", rtnValue.contactStatusPicklist);
                    cmp.set("v.uncontactReasonPicklist", rtnValue.uncontactReasonPicklist);
                    cmp.set("v.offerResultPicklist", rtnValue.offerResultPicklist);
                    cmp.set("v.unqualReasonPicklist", rtnValue.unqualReasonPicklist);
                    cmp.set("v.subUnqualReasonPicklist", rtnValue.subUnqualReasonPicklist);
                }
                var hasInterested = false;
                if(rtnValue.isCommercialAcc){
                    cmp.set("v.isCommercialAcc",true);
                }
                if(rtnValue.leadInfo.Status == 'Passed Prescreening'){
                    rtnValue.leadInfo.Status = 'Contacted';
                }
                var mode = cmp.get("v.isEdit");
                if(!isfetchCrossSell){
                    rtnValue.campaignProducts.forEach(product => {
                        product = this.setProductPicklistByValue(product, rtnValue.unqualReasonPicklist, rtnValue.subUnqualReasonPicklist,mode);
                        if(this.isNotBlank(product['Opportunity__c'])){
                            product['Opportunity'] = {
                                Id: product['Opportunity__c'],
                                Name: product['Opportunity__r']['Name']
                            }
                        }
                        if(product.COM_Offer_Result__c === 'Interested'){
                            hasInterested = true;
                        }
                    });
                }else{
                    var campaignProducts = cmp.get("v.campaignProducts");
                    campaignProducts.forEach(item => {
                        if(item['COM_Offer_Result__c'] == 'Interested'){
                            hasInterested = true;
                        }
                    });
                }

                rtnValue.crossSellProducts.forEach(product => {
                    product = this.setProductPicklistByValue(product, rtnValue.crossSellProducts, rtnValue.subUnqualReasonPicklist,mode);
                    if(this.isNotBlank(product['Opportunity__c'])){
                        product['Opportunity'] = {
                            Id: product['Opportunity__c'],
                            Name: product['Opportunity__r']['Name']
                        }
                    }
                    if(product.COM_Offer_Result__c == 'Interested'){
                        hasInterested = true;
                    }
                });
                if(!isfetchCrossSell){
                    cmp.set("v.campaignProducts", rtnValue.campaignProducts);
                }
                cmp.set("v.crossSellProducts", rtnValue.crossSellProducts);
                cmp.set("v.requiredExpectedDate", hasInterested);

                var isCanEditOfferResult = false;
                if(rtnValue.leadInfo.Status == 'Contact' || rtnValue.leadInfo.Status == 'Contacted' || rtnValue.leadInfo.Status == 'Call Back')
                {
                    isCanEditOfferResult = false;
                }else{
                    isCanEditOfferResult = true;
                }
                if(rtnValue.leadInfo.Status == 'Contact' || rtnValue.leadInfo.Status == 'Contacted'){
                    cmp.set("v.requireOfferResult",true);
                }
                cmp.set("v.isCanEditOfferResult", isCanEditOfferResult);

                var convertToOpptyList = ['None','Yes','No'];
                var covertPicklist = [];
                convertToOpptyList.forEach(value => {
                    var item = {
                        "label": value,
                        "value": value
                    };
                    covertPicklist.push(item);              
                }); 

                cmp.set("v.covertPicklist", covertPicklist);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        if(!isfetchCrossSell){
                            cmp.set("v.leadInfo", rtnValue.leadInfo);
                        }
                        if(isOpenCrossSell){
                            cmp.set("v.isEditCrossSell", false);
                            cmp.set("v.selectedCrossSellId", null);
                            cmp.set("v.activeCrossSellModal", true);
                            $A.util.addClass(cmp.find("backdrop"), 'slds-backdrop_open');
                            $A.util.addClass(cmp.find("crossSellModal"), 'slds-fade-in-open');
                        }
                    })
                )
                cmp.set("v.activeSpinner", false);
            }
            else if(state === 'ERROR'){
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
                cmp.set("v.activeSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    setProductPicklistByValue : function(product, unqualReasonPicklist, subUnqualReasonPicklist, mode) {
        if(this.isNotBlank(unqualReasonPicklist[product.COM_Offer_Result__c]) && unqualReasonPicklist[product.COM_Offer_Result__c].length > 0){
            product['unqualifiedReasonPicklist'] = unqualReasonPicklist[product.COM_Offer_Result__c];
            if(this.isNotBlank(product.COM_Unqualified_Reason__c)){
                product['subUnqualifiedReasonPicklist'] = subUnqualReasonPicklist[product.COM_Offer_Result__c + product.COM_Unqualified_Reason__c];
                if(this.isNotBlank(product['subUnqualifiedReasonPicklist']) && product['subUnqualifiedReasonPicklist'].length > 0){
                    if(mode){
                        product['COM_Sub_Unqualified_Reason__c'] = product['subUnqualifiedReasonPicklist'][0];
                    }
                }
            }
            else{
                product['COM_Unqualified_Reason__c'] = unqualReasonPicklist[product.COM_Offer_Result__c][0];
                product['subUnqualifiedReasonPicklist'] = subUnqualReasonPicklist[product.COM_Offer_Result__c + product.COM_Unqualified_Reason__c];
                if(this.isNotBlank(product['subUnqualifiedReasonPicklist']) && product['subUnqualifiedReasonPicklist'].length > 0){
                    if(mode){
                        product['COM_Sub_Unqualified_Reason__c'] = product['subUnqualifiedReasonPicklist'][0];
                    }
                }
            }
        }
        return product;
    },

    validateLead: function(cmp){
        cmp.set("v.activeSpinner", true);
        // console.log('leadInfo:',JSON.stringify(cmp.get("v.leadInfo")));
        var action = cmp.get("c.checkLead");
        action.setParams({ 
            leadId: cmp.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                // console.log('result:',rtnValue);
                if(rtnValue != null)
                {
                    if(!rtnValue.success && rtnValue.type == 'error') 
                    {    
                        var errorList = rtnValue.message.split('\n');
                        cmp.set("v.isError", true);
                        //cmp.set("v.error", rtnValue.message);
                        cmp.set("v.errorList", errorList);
                        // console.log(JSON.stringify(errorList))
                    } 
                    else
                    {
                        cmp.set("v.isAllowedToConvert",true);
                    } 
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
    validateLogACall: function(cmp,status){
        var action = cmp.get("c.checkLogaCall");
        action.setParams({ 
            leadId: cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                var errorlist = cmp.get("v.errorList");
                if((status == 'Contact' || status == 'Contacted') && rtnValue != null){
                        cmp.set("v.isError", true);
                        cmp.set("v.isAllowedToConvert", false);
                        if(!errorlist.includes(rtnValue)){
                            errorlist.push(rtnValue);
                        }
                        cmp.set("v.errorList", errorlist);
                }else{
                    errorlist = errorlist.filter(e => e !== rtnValue);
                    cmp.set("v.errorList", errorlist);
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
        });

        $A.enqueueAction(action);
    },
    save: function(cmp, isConvert){
        cmp.set("v.activeSpinner", true);
        var campaignProducts = cmp.get("v.campaignProducts");
        var crossSellProducts = cmp.get("v.crossSellProducts");
        campaignProducts.forEach(item => {
            if(this.isNotBlank(item['Opportunity'])){
                item['Opportunity__c'] = item['Opportunity'].Id;
            }
            delete item['Opportunity'];
            delete item['unqualifiedReasonPicklist'];
            delete item['subUnqualifiedReasonPicklist'];
        })
        crossSellProducts.forEach(item => {
            if(this.isNotBlank(item['Opportunity'])){
                item['Opportunity__c'] = item['Opportunity'].Id;
            }
            delete item['Opportunity'];
            delete item['unqualifiedReasonPicklist'];
            delete item['subUnqualifiedReasonPicklist'];
        })
        var infoWrapper = {
            leadInfo: cmp.get("v.leadInfo"),
            campaignProducts: campaignProducts,
            crossSellProducts: crossSellProducts
        }
        // console.log('infoWrapper:',infoWrapper);
        var action = cmp.get("c.saveForm");
        action.setParams({ 
            leadId : cmp.get("v.recordId"),
            infoWrapper : JSON.stringify(infoWrapper)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.init(cmp, false);
                if(isConvert){
                    this.convert(cmp);
                }
                else
                {
                    // if(response.getReturnValue() == true){
                        // console.log('Close Tab!')
                        //refresh tab
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": cmp.get("v.recordId")
                        });
                        navEvt.fire();
                        this.closeFocusedTab(cmp);

                    // }
                    cmp.set("v.activeSpinner", false);
                    
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
                cmp.set("v.activeSpinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    convert: function(cmp){
        cmp.set("v.activeSpinner", true);
        var campaignProducts = cmp.get("v.campaignProducts");
        var crossSellProducts = cmp.get("v.crossSellProducts");
        campaignProducts.forEach(item => {
            if(this.isNotBlank(item['Opportunity'])){
                item['Opportunity__c'] = item['Opportunity'].Id;
            }
            delete item['Opportunity'];
            delete item['unqualifiedReasonPicklist'];
            delete item['subUnqualifiedReasonPicklist'];
        })
        crossSellProducts.forEach(item => {
            if(this.isNotBlank(item['Opportunity'])){
                item['Opportunity__c'] = item['Opportunity'].Id;
            }
            delete item['Opportunity'];
            delete item['unqualifiedReasonPicklist'];
            delete item['subUnqualifiedReasonPicklist'];
        })
        // console.log(cmp.get("v.surveyId"));
        var action = cmp.get("c.convertLead");
        action.setParams({ 
            leadId : cmp.get("v.recordId"),
            surveyId : cmp.get("v.surveyId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                // console.log('rtnValue:',rtnValue);
                if(rtnValue.success){
                    this.closeFocusedTab(cmp);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": rtnValue.accountId
                    });
                    navEvt.fire();              
                }
                else{
                    if(rtnValue.type === 'redirect'){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": cmp.get("v.recordId")
                        });
                        navEvt.fire();
                    }
                    else{
                        cmp.set("v.error", rtnValue.message);
                        cmp.set("v.isError", true);
                    }
                    cmp.set("v.activeSpinner", false);
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
                cmp.set("v.activeSpinner", false);
            }         
        });

        $A.enqueueAction(action);
    },

    validateBeforeSave: function(cmp){
        var inputs = cmp.find('validate_input');
        var campaignProducts = cmp.get("v.campaignProducts");
        var crossSellProducts = cmp.get("v.crossSellProducts");
        // console.log('campaignProducts ----->' + JSON.stringify(campaignProducts));
        var errMsg = '';
        var leadInfo = cmp.get("v.leadInfo");
        if(leadInfo.Status == 'Contacted'){
        campaignProducts.forEach(item => {
            // console.log('COM_Offer_Result__c  ----->' + item['COM_Offer_Result__c']);
            if (item['COM_Offer_Result__c'] == 'Interested') {
                //errMsg += 'Please select offer result for ' + item['Product__r'].Name + '\n';
                cmp.set("v.containInterest",true);
            }
            if (item['COM_Offer_Result__c'] == 'None') {
                errMsg = 'Please Enter Offer Result If Contact Status is Contacted';
            }
        })
        crossSellProducts.forEach(item => {
            // console.log('COM_Offer_Result__c  ----->' + item['COM_Offer_Result__c']);
            if (item['COM_Offer_Result__c'] == 'Interested') {
                //errMsg += 'Please select offer result for ' + item['Product__r'].Name + '\n';
                cmp.set("v.containInterest",true);
                }
             })
            }

        if (errMsg != '') {
            cmp.set("v.isError", true);
            cmp.set("v.error", errMsg);
            return false;
        }

        if(inputs !== null && inputs !== undefined){
            var allValid = cmp.find('validate_input').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        }
        else{
            var allValid = true;
        }
        if (allValid) {
            return true;
        } else {
            cmp.set("v.isError", true);
            cmp.set("v.error", 'Please check invalid input and try again later.');
            return false;
        }
    },

    validateBeforeConvert: function(cmp){
        var allValid = true;
        var leadInfo = cmp.get("v.leadInfo");
        // console.log('leadInfo:',JSON.stringify(leadInfo));
        if(leadInfo.Status != 'Contact' && leadInfo.Status != 'Contacted'){
            allValid = false;
            cmp.set("v.isError", true);
            cmp.set("v.error", 'Contact Status must be equal to "Contact".');
        }
        return allValid;
    },
    validateproduct: function(cmp){
        var campaignProducts = cmp.get("v.campaignProducts");
        // console.log('length : ' + campaignProducts.length);
        if( campaignProducts.length > 0){
            return true;
        }else{
            return false;
        }
    },
    isNotBlank: function(value){
        if(value !== null && value !== undefined && value !== ''){
            return true;
        }
        return false;
    },

    isBlank: function(value){
        if(value === null || value === undefined || value === ''){
            return true;
        }
        return false;
    },
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                        tabId: focusedTabId,
                        includeAllSubtabs: true
                });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    closeFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        }).then(function(response){
            $A.get('e.force:refreshView').fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
})