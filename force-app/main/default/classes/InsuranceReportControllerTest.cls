@Istest
public class InsuranceReportControllerTest {

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
        acct.KYC_next_review_date__c = today.addDays(1);
        insert acct;

        Customer_Product_Alert__c cusp = new Customer_Product_Alert__c();
        cusp.Insurance_Maturity_Date__c = today.addDays(1);
        cusp.Financial_Account_Group__c = 'BA';
        cusp.Insurance_Sum_Insured__c = 1000000;
        cusp.Insurance_Premium_Amount_Due__c = 3000000;
        cusp.Insurance_Anniversary_Date__c = today.addDays(1);
        cusp.Insurance_Fully_Paid_Flag__c = true;
        cusp.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        insert cusp;
    }

	@isTest
    static void getAnniversaryInsuranceTest(){
        Test.startTest();
        InsuranceReportController.getAnniversaryInsurance(5);
        Test.stopTest();
    }

    @isTest
    static void getMatureInsuranceTest(){
        Test.startTest();
        InsuranceReportController.getMatureInsurance(5);
        Test.stopTest();
    }

    @isTest
    static void test(){
        Test.startTest();
        InsuranceReportController.getPaidUpInsurance(5);
        Test.stopTest();
    }
}