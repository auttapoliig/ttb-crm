@isTest
public class BirthdayReportTest {

    @TestSetup
    static void makeData(){
        Date today = Date.today();
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
        acct.RTL_Date_Of_Birth__c = date.newInstance(1999, today.month(), today.day() + 1);
        acct.OwnerId = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1].Id;
        insert acct;
    }

	@isTest
    static void test(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            BirthdayReport.getBirthdayList(5);
        }
        Test.stopTest();
    }
}