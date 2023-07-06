({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'AUM Calculation Date', fieldName: 'RMC_AUM_Calculation_Date__c', type: 'date' },
            { label: '% AUM Change', fieldName: 'percentChange', type: 'text' }

        ]);
        var action = component.get('c.getAUMPlus');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Id;
                    element.Id = '/'+ url;

                    var percentChange = (Math.round(element.RMC_AUM_Change__c * 100) / 100).toFixed(2);
                    element.percentChange = percentChange+'%';
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
            var workspaceAPI = component.find("AUMReportPlusCmp");
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