@isTest
public class MyCustomerControllerClassTest {

    private static Integer numFilter = 1;
    private static Integer numOptions = 3;

    private static List<String> filterIdList = new List<String>();

    @TestSetup
    static void settingAppConfig(){
        AppConfig__c appConfig1 = new AppConfig__c(Name='runtrigger', Value__c='false');
        insert appConfig1;
        
        AppConfig__c appConfig2 = new AppConfig__c(Name='runCustomerNoteTrigger', Value__c='false');
        insert appConfig2;
    }

    @isTest
    static void testGetFilters() {
        List<My_Customer_Filter__c> filterList = new List<My_Customer_Filter__c>();
        List<My_Customer_Filter_Option__c> optionList = new List<My_Customer_Filter_Option__c>();

        My_Customer_Filter__c filter = new My_Customer_Filter__c();
        filter.Name = 'Test Filter ';
        filter.Field_API__c = 'TEST_FIELD_API';
        filter.Order__c = 1;

        filterList.add(filter);
        insert filterList;
        filterIdList.add(filter.Id);

        for (String filterId: filterIdList) {
            for (Integer j=0; j<numOptions; j++) {
                My_Customer_Filter_Option__c filterOption = new My_Customer_Filter_Option__C();
                filterOption.Filter_Value__c = 'TEST VALUE' + j;
                filterOption.My_Customer_Filter__c = filterId;
                filterOption.Order__c = j + 1;
                optionList.add(filterOption);
            }
        }
        insert optionList;

        Test.startTest();
            Integer numOfOptions = [SELECT COUNT() FROM My_Customer_Filter_Option__c WHERE My_Customer_Filter__c IN :filterIdList];

            System.assertEquals(numOptions, numOfOptions);
            System.assertEquals(numFilter, MyCustomerControllerClass.getFilters().size());
        Test.stopTest();
    }

