public class TPerf_SummarizeActualAmoutBatchScheduler implements Schedulable{
    private String month;
    private String year;
    private String currentYear = System.Today().year() + '';
    private String lastYear = (System.Today().year() - 1) + '';
    private List<String> years = new List<String>{lastYear, currentYear};
    // private List<String> months = new List<String>{'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'};
    private Id recordTypeBranchId = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_branch').getRecordTypeId();
    private static Integer BATCH_CHUNK_SIZE {
        get{
            if(BATCH_CHUNK_SIZE == null){
                if(T_Performance_Summarize_Batch_Config__mdt.getInstance('Batch_chunk_size').Value__c == null){
                    BATCH_CHUNK_SIZE = 2000;
                } else {
                    BATCH_CHUNK_SIZE = Integer.valueOf(T_Performance_Summarize_Batch_Config__mdt.getInstance('Batch_chunk_size').Value__c);
                }
            }
            return BATCH_CHUNK_SIZE;
        }
        set;
    }
    

    public void execute(SchedulableContext sc) {
        runExecuteBatch(lastYear,'01');
        runExecuteBatch(lastYear,'02');
        runExecuteBatch(lastYear,'03');
        runExecuteBatch(lastYear,'04');
        runExecuteBatch(lastYear,'05');
        runExecuteBatch(lastYear,'06');
        runExecuteBatch(lastYear,'07');
        runExecuteBatch(lastYear,'08');
        runExecuteBatch(lastYear,'09');
        runExecuteBatch(lastYear,'10');
        runExecuteBatch(lastYear,'11');
        runExecuteBatch(lastYear,'12');

        runExecuteBatch(currentYear,'01');
        runExecuteBatch(currentYear,'02');
        runExecuteBatch(currentYear,'03');
        runExecuteBatch(currentYear,'04');
        runExecuteBatch(currentYear,'05');
        runExecuteBatch(currentYear,'06');
        runExecuteBatch(currentYear,'07');
        runExecuteBatch(currentYear,'08');
        runExecuteBatch(currentYear,'09');
        runExecuteBatch(currentYear,'10');
        runExecuteBatch(currentYear,'11');
        runExecuteBatch(currentYear,'12');
        
    }

    private void runExecuteBatch(String year, String month) {
        String level = 'branch';
        List<Summary_Team_and_Product__c> changed = [SELECT Id FROM Summary_Team_and_Product__c WHERE Month__c= :month AND Year__c=:year AND LastModifiedDate = TODAY LIMIT 1];
        if(changed.size() > 0){
            Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(level, year, month, BATCH_CHUNK_SIZE, null), BATCH_CHUNK_SIZE);
        } else {
            List<T_Performance_Target_Product_by_Team__c> changed2 = [SELECT Id FROM T_Performance_Target_Product_by_Team__c WHERE Month__c =: month AND Year__c =: year AND LastModifiedDate = TODAY LIMIT 1];
            if(changed2.size() > 0) {
                Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(level, year, month, BATCH_CHUNK_SIZE, null), BATCH_CHUNK_SIZE);
            }
        }
    }

    public TPerf_SummarizeActualAmoutBatchScheduler(){
    }
}