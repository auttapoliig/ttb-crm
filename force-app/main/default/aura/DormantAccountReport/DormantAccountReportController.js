({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'cusName' } } },
            { label: 'Account Number', fieldName: 'Account_Number__c', type: 'text' },
            {
                label: 'Due Date', fieldName: 'Dormant_Date__c', type: 'date',
                cellAttributes:
                {
                    class: { fieldName: 'textColor' }
                }
            }

        ]);
        var action = component.get('c.getDormantAccount');
        action.setParams({
            "queryLimit" : component.get('v.queryLimit') ? component.get('v.queryLimit') : 5
        })
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Customer__r.Id;
                    element.Id = '/' + url;

                    var cusName = element.Customer__r.Name;
                    element.cusName = cusName;

                    var today = new Date();
                    var duedate = new Date(element.Dormant_Date__c);
                   
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
            var workspaceAPI = component.find("DormantAccCmp");
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