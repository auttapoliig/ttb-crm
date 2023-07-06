({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'CusName' } } },
            { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
            { label: 'Transaction Date', fieldName: 'Transaction_Date_Time__c', type: 'date' },
          

        ]);
        var action = component.get('c.getTransactionMinus');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                //component.set('v.data', resp.data);
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Customer__c;
                    element.Id = '/'+ url;
                    
                    var name = element.Customer__r.Name;
                    element.CusName = name;
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
            var workspaceAPI = component.find("transactionMinus");
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