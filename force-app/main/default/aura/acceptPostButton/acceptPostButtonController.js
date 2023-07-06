({
    handleConfirm : function(component, event, helper) {
        var action = component.get("c.acceptPost");
        var UserId = component.get("v.userId");
        var RecordId = component.get("v.recordId");
        component.set("v.showspinner", true);
        action.setParams({
            recordId: RecordId,
            userId: UserId,

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('SUCCESS');
                helper.showToast(component, event, helper,'success','Success!','Accept success');
                helper.closeSubtab(component, event, helper);
                helper.refreshFocusedTab(component, event, helper);
            } else {
                console.log('FAIL!');
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                helper.showToast(component, event, helper,'error','Error!',message);
            }
            component.set("v.showspinner", false);
        });
        $A.enqueueAction(action);
    },
    handleCancel: function (component, event, helper) {
        helper.closeSubtab(component, event, helper);
    },
})