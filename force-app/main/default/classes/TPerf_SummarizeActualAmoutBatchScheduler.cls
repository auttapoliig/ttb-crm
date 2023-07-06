public class TPerf_SummarizeActualAmoutBatchScheduler implements Schedulable{
    private String month;
    private String year;
    private String currentYear = System.Today().year() + '';
    private String lastYear = (System.Today().year() - 1) + '';
    private List<String> years = new List<String>{lastYear, currentYear};
    private List<String> months = new List<String>{'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'};
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
        Map<String, Decimal> productActualMap = new Map<String, Decimal>();
        String level = 'branch';
        for(String year : years){
            for(String month : months){
                List<Summary_Team_and_Product__c> changed = [SELECT Id FROM Summary_Team_and_Product__c WHERE Month__c=:month AND Year__c=:year AND LastModifiedDate = TODAY LIMIT 1];
                if(changed.size() > 0){
                    // String query = 'SELECT Id, Cap_Max_Pct__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Target_Unit_Month__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c FROM T_Performance_Target_Product_by_Team__c WHERE RecordTypeId = \'' + this.recordTypeBranchId + '\' AND Year__c =\'' + this.year + '\' AND Month__c =\'' + this.month + '\'';
                    // List<Summary_Team_and_Product__c> productList = [SELECT Id, Year__c, Month__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Actual_Amount__c, Indicator_Code__c FROM Summary_Team_and_Product__c WHERE Year__c =: this.year AND Month__c =: this.month];
                    // for(Summary_Team_and_Product__c each : productList){
                    //     String summaryKey = String.valueOf(each.get('Year__c')) + String.valueOf(each.get('Month__c')) + String.valueOf(each.get('Channel_Name__c')) + String.valueOf(each.get('Branch_Team_Code__c')) + String.valueOf(each.get('Indicator_Code__c'));
                    //     productActualMap.put(summaryKey, Decimal.valueOf(String.valueOf(each.get('Actual_Amount__c'))));
                    // }
                    Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(level, year, month, BATCH_CHUNK_SIZE, null), BATCH_CHUNK_SIZE);
                } else {
                    List<T_Performance_Target_Product_by_Team__c> changed2 = [SELECT Id FROM T_Performance_Target_Product_by_Team__c WHERE Month__c =: month AND Year__c =: year AND LastModifiedDate = TODAY AND RecordType.Name = 'branch' LIMIT 1];
                    if(changed2.size() > 0) {
                        Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(level, year, month, BATCH_CHUNK_SIZE, null), BATCH_CHUNK_SIZE);
                    }
                }
            }
        }
    }

    public TPerf_SummarizeActualAmoutBatchScheduler(){
    }
}