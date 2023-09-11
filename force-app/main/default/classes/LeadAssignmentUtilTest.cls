@isTest
public class LeadAssignmentUtilTest {
    static User adminUser{
        get
        {
            if(adminUser == null){
                adminUser = [SELECT Id, Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.SYSADMIN_PROFILE_ID LIMIT 1];
            }
            return adminUser;
        }
        set;
    }

    static {
        System.runAs(adminUser){
                
            TestUtils.createAppConfig();

            Branch_and_zone__c bz = new Branch_and_zone__c();
            bz.Branch_Code__c = '001';
            bz.Name = '001';
            bz.RMC_User__c = adminUser.Id;
            bz.SE_Queue_Name__c = 'test_queue';
            bz.isActive__c = true;
            insert bz;

            Group queue = new Group();
            queue.Name = 'Email - TMB';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;
            
            QueuesObject qsObject = new QueueSObject();
            qsObject.QueueId = queue.Id;
            qsObject.SobjectType = 'Lead';
            insert qsObject;
            
            RTL_TestUtility.enableWebToLeadAutoAssign(true);
            RTL_TestUtility.createCampaignAssignmentRule();
        }
    }

    @isTest
    public static void testCreateLeadCommercialAssignUserField(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignUser(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User__c = userinfo.getUserId();
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Web';
        insert leadAssignmentrule;

        RTL_Lead_Assignment_Rule__c leadAssignmentrule2 = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule2.RTL_Active_Flag__c = true;
        leadAssignmentrule2.RTL_Priority__c = 0;
        leadAssignmentrule2.RTL_IsInsertProduct__c = true;
        leadAssignmentrule2.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule2.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule2.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule2.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule2.RTL_Lead_Field_Value_1__c = 'Web2';
        insert leadAssignmentrule2;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Web';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignQueueName(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_Queue_Name__c = 'test_queue';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignBranchZoneUserField(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Branch_and_Zone_Queue_User_field__c = 'SE_Queue_Name__c';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Q';
        insert leadAssignmentrule;

        leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 2;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Branch_and_Zone_Queue_User_field__c = 'RMC_User__c';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'User';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Q';
        led.RTL_Branch_Name__c = '001';
        insert led;

        Lead led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        led2.RTL_Branch_Name__c = '001';
        insert led2;
        
        led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        led2.RTL_Branch_Name__c = '111';
        insert led2;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignDefult(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Default_Queue_Name__c = 'test_queue';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Q';
        insert leadAssignmentrule;

        leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 2;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Default_User__c = adminUser.Id;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'User';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Q';
        insert led;

        Lead led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        insert led2;
        Test.stopTest();
    }
    @isTest
    public static void testCreateLeadNoMultiCover(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);
        Test.startTest();
        Lead led = new Lead();
        led.Company = 'Company';
        led.RecordTypeId = '01290000000iZYK';
        led.FirstName = 'Test';
        led.LastName = 'Test';
        led.RTL_Web_Unique_ID_c__c = 'WEB000000123001';
        led.RTL_Mobile_Number__c= '0946528664';
        led.RTL_Multiple_Interested_Product_s__c= false;
        led.RTL_Product_Name__c = 'GBHCC';
        led.RTL_Contact_Method__c = 'Normal Request';
        led.LeadSource = 'Referral';
        led.RTL_BranchW2L_Area__c = '18000';
        led.RTL_Branch_Name__c = '444';
        led.RTL_Priority_Product__c = '';
        insert led;

        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadNoMultiNoCover(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Not Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);
        Test.startTest();
        Lead led = new Lead();
        led.Company = 'Company';
        led.RecordTypeId = '01290000000iZYK';
        led.FirstName = 'Test';
        led.LastName = 'Test';
        led.RTL_Web_Unique_ID_c__c = 'WEB000000123001';
        led.RTL_Mobile_Number__c= '0946528664';
        led.RTL_Multiple_Interested_Product_s__c= false;
        led.RTL_Product_Name__c = 'GBHCC';
        led.RTL_Contact_Method__c = 'Normal Request';
        led.LeadSource = 'Referral';
        led.RTL_BranchW2L_Area__c = '18000';
        led.RTL_Branch_Name__c = '444';
        led.RTL_Priority_Product__c = '';
        insert led;

        Test.stopTest();
    }
    @isTest
    public static void testCreateLeadMultiCover(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);
        Test.startTest();
        Lead led1 = new Lead();
        led1.Company = 'Company1';
        led1.RecordTypeId = '01290000000iZYK';
        led1.FirstName = 'multiple3';
        led1.LastName = 'Test3';
        led1.RTL_Web_Unique_ID_c__c = 'WEBtestclass123002';
        led1.RTL_Mobile_Number__c= '0946527648';
        led1.RTL_Multiple_Interested_Product_s__c= true;
        led1.RTL_Product_Name__c = 'GBHCC;GBHFC';
        led1.RTL_Contact_Method__c = 'Normal Request';
        led1.LeadSource = 'Referral';
        led1.RTL_BranchW2L_Area__c = '18000';
        led1.RTL_Branch_Name__c = '444';
        led1.RTL_Priority_Product__c = 'GBHCC';
        insert led1;

        Test.stopTest();
    }
    @isTest
    public static void testCreateLeadMultiNotCover(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Not Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);
        Test.startTest();
        Lead led1 = new Lead();
        led1.Company = 'Company1';
        led1.RecordTypeId = '01290000000iZYK';
        led1.FirstName = 'multiple3';
        led1.LastName = 'Test3';
        led1.RTL_Web_Unique_ID_c__c = 'WEBtestclass123002';
        led1.RTL_Mobile_Number__c= '0946527648';
        led1.RTL_Multiple_Interested_Product_s__c= true;
        led1.RTL_Product_Name__c = 'GBHCC;GBHFC';
        led1.RTL_Contact_Method__c = 'Normal Request';
        led1.LeadSource = 'Referral';
        led1.RTL_BranchW2L_Area__c = '18000';
        led1.RTL_Branch_Name__c = '444';
        led1.RTL_Priority_Product__c = 'GBHCC';
        insert led1;

