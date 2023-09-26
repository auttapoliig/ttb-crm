@isTest
public class RTL_SchedulerEmailErrorLogTest {
    @testSetup static void setupmethod() {
        TestUtils.createAppConfig();
        RTL_TestUtility.createEmailConfig();
    }
    //use createddate to test since it's not able to change lastmodifieddate
    public static testMethod void scheduleEmailErrorLogTest(){
        //create retail online service log
        RTL_TestUtility.createOnlineServiceLog(100,true);
        List<Account> accList = RTL_TestUtility.createAccountDataQualityNA(true);
        List<Opportunity> oppListUpdate = TestForUtility.createOpportunities(accList.get(0),1,true);
        List<Campaign> commCampList = TestForUtility.createCampaign(1,'SE',true);
        TestForUtility.createCommLead(1, true,commCampList.get(0).Id);
        
        for (Opportunity opp:oppListUpdate) {
            opp.RTL_IsLock__c = false;
            opp.StageName = 'Closed Won (Deposit)';
        }

        update oppListUpdate;

        for (Opportunity opp:oppListUpdate) {
            opp.RTL_Lock_Opp_Date__c = Date.today().addDays(-1);
        }
        update oppListUpdate;

        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'On_Demand_Expired_Opportunity';
        Aconfig.Value__c = String.valueOf(Date.today());  

        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'On_Demand_Expired_Opportunity_N_DAYS';
        Aconfig2.Value__c = '0';

        apps.add(Aconfig);
        apps.add(Aconfig2);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'Inactive_User_Batch';
        Aconfig3.Value__c = 'true';

        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'Report_Export';
        Aconfig4.Value__c = 'true';

        apps.add(Aconfig3);
        apps.add(Aconfig4);

        insert apps;
        
        
        Schedule_Report_Config__c schReport = new Schedule_Report_Config__c();
        schReport.Name = 'Report1';
        schReport.Email__c = 'test@tmbbank.com';
        schReport.File_Name__c = 'test report';
        schReport.Report_Unique_Name__c = 'SampleReportTopAccounts';
        insert schReport;
        

        List<Migration_Info__c> migtLst = new List<Migration_Info__c>();
        migtLst.add(new Migration_Info__c(
            Name = 'Migrate_Branch_And_Zone',
            Email__c = 'aa@aa.com;bb@bb.com',
            IsActive__c = true,
            Migrated_Field__c = '',
            Migrated_Field_1__c = '',
            Migrated_Field_2__c = '',
            ObjectName__c = 'Branch_and_Zone__c',
            SQL1__c = 'Id,Name,Branch_Code__c',
            SQL2__c = 'Where RTL_Zone_Code__c in (\'6480\',\'6490\')',
            SQL3__c = '',
            Type__c = 'MIGRATE_INFO'
        ));
        migtLst.add(new Migration_Info__c(
            Name = 'CampaignMember_Closed_Won_Report',
            Email__c = 'aa@aa.com;bb@bb.com',
            IsActive__c = true,
            Migrated_Field__c = 'RTL_RelatedOpportunity_2__r.Closed_Won_Emp__c,RTL_RelatedOpportunity_2__r.Closed_Won_Date__c,RTL_RelatedOpportunity_3__r.Closed_Won_Emp__c,RTL_RelatedOpportunity_3__r.Closed_Won_Date__c',
            Migrated_Field_1__c = '',
            Migrated_Field_2__c = 'RTL_RelatedOpportunity_4__r.Closed_Won_Emp__c,RTL_RelatedOpportunity_4__r.Closed_Won_Date__c,RTL_RelatedOpportunity_5__r.Closed_Won_Emp__c,RTL_RelatedOpportunity_5__r.Closed_Won_Date__c',
            ObjectName__c = 'CampaignMember',
            SQL1__c = 'Id,Customer__r.TMB_Customer_ID_PE__c,Oldest_Closed_Date_Opportunity__c,RTL_RelatedOpportunity_1__r.Closed_Won_Emp__c,RTL_RelatedOpportunity_1__r.Closed_Won_Date__c',
            SQL2__c = '',
            SQL3__c = '',
            Type__c = 'EXPORT_REPORT'
        ));

        migtLst.add(new Migration_Info__c(
            Name = 'Fulfillment_Upload',
            Email__c = '',
            IsActive__c = true,
            Migrated_Field__c = 'RTL_Fulfillment_Type__c,RTL_Description__c,RTL_Account_ID__c,RTL_Amount__c,RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,RTL_Customer__r.TMB_Customer_ID_PE__c,RTL_Delivery_Date__c,RTL_Fulfillment_ID__c,RTL_Fulfillment_Status__c',
            Migrated_Field_1__c = 'RTL_Fulfillment_Type__c,RTL_Home_No__c,RTL_Mobile_No__c,RTL_Office_No__c,RTL_PCI_Card_NO__c',
            Migrated_Field_2__c = '',
            ObjectName__c = 'RTL_Fulfillment__c',
            SQL1__c = '',
            SQL2__c = '',
            SQL3__c = '',
            Type__c = 'UPLOAD_EMAIL'
        ));
        insert migtLst;
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;

        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        insert camp;
            
    
        List<CampaignMember> cmList = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'Web';     
        cm1.RTL_Product_Name__c = 'product';
        cm1.RTL_Lead_Group__c =  'group';
        cm1.RTL_OfferResult_Product_1__c = 'N/A';
        cmList.add(cm1);
            
        Contact con1 = RTL_TestUtility.createContacts(accList.get(0));
        con1.OwnerId = firstUser.id;
        insert con1;
    
        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = con1.id;
        cm2.CampaignId = camp.id;
        cm2.RTL_TMB_Campaign_Source__c = 'Web';     
        cm2.RTL_Product_Name__c = 'product';
        cm2.RTL_Lead_Group__c =  'group';
        cm2.RTL_OfferResult_Product_1__c = 'N/A';
        cmList.add(cm2);
    
        insert cmList;

        List<Opportunity> opptList = new List<Opportunity>();
        Id retailBancassuranceOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Retail_Bancassurance').getRecordTypeId();
        for (Integer i = 0;i<10;i++) {
            Opportunity o = new Opportunity(Name='II-OPP-'+i,
                                StageName = 'Analysis',
                                CloseDate = Date.today(),
                                AccountId = accList.get(0).Id,
                                Description = 'desc'+i,
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Expected_submit_date__c = Date.today(),
                                RecordTypeId=retailBancassuranceOpportunityRecordTypeId,
                                Created_Channel__c = 'Branch'
                            );
            opptList.add(o);
        }
        
        insert opptList;
        Test.startTest();
        // Schedule the test job, but after Test.stopTest, the purge hasn't started.
        String jobId = System.schedule('EmailErrorLogTest', RTL_TestUtility.CRON_EXP, new RTL_SchedulerEmailErrorLog());
        Test.stopTest();
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(RTL_TestUtility.CRON_EXP, ct.CronExpression);
    }
    
    public static testMethod void batchEmailErrorLogTest(){
        //create retail online service log
       RTL_TestUtility.createOnlineServiceLog(100,true);  
        
        Test.startTest();
        
        // Call the batch class in order to check the batch result
        String query = 'select ID from RTL_Online_Service_Log__c where CreatedDate = TODAY LIMIT 10';
        RTL_BatchEmailErrorLog emailLog = new RTL_BatchEmailErrorLog(query);
        Id BatchProcessId = Database.ExecuteBatch(emailLog);
                
        Test.stopTest();
        
        
    }
}