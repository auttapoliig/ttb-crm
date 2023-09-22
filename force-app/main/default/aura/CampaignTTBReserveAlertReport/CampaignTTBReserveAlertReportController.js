({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Product Group', fieldName: 'Product_Group', type: 'text' },
            // { label: 'Detail', fieldName: 'Details', type: 'text' },
            { label: 'ttb reserve', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'More_Detail' } } },

        ]);
        var action = component.get('c.getTTBReseveInvitation');
        action.setParams({
            "queryLimit" : component.get('v.queryLimit') ? component.get('v.queryLimit') : 5,
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Id;
                    element.Id = '/'+ url;
                    finalData.push(element);

                });
                helper.sortData(component,'Period','desc', finalData);
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
         
        helper.sortData(component,sortBy,sortDirection, null);
    },

    openTab: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var reportId = component.get('v.reportId');
        if(device == 'DESKTOP'){
            var workspaceAPI = component.find("CampaignTTBReserveAlertReport");
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