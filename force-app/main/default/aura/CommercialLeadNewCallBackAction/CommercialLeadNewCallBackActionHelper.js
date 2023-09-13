({
    helperMethod : function() {

    }
    // closeModal: function () {
    //     $A.get("e.force:closeQuickAction").fire();
    // },

    // displayToast: function (type, message) {
    //     var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
    //     var toastEvent = $A.get('e.force:showToast');
    //     toastEvent.setParams({
    //         key: type,
    //         type: type,
    //         message: message,
    //         duration: duration
    //     });
    //     toastEvent.fire();
    // },

    // startSpinner: function (component) {
    //     component.set('v.isLoading', true);
    // },
    
    // stopSpinner: function (component) {
    //     component.set('v.isLoading', false);
    // },

    // validateCallBackTask: function(component) {
    //     var callBackDate = component.get('v.callBackDate');
    //     var callBackTime = component.get('v.callBackTime');
          
    //     //Validate Date Time
    //     var today = new Date();
    //     if(callBackDate > $A.localizationService.formatDateTime(today,"yyyy-MM-dd")){
    //         //check Business Hours or Bank holiday or weekend 
    //         var action = component.get('c.isItBusinessHours');
    //         action.setParams({
    //             "callBackDate": callBackDate,
    //             "callBackTime": callBackTime,
    //         });
    //         action.setCallback(this, function (response) {
    //             if (component.isValid() && response.getState() === 'SUCCESS') {
    //                 var result = response.getReturnValue();
    //                 console.log(result);
    //                 if (result.isBusinessHours) {
    //                     this.saveCallBackTask(component);

    //                 } else {
    //                     this.displayToast('error', result.errorMessage);
    //                 }
    //             } else {
    //                 var errors = response.getError();
    //                 errors[0] ? errors[0].pageErrors.forEach(error => {
    //                     this.displayToast('error', error.message);
    //                 }) : console.log(errors);
    //             }
    //             this.stopSpinner(component);
    //         });
    //         $A.enqueueAction(action);

    //     }else{
    //         this.displayToast('error', 'Cannot create Call Back Schedule on This Day.');
    //         this.stopSpinner(component);
    //     }
        

    // },
    // getParameters : function(component) { 
    //     return {
    //         'cbDate': component.get('v.callBackDate'),
    //         'cbTime': component.get('v.callBackTime'),
    //         'cbPhoneNumber': component.get('v.callBackPhoneNumber'),
    //         'cbMode': component.get('v.callBackMode'),
    //         'cbNotes': component.get('v.callBackNotes')
    //     };
    // },

    // saveCallBackTask: function(component) {
    //     var params = this.getParameters(component);

    //     var action = component.get('c.saveCallBackTask');
    //     action.setParams({
    //         "recordId": component.get('v.recordId'),
    //         'callBack': JSON.stringify(params),
    //     });
    //     action.setCallback(this, function (response) {
    //         if (component.isValid() && response.getState() === 'SUCCESS') {
    //             helper.closeModal();
    //             $A.get('e.force:refreshView').fire();
    //         } else {
    //             var errors = response.getError();
    //             errors[0] ? errors[0].pageErrors.forEach(error => {
    //                 this.displayToast('error', error.message);
    //             }) : console.log(errors);
    //         }
    //         this.stopSpinner(component);
    //     });
    //     $A.enqueueAction(action);
    // },

})