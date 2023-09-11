@IsTest
public class TransactionMovementReportTest {

    @TestSetup
    static void makeData(){
        Date today = date.today();
        TestUtils.createAppConfig();

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        insert u;
        
        Account acct1 = new Account();
        acct1.First_Name_PE__c = 'เสถียรพร';
        acct1.Last_Name_PE__c = 'คำดี';
        acct1.First_Name_ENG_PE__c = 'SathianP';
        acct1.Last_Name_PE_Eng__c = 'KD';
        acct1.Name = acct1.First_Name_PE__c + ' ' + acct1.Last_Name_PE__c;
        acct1.Email_Address_PE__c = 'satian@tmb.com';
        acct1.Mobile_Number_PE__c = '0998877665';
        acct1.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct1.Account_Type__c = 'Retail Customer';
        acct1.ID_Type_PE__c = 'Citizen ID';
        acct1.ID_Number_PE__c = '4496799264466';
        acct1.RMC_AUM_Change__c = 10.00;
        acct1.RTL_NID__c = '44466';
        acct1.TMB_Customer_ID_PE__c = '001100000001100000000000000500';
        acct1.RMC_Wealth_Flag__c = 'Yes';
        acct1.RMC_Suitability_Risk_Level_Required__c = 9;
        acct1.RMC_Suitability_Risk_Level__c = 1;
        acct1.OwnerId = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1].Id;

        Account acct2 = new Account();
        acct2.First_Name_PE__c = 'ปราถณา';
        acct2.Last_Name_PE__c = 'ยืนยงค์';
        acct2.First_Name_ENG_PE__c = 'Prattana';
        acct2.Last_Name_PE_Eng__c = 'KD';
        acct2.Name = acct2.First_Name_PE__c + ' ' + acct2.Last_Name_PE__c;
        acct2.Email_Address_PE__c = 'satian@tmb.com';
        acct2.Mobile_Number_PE__c = '0998877665';
        acct2.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct2.Account_Type__c = 'Retail Customer';
        acct2.ID_Type_PE__c = 'Citizen ID';
        acct2.ID_Number_PE__c = '4496799264467';
        acct2.RMC_AUM_Change__c = 10.00;
        acct2.RTL_NID__c = '44467';
        acct2.TMB_Customer_ID_PE__c = '001500000001100000000000000500';
        acct2.RMC_Wealth_Flag__c = 'No';
        acct2.RMC_Suitability_Risk_Level_Required__c = 9;
        acct2.RMC_Suitability_Risk_Level__c = 2;
        acct2.OwnerId = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1].Id;

        List<Account> accountList = new List<Account>{acct1, acct2};
        insert accountList;

        Large_Transaction_Movements__c ltm1 = new Large_Transaction_Movements__c();
        ltm1.Transaction_Date_Time__c = date.newinstance(today.year(), today.month(), today.day() - 1);
        ltm1.Amount__c = -5000000;
        ltm1.Customer__c = [SELECT Id FROM Account WHERE RMC_Wealth_Flag__c = 'Yes' LIMIT 1].Id;

        Large_Transaction_Movements__c ltm2 = new Large_Transaction_Movements__c();
        ltm2.Transaction_Date_Time__c = date.newinstance(today.year(), today.month(), today.day() - 1);
        ltm2.Amount__c = 5000000;
        ltm2.Customer__c = [SELECT Id FROM Account WHERE RMC_Wealth_Flag__c = 'No' LIMIT 1].Id;

        List<Large_Transaction_Movements__c> ltmList = new List<Large_Transaction_Movements__c>{ltm1, ltm2};
        insert ltmList;

        Customer_Product_Alert__c cpa = new Customer_Product_Alert__c();
        cpa.Financial_Account_Group__c = 'MF-ADJ';
        cpa.MF_Gain_Loss_Percent__c = -10.19;
        cpa.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        insert cpa;
    }

	@isTest
    static void getTransactionForWealthNonWealthTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TransactionMovementReport.getTransactionForWealthNonWealth(5, 'Yes');
        }
        Test.stopTest();
    }

    @isTest
    static void getTransactionForWealthWealthTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TransactionMovementReport.getTransactionForWealthNonWealth(5, 'No');
        }
        Test.stopTest();
    }

    @isTest
    static void getRiskMisMatchTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        List<Account> acctList = [SELECT Id, RMC_Suitability_Risk_Level_Diff__c FROM Account];
        System.debug(JSON.serialize(acctList));
        System.runAs(u){
            TransactionMovementReport.getRiskMisMatch(5);
        }
        Test.stopTest();
    }

    @isTest
    static void getMFPortAdjustTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'UserTestqqq0' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TransactionMovementReport.getMFPortAdjust(5);
        }
        Test.stopTest();
    }

    @isTest
    static void getTransactionPlusTest(){
        Test.startTest();
        TransactionMovementReport.getTransactionPlus(5);
        Test.stopTest();
    }

    @isTest
    static void getTransactionMinusTest(){
        Test.startTest();
        TransactionMovementReport.getTransactionMinus(5);
        Test.stopTest();
    }
}