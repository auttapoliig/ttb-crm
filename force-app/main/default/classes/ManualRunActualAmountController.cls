public class ManualRunActualAmountController {
    @AuraEnabled
    public static String executeActualAmountBatch(String year, String month){
        String level = 'branch';
        Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(level, year, month, 2000, null));
        return 'success';
    }
}