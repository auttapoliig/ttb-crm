({
    onInit : function(component, event, helper) {
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                console.log('userObj:',result);      
                component.set('v.userObj',result);
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
                        console.log('Debug usertype ',channel,component.get('v.branchCode'))
                    }
                    if(result.userChannel)
                    {
                        component.set("v.channel",result.userChannel);
                    }
                    component.set('v.renderPage',result.page);    
                
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
                console.log('message',message);
                component.set('v.loaded', false)
            }         
        });
        
        $A.enqueueAction(action);
    },

})