({
    onInit : function(component, event, helper) {
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                // console.log('userObj:',result);      
                component.set('v.userObj',result);
                // console.log('isSummaryPage:'+ result.isSummaryPage);  
                // console.log('Navigate Message: '+ component.get("v.NavigateMessage"));
                component.set('v.NavigateMessage', result.isSummaryPage);
                if(result.isSummaryPage == false){
                    component.set("v.isIndividual", true);
                }  
                if(component.get("v.isIndividual") == true)
                {
                    if(result.user.RTL_Channel__c)
                    {
                        var channel = result.user.RTL_Channel__c == 'Branch' ? 'Branch' : 'RASC';
                        component.set('v.userType',channel); 
                        if (channel == 'Branch'){
                            component.set('v.branchCode',result.user.RTL_Branch_Code__c);
                        }
                        else{
                            component.set('v.branchCode',result.user.Zone_Code__c);
                        }
                        // console.log('Debug usertype ',channel,component.get('v.branchCode'))
                    }
                    if(result.userChannel)
                    {
                        component.set("v.channel",result.userChannel);
                    }
                    component.set('v.renderPage',result.page);  
                    component.set('v.NavigateMessage', false);   
                }
                //  console.log('renderPage:',component.get('v.renderPage'));  
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                // console.log('message',message);
                component.set('v.loaded', false)
                helper.showToastError('User is unauthorized to access the page');
            }         
        });
        
        $A.enqueueAction(action);
    },

    insertTermOfUseLog : function(component, helper){
        var status = component.get('v.status');// at cmp
        var action = component.get('c.insertTermOfUseLog');// get function at apex
        action.setParams({
            "status" : status
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {               
                console.log('status',status)
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('message',message);
                component.set('v.loaded', false)
                helper.showToastError('Get user info, Massage: '+message);
            }  
        });
        $A.enqueueAction(action);  

    },

    
    showToastError : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error",
            "message": msg
        });
        toastEvent.fire();
    },
    
    getWatermarkHTML: function (component) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var watermarkHTML = response.getReturnValue();
            // console.log('watermarkHTML: ', watermarkHTML);
    
            var imgEncode = btoa(
              "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" +
                watermarkHTML +
                "</text></svg>"
            );
            var bg = 'url("data:image/svg+xml;base64,' + imgEncode + '")';
    
            // console.log("watermarkHTML: ", bg);
            component.set("v.waterMarkImage", bg);
          } else if (state === "ERROR") {
            // console.log("STATE ERROR");
            // console.log("error: ", response.error);
          } else {
            // console.log(
            //   "Unknown problem, state: " +
            //     state +
            //     ", error: " +
            //     JSON.stringify(response.error)
            // );
          }
        });
        $A.enqueueAction(action);
      },
})