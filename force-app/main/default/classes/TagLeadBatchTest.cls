@isTest
public class TagLeadBatchTest{
    static{
        TestUtils.createAppConfig();
        Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User User = new User(FirstName='Test',LastName='Test', 
                                    UserName='TestTMB@tmb.com',
                                    Email='Test@tmbbank.com', Alias='Test',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='TestNickname',
                                    ProfileId = ADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='11111');
        insert User;
        System.runAs(User){
            Lead newlead = new Lead();
            newlead.LastName = 'JuLead';
            newlead.recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
            newlead.Company = 'Test Lead';
            insert newlead;

            Product_Interest__c product = new Product_Interest__c();
            product.COM_Unqualified_Reason__c = 'reason1';
            product.COM_Sub_Unqualified_Reason__c = 'sub unqualified Reason1';
            product.Lead__c = newlead.Id;
            insert product;

            Task newTask = new Task();
            newTask.Call_Log_ID__c = '10002102911653563036';
            newTask.Call_Agent_Id__c = '11111';
            newTask.Call_Number__c = '0951234567';
            newTask.RTL_TMB_Customer_ID_PE__c = '001100000000000000000007964457';
            newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
            newTask.call_start_datetime__c = Datetime.now();
            newTask.Call_End_Time__c = Datetime.now().addHours(1);
            newTask.TaskSubtype = 'Call';
            newTask.Type = 'Call';
            newTask.Subject = 'Call';
            newTask.Agent_Extension_Number__c = '59056153';
            newTask.Status = 'In Progress';
            newTask.RTL_Channel__c = 'Outbound Call';
            newTask.Related_Object__c = newlead.Id;
            insert newTask;
            
            Task newTask_error = new Task();
            newTask_error.Call_Log_ID__c = '10002102911653563037';
            newTask_error.Call_Agent_Id__c = '11111';
            newTask_error.Call_Number__c = '0951234567';
            newTask_error.RTL_TMB_Customer_ID_PE__c = '001100000000000000000007964457';
            newTask_error.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
            newTask_error.call_start_datetime__c = Datetime.now();
            newTask_error.Call_End_Time__c = Datetime.now().addHours(1);
            newTask_error.TaskSubtype = 'Call';
            newTask_error.Type = 'Call';
            newTask_error.Subject = 'Call';
            newTask_error.Agent_Extension_Number__c = '59056153';
            newTask_error.Status = 'In Progress';
            newTask_error.RTL_Channel__c = 'Inbound Call';
            insert newTask_error;
        }
        
        
        List<Voice_Tagging_Setting__c> listvt = new List<Voice_Tagging_Setting__c>();

        Voice_Tagging_Setting__c AggregationOperator = new Voice_Tagging_Setting__c();
        AggregationOperator.name = 'AggregationOperator';
        AggregationOperator.Value__c = 'NONE';
        listvt.add(AggregationOperator);
        Voice_Tagging_Setting__c Application = new Voice_Tagging_Setting__c();
        Application.name = 'Application';
        Application.Value__c = 'EnterpriseTransactionManagement';
        listvt.add(Application);
        Voice_Tagging_Setting__c Conditions_type = new Voice_Tagging_Setting__c();
        Conditions_type.name = 'Conditions_type';
        Conditions_type.Value__c = 'AndLogicalExpression';
        listvt.add(Conditions_type);
        Voice_Tagging_Setting__c Database = new Voice_Tagging_Setting__c();
        Database.name = 'Database';
        Database.Value__c = 'LocalContact';
        listvt.add(Database);
        Voice_Tagging_Setting__c Direction = new Voice_Tagging_Setting__c();
        Direction.name = 'Direction';
        Direction.Value__c = 'Ascending';
        listvt.add(Direction);
        Voice_Tagging_Setting__c Field_AggregationOperator = new Voice_Tagging_Setting__c();
        Field_AggregationOperator.name = 'Field_AggregationOperator';
        Field_AggregationOperator.Value__c = 'NONE';
        listvt.add(Field_AggregationOperator);
        Voice_Tagging_Setting__c Field_Name = new Voice_Tagging_Setting__c();
        Field_Name.name = 'Field_Name';
        Field_Name.Value__c = 'AUDIO_START_TIME';
        listvt.add(Field_Name);
        Voice_Tagging_Setting__c Field_SequentialId = new Voice_Tagging_Setting__c();
        Field_SequentialId.name = 'Field_SequentialId';
        Field_SequentialId.Value__c = '0';
        listvt.add(Field_SequentialId);
        Voice_Tagging_Setting__c GUID = new Voice_Tagging_Setting__c();
        GUID.name = 'GUID';
        GUID.Value__c = '00000000-0000-0000-0000-000000000000';
        listvt.add(GUID);
        Voice_Tagging_Setting__c HasEmotion = new Voice_Tagging_Setting__c();
        HasEmotion.name = 'HasEmotion';
        HasEmotion.Value__c = 'false';
        listvt.add(HasEmotion);
        Voice_Tagging_Setting__c Operator_type = new Voice_Tagging_Setting__c();
        Operator_type.name = 'Operator_type';
        Operator_type.Value__c = 'AndLogicalOperator';
        listvt.add(Operator_type);
        Voice_Tagging_Setting__c PageSize = new Voice_Tagging_Setting__c();
        PageSize.name = 'PageSize';
        PageSize.Value__c = '100';
        listvt.add(PageSize);
        Voice_Tagging_Setting__c Period_Days = new Voice_Tagging_Setting__c();
        Period_Days.name = 'Period_Days';
        Period_Days.Value__c = '0';
        listvt.add(Period_Days);
        Voice_Tagging_Setting__c Period_Type = new Voice_Tagging_Setting__c();
        Period_Type.name = 'Period_Type';
        Period_Type.Value__c = 'Absolute';
        listvt.add(Period_Type);
        Voice_Tagging_Setting__c QueryPurpose = new Voice_Tagging_Setting__c();
        QueryPurpose.name = 'QueryPurpose';
        QueryPurpose.Value__c = 'SEARCH';
        listvt.add(QueryPurpose);
        Voice_Tagging_Setting__c QueryTime = new Voice_Tagging_Setting__c();
        QueryTime.name = 'QueryTime';
        QueryTime.Value__c = 'UTCTime';
        listvt.add(QueryTime);
        Voice_Tagging_Setting__c RandomSampling = new Voice_Tagging_Setting__c();
        RandomSampling.name = 'RandomSampling';
        RandomSampling.Value__c = 'false';
        listvt.add(RandomSampling);
        Voice_Tagging_Setting__c RequestedData_Field = new Voice_Tagging_Setting__c();
        RequestedData_Field.name = 'RequestedData_Field';
        RequestedData_Field.Value__c = 'AUDIO_MODULE_NUM';
        listvt.add(RequestedData_Field);
        Voice_Tagging_Setting__c RequestedData_SequentialId = new Voice_Tagging_Setting__c();
        RequestedData_SequentialId.name = 'RequestedData_SequentialId';
        RequestedData_SequentialId.Value__c = '0';
        listvt.add(RequestedData_SequentialId);
        Voice_Tagging_Setting__c UserId = new Voice_Tagging_Setting__c();
        UserId.name = 'UserId';
        UserId.Value__c = '8001';
        listvt.add(UserId);
        Voice_Tagging_Setting__c Visibility_UserRole = new Voice_Tagging_Setting__c();
        Visibility_UserRole.name = 'Visibility_UserRole';
        Visibility_UserRole.Value__c = 'Supervisor';
        listvt.add(Visibility_UserRole);
        insert listvt;
    }

    @isTest
    public static void testBatch(){
        String query = 'SELECT Id, Status,' +
                        '(SELECT Id, Name, COM_Offer_Result__c, COM_Unqualified_Reason__c FROM Product_Interest__r)' +
                        'FROM Lead ' +
                        'WHERE Recordtype.Name = \'Commercial Lead\'' +
                        ' ORDER BY CreatedDate ASC';

        List<Lead> listLead = Database.query(query);
        Test.setMock(HttpCalloutMock.class, new TelephonyVoiceTaggingHTTPMockResponse());
		Test.setMock(WebServiceMock.class, new datamodelwsVerintComMockImpl());
        Test.startTest();
        Database.executeBatch(new TagLeadBatch(listLead));
        Test.stopTest();
    }

    @isTest
    public static void testScheduled(){
        Test.setMock(HttpCalloutMock.class, new TelephonyVoiceTaggingHTTPMockResponse());
        Test.startTest();
        String jobId = System.schedule('test', '0 15 * ? * * *', new TagLeadSchedule());
        Test.stopTest();
    }
}