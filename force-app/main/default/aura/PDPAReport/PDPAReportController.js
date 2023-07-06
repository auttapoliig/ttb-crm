({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'accId', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Has PDPA', fieldName: 'RMC_Has_PDPA__c', type: 'text' },

        ]);
        var action = component.get('c.getPDPAReport');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var accountId = element.Id;
                    element.accId = '/'+ accountId;
                    if(element.pdpaId){
                        var pdpaId = element.pdpaId;
                        element.pdpaId = '/'+ pdpaId;
                    }
                    
                    finalData.push(element);

                });
                component.set('v.data', finalData);
                component.set('v.reportId', resp.reportId);
            }
            component.set('v.isLoading', false);

        })
        $A.enqueueAction(action);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("pdpaReportCmp");
            workspaceAPI.openTab({
                recordId: component.get('v.reportId'),
                focus: true
            }).then(function (response) {
                workspaceAPI.getTabInfo({
                    tabId: response
                }).then(function (tabInfo) {
                });
            }).catch(function (error) {
                console.log('pdpa error: '+error);
            });
        }
        else{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/r/Report/' + reportId + '/view',
            });
            urlEvent.fire();
        }
    }

})