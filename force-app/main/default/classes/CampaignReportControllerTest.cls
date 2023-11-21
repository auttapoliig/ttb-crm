@isTest
public class CampaignReportControllerTest {

    @TestSetup
    static void makeData(){
        Date today = date.today();
        TestUtils.createAppConfig();

        String master = [SELECT Id, Name From recordtype where developername = 'Master_Campaign' LIMIT 1].Id;
        String exclusive = [SELECT Id, Name From recordtype where developername = 'Exclusive_Campaign' LIMIT 1].Id;

        Campaign c1 = new Campaign();
        c1.RTL_Campaign_Type__c = 'Mass';
        c1.Name = 'This is a Campaign';
        c1.RecordTypeId = master;
        c1.RTL_Campaign_Code_9_digits__c = 'M11111111';
        c1.RTL_Campaign_Code_10_digits__c = 'M111111110';
        c1.IsActive = true;
        insert c1;

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
        acct.Mainbank_Campaign_Period__c =  today.addMonths(1);
        acct.RMC_Reserve_Waive_Doc_Flag__c =  true;
        acct.Main_Bank_Group2_Value__c =  'ให้ดำเนินการ: นำเสนอบัตรใหม่ | หน้าบัตรเครดิต: reserve Signature | อ้างอิงเกณฑ์ BOT 180 วัน (ขอวงเงินเพิ่ม/ใหม่): ผ่าน (ใช้บัตรปชชใบเดียว) | สินทรัพย์เฉลี่ย 180 วัน (บาท): 4,896,737.82 (ใช้อ้างอิงขอวงเงินสูงสุด 10%) | ยอดรวมผลิตภัณฑ์ (บาท): 4,928,028.10 | เฉลี่ยกองทุนรวม 6 เดือน (บาท): 0 | เบี้ยประกันรวม 12 เดือน (บาท): 0 | ระยะเวลารับสิทธิ์บัตรอนุมัติภายใน: ส.ค. 2565';
        insert acct;

        Retail_Instant_Lending__c instant1 = new Retail_Instant_Lending__c();
        instant1.Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        instant1.Expiry_Date__c = today.addDays(5);
        instant1.Instant_lending_detail__c = 'ผ่านเกณฑ์การสมัคร ผลิตภัณฑ์ผ่านทัช ภายใน ม.ค. 66 (ไม่ต้องใช้เอกสารรายได้ Waive Doc - Instant) วงเงิน 513,000 บาท';
        instant1.Cash_2_go_flag__c = true;
        instant1.Cash_2_go_limit__c = 514000;
        instant1.Credit_Card_flag__c = true;
        instant1.Credit_Card_limit__c = 514000;
        instant1.Flash_Card_flag__c = true;
        instant1.Flash_Card_limit__c = 514000;
        insert instant1;

        RTL_Fulfillment__c fulfill = new RTL_Fulfillment__c();
        fulfill.RTL_Fulfillment_Type__c = 'BigPlan';
        fulfill.RTL_Description__c = 'Big Big Plan';
        fulfill.RTL_Delivery_Date__c = today.addDays(5);
        fulfill.RTL_Customer__c = [SELECT Id FROM Account LIMIT 1].Id;
        fulfill.RTL_Campaign__c = [SELECT Id FROM Campaign LIMIT 1].Id;
        insert fulfill;
    }
    
    @isTest
    static void getCampaignListTest(){
        Test.startTest();
        CampaignReportController.getCampaignList(5);
        Test.stopTest();
    }

    @isTest
    static void getInstantLendingTest(){
        Test.startTest();
        CampaignReportController.getInstantLending(5);
        Test.stopTest();
    }

    @isTest
    static void getTTBReseveInvitationTest(){
        Test.startTest();
        CampaignReportController.getTTBReseveInvitation(5);
        Test.stopTest();
    }

    @isTest
    static void getFulfillmentTest(){
        Test.startTest();
        CampaignReportController.getFulfillment(5);
        Test.stopTest();
    }
}