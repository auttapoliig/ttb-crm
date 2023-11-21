({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Title', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Title' } } },
            { label: 'Published Date', fieldName: 'FirstPublishedDate', type: 'date', wrapText: true },
            { label: 'Modified Date', fieldName: 'LastModifiedDate', type: 'date', wrapText: true },
           
        ]);

        var action = component.get('c.getTipKnowledge');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                if (data) {
                    data.forEach(element => {
                        element.Id = '/' + element.Id;
                        finalData.push(element);

                    });
                }
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
            var workspaceAPI = component.find("TipReport");
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
    }

})