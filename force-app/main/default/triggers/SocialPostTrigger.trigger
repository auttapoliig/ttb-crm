trigger SocialPostTrigger on Social_Post__c	(before insert, after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        System.debug('SocialPostTrigger : Before Insert');
        SocialPostTriggerHandler.beforeInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert ) {
        // Create case when axx
       
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('SocialPostTrigger : After Update');
        SocialPostTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

}