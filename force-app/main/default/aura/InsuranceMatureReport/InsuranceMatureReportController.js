({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Insurance Policy No.', fieldName: 'Account_Number', type: 'text', wrapText: true },
            { label: 'Insurance Sum Insured', fieldName: 'Insurance_Sum_Insured', type: 'currency', wrapText: true },
            { label: 'Insurance Maturity Date', fieldName: 'Insurance_Maturity_Date', type: 'date', wrapText: true }
        ]);

        var action = component.get('c.getMatureInsurance');
        action.setParams({
            "queryLimit" : component.get('v.queryLimit') ? component.get('v.queryLimit') : 5
        })
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
         
        helper.sortData(component,sortBy,sortDirection);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("InsuranceMature");
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