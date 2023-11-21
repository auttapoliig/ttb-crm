@istest
public class InvestmentReportControllerTest {

    @TestSetup
    static void makeData(){
        Date today = Date.Today();
        TestUtils.createAppConfig();

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        insert u;
        
        Account acct = new Account();
        acct.First_Name_PE__c = 'เสถียรพร';
        acct.Last_Name_PE__c = 'คำดี';
        acct.First_Name_ENG_PE__c = 'SathianP';
        acct.Last_Name_PE_Eng__c = 'KD';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'satian@tmb.com';
        acct.Mobile_Number_PE__c = '0998877665';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.RMC_AUM_Change__c = 10.00;
        acct.RTL_NID__c = '44466';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000000000500';
        acct.OwnerId = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1].Id;
        insert acct;

        Customer_Product_Alert__c cpa1 = new Customer_Product_Alert__c();
        cpa1.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        cpa1.Maturity_Date__c = date.newinstance(today.year(), today.month(), today.day() + 1);
        cpa1.Amount__c = 500000;
        cpa1.Financial_Account_Group__c = 'DP';

        Customer_Product_Alert__c cpa2 = new Customer_Product_Alert__c();
        cpa2.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        cpa2.Maturity_Date__c = date.newinstance(today.year(), today.month(), today.day() + 1);
        cpa2.Amount__c = 500000;
        cpa2.Financial_Account_Group__c = 'MF';
        List<Customer_Product_Alert__c> cpaList = new List<Customer_Product_Alert__c>{cpa1, cpa2};
        insert cpaList;
    }

	@istest
    static void getDepositTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            InvestmentReportController.getDeposit(5);
        }
        Test.stopTest();
    }

	@istest
    static void getMFTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            InvestmentReportController.getMF(5);
        }
        Test.stopTest();
    }    
}