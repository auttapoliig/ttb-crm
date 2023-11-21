({  
    onInitConsent: function(component, event, helper) {
      let hostname = window.location.protocol+'//'+window.location.hostname;
      component.set('v.consentLink',hostname+"/apex/T_Performance_ConsentPage")
      helper.getWatermarkHTML(component);
      
     },
    
     selectDecline: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.status", 'Declined');  
        component.set("v.isModalOpen", false);
        component.set("v.declineMessage", true);
        helper.insertTermOfUseLog(component, helper)
        var customLabelText = $A.get('$Label.c.T_Performance_Decline_Consent_Message');
        var customLabelTextArr = customLabelText.split(';');
        component.set('v.textList',customLabelTextArr)
     },
    
     selectContinue: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.status", 'Accepted');
        component.set("v.isModalOpen", false);
        helper.insertTermOfUseLog(component, helper);
        helper.onInit(component, event ,helper);
     },
     onCheck: function(component, event,helper) {
        console.log('event',event.target.checked);  
        component.set('v.myBool',event.target.checked);  
    },

    returnTperf: function(component, event,helper) {
        component.set("v.declineMessage", false);
        component.set("v.isModalOpen", true);
        component.set('v.myBool',false);

   },
   selectIndividual: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      helper.insertTermOfUseLog(component, helper)
      component.set("v.isIndividual", true)
      helper.onInit(component, event ,helper);
   },
   selectSummary: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.NavigateMessage", false);
      component.set("v.isSummary", true);
   },
   navigateToSummary : function(component, event, helper) {
      var evt = $A.get("e.force:navigateToComponent");
      evt.setParams({
          componentDef : "c:T_Performance_SummaryPage"
      });
      evt.fire();
  },

  navigateToIndividual : function(component, event, helper) {
   var evt = $A.get("e.force:navigateToComponent");
   evt.setParams({
       componentDef : "c:T_Performance_IndividualPage"
   });
   evt.fire();
}
    
})