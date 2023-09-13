@isTest
public class CampaignMemberCallBackCtrlTest {
    @testSetup static void setup() {
        // Implement test code
        
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        
        //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        AccountTeamMember atm = new AccountTeamMember(accountid = acc.id, UserId = u.id);
        insert atm;
        
        Contact ct = RTL_TestUtility.createContacts(acc);
        ct.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c;
        ct.OwnerId = u.id;
        insert ct;
        
        Lead lead = RTL_TestUtility.createLeads(1,false).get(0);
        insert lead;
        
        
        Branch_And_Zone__c branch = RTL_TestUtility.createBranchZone(1,true).get(0);
        RTL_Referral__c rf = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                                 RTL_LastName__c='Without Account',
                                                 RTL_Mobile1__c = '1111111111',
                                                 RTL_Preferred_Branch__c = branch.Id);
        
        insert rf;        
        
        Campaign masterC = new Campaign();
        masterC.Name = 'Test Campaign';
        masterC.OwnerId  = u.id;
        masterC.isActive = true;
        masterC.Approvedflag__c = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        insert masterC;   
        
        //Commercial Lead
        RecordType recordType = [select Id from RecordType where developername='Commercial_Lead' and IsActive = true limit 1];   
        Lead comLead = new Lead();
        comLead.Title = 'TH';
        comLead.Company = 'X';
        comLead.FirstName = 'Test';
        comLead.LastName = 'TestcomLead';
        comLead.Email = 'test1@salesforce.com';
        comLead.RTL_Mobile_Number__c = '1111111111';
        comLead.RTL_Phone_Number__c = '222222222';
        comLead.RTL_Office_Number__c = '333333333';
        comLead.Status = 'New';
        comLead.Street = 'aaa';
        comLead.City = 'bbb';
        comLead.State = 'CC';
        comLead.PostalCode = '1111111';
        comLead.Country = 'DD';
        comLead.RecordTypeId = recordType.id;
        comLead.RTL_ID_Type__c = 'Passport ID';
        comLead.RTL_Citizen_Id__c = 'aaaaaa';
        comLead.RTL_Web_Unique_ID_c__c = 'Test';
        comLead.Avaya_Integration_Lead__c = true;
        insert comLead;

        //Call Log Record Type
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Call';
        newTask.Subject = 'Call';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        newTask.Call_Start_Datetime__c = Date.today();
        newTask.Related_Object__c = comLead.Id ;
        newTask.Agent_Extension_Number__c = '7841';
        newTask.RTL_Channel__c = 'Outbound Call';
        insert newTask;

