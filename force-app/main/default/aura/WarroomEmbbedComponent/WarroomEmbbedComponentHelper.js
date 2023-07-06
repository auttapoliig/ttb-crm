({
    initialWarroomUrl : function(component, event, helper) {
        var action = component.get('c.getURLforIframe');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('iframeUrl:',result);
                if(result) {
                    component.set('v.iframeUrl',result);                 
                }

                component.set('v.loaded',false);
            } else {
            }
        })

        $A.enqueueAction(action);
    }
})