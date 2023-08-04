@isTest
public with sharing class CCOutbound_CSVControllerTest {

    @TestSetup
    static void setUpTestData() {
        AppConfig__c appConfig1 = new AppConfig__c(Name='runtrigger', Value__c='false');
        insert appConfig1;
        
        AppConfig__c appConfig2 = new AppConfig__c(Name='runCustomerNoteTrigger', Value__c='false');
        insert appConfig2;

        AppConfig__c appConfig3 = new AppConfig__c(Name='DefaultOwner', Value__c='00000');
        insert appConfig3;

        AppConfig__c appConfig4 = new AppConfig__c(Name='FilterRetailSegment', Value__c='5|6|7|8|9');
        insert appConfig4;

        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Section_Name__c = 'RtlCust:Customer Relationship';
        dsm.Profile_Name__c = 'System Administrator';
        dsm.Access_Type__c = 'All';
        insert dsm;
        
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Section_Name__c = 'RtlCust:Sales Support Information';
        dsm2.Profile_Name__c = 'System Administrator';
        dsm2.Access_Type__c = 'All';
        insert dsm2;
    }

    @isTest
    static void testGetDescribeFieldFromOSC07() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);

        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        acct.RMC_TTB_Touch__c = true;
        acct.Last_login_success_date__c = Date.today();
        insert acct;

        String body = '{ "GetCVSAnalyticsDataResponse": { "Result": { "Status": "SUCCESS", "MIBStatus": "YES/YES", "UsagePercentage": "0:37:5:18:21:18", "suitability": "", "currentPrivilege2Desc": "- ดอกเบี้ยพิเศษ NO FIXED", "touchStatus": "YES", "ibStatus": "YES", "LastLoginSuccessDate": "2023-07-20" } }, "Status": { "StatusCode": "200", "StatusDesc": "Success" } }';

        Test.startTest();
            System.runAs(testUser[0]) {
                Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, body));
                Object returnObj = CCOutbound_CSVController.getDescribeFieldFromOSC07(acct.Id);
            }
        Test.stopTest();
    }

    @isTest
    static void testGetDescribeFieldFromOSC07_2() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);

        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        acct.RMC_TTB_Touch__c = true;
        acct.Last_login_success_date__c = Date.today();
        insert acct;

        Test.startTest();
            System.runAs(testUser[0]) {
                Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
                Object failedreturnObj = CCOutbound_CSVController.getDescribeFieldFromOSC07(acct.Id);
            }
        Test.stopTest();
    }

    @isTest 
    static void testGetReference() {
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        insert acct;
        Test.startTest();
            CCOutbound_CSVController.getReference(acct.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetDescribeFieldResultAndValue() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        insert acct;

        List<String> fields = new List<String>{'Id', 'Name'};
        List<String> fields_translate = new List<String>();

        Test.startTest();
        System.runAs(testUser[0]) {
            Object returnObj = CCOutbound_CSVController.getDescribeFieldResultAndValue(acct.Id, fields, fields_translate);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetDescribeFieldFromPDPA() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);

        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000051187';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        acct.RMC_TTB_Touch__c = true;
        insert acct;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
            System.runAs(testUser[0]) {
                Object returnObj = CCOutbound_CSVController.getDescribeFieldFromPDPA(acct.Id);
            }
        Test.stopTest();
    }

    @isTest
    static void testGetSetUpFormat() {
        Test.startTest();
            CCOutbound_CSVController.getSetUpFormat('formatName');
        Test.stopTest();
    }

    @isTest
    static void testGetWatermarkHTML() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);
        Test.startTest();
            System.runAs(testUser[0]) {
                CCOutbound_CSVController.getWatermarkHTML();
            }
        Test.stopTest();
    }

    @isTest 
    static void testGetSubDebtTransaction() {
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RMC_TTB_Touch__c = true;
        insert acct;

        Sub_Debt_Transaction__c subdebt = new Sub_Debt_Transaction__c();
        subdebt.Customer__c = acct.Id;
        subdebt.Name = 'TEST TRANSACTION';
        subdebt.Sub_Debt_Transaction_Name__c = 'TEST TRANSACTION';
        insert subdebt;
        Test.startTest();
            CCOutbound_CSVController.getSubDebtTransaction(acct.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetAccountFieldHandle() {
        Test.startTest();
            CCOutbound_CSVController.getAccountField(null);
        Test.stopTest();
    }

    @isTest
    static void testGetInstantLeningDetail() {
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RMC_TTB_Touch__c = true;
        insert acct;

        Retail_Instant_Lending__c ril = new Retail_Instant_Lending__c();
        ril.Instant_lending_detail__c = 'TEST';
        ril.Customer__c = acct.Id;
        insert ril;
        Test.startTest();
            CCOutbound_CSVController.getInstantLendingDetail(acct.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetSubSegmentDesc() {
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Privilege1__c = '';
        acct.RTL_Average_AUM__c = 0.0;
        acct.TMB_Customer_ID_PE__c = 'MOCKTESTACCOUNT000001';
        acct.RMC_TTB_Touch__c = true;
        acct.Sub_segment__c = '880';
        insert acct;

        Test.startTest();
            CCOutbound_CSVController.getSubSegmentDesc(acct.Id);

            try {
                CCOutbound_CSVController.getSubSegmentDesc(null);
            } catch (Exception e) {

            }
        Test.stopTest();
    }
}