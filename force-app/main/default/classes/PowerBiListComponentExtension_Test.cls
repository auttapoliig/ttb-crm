@isTest
private class PowerBiListComponentExtension_Test {
    public static String testWealthUser = 'wealth@test-tmbbank.com';
    public static String testNonWealthUser = 'non-wealth@test-tmbbank.com';
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
                UserName=PowerBiListComponentExtension_Test.testWealthUser,
                Email=PowerBiListComponentExtension_Test.testWealthUser, 
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
            //setup data security matrix
            Data_Security_Matrix__c testSecurityMatrix = new Data_Security_Matrix__c(
                Access_Type__c = 'Authorize Only',
                Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Customer Product Holding (High)',
                Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit',
                Section_Name__c = 'RtlCust:Customer Product Holding (High)'
            );
            insert testSecurityMatrix;
        }
        System.runAs(adminUser){
            //Create User Non-Wealth Management Test
            Profile retailChannelSales = [SELECT Id FROM Profile WHERE Name ='TMB Retail Channel Sales'];
            UserRole userRoleBR_Sales_Zone_1870 = [SELECT Id FROM UserRole WHERE DeveloperName = 'BR_Sales_Zone_1870'];
            User testUser = new User(
                FirstName = 'non-wealth test',
                LastName = 'non-wealth test',
                UserName=PowerBiListComponentExtension_Test.testNonWealthUser,
                Email=PowerBiListComponentExtension_Test.testNonWealthUser, 
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
    }

    @isTest static void Test_WealthUser_PowerBiListComponentExtension() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiListComponentExtension_Test.testWealthUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];
        acc.RTL_Wealth_RM__c = testUser.Id;
        acc.OwnerId = testUser.Id;
        update acc;
        system.assertEquals('Retail_Customer',acc.RecordType.DeveloperName,'Account should be retail customer');
        Test.startTest();
        System.runAs(testUser){
            Account acObj = [SELECT Id FROM Account LIMIT 1];
            ApexPages.StandardController sc1 = new ApexPages.StandardController(acObj);
            PageReference powerbiListPage = Page.PowerBiListComponent;
            powerbiListPage.getparameters().put('id',acObj.id);
            Test.setCurrentPage(powerbiListPage);
            PowerBiListComponentExtension biExten = New PowerBiListComponentExtension(sc1);
            system.assertEquals(true,biExten.IsAccess,'User should have access');
        }
        Test.stopTest();
    }

    @isTest static void Test_Non_WealthUser_PowerBiListComponentExtension() {
        User testUser = [SELECT Id FROM User WHERE UserName=:PowerBiListComponentExtension_Test.testNonWealthUser];
        Account acc = [SELECT Id,RTL_Wealth_RM__c,RTL_Wealth_RM__r.UserName,RecordType.DeveloperName FROM Account LIMIT 1];
        acc.RTL_Wealth_RM__c = testUser.Id;
        acc.OwnerId = testUser.Id;
        update acc;
        Test.startTest();
        System.runAs(testUser){
            Account acObj = [SELECT Id FROM Account LIMIT 1];
            ApexPages.StandardController sc1 = new ApexPages.StandardController(acObj);
            PageReference powerbiListPage = Page.PowerBiListComponent;
            powerbiListPage.getparameters().put('id',acObj.id);
            Test.setCurrentPage(powerbiListPage);
            PowerBiListComponentExtension biExten = New PowerBiListComponentExtension(sc1);
            system.assertEquals(false,biExten.IsAccess,'User should have not access');
        }
        Test.stopTest();
    }
}