    @isTest
    static void testGetCustomerTableData() {
        List<Account> acctList = new List<Account>();

        List<String> acctIdList = new List<String>();

        List<User> Wealth_RMC = TestUtils.createUsers(1 ,'test', 'user', 'tus@example.com', true);
        String wealthrmName = Wealth_RMC[0].FirstName + ' ' + Wealth_RMC[0].LastName;

        Integer td_os_min = 0;
        Integer td_os_max = 0;

        Integer nfx_os_min = 0;
        Integer nfx_os_max = 0;

        List<Integer> expected_td_os = new List<Integer>();
        List<Integer> expected_nfx_os = new List<Integer>();

        for (Integer i=0;i<2;i++) {
            Double rand = Math.random() * 10000;
            Integer rounded = Math.round(rand);

            Account acct = new Account();
            acct.Name = 'TEST ACCOUNT' + i;
            acct.Mobile_Number_PE__c = '081234567' + i;
            acct.RMC_TD_OS__c = rounded;
            expected_td_os.add(rounded);
            acct.RMC_NFX_OS__c = rounded - (rounded/2);
            expected_nfx_os.add(rounded);
            acct.RTL_Wealth_RM__c = Wealth_RMC[0].Id;

            acct.RMC_Relationship_Level__c = Math.mod(i, 2) == 0 ? 'Hot' : 'Warm';
            acct.CC_Reserve_Point__c = 10;
            acct.RMC_AUM_Change__c = 5.12;
            acct.RMC_AUM__c = 20;

            acctList.add(acct);

            if (rounded - (rounded/2) > nfx_os_max) {
                nfx_os_max = rounded - (rounded/2);
            }
            
            if (rounded < td_os_min) {
                td_os_min = rounded;
            }
            if (rounded > td_os_max) {
                td_os_max = rounded;
            }
        }
        insert acctList;

        for (Account account : acctList) {
            acctIdList.add(account.Id);
        }

        MyCustomerControllerClass.createTaskForSelectedAccount(acctIdList);
        

        List<Customer_Product_Alert__c> customerProductAlertList = new List<Customer_Product_Alert__c>();

        List<String> alertList = new List<String>{'DEB', 'MF', 'DP', 'BA'};

        for (String accId : acctIdList) {
            Large_Transaction_Movements__c ltm = new Large_Transaction_Movements__c();
            ltm.Customer__c = accId;
            ltm.Transaction_Date_Time__c = Date.today().addDays(-6);

            for (Integer i=0; i<alertList.size(); i++) {
                Customer_Product_Alert__c customerProductAlert = new Customer_Product_Alert__c();
                customerProductAlert.Customer__c = accId;
                customerProductAlert.Account_Number__c = '9143000263';
                customerProductAlert.Maturity_Date__c = Math.mod(i, 2) == 0 ? Date.today().addMonths(1) : Date.today().addDays(5);
                customerProductAlert.Insurance_Anniversary_Date__c = Date.today().addDays(3); // Math.mod(i, 2) == 0 ? Date.today().addMonths(1) : Date.today();
                customerProductAlert.Financial_Account_Group__c = alertList[i];

                customerProductAlert.Dormant_Date__c = Date.today().addDays(5);
    
                if (alertList[i] == 'DEB' || alertList[i] == 'MF') {
                    customerProductAlert.MF_Fund_Type__c = 'FUND ' + (Math.mod(i, 2) == 0 ? 'A' : 'B');
                    customerProductAlert.Insurance_Company__c = 'Company ' + (Math.mod(i, 2) == 0 ? 'A' : 'B');
                }
    
                if (alertList[i] == 'BA') {
                    customerProductAlert.Insurance_Type__c = 'Insurance ' + (Math.mod(i, 2) == 0 ? 'A' : 'B');
                    customerProductAlert.Insurance_Paid_Up_Date__c = Date.today().addDays(5);
                    customerProductAlert.Insurance_Maturity_Date__c = Date.today().addDays(5);
                }
    
                customerProductAlert.Amount__c = Math.random() * 10000;
                customerProductAlert.Dept_No_Fund_Code__c = '00' + String.valueOf(i+1);
                customerProductAlert.Product_Code__c = alertList[i] + String.valueOf(i+1);
                customerProductAlert.Product_Name__c = 'TEST Product Name ' + i;

                customerProductAlertList.add(customerProductAlert);
            }
        }
        insert customerProductAlertList;
        
        List<Object> filterList = new List<Object>();
        String rng_nfx_os = '{"filterLabel": "NFX OS", "fieldApi": "RMC_NFX_OS__c", "value": "", "min": ' + nfx_os_min + ', "max": ' + nfx_os_max + ', "recordType": "Range Number"}';
        filterList.add((Object)JSON.deserializeUntyped(rng_nfx_os));

        String rng_rmc_td_os = '{"filterLabel": "CC_Reserve_Point__c", "fieldApi": "CC_Reserve_Point__c", "value": "", "min": ' + 0 + ', "recordType": "Range Number"}';
        filterList.add((Object)JSON.deserializeUntyped(rng_rmc_td_os));

        String rng_rmc_td_os_max = '{"filterLabel": "TD OS", "fieldApi": "RMC_TD_OS__c", "value": "", "max": ' + td_os_max + ', "recordType": "Range Number"}';
        filterList.add((Object)JSON.deserializeUntyped(rng_rmc_td_os_max));

        String rmc_aum_c = '{"filterLabel": "RMC_AUM_Change__c", "fieldApi": "RMC_AUM_Change__c", "value": 5.12, "recordType": "Text Equals"}';
        filterList.add((Object)JSON.deserializeUntyped(rmc_aum_c));

        String tq_rmc_relationship = '{"filterLabel": "Relationship Level", "fieldApi": "RMC_Relationship_Level__c", "value": "Hot", "recordType": "Text Equals"}';
        filterList.add((Object)JSON.deserializeUntyped(tq_rmc_relationship));

        List<Object> lstFilter = (List<Object>)JSON.deserializeUntyped(JSON.serialize(filterList));

        List<Map<String, Object>> filterObj = new List<Map<String, Object>>();
        for (Object obj : lstFilter) {
            Map<String, Object> tempMap = (Map<String, Object>)obj;
            filterObj.add(tempMap);
        }

        System.runAs(Wealth_RMC[0]) {
            Test.startTest();
            List<Object> returnObj = MyCustomerControllerClass.getCustomerTableData(filterObj);
            MyCustomerControllerClass.getFieldLabelTaskMap();
            MyCustomerControllerClass.getTaskCustomSetting();

            if (returnObj.size() > 0) {
                for (Object obj : returnObj) {
                    Map<String, Object> objdetail = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                    if (objdetail.get('nfx_os') == expected_nfx_os[0]) {
                        Decimal dc_nfx_os = (Decimal)expected_nfx_os[0];
                        List<String> formatArgs = new String[]{'0','number','###,###,##0.00'};
                        String test_nfx_os = String.format(dc_nfx_os.format(), formatArgs);
                        System.assertEquals(test_nfx_os, objdetail.get('nfx_os'));
                    } else if (objdetail.get('nfx_os') == expected_nfx_os[1]) {
                        Decimal dc_nfx_os = (Decimal)expected_nfx_os[1];
                        List<String> formatArgs = new String[]{'0','number','###,###,##0.00'};
                        String test_nfx_os = String.format(dc_nfx_os.format(), formatArgs);
                        System.assertEquals(test_nfx_os, objdetail.get('nfx_os'));
                    }

                    System.assertEquals('Hot', objdetail.get('relationship'));
                }
            }

            System.assertEquals(wealthrmName, MyCustomerControllerClass.getCurrentUserName());

            Integer checkSOQL = [SELECT COUNT() FROM Task WHERE WhatId IN :acctIdList];
            System.assertEquals(acctIdList.size(), checkSOQL);

            Test.stopTest();
        }
    }

