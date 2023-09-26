({
    onInit : function(cmp, event, helper) {
        
        var isEdit = false;
        var uid = '1';
        var LeadName = 'Product Summary';
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__LeadConvertComercial"
                    },
                    "state": {
                        "uid": uid,
                        "c__recordId": cmp.get("v.recordId"),
                        "c__mode": isEdit
                    }
                }
            }).then(function(subtabId) {
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: "standard:default",
                    iconAlt: "Lead",
                });
                if(isEdit){
                    workspaceAPI.setTabLabel({
                        tabId: subtabId,
                        label: "Convert Lead"
                    });
                    cmp.find("overlayLib").notifyClose();
                }
              
                if(!isEdit){
                    workspaceAPI.setTabLabel({
                        tabId: subtabId,
                        label: LeadName
                    });
                    workspaceAPI.getAllTabInfo().then(function(response) {
                        console.log(JSON.parse(JSON.stringify(response)));
                        for(var i=0; i<response.length; i++){
                            if(response[i].focused){
                                for(var j=0; j<response[i].subtabs.length; j++){
                                    if(!response[i].subtabs[j].focused && response[i].subtabs[j].pageReference.attributes.name == 'c:LeadConvertComercialContainer'){
                                        workspaceAPI.closeTab({tabId: response[i].subtabs[j].tabId});
                                    }
                                }
                            }
                        }
                   })
                }
            }).catch(function(error) {
                console.log(error);
            });
        });
    },

    
    
})