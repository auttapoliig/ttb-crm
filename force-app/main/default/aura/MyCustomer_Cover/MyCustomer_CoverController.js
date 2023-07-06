({
    myAction : function(component, event, helper) {

    },

    clearFilter : function(component, event, helper){
        console.log('clear Filter');
        var childCmp = component.find("cComp")
        childCmp.clearFilterMethod();
    }
})