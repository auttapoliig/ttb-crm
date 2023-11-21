@isTest
public class DormantAccountControllerTest {

    @TestSetup
    static void makeData(){
        Date today = date.today();
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
        insert acct;

        Customer_Product_Alert__c cusp = new Customer_Product_Alert__c();
        cusp.Financial_Account_Group__c = 'DP-DORMANT';
        cusp.Amount__c = 1000000;
        cusp.Dormant_Date__c = today.addDays(10);
        cusp.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        insert cusp;
    }

	@isTest
    static void test(){
        DormantAccountController.getDormantAccount(5);
    }
}