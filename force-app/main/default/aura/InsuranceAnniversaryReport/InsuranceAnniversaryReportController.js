({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Insurance Policy No.', fieldName: 'Account_Number', type: 'text', wrapText: true },
            { label: 'Anniversary Date', fieldName: 'Anniversary_Date', type: 'date', cellAttributes: { class: { fieldName: 'textColor' }}},
            { label: 'Insurance Premium', fieldName: 'Insurance_Premium', type: 'text', wrapText: true },
            { label: 'Flag Fully Paid', fieldName: 'Insurance_Fully_Paid_Flag', type: 'text', wrapText: true }
        ]);

        var action = component.get('c.getAnniversaryInsurance');
        action.setParams({
            "queryLimit" : component.get('v.queryLimit') ? component.get('v.queryLimit') : 5
        })
        action.setCallback(this, function (response) {
            var finalData = [];
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var data = resp.data;
                data.forEach(element => {
                    element.Id = '/' + element.Id;

                    var today = new Date();
                    var duedate = new Date(element.Anniversary_Date);
                   
                    if (duedate < today) {                      
                        element.textColor = 'redText';
                    }

                    finalData.push(element);

                });
                component.set('v.reportId', resp.reportId);
                component.set('v.data', finalData);
            } 
            else {
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
         
        helper.sortData(component, sortBy, sortDirection, null);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("InsuranceAnniversary");
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