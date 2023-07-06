global without sharing class ClearSocialNegativeScheduler implements Schedulable {
    

    global void execute(SchedulableContext ctx) {
        ClearSocialNegative();
    }

    private void ClearSocialNegative() {
        List<Social_Post_Negative__c> socialPostNegativeListForDelete = [SELECT id, Posted_Date__c FROM Social_Post_Negative__c where Posted_Date__c < LAST_N_DAYS:30];
        System.debug('Deleted records [' + socialPostNegativeListForDelete + ']');
        
        delete socialPostNegativeListForDelete;
    }
}