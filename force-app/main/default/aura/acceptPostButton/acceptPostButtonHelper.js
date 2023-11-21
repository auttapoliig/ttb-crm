({
    showToast : function(component, event, helper,type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    refreshFocusedTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: false
            });
        })
    },
    closeSubtab: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})