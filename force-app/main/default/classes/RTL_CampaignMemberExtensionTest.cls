@isTest
public with sharing class RTL_CampaignMemberExtensionTest {
    static {
        TestUtils.createAppConfig();

        //Add for Test Campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
    }
    public static testMethod void testNagativeVFPage(){
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
    }
	public static testMethod void testAPIServiceNegativeService400(){
        //insert RTL_Campaign_Endpoint__c
        RTL_Campaign_Endpoint__c campaignEndPoint = new RTL_Campaign_Endpoint__c(
            Name = 'Campaign TO HQ INT06',
            RTL_Endpoint__c ='https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
        );
        insert campaignEndPoint;
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCampaignMemberExtension());
        Continuation conti = (Continuation)camPage.requestCampaignData();
        HttpResponse response = new HttpResponse();
        response.setBody('');
        response.setStatusCode(400);
        Test.setContinuationResponse(camPage.requestLabel, response);
        Object result = Test.invokeContinuationMethod(camPage, conti);
        Test.stopTest();
    }
    public static testMethod void testAPIServiceNegativeNonResponse(){
        //insert RTL_Campaign_Endpoint__c
        RTL_Campaign_Endpoint__c campaignEndPoint = new RTL_Campaign_Endpoint__c(
            Name = 'Campaign TO HQ INT06',
            RTL_Endpoint__c ='https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
        );
        insert campaignEndPoint;
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        camPage.processResponse();
        Test.stopTest();
    }
    public static testMethod void testAPIServiceNegativeNonURL(){
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        Continuation conti = (Continuation)camPage.requestCampaignData();
        
    }
    public static testMethod void testAPIServiceNegative(){
        
        //insert RTL_Campaign_Endpoint__c
        RTL_Campaign_Endpoint__c campaignEndPoint = new RTL_Campaign_Endpoint__c(
            Name = 'Campaign TO HQ INT06',
            RTL_Endpoint__c ='https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
        );
        insert campaignEndPoint;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        RTL_CampaignMemberExtension.retrieveValueTranformation(camp.Id);
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        
        system.debug('currentObject = '+camPage.currentObject);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCampaignMemberExtension());
        
		Continuation conti = (Continuation)camPage.requestCampaignData();
        HttpResponse response = new HttpResponse();
        response.setBody('<?xml version=\'1.0\' encoding=\'UTF-8\'?>'+
                            '<CampaignMemberResponse>'+
                              	'<CampaignMemberList>'+
    								'<CampaignMember>'+
                                        '<CampaignCode>0DSSZLZA37</CampaignCode>'+
                         				'<MarketingCode>0DSSZLZA37</MarketingCode>'+
                         				'<ProductOfferString>0DSSZLZA37</ProductOfferString>'+
                         				'<CampaignChannel>0DSSZLZA37</CampaignChannel>'+
                         				'<MobileNumber>0DSSZLZA37</MobileNumber>'+
                         				'<UpdateDate>Test</UpdateDate>'+
                                        '<ResultContact>Test</ResultContact>'+
                                        '<AgentID>Test</AgentID>'+
                                        '<ResultDetail>Test</ResultDetail>'+
                                        '<OfferResult>Test</OfferResult>'+
                                        '<Reason>Test</Reason>'+
                                        '<SmsMessage>Test</SmsMessage>'+
                                        '<SmsContent>Test</SmsContent>'+
                                        '<RegisterDate>Test</RegisterDate>'+
                                        '<DisplayFlag>Test</DisplayFlag>'+
                                        '<DisplayDate>Test</DisplayDate>'+
                                        '<ClickFlag>Test</ClickFlag>'+
                                        '<ClickDate>Test</ClickDate>'+
                                        '<EmailSendDate>Test</EmailSendDate>'+
                                        '<EmailRejectDate>Test</EmailRejectDate>'+
                                        '<EmailOpenFlag>Test</EmailOpenFlag>'+
                                        '<EmailOpenDate>Test</EmailOpenDate>'+
                                        '<EmailClickFlag>Test</EmailClickFlag>'+
                                        '<EmailClickDate>Test</EmailClickDate>'+
                         				'<ContactSubStatus>Test</ContactSubStatus>'+
                                        '<OfferSubResult>Test</OfferSubResult>'+
                                        '<ResultBusiness>Test</ResultBusiness>'+
                                        '<ContactDate>Test</ContactDate>'+
                                        '<PersonalizedMessage>Test</PersonalizedMessage>'+
                                    '</CampaignMember>'+
    							'</CampaignMemberList>'+
    							'<Header>'+
                                	'<ErrorStatus>success</ErrorStatus>'+
                                	'<ErrorCode>00</ErrorCode>'+
                                	'<ErrorDescription/>'+
                                	'<TotalRecords>0</TotalRecords>'+
                              	'</Header>'+
                            '</CampaignMemberResponse>');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        system.debug('requestLabel---'+camPage.requestLabel);
        Test.setContinuationResponse(camPage.requestLabel, response);
        camPage.pagination(new List<Integer>{1,2,3,4,5,6,7,8,9,10,11,12},5);
        camPage.currentObject = new CampaignMember();
        Object result = Test.invokeContinuationMethod(camPage, conti);
        system.debug('result'+result);
        Test.stopTest();
        Map<ID, String> userNameMap = RTL_CampaignMemberExtension.userNameMap;
        Map<ID, String> branchNameMap = RTL_CampaignMemberExtension.branchNameMap;
        Map<ID, String> contactNameMap = RTL_CampaignMemberExtension.contactNameMap;
        camPage.updateProductOfferString(cm1,'store data');
    }
    public static testMethod void testAPIService(){
        
        //insert RTL_Campaign_Endpoint__c
        RTL_Campaign_Endpoint__c campaignEndPoint = new RTL_Campaign_Endpoint__c(
            Name = 'Campaign TO HQ INT06',
            RTL_Endpoint__c ='https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
        );
        insert campaignEndPoint;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        RTL_CampaignMemberExtension.retrieveValueTranformation(camp.Id);
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        
        system.debug('currentObject = '+camPage.currentObject);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCampaignMemberExtension());
        
		Continuation conti = (Continuation)camPage.requestCampaignData();
        HttpResponse response = new HttpResponse();
        response.setBody('<?xml version=\'1.0\' encoding=\'UTF-8\'?>'+
                            '<CampaignMemberResponse>'+
                              	'<CampaignMemberList>'+
    								'<CampaignMember>'+
                                        '<CampaignCode>0DSSZLZA37</CampaignCode>'+
                         				'<MarketingCode>0DSSZLZA37</MarketingCode>'+
                         				'<ProductOfferString>0DSSZLZA37</ProductOfferString>'+
                         				'<CampaignChannel>0DSSZLZA37</CampaignChannel>'+
                         				'<MobileNumber>0DSSZLZA37</MobileNumber>'+
                         				'<UpdateDate>Test</UpdateDate>'+
                                        '<ResultContact>Test</ResultContact>'+
                                        '<AgentID>Test</AgentID>'+
                                        '<ResultDetail>Test</ResultDetail>'+
                                        '<OfferResult>Test</OfferResult>'+
                                        '<Reason>Test</Reason>'+
                                        '<SmsMessage>Test</SmsMessage>'+
                                        '<SmsContent>Test</SmsContent>'+
                                        '<RegisterDate>Test</RegisterDate>'+
                                        '<DisplayFlag>Test</DisplayFlag>'+
                                        '<DisplayDate>Test</DisplayDate>'+
                                        '<ClickFlag>Test</ClickFlag>'+
                                        '<ClickDate>Test</ClickDate>'+
                                        '<EmailSendDate>Test</EmailSendDate>'+
                                        '<EmailRejectDate>Test</EmailRejectDate>'+
                                        '<EmailOpenFlag>Test</EmailOpenFlag>'+
                                        '<EmailOpenDate>Test</EmailOpenDate>'+
                                        '<EmailClickFlag>Test</EmailClickFlag>'+
                                        '<EmailClickDate>Test</EmailClickDate>'+
                         				'<ContactSubStatus>Test</ContactSubStatus>'+
                                        '<OfferSubResult>Test</OfferSubResult>'+
                                        '<ResultBusiness>Test</ResultBusiness>'+
                                        '<ContactDate>Test</ContactDate>'+
                                        '<PersonalizedMessage>Test</PersonalizedMessage>'+
                                    '</CampaignMember>'+
    							'</CampaignMemberList>'+
    							'<Header>'+
                                	'<ErrorStatus>success</ErrorStatus>'+
                                	'<ErrorCode>00</ErrorCode>'+
                                	'<ErrorDescription/>'+
                                	'<TotalRecords>0</TotalRecords>'+
                              	'</Header>'+
                            '</CampaignMemberResponse>');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        system.debug('requestLabel---'+camPage.requestLabel);
        Test.setContinuationResponse(camPage.requestLabel, response);
        Object result = Test.invokeContinuationMethod(camPage, conti);
        system.debug('result'+result);
        Test.stopTest();
    }
    public static testMethod void testAPIServiceFailMessage(){
        
        //insert RTL_Campaign_Endpoint__c
        RTL_Campaign_Endpoint__c campaignEndPoint = new RTL_Campaign_Endpoint__c(
            Name = 'Campaign TO HQ INT06',
            RTL_Endpoint__c ='https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
        );
        insert campaignEndPoint;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Dummy_Campaign').getRecordTypeId();
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        RTL_CampaignMemberExtension.retrieveValueTranformation(camp.Id);
        List<Lead> leads = RTL_TestUtility.createLeads(1,true);
        CampaignMember cm1 = new CampaignMember(
        	LeadId = leads.get(0).id,
            CampaignId = camp.id,
            RTL_TMB_Campaign_Source__c = 'web', 
            RTL_Contact_Status__c = 'Contact',
            RTL_Product_Group_1__c = 'Bancassurance',
            RTL_OfferResult_Product_1__c = 'Interested'
        );
        insert cm1;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        
        system.debug('currentObject = '+camPage.currentObject);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCampaignMemberExtension());
        
		Continuation conti = (Continuation)camPage.requestCampaignData();
        HttpResponse response = new HttpResponse();
        response.setBody('<?xml version=\'1.0\' encoding=\'UTF-8\'?>'+
                            '<CampaignMemberResponse>'+
                              	'<CampaignMemberList/>'+
    							'<Header>'+
                                	'<ErrorStatus>fail</ErrorStatus>'+
                                	'<ErrorCode>00</ErrorCode>'+
                                	'<ErrorDescription/>'+
                                	'<TotalRecords>0</TotalRecords>'+
                              	'</Header>'+
                            '</CampaignMemberResponse>');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        system.debug('requestLabel---'+camPage.requestLabel);
        Test.setContinuationResponse(camPage.requestLabel, response);
        Object result = Test.invokeContinuationMethod(camPage, conti);
        system.debug('result'+result);
        Test.stopTest();
    }
    public static testMethod void positive() {     
        //TestUtils.createForCXMToSales();
        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;

        RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
            Name ='Local Exclusive Campaign Running No.' , 
            DateValue__c='170717',
            Day__c='17',
            Month__c='07',
            Year__c='17',
            Running_No__c = '01' );
        insert rn;
        
        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
        );
        
        insert cmrn;
        
        List<Lead> leads = new List<Lead>();
        
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        List<Opportunity> oppList = new List<Opportunity>();
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            RTL_TestUtility.createRetailMasterProducts(true);
        	leads = RTL_TestUtility.createLeads(2,true);
        	RTL_TestUtility.createInterestedProducts(leads, true);
            
            RTL_Interested_products_c__c nonPrimaryProduct = [select Is_Primary__c from RTL_Interested_products_c__c where Lead__c = :leads.get(0).Id and Is_Primary__c = false];
            nonPrimaryProduct.Is_Primary__c = true;
            //check result: the update should be failed because no more than one primary interested product is allowed
            boolean errMsgMatch = false;
            try {
                update nonPrimaryProduct;
            } catch (Exception ex) {
                
            }   
        }
        System.runAs(firstUser) {
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=firstUser.Id);
        }
        System.runAs(firstUser) {
            oppList = RTL_TestUtility.createOpportunity(accList,true);
        }
        
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        // 2023-09-20
        camp.RTL_Campaign_Code_10_digits__c = '0DSSZLZA37';
        insert camp;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = leads.get(0).id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'web';     
        cm1.RTL_Contact_Status__c = 'Contact';
        cm1.RTL_Product_Group_1__c = 'Bancassurance';
        cm1.RTL_OfferResult_Product_1__c = 'Interested';
        //cm1.RTL_RelatedOpportunity_1__c = oppList.get(0).Id;
        insert cm1;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);
        for( Integer i = 1 ; i <= 1 ; i++ ){
            camPage.createOppList.add( new RTL_CampaignMemberExtension.CampaignProductInterestedWrapper(i++,
                                                                            'RTL_Product_Group_'+i+'__c',
                                                                            'RTL_Sub_Group_'+i+'__c',
                                                                            'RTL_Campaign_Product_'+i+'__c',
                                                                            'RTL_Campaign_Product_'+i+'__r.Name',
                                                                            oppList.get(0),
                                                                            true,
                                                                            true,
                                                                            'RTL_Campaign_Product_'+i+'__r.Name'                            
                                                                           )  );
        }
        camPage.saveLogCampaignmember(cm1);
        camPage.createInterestedProduct(leads.get(0));
        camPage.updateCampaignMember();
        camPage.getOpportunityList();
        //camPage.queryFulfillment('1','1');
        camPage.getNID('123');
        
        camPage.apexSave();
        camPage.redirectAfterSave();
        camPage.apexCreateOpportunity();

        cm1.RTL_RelatedOpportunity_1__c = null;
        update cm1;
        camPage.nextPageCreateOpportunity();
        camPage.getCampaignProductInterested();
        
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        // cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Contact_Status__c = 'New';
        cm1.RTL_Memo__c = 'test only';
        update cm1;
        camPage.apexSave();
        camPage.redirectAfterSave();
                
        
        camPage.backPageEditCampaignMember();
        camPage.nextPageViewOpportunity();
        camPage.defaultContactStatus();
        camPage.editCampaignMemberButton();
        camPage.closeWithSalesApp();
        camPage.canceltoview();
        camPage.getCampaignProduct();
        
        camPage.isCampaignActive = true;
        camPage.editCampaignMemberButton();
        camPage.query = 'test';
		camPage.runQuery();
        camPage.selectRadio();
        List<CM_OB_Sell_Permission__mdt> sellPermission = camPage.cmOBSellPermissionList;
        camPage.getCampaingNameEscaped();
		String exclusiveCalloutErrorDesc = camPage.exclusiveCalloutErrorDesc;
		String exclusiveCalloutError = camPage.exclusiveCalloutError;
		Boolean exclusiveCalloutSuccess = camPage.exclusiveCalloutSuccess;
        
        List<RTL_CampaignProductInterestedWrapper> createOptyList = camPage.CreateOpytyList;
        Account custTMBCustomerIDPE = [SELECT Id,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Campaign campaignCode10Digits = [SELECT Id,RTL_Campaign_Code_10_digits__c FROM Campaign LIMIT 1];
        //Insert RTL FulfillMent for test
        List<RTL_Fulfillment__c> rtlFullFillMents = new List<RTL_Fulfillment__c>();
        rtlFullFillMents.add(new RTL_Fulfillment__c(
            RTL_Customer__c = custTMBCustomerIDPE.Id,
            RTL_Campaign__c = campaignCode10Digits.Id
        ));
        insert rtlFullFillMents;
        //Insert Contact for Test
        List<Contact> contactTests = new List<Contact>();
        contactTests.add(new Contact(
            TMB_Customer_ID__c = custTMBCustomerIDPE.TMB_Customer_ID_PE__c,
            LastName = 'Test',
            AccountId = custTMBCustomerIDPE.Id
        ));
        insert contactTests;
        camPage.contactData = contactTests.get(0);
        System.debug([SELECT id,name,TMB_Customer_ID__c,account.name,AccountId FROM CONTACT]);
		camPage.getFulfillmentList(custTMBCustomerIDPE.TMB_Customer_ID_PE__c,campaignCode10Digits.RTL_Campaign_Code_10_digits__c,1);
        camPage.previousFulfillment();
        camPage.navigateFulfillment();
        camPage.close();
        camPage.clearLookupSearch();
        camPage.nextFulfillment();
        RTL_CampaignMemberExtension.settingValueTranformation(custTMBCustomerIDPE.Id);
        System.debug(custTMBCustomerIDPE);
        System.debug(campaignCode10Digits);
        System.debug([SELECT Id,RTL_Customer__r.TMB_Customer_ID_PE__c FROM RTL_Fulfillment__c]);
        Test.stopTest();
    }          
}