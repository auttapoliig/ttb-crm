({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } }},
            { label: 'KYC Status', fieldName: 'KYC_flag', type: 'text', cellAttributes: {class: { fieldName: 'textColor' }}},
            { label: 'IAL', fieldName: 'IAL', type: 'text'},
        ]);
        var action = component.get('c.getAccountList');
        action.setParams({
            "queryLimit" : 0
        })
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    element.Id = '/' + element.Id;
                    if (element.KYC_flag_limited_value == 0) {                      
                        element.textColor = 'redText';
                    }
                    finalData.push(element);
                    
                });
                helper.sortData(component, helper, 'KYC_flag_limited_value', 'desc', finalData);
                component.set('v.reportId', resp.reportId);
            } else {
            }
            component.set('v.isLoading', false);

        })
        $A.enqueueAction(action);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("KYCReportCmp");
            workspaceAPI.openTab({
                recordId: component.get('v.reportId'),
                focus: true
            }).then(function (response) {
                workspaceAPI.getTabInfo({
                    tabId: response
                }).then(function (tabInfo) {
                });
            }).catch(function (error) {
                console.log(error);
            });
        }
        else{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/r/Report/' + reportId + '/view',
            });
            urlEvent.fire();
        }
    },
    handleSort: function(component,event,helper){
        var sortField = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        let columns = component.get('v.columns');
        let sortBy;
        columns.forEach((e) => {
            if(e.fieldName == sortField){
                sortBy = e.sortBy;
            }
        })
   
        component.set("v.sortBy",sortField);
        component.set("v.sortDirection",sortDirection);
         
        helper.sortData(component,sortBy,sortDirection, null);
    },

})