        Task_Extension__c newTaskExtension = new Task_Extension__c();
        newTaskExtension.Task_Id__c = newTask.Id;
        newTaskExtension.AVY_Agent_id__c = '1251789';
        newTaskExtension.AVY_Contact_List_Name__c = 'RestContactList' ;
        newTaskExtension.AVY_Campaign_Name__c = 'hrCamp';
        insert newTaskExtension;
           
    }
    
    
    @isTest static void insertTask() 
    {
        Test.StartTest();
        // Implement test code   
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('datetime','1614826800000');
        valueMap.put('date',Date.today());
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');       
        
        CampaignMemberCallBackCtrl.insertTask(cm.Id, valueMap,'12345','Default');
        Test.StopTest();
    }
    
    @isTest static void insertTaskLead() 
    {
        Test.StartTest();
        // Implement test code   
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.LeadId = ld.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('datetime','1614826800000');
        valueMap.put('date',Date.today());
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        
        CampaignMemberCallBackCtrl.insertTask(cm.Id, valueMap,'12345','Default');
        Test.StopTest();
    }
    
    @isTest static void transformDateTime() 
    {
        Test.StartTest();
        CampaignMemberCallBackCtrl.transformDateTime('1614826800000');
        Test.StopTest();
    }
    
    @isTest static void rescheduleCallback() 
    {
        Test.StartTest();
        // Implement test code   
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Outbound';
        newTask.Subject = 'Call Back';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Back').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        insert newTask;
        
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',newTask.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('date',Date.today());
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        
        CampaignMemberCallBackCtrl.rescheduleCallback(valueMap,'Default');
        Test.StopTest();
    }
    
     @isTest static void searchExistingCallback() 
    {
        Test.StartTest();
        // Implement test code   
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Outbound';
        newTask.Subject = 'Call Back';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Back').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        insert newTask;

        CampaignMemberCallBackCtrl.searchExistingCallback(newTask.Id);
        Test.StopTest();
    }

    @isTest static void scheduleCallbackSuccess() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(200,
                                                 'OK',
                                                 '{'+ '"callbackID": 83'+'}',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        System.assertEquals('83', String.valueOf(result.get('callbackID')));
        Test.StopTest();
    }

    @isTest static void scheduleCallbackFail1() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(500,
                                                 'OK',
                                                 '{'+
                                                    '"displayMessage": "null",'+
                                                    '"errorCode": "3307",'+
                                                    '"errorMessage": "Agent not found",'+
                                                    '"detailedCode": 0'+
                                                '}',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        System.assertEquals('3307', String.valueOf(result.get('errorCode')));
        Test.StopTest();
    }

    @isTest static void scheduleCallbackFail2() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(500,
                                                 'OK',
                                                 'null',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        Test.StopTest();
    }

    @isTest static void scheduleCallbackFail3() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(404,
                                                 'OK',
                                                 '{'+
                                                    '"displayMessage": "null",'+
                                                    '"errorCode": "3307",'+
                                                    '"errorMessage": "Agent not found",'+
                                                    '"detailedCode": 0'+
                                                '}',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        Test.StopTest();
    }

    @isTest static void scheduleCallbackFail4() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(400,
                                                 'OK',
                                                 '{'+
                                                    '"displayMessage": "null",'+
                                                    '"errorCode": "3307",'+
                                                    '"errorMessage": "Agent not found",'+
                                                    '"detailedCode": 0'+
                                                '}',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        Test.StopTest();
    }

    @isTest static void scheduleCallbackFail5() 
    {
        Test.StartTest(); 
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id,AVY_Agent_id__c ,AVY_Campaign_Name__c,AVY_Contact_List_Name__c FROM Task_Extension__c LIMIT 1];
        Map<String, Object> valueMap = new	Map<String, Object>();
        valueMap.put('task_id',task.Id);
        valueMap.put('datetime','1614826800000');
        valueMap.put('number','0987654321');
        valueMap.put('note','Test');
        valueMap.put('mode','Strict Agent');
        valueMap.put('agentId', taskExtension.AVY_Agent_id__c);
        valueMap.put('contactListName',taskExtension.AVY_Contact_List_Name__c);
        valueMap.put('campaignName',taskExtension.AVY_Campaign_Name__c);
        valueMap.put('sfId',lead.Id);
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(000,
                                                 'OK',
                                                 '{'+
                                                    '"displayMessage": "null",'+
                                                    '"errorCode": "3307",'+
                                                    '"errorMessage": "Agent not found",'+
                                                    '"detailedCode": 0'+
                                                '}',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String, Object> result = CampaignMemberCallBackCtrl.scheduleCallback(valueMap);
        Test.StopTest();
    }


    @isTest static void getAvayaIntegrationLeadTest() 
    {
        Test.StartTest();
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Boolean result = CampaignMemberCallBackCtrl.getAvayaIntegrationLead(lead.Id);
        System.assertEquals(result, true);
        Test.StopTest();
    }

    @isTest static void searchExistingLogCallTest() 
    {
        Test.startTest();
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        Task result = CampaignMemberCallBackCtrl.searchExistingLogCall(lead.Id, '12345' );
        System.assertEquals(result.Id,task.Id);
        Test.StopTest();
    }

    @isTest static void CheckCallBackPermissionTest() 
    {
        Test.startTest();
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];
        CampaignMemberCallBackCtrl.CheckCallBackPermission(lead.Id);
        Test.StopTest();
    }

    @isTest static void getTaskExtensionTest() 
    {
        Test.startTest();
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        Task_Extension__c taskExtension = [SELECT Id FROM Task_Extension__c LIMIT 1];
        Task_Extension__c result = CampaignMemberCallBackCtrl.getTaskExtension(task.Id);
        System.assertEquals(result.Id,taskExtension.Id);
        Test.StopTest();
    }

    @isTest static void getCurrentUser()
    {
        Test.startTest();
        CampaignMemberCallBackCtrl.getCurrentUser();       
        Test.stopTest();       
    }

    @isTest static void getSalesforceIdCaseCampaignMember() 
    {
        Test.startTest();
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        cm.RTL_Marketing_code__c  = 'DEGGUOL11A1354363062';
        insert cm;

        String result = CampaignMemberCallBackCtrl.getSalesforceId(cm.Id);
        System.assertEquals(result,cm.RTL_Marketing_code__c);
        Test.StopTest();
    }

    @isTest static void getSalesforceIdCaseLeadOrReferral() 
    {
        Test.startTest();
        Lead lead = [SELECT Id FROM Lead WHERE RecordType.Name = 'Commercial Lead' LIMIT 1];

        String result = CampaignMemberCallBackCtrl.getSalesforceId(lead.Id);
        System.assertEquals(result,lead.Id);
        Test.StopTest();
    }

    @isTest static void isCampaignMemberTest() 
    {
        Test.startTest();
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        cm.RTL_Marketing_code__c  = 'DEGGUOL11A1354363062';
        insert cm;

        Boolean result = CampaignMemberCallBackCtrl.isCampaignMember(cm.Id);
        System.assertEquals(result,true);
        Test.StopTest();
    }

    @isTest static void cancelCallBackTest() 
    {
        Test.startTest();
        Task task = [SELECT Id FROM Task WHERE RecordType.Name = 'Call Log Record Type' LIMIT 1];
        CampaignMemberCallBackCtrl.cancelCallback(task.id);
        Test.StopTest();
    }

}