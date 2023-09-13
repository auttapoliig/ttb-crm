({    
    myAction : function(component, event, helper) {

    }
    // onInit: function (component, event, helper) {
    //     //check Avaya Integration Lead
    //     helper.startSpinner(component)
    //     var action = component.get('c.getAvayaIntegrationLead');
    //     action.setParams({
    //         "recordId": component.get('v.recordId')
    //     });
    //     action.setCallback(this, function (response) {
    //         if (component.isValid() && response.getState() === 'SUCCESS') {
    //             var result = response.getReturnValue();
    //             if (!result) {
    //                 helper.closeModal();
    //                 alert("hello there!"); 
    //             }
    //         } else {
    //             var errors = response.getError();
    //             errors.forEach(error => {
    //                 helper.displayToast('error', error.message);
    //             });
    //         }
    //         helper.stopSpinner(component);
    //     });
    //     $A.enqueueAction(action);
    // },
    
    // onSubmit: function (component, event, helper) {
    //     var callBackDate = component.get('v.callBackDate');
    //     var callBackTime = component.get('v.callBackTime');
    //     var callBackPhoneNumber = component.get('v.callBackPhoneNumber');  
    //     var cbDate = component.find("cbDateId")
    //     var cbTime = component.find("cbTimeId")
    //     var cbPhoneNumber = component.find("cbPhoneId") 
    //     helper.startSpinner(component);
    //     if(callBackDate != null && callBackTime != null && callBackPhoneNumber != null){
    //         console.log(cbPhoneNumber.get("v.validity").valid)
    //         if(cbPhoneNumber.get("v.validity").valid){
    //             helper.validateCallBackTask(component);
    //         }
    //     }else{
    //         cbDate.reportValidity();
    //         cbTime.reportValidity();
    //         cbPhoneNumber.reportValidity();
    //         helper.stopSpinner(component);
    //     }


        
    // },
    // onCancel: function (component, event, helper) {
    //     // if (component.get('v.isSubmitted')) {
    //     //     $A.get('e.force:refreshView').fire();
    //     // }
    //     helper.closeModal();
    // },
})