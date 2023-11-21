({
    init: function (component, event, helper) {
        helper.getOptions(component, event, helper);
    },

    onChangeYear: function (component, event, helper) {
        component.set('v.choosed_year', component.find('selectYear').get('v.value'));
    },
    
    onChangeMonth: function (component, event, helper) {
        component.set('v.choosed_month', component.find('selectMonth').get('v.value'));
    },

    handleClick: function (component, event, helper){
        component.set('v.showConfirmDialogBox', true);
    },
    
    handleConfirmDialogOk : function(component, event, helper) {
        component.set('v.showConfirmDialogBox', false);
        helper.callManualExecuteBatch(component, event, helper);
        component.set('v.isExecuting', true);
    },
    
    handleConfirmDialogCancel : function(component, event, helper) {
        component.set('v.showConfirmDialogBox', false);
    },
})