@isTest 
public class avayaCallListReferralBatchTest {
    private class mockupResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"api_token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"9f4082e43710ee3e981c989283a3a837","encrypted_data":"2f96f536740c1fefec528b0254d30e6c0f6fb333d91ad0c09a54eeef6d239178e2d3b65938174a826fe95432a2243391d4b34fb852a04e9433c06c80d6a0f7a6517278fe45407717ed9fcec8a69c522fdc1fe12e97764d528be16320f2a33a24777dc7b1344cf800668d9b424f046c13"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class mockupResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"api_token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"3ef089dbeaa6a83f148954dfceaac81f","encrypted_data":"7344ef3d4b57da5bc4894487affd9314244bd9793a215ca0816469c43eaf16e76d535a3987ffd5ce97e14d3e5589f45fd0a985d88f39bfb64813c9b3216491c35efe7f3ac6ac2359699c96df36777cf896df263cff6f3c298b4e2f1f9fec2beca35f20180ac7aee3164aecb22a83321c2d387398dbbea3dc641d56e9683faf61"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();

        AppConfig__c app = new AppConfig__c();
        app.Name = 'RTL_Referral_Assignment_ISNULL';
        app.Value__c = 'IS NULL';
        insert app;

        app = new AppConfig__c();
        app.Name = 'RTL_Referral_Assignment_NOTNULL';
        app.Value__c = 'IS NOT NULL';
        insert app;

        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 0;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_Queue_Name__c = 'RTLQ_Outbound';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Integration_Type__c = 'Avaya';

        insert leadAssignmentrule;

        RTL_TestUtility.enableWebToLeadAutoAssign(true);
        RTL_TestUtility.createCampaignAssignmentRule();
    }
    
    @isTest
    static void avayaCallListReferralBatchTestService() {
        RTL_TestUtility.createRetailMasterProducts(true);
        RTL_Referral__c refer = new RTL_Referral__c();
        refer.RecordtypeId = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Refer from Digital Channel').getRecordTypeId();
        refer.RTL_Title__c = 'Mr.';
        refer.RTL_FirstName__c = 'Taecha020tipon';
        refer.RTL_LastName__c = 'Janta020Par';
        refer.RTL_Mobile1__c = '0652312882';
        refer.RTL_Preferred_Branch__c = 'a090l000009ptMlAAI';
        refer.Assigned_Pool__c = 'OUTBOUND';
        refer.RTL_Channel_Segment__c = 'CMN_FNA';
        refer.FNA_Have_Loan_Product__c = true;
        refer.RTL_Campaign_Reference__c = 'Normal Request';
        refer.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        refer.RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB';
        refer.RTL_Reporting_Product__c = 'Loan';
        refer.RTL_Sub_Product__c = 'สินเชื่อเงินกู้เบิกเกินบัญชีทั่วไป';
        refer.web_business01__c = 'web_business01__c';
        refer.web_business02__c = 'web_business02__c';
        refer.web_business03__c = 'web_business03__c';
        refer.web_business04__c = 'web_business04__c';
        refer.web_business05__c = 'web_business05__c';
        refer.web_business06__c = 'web_business06__c';
        refer.web_business07__c = 'web_business07__c';
        refer.web_business08__c = 'web_business08__c';
        refer.web_business09__c = 'web_business09__c';
        refer.web_business10__c = 'web_business10__c';
        refer.RTL_Remark_from_Online_Loan__c = 'REMARK TEST';

        Test.setMock(HttpCalloutMock.class, new mockupResponse());
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            insert refer;
            String referralQuery = 'SELECT Id, Name, RTL_FirstName__c, Assigned_Pool__c, RTL_LastName__c, RTL_RecordType_Name__c, RTL_Product_Name_Str__c, FNA_Product_Name__c, RTL_Interested_Product__c, RTL_Sub_Product__c, RTL_Mobile1__c, RTL_Channel_Segment__c, RTL_Campaign__c, RTL_Call_Me_Now_Request_Count__c, web_business01__c, web_business02__c, web_business03__c, web_business04__c, web_business05__c, web_business06__c, web_business07__c, web_business08__c, web_business09__c, web_business10__c, RTL_Remark_from_Online_Loan__c FROM RTL_Referral__c WHERE Id = \'' + refer.Id + '\'';
            Set<Id> referralId = new Set<Id>();
            referralId.add(refer.Id);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralId), 100);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralQuery, referralId), 100);
        }
        Test.stopTest();
    }

    @isTest
    static void avayaCallListReferralBatchTestServiceError() {
        RTL_TestUtility.createRetailMasterProducts(true);
        RTL_Referral__c refer = new RTL_Referral__c();
        refer.RecordtypeId = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Cross Channel Referral').getRecordTypeId();
        refer.RTL_Title__c = 'Mr.';
        refer.RTL_FirstName__c = 'Taecha020tipon';
        refer.RTL_LastName__c = 'Janta020Par';
        refer.RTL_Mobile1__c = '0652312882';
        refer.RTL_Preferred_Branch__c = 'a090l000009ptMlAAI';
        refer.Assigned_Pool__c = 'OUTBOUND';
        refer.RTL_Channel_Segment__c = 'CMN_FNA';
        refer.FNA_Have_Loan_Product__c = true;
        refer.RTL_Campaign_Reference__c = 'Normal Request';
        refer.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        refer.RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB';
        refer.RTL_Reporting_Product__c = 'Loan';
        refer.RTL_Sub_Product__c = 'สินเชื่อเงินกู้เบิกเกินบัญชีทั่วไป';
        refer.web_business01__c = 'web_business01__c';
        refer.web_business02__c = 'web_business02__c';
        refer.web_business03__c = 'web_business03__c';
        refer.web_business04__c = 'web_business04__c';
        refer.web_business05__c = 'web_business05__c';
        refer.web_business06__c = 'web_business06__c';
        refer.web_business07__c = 'web_business07__c';
        refer.web_business08__c = 'web_business08__c';
        refer.web_business09__c = 'web_business09__c';
        refer.web_business10__c = 'web_business10__c';
        refer.RTL_Remark_from_Online_Loan__c = 'REMARK TEST';

        Test.setMock(HttpCalloutMock.class, new mockupResponseError());
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            insert refer;
            String referralQuery = 'SELECT Id, Name, RTL_FirstName__c, Assigned_Pool__c, RTL_LastName__c, RTL_RecordType_Name__c, RTL_Product_Name_Str__c, FNA_Product_Name__c, RTL_Interested_Product__c, RTL_Sub_Product__c, RTL_Mobile1__c, RTL_Channel_Segment__c, RTL_Campaign__c, RTL_Call_Me_Now_Request_Count__c, web_business01__c, web_business02__c, web_business03__c, web_business04__c, web_business05__c, web_business06__c, web_business07__c, web_business08__c, web_business09__c, web_business10__c, RTL_Remark_from_Online_Loan__c FROM RTL_Referral__c WHERE Id = \'' + refer.Id + '\'';
            Set<Id> referralId = new Set<Id>();
            referralId.add(refer.Id);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralId), 100);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralId), 100);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralId), 100);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralId), 100);
            DataBase.executeBatch(new avayaCallListReferralBatch(referralQuery, referralId), 100);
        }
        Test.stopTest();
    }
}