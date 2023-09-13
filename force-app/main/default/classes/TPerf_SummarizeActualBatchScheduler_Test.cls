@isTest
public class TPerf_SummarizeActualBatchScheduler_Test {
    private static final String currentYear = System.Today().year() + '';
    private static final String recordTypeIdBranch = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_branch').getRecordTypeId();

    @isTest
    private static void test_SummaryProductChanged() {
        Summary_Team_and_Product__c mockActual = new Summary_Team_and_Product__c();
        mockActual.Actual_Amount__c = 99; 
        mockActual.Indicator_Code_Level1__c = 'T011';
        mockActual.Indicator_Code_Level2__c = 'T111';
        mockActual.Indicator_Code__c = 'T001';
        mockActual.Indicator_Level1__c = 'test 01';
        mockActual.Indicator_Level2__c = 'test 11';
        mockActual.Indicator_Name__c = 'Test';
        mockActual.Indicator_Rank__c = '2';
        mockActual.Month__c = '01';
        mockActual.Unique_External_Key__c = '202301T001';
        mockActual.Year__c = currentYear;
        mockActual.Channel_Name__c = 'Branch';
        mockActual.Region_Code__c = '1800';
        mockActual.Zone_Code__c = '1810';
        mockActual.Branch_Team_Code__c = '1811';
        insert mockActual;

        String CRON_EXP = '0 0 22 * * ?';
        Test.startTest();
            TPerf_SummarizeActualAmoutBatchScheduler p = new TPerf_SummarizeActualAmoutBatchScheduler();
            String jobId = System.schedule('T-PerformanceSummarizeData_TEST', CRON_EXP, p);
        Test.stopTest();
    }

    @isTest
    private static void test_TargetProductbyTeamChanged() {
        T_Performance_Target_Product_by_Team__c mockTarget = new T_Performance_Target_Product_by_Team__c();
        mockTarget.RecordTypeId = recordTypeIdBranch;
        mockTarget.Unique_External_Key__c = '202301TEST002';
        mockTarget.Year__c = currentYear;
        mockTarget.Month__c = '01';
        mockTarget.Branch_Team_Code__c = '1811';
        mockTarget.Region_Code__c = '1800';
        mockTarget.Zone_Code__c = '1810';
        mockTarget.Product_Group_Code__c = 'BR1001';
        mockTarget.Product_Group_Name__c = 'TEST NAME';
        mockTarget.Indicator_Level1__c ='BR1111';
        mockTarget.Target_Unit_Year__c = 10000;
        mockTarget.Target_Unit_Month__c = 1000;
        mockTarget.Product_List__c = 'BR101;BR102';
        mockTarget.Rank__c = '1';
        insert mockTarget;

        String CRON_EXP = '0 0 22 * * ?';
        Test.startTest();
            TPerf_SummarizeActualAmoutBatchScheduler p = new TPerf_SummarizeActualAmoutBatchScheduler();
            String jobId = System.schedule('T-PerformanceSummarizeData_TEST2', CRON_EXP, p);
        Test.stopTest();
    }
}