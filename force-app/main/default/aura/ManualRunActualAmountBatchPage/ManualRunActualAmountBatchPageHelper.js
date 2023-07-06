({
    getOptions: function (component, event, helper) {
        const d = new Date();
        const options = {
            selectedMonthId: 1,
            months: [
                { id: 1, label: '01', selected: true},
                { id: 2, label: '02'},
                { id: 3, label: '03'},
                { id: 4, label: '04'},
                { id: 5, label: '05'},
                { id: 6, label: '06'},
                { id: 7, label: '07'},
                { id: 8, label: '08'},
                { id: 9, label: '09'},
                { id: 10, label: '10'},
                { id: 11, label: '11'},
                { id: 12, label: '12'},
            ],
            selectedYearId: 1,
            years: [
                { id: 1, label: d.getFullYear()-1, selected: true},
                { id: 2, label: d.getFullYear()},
            ]
        };
        component.set('v.option_month', options.months);
        component.set('v.option_year', options.years);
        component.set('v.choosed_year', d.getFullYear()-1);
        component.set('v.choosed_month', '01');
    },

    callManualExecuteBatch: function(component, event, helper){
        var action = component.get("c.executeActualAmountBatch");
        action.setParams({ 
            year : component.get('v.choosed_year'),
            month: component.get('v.choosed_month')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                console.log(response.getReturnValue());
                component.set('v.isExecuting', false);
                helper.showToast(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "The batch is executing."
        });
        toastEvent.fire();
    }
})