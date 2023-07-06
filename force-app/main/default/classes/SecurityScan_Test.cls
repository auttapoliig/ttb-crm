@isTest
public class SecurityScan_Test {

    public static final Id Channel_Sales_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;
    public static final Id SYSTEM_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id RM_Cockpit_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Wealth Management RM Cockpit' LIMIT 1].Id;
    public static Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();

    public static RecordType RetailLeadRecoordType {
        get{
            if(RetailLeadRecoordType == null){
                RetailLeadRecoordType = [SELECT id,Name,DeveloperName FROM RecordType 
                                        WHERE DeveloperName='Retail_Banking' 
                                        AND sObjectType='Lead' LIMIT 1];
            }
            return RetailLeadRecoordType;
        }
        set;
	}

    @testSetup static void setup() {
        TestUtils.createAppConfig();
        
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        List<User> userList = new List<User>();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Branch_Code__c = '252';
        branch.isActive__c = true;
        insert branch;    

        RTL_product_master__c productMaster = new RTL_product_master__c();
        productMaster.Active__c = TRUE;
        productMaster.Name = 'test product1';
        productMaster.Product_Code__c = '0001';
        productMaster.Product_Group__c = 'test group1';
        productMaster.Product_Sub_group__c = 'test subgroup1';
        insert productMaster;

        //insert user for run as
        User newUser = new User(FirstName = 'Test' , LastName = 'Man', 
                UserName='testMan@tmbbank.com',
                Email='testman@gmail.com', Alias='Testtmb',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb',
                ProfileId = Channel_Sales_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM01');
        userList.add(newUser);
        User newUser2 = new User(FirstName = 'Test' , LastName = 'Man2', 
                UserName='testMan2@tmbbank.com',
                Email='testman2@gmail.com', Alias='Testtmb2',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb2',
                ProfileId = RM_Cockpit_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM02');
        userList.add(newUser2);
        User newUser3 = new User(FirstName = 'Test' , LastName = 'Man3', 
                UserName='testMan3@tmbbank.com',
                Email='testman3@gmail.com', Alias='Testtmb3',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb3',
                ProfileId = SYSTEM_ADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM03',RTL_Branch_Code__c='252');
        userList.add(newUser3);
        insert userList;
        
        List<Data_Security_Matrix__c> dsmList = new List<Data_Security_Matrix__c>();
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Demographic (Low)';
        dsm.Profile_Name__c = 'TMB System Administrator';
        dsm.Data_Matrix_Key__c = 'TMB System AdministratorRtlCust:Customer Demographic (Low)';
        dsmList.add(dsm);
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Demographic (Low)';
        dsm2.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm2.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Customer Demographic (Low)';
        dsmList.add(dsm2);
        Data_Security_Matrix__c dsm3 = new Data_Security_Matrix__c();
        dsm3.Access_Type__c = 'All';
        dsm3.Section_Name__c = 'RtlCust:Sales Support Information';
        dsm3.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm3.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Sales Support Information';
        dsmList.add(dsm3);
        Data_Security_Matrix__c dsm4 = new Data_Security_Matrix__c();
        dsm4.Access_Type__c = 'All';
        dsm4.Section_Name__c = 'RtlCust:Contact Number and Email Address';
        dsm4.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm4.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Contact Number and Email Address';
        dsmList.add(dsm4);
        Data_Security_Matrix__c dsm5 = new Data_Security_Matrix__c();
        dsm5.Access_Type__c = 'Authorize Only';
        dsm5.Section_Name__c = 'RtlCust:Sales Support Information';
        dsm5.Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit';
        dsm5.Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Sales Support Information';
        dsmList.add(dsm5);
        Data_Security_Matrix__c dsm6 = new Data_Security_Matrix__c();
        dsm6.Access_Type__c = 'No Access';
        dsm6.Section_Name__c = 'RtlCust:Contact Number and Email Address';
        dsm6.Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit';
        dsm6.Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Contact Number and Email Address';
        dsmList.add(dsm6);
        insert dsmList;
    }
    //mock custom metadata

    @IsTest static void testgetAllSection1 () {
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan@tmbbank.com'];
        
        System.runAs(u){
            String dataHidden = Label.Data_Condition_Hidden_Text;
            List<String> fields = new List<String>{ 'FATCA_Form_Completed__c', 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c', 'RecordTypeId'}; 
            List<String> fieldstranslate = new List<String>{};
            List<Account> accList = createAccounts(1, true);
            Map<String, Object> param = getDescribeFieldResultMock(accList.get(0).Id, fields, fieldstranslate);     
            //หลังจากส่ง
            Test.startTest();
            Object returnData = SecurityScan.applySecurityMatrix( param, accList.get(0).Id, fields, fieldstranslate);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnData));
            Map<String, Object> searchKeyMap = new Map<string, Object>();
            for(String key : m.keyset()){
                searchKeyMap = (Map<string,Object>) m.get(key);
                if(searchKeyMap.get('isAccessible') == false){
                    System.assertEquals(dataHidden, searchKeyMap.get('value'));
                }
            }
            Test.stopTest();
        }
    }

    @IsTest static void testgetAllSection2 () {
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan2@tmbbank.com'];
        
        System.runAs(u){
            String dataHidden = Label.Data_Condition_Hidden_Text;
            List<String> fields = new List<String>{ 'Email_Address_PE__c', 'FATCA_Form_Completed__c', 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c', 'RecordTypeId'}; 
            List<String> fieldstranslate = new List<String>{};
            List<Account> accList = createAccounts(1, true);
            Map<String, Object> param = getDescribeFieldResultMock(accList.get(0).Id, fields, fieldstranslate);     
            //หลังจากส่ง
            Test.startTest();
            Object returnData = SecurityScan.applySecurityMatrix( param, accList.get(0).Id, fields, fieldstranslate);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnData));
            Map<String, Object> searchKeyMap = new Map<string, Object>();
            for(String key : m.keyset()){
                searchKeyMap = (Map<string,Object>) m.get(key);
                if(searchKeyMap.get('isAccessible') == false){
                    System.assertEquals(dataHidden, searchKeyMap.get('value'));
                }
            }
            Test.stopTest();
        }
    }
    @IsTest static void testgetVerifyByField(){
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan@tmbbank.com'];
        System.runAs(u){
            List<Account> accList = createAccounts(1, true);
            Test.startTest();
            Object isVisible = SecurityScan.getVerifyByField('TMB_Customer_ID_PE__c', 'TMB Retail Channel Sales', accList.get(0).Id);
            Test.stopTest();
            System.assertEquals(true, isVisible);
        }
    }

    @IsTest static void testIsAccountLeadVisible(){
        User userTest = [SELECT Id, UserName FROM User WHERE UserName = 'testMan3@tmbbank.com'];
        List<Account> accList = createAccounts(1, true);
        Lead leadObj1 = createLeads(userTest.Id, accList[0].Id);
        System.runAs(userTest){
            Test.startTest();
            Boolean isAccess = SecurityScan.isAccountLeadVisible(accList[0].Id);
            // leadObj1.OwnerId = groupList.Id;
            // update leadObj1;
            // isAccess = SecurityScan.isAccountLeadVisible(accList[0].Id);
            Test.stopTest();
        }
    }



    @IsTest static void testIsAccountReferralVisible_User(){
        User userTest = [SELECT Id, UserName FROM User WHERE UserName = 'testMan3@tmbbank.com'];
        List<Account> accList = createAccounts(1, true);
        RTL_Referral__c referralObj = createReferral(userTest.Id, accList[0].Id);
        System.runAs(userTest){
            Test.startTest();
            Boolean isAccess = SecurityScan.isAccountReferralVisible(accList[0].Id);
            Test.stopTest();
        }
    }

    @IsTest static void testIsAccountReferralVisible_Branch(){
        User userTest = [SELECT Id, UserName FROM User WHERE UserName = 'testMan3@tmbbank.com'];
        Group groupList = [SELECT Id,DeveloperName,Type FROM Group WHERE DeveloperName = 'RTL_252' LIMIT 1];
        List<Account> accList = createAccounts(1, true);
        RTL_Referral__c referralObj = createReferral(userTest.Id, accList[0].Id);
        referralObj.OwnerID = groupList.Id;
        update referralObj;
        System.runAs(userTest){
            Test.startTest();
            Boolean isAccess = SecurityScan.isAccountReferralVisible(accList[0].Id);
            Test.stopTest();
        }
    }

    @IsTest static void testIsAccountBranchVisible(){
        User userTest = [SELECT Id, UserName FROM User WHERE UserName = 'testMan3@tmbbank.com'];
        Branch_and_Zone__c branchobj = [SELECT Id,Branch_Code__c FROM Branch_and_Zone__c WHERE Branch_Code__c = '252' LIMIT 1];
        List<Account> accList = createAccounts(1, true);
        // accList[0].RTL_Assigned_BRC__c = userTest.Id;
        accList[0].RTL_Most_Operating_Branch__c = branchobj.Id;

        update accList;
        System.runAs(userTest){
            Test.startTest();
            Boolean isAccess = SecurityScan.isAccountBranchVisible(accList[0]);

            // accList[0].RTL_Assigned_BRC__c = null;
            // accList[0].RTL_Most_Operating_Branch__c = branchobj.Id;
            // update accList;
            // isAccess = SecurityScan.isAccountBranchVisible(accList[0]);

            Test.stopTest();
        }
    }



    public static Map<String, Object> getDescribeFieldResultMock(String recordId, List<String> fields, List<String> fields_translate){
        String queryString = 'SELECT ' + String.join(fields, ',') + ' FROM Account WHERE Id = :recordId LIMIT 1';
        for (string fieldTranslate : fields_translate) {
            queryString = queryString.replace( fieldTranslate, 'toLabel('+fieldTranslate+')');
        }
        Account AccountObj = Database.query(queryString);
        Map<String, Schema.SObjectField> sObjectField = Schema.SObjectType.Account.fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            if(!f.contains('__r')) {
                Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => dfr.getName(),
                    'value' => AccountObj.get(dfr.getName()) != null ? AccountObj.get(dfr.getName()) : '',
                    'label' => dfr.getLabel(),
                    'type' => dfr.getType(),
                    'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                    'isAccessible' => dfr.isAccessible()
                });
            }
            else {
                Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(AccountObj));
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => f,
                    'value' => AccountObj.get(f.substringBefore('.').replace('__r', '__c')) != null ? ((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : null
                });
            }
        }
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }

    public static List<Account> createAccounts(Integer size , Boolean doInsert)
    {
        List<Account> accountsToCreate = new List<Account>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        for(Integer i =1 ; i<=size ;i++)
        {   
            Account acct = new Account(); 
            acct.Name = 'Test RTL Account '+i;
            acct.First_Name_PE__c = 'Test';
            acct.Last_name_PE__c = 'RTL Account '+i;
            acct.Phone ='1111111111';
            acct.Mobile_Number_PE__c  = '1111111111';
            acct.ID_Type_PE__c = 'Passport ID';
            acct.ID_Number_PE__c = '11111' + i;
            acct.RTL_NID__c = '1111' + i;
            acct.RecordType = recordType;
            acct.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAD' + i;
            acct.RTL_RM_Name__c = '00102';
            acct.RecordTypeId = acctRT;
            
            accountsToCreate.add(acct);    
        }
        if(doInsert){
                insert accountsToCreate;
        }
        return accountsToCreate;
    }  
    
    public static Lead createLeads(Id ownerId, Id accId){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = RetailLeadRecoordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = ownerId;
        leadRec.Account__c = accId;
        leadRec.Customer__c = accId;
        leadRec.Status = 'New';
        leadRec.RTL_Mobile_Number__c = '0854435523';
        leadRec.RTL_Product_Name__c = 'test product1';
        insert leadRec;
        return leadRec;
    }

    private static RTL_Referral__c createReferral(Id ownerId, Id accId){
        Branch_and_Zone__c branchobj = [SELECT Id,Branch_Code__c FROM Branch_and_Zone__c WHERE Branch_Code__c = '252' LIMIT 1];
        RTL_Referral__c referralObj = new RTL_Referral__c();
        referralObj.RTL_Stage__c = 'New';
        referralObj.RTL_Mobile1__c = '0854435523';
        referralObj.RTL_Account_Name__c = accId;
        referralObj.RTL_Preferred_Branch__c = branchobj.Id;
        referralObj.OwnerId = ownerId;
        
        insert referralObj;
        return referralObj;
    }



}