    @isTest
    static void testProductAlertList() {
        List<String> productAlertList = new List<String>{'BA'};

        List<User> Wealth_RMC = TestUtils.createUsers(1 ,'test', 'user', 'tus@example.com', true);

        System.runAs(Wealth_RMC[0]) {
            Test.startTest();
                Account acct = new Account();
                acct.Name = 'TEST ACCOUNT';
                acct.Mobile_Number_PE__c = '0812345678';
                acct.RTL_Wealth_RM__c = Wealth_RMC[0].Id;

                acct.RMC_Relationship_Level__c = 'Hot';
                insert acct;
        
                List<Customer_Product_Alert__c> cpaList = new List<Customer_Product_Alert__c>();

                for (Integer i=0; i<productAlertList.size(); i++) {
                    Customer_Product_Alert__c cpa = new Customer_Product_Alert__c();
                    cpa.Customer__c = acct.Id;
                    cpa.Financial_Account_Group__c = productAlertList[i];
                    cpa.Insurance_Paid_Up_Date__c = Date.today().addDays(5);
        
                    cpaList.add(cpa);
                }
                insert cpaList;

                String param = '[{"filterLabel": "RMC_Relationship_Level__c", "fieldApi": "RMC_Relationship_Level__c", "value": "Hot", "recordType": "Text Equals"}]';
                List<Object> paramList = (List<Object>)JSON.deserializeUntyped(param);
                MyCustomerControllerClass.getCustomerTableData(paramList);
            Test.stopTest();
        }
    }

    @isTest
    static void testInsuranMaturityList() {
        List<User> Wealth_RMC = TestUtils.createUsers(1 ,'test', 'user', 'tus@example.com', true);

        System.runAs(Wealth_RMC[0]) {
            Test.startTest();
                Account acct2 = new Account();
                acct2.Name = 'TEST ACCOUNT2';
                acct2.Mobile_Number_PE__c = '0812345678';
                acct2.RTL_Wealth_RM__c = Wealth_RMC[0].Id;

                acct2.RMC_Relationship_Level__c = 'Hot';
                acct2.Sub_Segment__c = '800';
                insert acct2;
        
                Customer_Product_Alert__c cpa2 = new Customer_Product_Alert__c();
                cpa2.Customer__c = acct2.Id;
                cpa2.Financial_Account_Group__c = 'BA';
                cpa2.Insurance_Maturity_Date__c = Date.today().addDays(5);
                insert cpa2;

                String param = '[{"filterLabel": "RMC_Relationship_Level__c", "fieldApi": "RMC_Relationship_Level__c", "value": "Hot", "recordType": "Text Equals"}]';
                List<Object> paramList = (List<Object>)JSON.deserializeUntyped(param);
                MyCustomerControllerClass.getCustomerTableData(paramList);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testHandledException() {
        Test.startTest();
            String param = '[{"filterLabel": "asasd", "fieldApi": "adasdasd", "value": "Hot", "recordType": ""}]';
            List<Object> paramList = (List<Object>)JSON.deserializeUntyped(param);

            try {
                MyCustomerControllerClass.getCustomerTableData(paramList);
            } catch (Exception e) {
            }
        Test.stopTest();
    }
}