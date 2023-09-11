@isTest
private class PowerBiUtils_Test {
    public static String testWealthUser = 'wealth@test-tmbbank.com';
    public static String testNonWealthUser = 'non-wealth@test-tmbbank.com';
    public static String testRetailUser = 'retail-user01@test-tmbbank.com';
    public static String testBussinessSupUser = 'bussiness-user01@test-tmbbank.com';
    public static String pageName ='PowerBiList';
    @testSetup static void setup() {
        TestUtils.createAppConfig();
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        //create test user
        User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs(adminUser){
            //Create User Wealth Management Test
            Profile wealthManagementRMCockpit = [SELECT Id FROM Profile WHERE Name ='TMB Retail Wealth Management RM Cockpit'];
            UserRole userRoleWM_SS_2_6 = [SELECT Id FROM UserRole WHERE DeveloperName = 'WM_SS_2_6'];
            User testUser = new User(
                FirstName = 'wealth test',
                LastName = 'wealth test',
                UserName=PowerBiUtils_Test.testWealthUser,
                Email=PowerBiUtils_Test.testWealthUser, 
                Alias='w-testus',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US', 
                EmailEncodingKey='ISO-8859-1',
                ProfileId = wealthManagementRMCockpit.Id,
                UserRoleId = userRoleWM_SS_2_6.Id,
                TimeZoneSidKey='America/New_York',
                isActive = true,
                Employee_ID__c ='MM01t'
            );
            insert testUser;
        }

        System.runAs(adminUser){
            //Create User Non-Wealth Management Test
            Profile retailChannelSales = [SELECT Id FROM Profile WHERE Name ='TMB Retail Channel Sales'];
            UserRole userRoleBR_Sales_Zone_1870 = [SELECT Id FROM UserRole WHERE DeveloperName = 'BR_Sales_Zone_1870'];
            User testUser = new User(
                FirstName = 'retial_user',
                LastName = 'retial_user',
                UserName=PowerBiUtils_Test.testNonWealthUser,
                Email=PowerBiUtils_Test.testNonWealthUser, 
                Alias='user001',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US', 
                EmailEncodingKey='ISO-8859-1',
                ProfileId = retailChannelSales.Id,
                UserRoleId = userRoleBR_Sales_Zone_1870.Id,
                TimeZoneSidKey='America/New_York',
                isActive = true,
                Employee_ID__c ='retail01'
            );
            insert testUser;
        }
        System.runAs(adminUser){
            //Create User Retail Test
            Profile retailChannelSales = [SELECT Id FROM Profile WHERE Name ='TMB Retail Channel Sales'];
            UserRole userRoleBR_Sales_Zone_1870 = [SELECT Id FROM UserRole WHERE DeveloperName = 'BR_Sales_Zone_1870'];
            User testUser = new User(
                FirstName = 'non-wealth test',
                LastName = 'non-wealth test',
                UserName=PowerBiUtils_Test.testRetailUser,
                Email=PowerBiUtils_Test.testRetailUser, 
                Alias='mw-test',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US', 
                EmailEncodingKey='ISO-8859-1',
                ProfileId = retailChannelSales.Id,
                UserRoleId = userRoleBR_Sales_Zone_1870.Id,
                TimeZoneSidKey='America/New_York',
                isActive = true,
                Employee_ID__c ='non-w01t'
            );
            insert testUser;
        }
        System.runAs(adminUser){
            //Create User Contact_Center Test
            Profile retailChannelSales = [SELECT Id FROM Profile WHERE Name ='TMB Retail Business Support'];
            UserRole userRoleBR_Sales_Zone_1870 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'];
            User testUser = new User(
                FirstName = 'Business Support',
                LastName = 'Business Support',
                UserName=PowerBiUtils_Test.testBussinessSupUser,
                Email=PowerBiUtils_Test.testBussinessSupUser, 
                Alias='bs-test',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US', 
                EmailEncodingKey='ISO-8859-1',
                ProfileId = retailChannelSales.Id,
                UserRoleId = userRoleBR_Sales_Zone_1870.Id,
                TimeZoneSidKey='America/New_York',
                isActive = true,
                Employee_ID__c ='bs-usr'
            );
            insert testUser;
        }
        System.runAs(adminUser){
            //setup data security matrix
            List<Data_Security_Matrix__c> dataSecmdt = new List<Data_Security_Matrix__c>();
            Data_Security_Matrix__c testSecurityMatrix = new Data_Security_Matrix__c(
                Access_Type__c = 'Authorize Only',
                Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Customer Product Holding (High)',
                 Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit',
                Section_Name__c = 'RtlCust:Customer Product Holding (High)'
            );
            dataSecmdt.add(testSecurityMatrix);
            Data_Security_Matrix__c testSecurityMatrixAll = new Data_Security_Matrix__c(
                Access_Type__c = 'All',
                Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Customer Product Holding (High)',
                Profile_Name__c = 'TMB Retail Channel Sales',
                Section_Name__c = 'RtlCust:Customer Product Holding (High)'
            );
            dataSecmdt.add(testSecurityMatrixAll);
            insert dataSecmdt;
        }
        
    }