        Test.stopTest();
    }
    @isTest
    public static void testCreateLeadnoProductNobranch(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);

        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        RTL_product_master__c product = new RTL_product_master__c(Name='Test', Product_Group__c='Credit Card', Product_Sub_group__c='Credit Card',Active__c=true);
        insert productList;



        Test.startTest();
        Lead led1 = new Lead();
        led1.Company = 'Company1';
        led1.RecordTypeId = '01290000000iZYK';
        led1.FirstName = 'multiple3';
        led1.LastName = 'Test3';
        led1.RTL_Web_Unique_ID_c__c = 'WEBtestclass123002';
        led1.RTL_Mobile_Number__c= '0946527648';
        led1.RTL_Multiple_Interested_Product_s__c= false;
        led1.RTL_Product_Name__c = 'test';
        led1.RTL_Contact_Method__c = 'Normal Request';
        led1.LeadSource = 'Referral';
        led1.RTL_BranchW2L_Area__c = '18000';
        led1.RTL_Branch_Name__c = '';
        led1.RTL_Priority_Product__c = '';
        insert led1;

        Test.stopTest();
    }
    // @isTest
    // public static void testCreateLeadnoProduct(){
    //     RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
    //     leadAssignmentrule.RTL_Active_Flag__c = true;
    //     leadAssignmentrule.RTL_Priority__c = 40;
    //     leadAssignmentrule.RTL_IsInsertProduct__c = true;
    //     leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
    //     leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
    //     leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
    //     leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
    //     leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
    //     leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
    //     leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
    //     insert leadAssignmentrule;

    //     RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
    //     coverarea.RTL_Area__c  ='Cover';
    //     coverarea.RTL_Zip_Code__c  ='18000';
    //     insert coverarea;

    //     RTL_TestUtility.createLeadAssignCriteriasGBH(true);

    //     List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
    //     RTL_product_master__c product = new RTL_product_master__c(Name='Test', Product_Group__c='Credit Card', Product_Sub_group__c='Credit Card',Active__c=true);
    //     insert productList;

    //     Group newgroup = new Group();
    //     newgroup.Name = 'Test_444';
    //     newgroup.DeveloperName = 'Test_444';
    //     newgroup.Type = 'Queue';
    //     insert newgroup;

    //     Branch_and_Zone__c newBranch = new Branch_and_Zone__c ();
    //     newBranch.Name = 'Test';
    //     newBranch.Branch_Code__c = '444';
    //     newBranch.RTL_Region_Code__c = '444';
    //     newBranch.RTL_Zone_Code__c = '444';
    //     newBranch.IsActive__c = true;
    //     insert newBranch;

    //     Test.startTest();
    //     Lead led1 = new Lead();
    //     led1.Company = 'Company1';
    //     led1.RecordTypeId = '01290000000iZYK';
    //     led1.FirstName = 'multiple3';
    //     led1.LastName = 'Test3';
    //     led1.RTL_Web_Unique_ID_c__c = 'WEBtestclass123002';
    //     led1.RTL_Mobile_Number__c= '0946527648';
    //     led1.RTL_Multiple_Interested_Product_s__c= false;
    //     led1.RTL_Product_Name__c = 'test';
    //     led1.RTL_Contact_Method__c = 'Normal Request';
    //     led1.LeadSource = 'Referral';
    //     led1.RTL_BranchW2L_Area__c = '18000';
    //     led1.RTL_Branch_Name__c = '444';
    //     led1.RTL_Priority_Product__c = '';
    //     insert led1;

    //     Test.stopTest();
    // }
    @isTest
    public static void testCreateLeadnoProductbranchnovalid(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 40;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Assigned_Apex__c = 'RTL_ReferAssignmentService';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'RTL_Contact_Method__c';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Normal Request';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Referral';
        insert leadAssignmentrule;

        RTL_Messenger_Cover_Area__c coverarea = new RTL_Messenger_Cover_Area__c();
        coverarea.RTL_Area__c  ='Cover';
        coverarea.RTL_Zip_Code__c  ='18000';
        insert coverarea;

        RTL_TestUtility.createLeadAssignCriteriasGBH(true);

        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        RTL_product_master__c product = new RTL_product_master__c(Name='Test', Product_Group__c='Credit Card', Product_Sub_group__c='Credit Card',Active__c=true);
        insert productList;

        Group newgroup = new Group();
        newgroup.Name = 'Test_444';
        newgroup.DeveloperName = 'Test_444';
        newgroup.Type = 'Queue';
        insert newgroup;

        Test.startTest();
        Lead led1 = new Lead();
        led1.Company = 'Company1';
        led1.RecordTypeId = '01290000000iZYK';
        led1.FirstName = 'multiple3';
        led1.LastName = 'Test3';
        led1.RTL_Web_Unique_ID_c__c = 'WEBtestclass123002';
        led1.RTL_Mobile_Number__c= '0946527648';
        led1.RTL_Multiple_Interested_Product_s__c= false;
        led1.RTL_Product_Name__c = 'test';
        led1.RTL_Contact_Method__c = 'Normal Request';
        led1.LeadSource = 'Referral';
        led1.RTL_BranchW2L_Area__c = '18000';
        led1.RTL_Branch_Name__c = '444';
        led1.RTL_Priority_Product__c = '';
        insert led1;

        Test.stopTest();
    }
}