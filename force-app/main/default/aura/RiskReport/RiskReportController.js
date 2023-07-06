({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },           
            {
                label: 'Suitability Risk Expiry Date', fieldName: 'RMC_Suitability_Risk_Expiry_Date__c', type: 'date',
                cellAttributes:
                {
                    class: { fieldName: 'textColor' }
                }
            },
            { label: 'Risk Suitability Risk Level', fieldName: 'RMC_Suitability_Risk_Level__c', type: 'text' },

        ]);
        var action = component.get('c.getAccountList');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Id;
                    element.Id = '/' + url;

                    var today = new Date();
                    var duedate = new Date(element.RMC_Suitability_Risk_Expiry_Date__c);
                   
                    if (duedate < today) {                      
                        element.textColor = 'redText';
                    }
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
            var workspaceAPI = component.find("riskReportCmp");
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