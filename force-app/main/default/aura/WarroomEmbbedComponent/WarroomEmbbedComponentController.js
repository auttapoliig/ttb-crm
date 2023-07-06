({
    onInit : function(component, event, helper) {
        component.set('v.loaded',true);

        helper.initialWarroomUrl(component, event, helper);
        component.set('v.loaded',false); 
    }
})