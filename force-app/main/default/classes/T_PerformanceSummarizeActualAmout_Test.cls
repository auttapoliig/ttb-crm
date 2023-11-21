@isTest
public class T_PerformanceSummarizeActualAmout_Test {

    private static String recordTypeIdBranch = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_branch').getRecordTypeId();
    private static String recordTypeIdZone = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_zone').getRecordTypeId();
    private static String recordTypeIdRegion = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_region').getRecordTypeId();
    private static String recordTypeIdChannel = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_channel').getRecordTypeId();
    private static String recordTypeIdGOC = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_group_of_channel').getRecordTypeId();
    private static String recordTypeIdRetail = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_retail').getRecordTypeId();

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

    Static testmethod void TestSummarizeActualAmoutBatchBranch(){
        List<Summary_Team_and_Product__c> productActuallist = new List<Summary_Team_and_Product__c>();
        Summary_Team_and_Product__c productActual = new Summary_Team_and_Product__c();
        productActual.Year__c = String.valueOf(Date.Today().year()) ;
        productActual.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0') ;
        productActual.Channel_Name__c = 'Branch' ;
        productActual.Branch_Team_Code__c = '001' ;
        productActual.Zone_Code__c = '1820';
        productActual.Region_Code__c = '1800';
        productActual.Indicator_Code__c = 'BR1001' ;
        productActual.Actual_Amount__c = 1000 ;
        productActual.Unique_External_Key__c = '202208001BR1001' ;
        productActuallist.add(productActual);

        Summary_Team_and_Product__c productActual2 = new Summary_Team_and_Product__c();
        productActual2.Year__c = String.valueOf(Date.Today().year()) ;
        productActual2.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0') ;
        productActual2.Channel_Name__c = 'Branch' ;
        productActual2.Branch_Team_Code__c = '001' ;
        productActual2.Zone_Code__c = '1820';
        productActual2.Region_Code__c = '1800';
        productActual2.Indicator_Code__c = 'BR1001' ;
        productActual2.Actual_Amount__c = 1000 ;
        productActual2.Unique_External_Key__c = '202208001BR1001x' ;
        productActuallist.add(productActual2);
        insert productActuallist;

        List<T_Performance_Target_Product_by_Team__c> targetlist = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c target = new T_Performance_Target_Product_by_Team__c();
        target.Product_Group_Name__c = 'MF Type B	';
        target.Actual_Amount__c =10;
        // target.Actual_Amount_with_Capmax__c = 100;
        target.Cap_Max_Pct__c = 0;
        target.Target_Unit_Month__c = 5;
        target.Target_Unit_Year__c = 150;
        target.Branch_Team_Code__c = '001';
        target.Region_Code__c = '1800';
        target.Indicator_Level1__c = 'Deposit&Investment	';
        target.Zone_Code__c = '1820';
        target.Year__c = String.valueOf(Date.Today().year()) ;
        target.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target.Product_Group_Code__c = 'SUM1001';
        target.Product_List__c = 'BR1001;BR1002;';
        target.Group_Channel__c = 'BBD';
        target.Channel_Name__c = 'Branch';
        target.Rank__c = '1.1';
        target.Branch_Point_Engine__c = 70;
        target.Unique_External_Key__c = '202201043SUM1001Branch';
        target.RecordTypeId = recordTypeIdBranch;
        targetlist.add(target);

        T_Performance_Target_Product_by_Team__c target2 = new T_Performance_Target_Product_by_Team__c();
        target2.Product_Group_Name__c = 'MF Type B	';
        target2.Actual_Amount__c =10;
        target2.Cap_Max_Pct__c = 0;
        target2.Target_Unit_Month__c = 5;
        target2.Target_Unit_Year__c = 150;
        target2.Region_Code__c = '1800';
        target2.Indicator_Level1__c = 'Deposit&Investment	';
        target2.Zone_Code__c = '1820';
        target2.Year__c = String.valueOf(Date.Today().year()) ;
        target2.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target2.Product_Group_Code__c = 'SUM1001';
        target2.Product_List__c = 'BR1001;BR1002;';
        target2.Group_Channel__c = 'BBD';
        target2.Channel_Name__c = 'Branch';
        target2.Rank__c = '1.1';
        target2.Branch_Point_Engine__c = 70;
        target2.Unique_External_Key__c = '202201043SUM1001Zone';
        target2.RecordTypeId = recordTypeIdZone;
        targetlist.add(target2);

        T_Performance_Target_Product_by_Team__c target3 = new T_Performance_Target_Product_by_Team__c();
        target3.Product_Group_Name__c = 'MF Type B	';
        target3.Actual_Amount__c =10;
        target3.Cap_Max_Pct__c = 0;
        target3.Target_Unit_Month__c = 5;
        target3.Target_Unit_Year__c = 150;
        target3.Region_Code__c = '1800';
        target3.Indicator_Level1__c = 'Deposit&Investment	';
        target3.Year__c = String.valueOf(Date.Today().year()) ;
        target3.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target3.Product_Group_Code__c = 'SUM1001';
        target3.Product_List__c = 'BR1001;BR1002;';
        target3.Group_Channel__c = 'BBD';
        target3.Channel_Name__c = 'Branch';
        target3.Rank__c = '1.1';
        target3.Branch_Point_Engine__c = 70;
        target3.Unique_External_Key__c = '202201043SUM1001Region';
        target3.RecordTypeId = recordTypeIdRegion;
        targetlist.add(target3);

        T_Performance_Target_Product_by_Team__c target4 = new T_Performance_Target_Product_by_Team__c();
        target4.Product_Group_Name__c = 'MF Type B	';
        target4.Actual_Amount__c =10;
        target4.Cap_Max_Pct__c = 0;
        target4.Target_Unit_Month__c = 5;
        target4.Target_Unit_Year__c = 150;
        target4.Indicator_Level1__c = 'Deposit&Investment	';
        target4.Year__c = String.valueOf(Date.Today().year()) ;
        target4.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target4.Product_Group_Code__c = 'SUM1001';
        target4.Product_List__c = 'BR1001;BR1002;';
        target4.Group_Channel__c = 'BBD';
        target4.Channel_Name__c = 'Branch';
        target4.Rank__c = '1.1';
        target4.Branch_Point_Engine__c = 70;
        target4.Unique_External_Key__c = '202201043SUM1001Channel';
        target4.RecordTypeId = recordTypeIdChannel;
        targetlist.add(target4);

        T_Performance_Target_Product_by_Team__c target5 = new T_Performance_Target_Product_by_Team__c();
        target5.Product_Group_Name__c = 'MF Type B	';
        target5.Actual_Amount__c =10;
        target5.Cap_Max_Pct__c = 0;
        target5.Target_Unit_Month__c = 5;
        target5.Target_Unit_Year__c = 150;
        target5.Indicator_Level1__c = 'Deposit&Investment	';
        target5.Year__c = String.valueOf(Date.Today().year()) ;
        target5.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target5.Product_Group_Code__c = 'SUM1001';
        target5.Product_List__c = 'BR1001;BR1002;';
        target5.Group_Channel__c = 'BBD';
        target5.Rank__c = '1.1';
        target5.Branch_Point_Engine__c = 70;
        target5.Unique_External_Key__c = '202201043SUM1001GOC';
        target5.RecordTypeId = recordTypeIdGOC;
        targetlist.add(target5);
        insert targetlist;

        List<T_Performance_Target_Product_by_Team__c> targetlist1 = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c target1 = new T_Performance_Target_Product_by_Team__c();
        target1.Product_Group_Name__c = 'MF Type B	';
        target1.Actual_Amount__c =10;
        // target1.Actual_Amount_with_Capmax__c = 100;
        target1.Cap_Max_Pct__c = 0;
        target1.Target_Unit_Month__c = 5;
        target1.Target_Unit_Year__c = 150;
        target1.Branch_Team_Code__c = '043';
        target1.Region_Code__c = '1800';
        target1.Indicator_Level1__c = 'Deposit&Investment';
        target1.Zone_Code__c = '1820';
        target1.Year__c = String.valueOf(Date.Today().year()) ;
        target1.Month__c = String.valueOf(Date.today().month()).leftPad(2, '0');
        target1.Product_Group_Code__c = 'SUM1001';
        target1.Product_List__c = 'BR1001;BR1002;';
        target1.Group_Channel__c = 'BBD';
        target1.Channel_Name__c = 'Branch';
        target1.Rank__c = '1.1';
        target1.Branch_Point_Engine__c = 70;
        target1.Unique_External_Key__c = '202201042SUM1001';
        targetlist1.add(target1);
        insert targetlist1;

        String level = 'branch';
        String year = String.valueOf(Date.Today().year());
        String month = String.valueOf(Date.today().month()).leftPad(2, '0');
        
        // T_PerformanceSummarizeActualAmoutBatch data = new T_PerformanceSummarizeActualAmoutBatch('branch', '2022', '01', BATCH_CHUNK_SIZE);
        Test.startTest();
        T_PerformanceSummarizeActualAmoutBatch data = new T_PerformanceSummarizeActualAmoutBatch(level, year, month, BATCH_CHUNK_SIZE,null);
        Database.executeBatch(data, BATCH_CHUNK_SIZE);
        Test.stopTest();

    }
  
}