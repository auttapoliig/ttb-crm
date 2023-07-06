({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Campaign Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Start Date', fieldName: 'StartDate', type: 'date' },
            { label: 'End Date', fieldName: 'EndDate', type: 'date' }

        ]);
        var action = component.get('c.getCampaignList');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = '/' + element.Id;
                    element.Id = url;
                    finalData.push(element);

                });
                component.set('v.data', finalData);
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
            var workspaceAPI = component.find("campaignReportCmp");
            workspaceAPI.openTab({
                recordId: component.get('v.reportId'),
                focus: true
            }).then(function (response) {
                workspaceAPI.getTabInfo({
                    tabId: response
                }).then(function (tabInfo) {
                });
            })
                .catch(function (error) {
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
    }

})