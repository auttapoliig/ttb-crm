global without sharing class ClearSocialPostRejectedCaseScheduler implements Schedulable {
    

    global void execute(SchedulableContext ctx) {
        ClearRejectedCase();
    }

    private void ClearRejectedCase() {
        ClearSocialPostRejectedCaseBatch snInstance = new ClearSocialPostRejectedCaseBatch();
        ID batchprocessid = Database.executeBatch(snInstance, 2000);
    }
}