    @isTest static void Test_Authorize_Only_PowerBiUtils_Test() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiUtils_Test.testWealthUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];
        acc.RTL_Wealth_RM__c = testUser.Id;
        acc.OwnerId = testUser.Id;
        update acc;
        system.assertEquals('Retail_Customer',acc.RecordType.DeveloperName,'Account should be retail customer');
        Test.startTest();
        System.runAs(testUser){
            Map<String, Boolean> result_Map =  PowerBiUtils.getFieldVisibilityByPage(String.valueOf(acc.id),pageName);
           system.assertEquals(true,result_Map.get('Authorize'),'User should have access : Authorize_Only ');
        }
        Test.stopTest();
    }

    @isTest static void Test_Authorize_ALL_PowerBiUtils_Test() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiUtils_Test.testRetailUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];
        acc.RTL_Wealth_RM__c = testUser.Id;
        acc.OwnerId = testUser.Id;
        update acc;
        system.assertEquals('Retail_Customer',acc.RecordType.DeveloperName,'Account should be retail customer');
        Test.startTest();
        System.runAs(testUser){
            Map<String, Boolean> result_Map =  PowerBiUtils.getFieldVisibilityByPage(String.valueOf(acc.id),pageName);
            system.assertEquals(true,result_Map.get('Authorize'),'User should have access : ALL');
        }
        Test.stopTest();
    }

    @isTest static void Test_Authorize_No_Access_PowerBiUtils_Test() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiUtils_Test.testBussinessSupUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];

        system.assertEquals('Retail_Customer',acc.RecordType.DeveloperName,'Account should be retail customer');
        Test.startTest();
        System.runAs(testUser){
            Map<String, Boolean> result_Map =  PowerBiUtils.getFieldVisibilityByPage(String.valueOf(acc.id),pageName);
            system.assertEquals(false,result_Map.get('Authorize'),'User should have No access : No Access');
        }
        Test.stopTest();
    }


    @isTest static void Test_Encryption_PowerBiUtils_Test() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiUtils_Test.testRetailUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];
        acc.RTL_Wealth_RM__c = testUser.Id;
        acc.OwnerId = testUser.Id;
        acc.TMB_Customer_ID_PE__c ='001100000000000000000005977076';
        update acc;

        system.assertEquals('Retail_Customer',acc.RecordType.DeveloperName,'Account should be retail customer');
        Test.startTest();
        System.runAs(testUser){
            String strAccTmbCust = PowerBiUtils.getAccount(String.valueOf(acc.id));   
            system.assertEquals(acc.TMB_Customer_ID_PE__c,strAccTmbCust,'TMB_Customer_ID_PE__c  should be : 001100000000000000000005977076 '); 
            String resultEncrypt =  PowerBiUtils.encryptCustomerId(String.valueOf(acc.TMB_Customer_ID_PE__c));
            system.assertEquals('34f82f5572d3038345f509aeeba1dbd857782f192992357569b6cc47964de5f8',resultEncrypt,'Encrypt key should be :34f82f5572d3038345f509aeeba1dbd857782f192992357569b6cc47964de5f8 ');
          
            }
        Test.stopTest();
          
    }
    @isTest static void Test_getMetaPowerbi_PowerBiUtils_Test(){
        Test.startTest();
        Power_Bi_Report__mdt  reportMdt = PowerBiUtils.getMetaPowerbi();
        system.assertNotEquals(null,reportMdt.Id, 'Report Type  should be Not null');
        Test.stopTest(); 
    }

}