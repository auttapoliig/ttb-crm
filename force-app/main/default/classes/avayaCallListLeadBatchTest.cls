@isTest
public class avayaCallListLeadBatchTest {
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
    static void avayaCallListLeadBatchTestService() {
        RTL_TestUtility.createRetailMasterProducts(true);
        List<lead> leadList = RTL_TestUtility.createLeads(1,false);
        leadList.get(0).RTL_Web_Unique_ID_c__c = '989988712';
        // leadList.get(0).RTL_Call_Back_Date_time__c = Datetime.now();
        leadList.get(0).RTL_TMB_Campaign_Source__c = 'Web';
        leadList.get(0).RTL_Contact_Method__c = 'Call Me Later';

        Test.setMock(HttpCalloutMock.class, new mockupResponse());
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            insert leadList;
        }
        Test.stopTest();
    }
    
    @isTest 
    static void avayaCallListLeadBatchTestServiceError() {
        RTL_TestUtility.createRetailMasterProducts(true);
        List<lead> leadList = RTL_TestUtility.createLeads(1,false);
        leadList.get(0).RTL_Web_Unique_ID_c__c = '989988712';
        // leadList.get(0).RTL_Call_Back_Date_time__c = Datetime.now();
        leadList.get(0).RTL_TMB_Campaign_Source__c = 'Web';
        leadList.get(0).RTL_Contact_Method__c = 'Call Me Later';
        
        Test.setMock(HttpCalloutMock.class, new mockupResponseError());
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            insert leadList;
            String leadQuery = 'SELECT Id, LeadId, Lead.Name, Lead.FirstName, Lead.LastName, Lead.RTL_Product_Name__c, Lead.RTL_Mobile_Number__c, Lead.RTL_Lead_Campaign_Outbound__c, Lead.RTL_Lead_Channel_Outbound__c, Lead.RTL_Call_Back_Date_time__c, Lead.RTL_Lead_Assigned_By_Rule__c, Lead.RTL_Web_Unique_ID_c__c, Lead.RTL_Call_Me_Now_Status__c, Lead.RTL_Call_Me_Now_Retry_Count__c, Lead.web_business01__c, Lead.web_business02__c, Lead.web_business03__c, Lead.web_business04__c, Lead.web_business05__c, Lead.web_business06__c, Lead.web_business07__c, Lead.web_business08__c, Lead.web_business09__c, Lead.web_business10__c ,Lead.RTL_Contact_Method__c, Lead.RTL_Remark__c FROM CampaignMember WHERE Id=\'' + leadList[0].id + '\'';
            Set<Id> leadIdset = new Set<Id>();
            DataBase.executeBatch(new avayaCallListLeadBatch(leadQuery, leadIdset), 100);
        }
        Test.stopTest();
    }
}