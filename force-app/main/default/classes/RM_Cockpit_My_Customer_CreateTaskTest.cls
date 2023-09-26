@isTest
public class RM_Cockpit_My_Customer_CreateTaskTest {

    @TestSetup
    static void makeData(){
        AppConfig__c aConfig1 = new AppConfig__c(Name='runtrigger', Value__c='false');
        insert aConfig1;

        AppConfig__c aConfig2 = new AppConfig__c(Name='runCustomerNoteTrigger', Value__c = 'false');
        insert aConfig2;
    }

    @isTest
    static void testCreateTaskHelper() {
       
        List<String> acctIdList = new List<String>();
        
        List<Account> acctList = new List<Account>();

        List<User> Wealth_RMC = TestUtils.createUsers(1 ,'mvp2TestUser', 'user', 'mvp2_tus@example.com', true);
        
        Account acct = new Account();
        acct.Name = 'TEST ACCOUNT';
        acct.Mobile_Number_PE__c = '0812345678';
        acct.RTL_Wealth_RM__c = Wealth_RMC[0].id;
        acctList.add(acct);
        
        insert acctList;
        acctIdList.add(acct.Id);

        Test.startTest();
            RM_Cockpit_My_Customer_CreateTask.createTaskHelper(acctIdList);
        
            Integer checkSOQL = [SELECT COUNT() FROM Task WHERE WhatId IN :acctIdList];
        
            System.assertEquals(acctIdList.size(), checkSOQL);
        Test.stopTest();
    }
}