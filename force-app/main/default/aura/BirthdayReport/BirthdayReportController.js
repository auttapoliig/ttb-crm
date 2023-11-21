({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Customer Name',    fieldName: 'Id', sortBy: 'Name', type: 'url' , wrapText: true, typeAttributes: {label: { fieldName: 'Name' }}},
            {label: 'Birthday',         fieldName: 'RTL_Date_Of_Birth__c', sortBy: 'RTL_Date_Of_Birth__c', type: 'date'},
            {label: 'Turning',         fieldName: 'Age', sortBy: 'Age', type: 'text'}
        
        ]);
        var action = component.get('c.getBirthdayList');
        action.setParams({
            "queryLimit" : 0
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
                helper.sortData(component, helper, 'RMC_Next_Birthday__c', 'desc', finalData)
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
         
        helper.sortData(component,sortBy,sortDirection, null);
    },
})