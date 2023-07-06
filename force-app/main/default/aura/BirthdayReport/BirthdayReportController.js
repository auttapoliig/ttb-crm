({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Customer Name',    fieldName: 'Id',      type: 'url' , wrapText: true, typeAttributes: {label: { fieldName: 'Name' }}},
            {label: 'Birthday',         fieldName: 'RTL_Date_Of_Birth__c', type: 'date'},
            {label: 'Turning',         fieldName: 'Age',   type: 'text'}
        
        ]);
        var action = component.get('c.getBirthdayList');
        action.setParams({
            "queryLimit" : component.get('v.queryLimit') ? component.get('v.queryLimit') : 5
        });
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS'){
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = '/'+element.Id;
                    element.Id = url;

                    element.Age = (new Date().getFullYear()) - parseInt(element.RTL_Date_Of_Birth__c.slice(0, 4));
                    finalData.push(element);

                });
                component.set('v.data', finalData);
                component.set('v.reportId', resp.reportId);
            }else{
            }
            component.set('v.isLoading', false);
           
        })
        $A.enqueueAction(action);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("birthdayReportCmp");
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