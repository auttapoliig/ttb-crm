@isTest
public with sharing class editCustomerForCCOutboundCSVCtlTest {

    @TestSetup
    static void settingAppConfig(){
        AppConfig__c appConfig1 = new AppConfig__c(Name='runtrigger', Value__c='false');
        insert appConfig1;
        
        AppConfig__c appConfig2 = new AppConfig__c(Name='runCustomerNoteTrigger', Value__c='false');
        insert appConfig2;

        AppConfig__c appConfig3 = new AppConfig__c(Name='DefaultOwner', Value__c='00000');
        insert appConfig3;

        AppConfig__c appConfig4 = new AppConfig__c(Name='FilterRetailSegment', Value__c='5|6|7|8|9');
        insert appConfig4;

        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Section_Name__c = 'RtlCust:Contact Number and Email Address';
        dsm.Profile_Name__c = 'System Administrator';
        dsm.Access_Type__c = 'All';
        insert dsm;
    }

    @isTest
    static void getDescribeFieldResultAndValue() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        insert acct;

        List<String> fields = new List<String>{'Id', 'Name'};
        List<String> fields_translate = new List<String>();
        Test.startTest();
            Object returnObj = editCustomerForCCOutboundCSVController.getDescribeFieldResultAndValue(acct.Id, fields, fields_translate);
        Test.stopTest();
    }

    @isTest
    static void testGetInitialData() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        insert acct;
        Test.startTest();
            System.runAs(testUser[0]) {
                System.debug(testUser[0]);

                Object returnObj = editCustomerForCCOutboundCSVController.getInitialData(acct.Id);
                Map<String, Object> returnAccObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(returnObj));

                Map<String, Object> returnAccountId = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(returnAccObj.get('account')));
                
                System.assertEquals(acct.Id, returnAccountId.get('Id'));

                try {
                    Object falsereturnObj = editCustomerForCCOutboundCSVController.getInitialData(null);
                } catch (Exception e) {
                    
                }
            }
        Test.stopTest();
    }

    @isTest
    static void testUpdateAccountData() {
        List<User> testUser = TestUtils.createUsers(1, 'myTest', 'User1', 'testUser1@example.com', true);
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RTL_Wealth_RM__c = testUser[0].Id;
        acct.TMB_Employee_ID__c = testUser[0].Employee_ID__c;
        insert acct;

        Account acctToUpdate = [SELECT Id, Mobile_Number_PE__c FROM Account WHERE Id =:acct.Id];
        acctToUpdate.Mobile_Number_PE__c = '0000000000';
        
        Test.startTest();
            System.runAs(testUser[0]) {
                Map<String, Object> returnResult = editCustomerForCCOutboundCSVController.updateAccountData(acctToUpdate);
                System.assertEquals(true, returnResult.get('success'));

                try {
                    Map<String, Object> failResult = editCustomerForCCOutboundCSVController.updateAccountData(null);
                } catch (Exception e) {
                    
                }
            }
        Test.stopTest();
    }
}