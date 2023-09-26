public without sharing class LeadConvertComercialController {
    public static RecordType CompletedSurvey {
        get{
        if(CompletedSurvey==null){
                CompletedSurvey = [SELECT id,Name FROM RecordType 
                                 WHERE Name='NPS Survey Complete' 
                                 AND sObjectType='Survey__c' LIMIT 1];
            }
        return CompletedSurvey;
        }set;
    }

    @AuraEnabled
    public static InitInfoWrapper getInitInfo(String leadId){
        InitInfoWrapper res = new InitInfoWrapper();
        res.offerResultPicklist.add('None');
        List<Business_Outcome_Mapping__c> outcomeMappings = [SELECT Avaya_Completion_Code__c, Contact_Status__c, Uncontact_Reason__c, Offer_Result__c, Unqualified_Reason__c, Sub_Unqualified_Reason__c FROM Business_Outcome_Mapping__c WHERE IsActive__c = true AND (Contact_Status__c != null OR Uncontact_Reason__c != null) AND Screen_type__c =: 'Juristic Lead'];
        List<String> contactStatusSet = getDependentPicklistValues('Business_Outcome_Mapping__c','Contact_Status__c','Juristic Lead');
        // List<String> unContactReasonSet = getDependentPicklistValues('Business_Outcome_Mapping__c','Uncontact_Reason__c','Uncontact');
        Set<String> unContactReasonSet = new Set<String>();

        // Set<String> unContactReasonSet = new Set<String>();
        Business_Outcome_Mapping__c productOutcomeDefault = null;
        for(Business_Outcome_Mapping__c each :outcomeMappings){
            // if(String.isNotBlank(each.Contact_Status__c)){
            //     contactStatusSet.add(each.Contact_Status__c);
            // }
            if(String.isNotBlank(each.Uncontact_Reason__c)){
                unContactReasonSet.add(each.Uncontact_Reason__c);
            }
            if(String.isNotBlank(each.Offer_Result__c)){
                res.offerResultPicklist.add(each.Offer_Result__c);
                if(String.isNotBlank(each.Unqualified_Reason__c)){
                    if(!res.unqualReasonPicklist.containsKey(each.Offer_Result__c)){
                        res.unqualReasonPicklist.put(each.Offer_Result__c, new Set<String>());
                    }
                    res.unqualReasonPicklist.get(each.Offer_Result__c).add(each.Unqualified_Reason__c);

                    if(String.isNotBlank(each.Sub_Unqualified_Reason__c)){
                        if(!res.subUnqualReasonPicklist.containsKey(each.Offer_Result__c + each.Unqualified_Reason__c)){
                            res.subUnqualReasonPicklist.put(each.Offer_Result__c + each.Unqualified_Reason__c, new Set<String>());
                        }
                        res.subUnqualReasonPicklist.get(each.Offer_Result__c + each.Unqualified_Reason__c).add(each.Sub_Unqualified_Reason__c);
                    }
                }
                if(productOutcomeDefault == null){
                    productOutcomeDefault = each;
                }
            }
        }
        for(String each :contactStatusSet){
            PicklistOption picklist = new PicklistOption(each, each);
            res.contactStatusPicklist.add(picklist);
        }
        for(String each :unContactReasonSet){
            PicklistOption picklist = new PicklistOption(each, each);
            res.uncontactReasonPicklist.add(picklist);
        }
        
        List<Lead> leads = [SELECT Id, Status, RTL_Uncontact_reason__c, COM_Complete_Code__c, COM_Expected_Complete_Date__c, COM_Expected_Submit_Date__c,Interest_result__c, Other_Reason__c,Account__c,RecordTypeId,Avaya_Integration_Lead__c,
        (SELECT Id, Name, Opportunity_Type__c, COM_Offer_Result__c, COM_Unqualified_Reason__c, COM_Sub_Unqualified_Reason__c, COM_Other_Reason__c, Amount__c, Cross_Sell__c, Opportunity__c, Opportunity__r.Name, Related_Account__c,Product__c,Product__r.Name FROM Product_Interest__r ORDER BY CREATEDDATE ASC) 
        FROM Lead 
        WHERE Id = :leadId];


        if(leads.size() > 0){
            Lead curLead = leads.get(0);
            // if(curLead.Status == 'Contacted')
            // {
            //     curLead.Status = 'Contact';
            // }
            String recordTypeId_ComAcc = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
            if(curLead.RecordTypeId == recordTypeId_ComAcc){
                res.isCommercialAcc = true;
            }else{
                res.isCommercialAcc = false;
            }
            for(Product_Interest__c each :curLead.Product_Interest__r){
                if(String.isBlank(each.COM_Offer_Result__c)){
                    //each.COM_Offer_Result__c = 'Interested';
                    // Default offer result to None
                    each.COM_Offer_Result__c = 'None';
                    each.COM_Unqualified_Reason__c = null;
                    each.COM_Sub_Unqualified_Reason__c = null;
                }
                if(each.Cross_Sell__c){
                    res.crossSellProducts.add(each);
                }
                else{
                    res.campaignProducts.add(each);
                }
            }
            res.leadInfo.Id = curLead.Id;
            res.leadInfo.COM_Complete_Code__c = curLead.COM_Complete_Code__c;
            res.leadInfo.COM_Expected_Complete_Date__c = curLead.COM_Expected_Complete_Date__c;
            res.leadInfo.COM_Expected_Submit_Date__c = curLead.COM_Expected_Submit_Date__c;
            res.leadInfo.Interest_result__c = curLead.Interest_result__c;
            res.leadInfo.Other_Reason__c = curLead.Other_Reason__c;
            res.leadInfo.Account__c = curLead.Account__c;
            res.leadInfo.RecordTypeId = curLead.RecordTypeId;
            res.leadInfo.Avaya_Integration_Lead__c = curLead.Avaya_Integration_Lead__c;
            if(String.isBlank(curLead.Status)){
                res.leadInfo.Status = 'Contacted';
                res.leadInfo.RTL_Uncontact_reason__c = null;
            }
            else{
                res.leadInfo.Status = curLead.Status;
                res.leadInfo.RTL_Uncontact_reason__c = curLead.RTL_Uncontact_reason__c;
            }
        }
        return res;
    }
    public static List<String> getPickListValues(String objectName,String fieldName){
        
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        List<String> pickListValuesList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = objectFields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> valueList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : valueList){
            pickListValuesList.add(pickListVal.getValue());
        }     
        return pickListValuesList;
    }
    public static List<String> getDependentPicklistValues (String objectName,String fieldName, String contrlValue) //( Schema.sObjectField dependToken )
    {
        List<String> dependentPicklistValueList = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        //Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.DescribeFieldResult depend = objectFields.get(fieldName).getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                    //  :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getValue() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                //dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
                dependentPicklistValues.get( controlValue ).add( entry.getValue() );
            }
        }
        for(Object key : dependentPicklistValues.keySet())
        {
            // System.debug('key:'+key.ToString().toUpperCase());
            // System.debug('contrlValue:'+contrlValue.toUpperCase());
            // System.debug('dependentPicklistValues:'+dependentPicklistValues.get(key));
            if(key.ToString().toUpperCase() == contrlValue.toUpperCase())
            {
                if(dependentPicklistValues.containsKey(key))
                {
                    dependentPicklistValueList = dependentPicklistValues.get(key);
                }
                
            }
            
        }
        return dependentPicklistValueList;
    }
    @AuraEnabled
    public static ConvertResponse checkLead(String leadId){
        // System.debug('leadInfo:'+leadInfo);
        ConvertResponse res = new ConvertResponse();
        // Boolean IsAllowToConvert = true;
        Boolean isCommercialLead = false;
        Boolean isFromSurvey = false;
        String errorMsg = '';

        try 
        {
            Lead leadObj = [SELECT Name,Status, Unqualified_Reasons__c, Remark__c, RecordType.Name, MobilePhone, Phone, Primary_Campaign__c,
            Customer_Type__c, Salutation, FirstName, LastName, company, Customer_Name_EN__c, ID_Type__c, 
            ID_Number__c, Exception_Flag__c, OwnerID, Contacted_Flag__c, Interest_result__c,
            Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ext__c, email, Email__c,
            RecordTypeId,Mobile_No__c, Office_No__c, Unqualified_Action__c, Parent_Company__c,
            Total_Expected_Revenue__c, LeadSource,Other_Source__c, Preferred_Branch__c, 
            Branch_Referred__c, Referral_Staff_ID__c, Referral_Staff_Name__c, Rating, 
            Industry__c, Account__c, Account__r.OwnerID, Account__r.Name, Owner_Segment__c,
            Title, Decision_Map__c, Phone__c, Province__c, Zipcode__c, Country__c,
            Sales_amount_per_year__c, No_of_Years_Business_Run__c, Group__c, Original_Referral_Staff_ID__c,
            Original_Referral_Staff__c, Suggested_Segment__c, Suggested_Team__c, Pre_screen_passed__c, Sub_Unqualified_Reason__c,
            FNA_Activity__c, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c, Fna_Product_Holding__c, Fna_Product_Interested__c,
            RTL_Referral__c, Link_Document__c, Other_Reason__c, Lead_Segment__c
            FROM Lead WHERE Id =: leadId];

            List<Call_Report__c> visitplan = [SELECT Id,Lead__c FROM Call_Report__c WHERE Lead__c =: leadId];
            List<Task> logaCall = [SELECT Id From Task WHERE LeadID__c =: leadId AND Lead_Record_Type__c LIKE 'Commercial%'];
            List<Task> logaCall_Popup = [SELECT Id From Task WHERE Related_Object__c =: leadId];
            System.debug('LeadObj:'+leadObj);
            List<Product_Interest__c> ProductList = [SELECT Amount__c, Opportunity__c, Opportunity_Type__c, Product__c, Product__r.Name,Status__c 
                            FROM Product_Interest__c 
                            WHERE Lead__c =: leadId];
            System.debug('RecordType:'+leadobj.RecordType.Name );
            if(leadobj.RecordType.Name == 'Commercial Lead'){
                isCommercialLead = true;
            }
            if(leadObj.Status == 'Contacted' && visitplan.size() == 0 && logaCall.size() == 0 && logaCall_Popup.size() == 0){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6004').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6004').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }
            System.debug('leadobj.Pre_screen_passed__c  :'+leadobj.Pre_screen_passed__c );
            if(!leadobj.Pre_screen_passed__c ){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6020').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6020').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }
    
            if(!leadobj.Contacted_Flag__c && !isFromSurvey){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6004').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6004').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }
        
            if(leadobj.Customer_Type__c == null || leadobj.Customer_Type__c ==''){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6005').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6005').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert =false;
            }

            if(leadobj.LastName.containsIgnoreCase('N/A') || (leadobj.LastName == null || leadobj.LastName == '')){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6006').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6006').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert =false; 
            }

            if((leadobj.FirstName == null || leadobj.FirstName == '')){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6007').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6007').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert =false; 
            }    

            if((leadobj.ID_Type__c == null || leadobj.ID_Type__c =='') || (leadobj.ID_Number__c == null || leadobj.ID_Number__c == '')){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6008').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6008').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }

            if(leadobj.Office_No__c == null && leadobj.Mobile_No__c == null && leadobj.RecordType.Name == 'Commercial Lead'){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6009').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6009').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }

            if(ProductList.size() == 0 && !isFromSurvey && (leadObj.Status == 'Contacted' || leadObj.Status == 'Passed Prescreening' || leadObj.Status == 'Open')){
                res.success = false;
                res.type = 'error';
                if(errorMsg == '')
                {
                    errorMsg = Status_Code__c.GetValues('6010').Status_Message__c;
                }
                else {
                    errorMsg += '\n'+Status_Code__c.GetValues('6010').Status_Message__c;
                }
                res.message = errorMsg;
                // IsAllowToConvert = false;
            }
        } 
        catch(DMLException e){
            System.debug(e.getMessage());
            res.success = false;
            res.type = 'redirect';
            res.message = e.getMessage();
        }
        return res;
    }
    @AuraEnabled
    public static String checkLogaCall(String leadId){
      
        List<Call_Report__c> visitplan = [SELECT Id,Lead__c FROM Call_Report__c WHERE Lead__c =: leadId];
        List<Task> logaCall = [SELECT Id From Task WHERE LeadID__c =: leadId AND Lead_Record_Type__c LIKE 'Commercial%'];
        List<Task> logaCall_Popup = [SELECT Id From Task WHERE Related_Object__c =: leadId];

        if(visitplan.size() == 0 && logaCall.size() == 0 && logaCall_Popup.size() == 0){
            String errorMsg = Status_Code__c.GetValues('6004').Status_Message__c;
            return errorMsg;
        }
        return null;
    }
    @AuraEnabled
    public static Map<String, String> mapAvayaCode(){
        Map<String, String> mapAvayaCode = new Map<String, String>();
        List<Business_Outcome_Mapping__c> outcomeMappings = [SELECT Avaya_Completion_Code__c, Contact_Status__c, Uncontact_Reason__c, Offer_Result__c, Reason__c, Unqualified_Reason__c, Sub_Unqualified_Reason__c,Lead_Survey__c FROM Business_Outcome_Mapping__c WHERE IsActive__c = true AND (Contact_Status__c != null OR Offer_Result__c != null) AND Screen_type__c =: 'Juristic Lead'];
        System.debug('outcomeMappings:'+outcomeMappings);
        for(Business_Outcome_Mapping__c each :outcomeMappings){
            if(String.isNotBlank(each.Offer_Result__c)){
                String key = (String.isNotBlank(each.Offer_Result__c)? each.Offer_Result__c : '') + (String.isNotBlank(each.Reason__c)? ' ' + each.Reason__c : '') + (String.isNotBlank(each.Unqualified_Reason__c)? ' ' + each.Unqualified_Reason__c : '') + (String.isNotBlank(each.Sub_Unqualified_Reason__c)? each.Sub_Unqualified_Reason__c : '');
                mapAvayaCode.put(key, each.Avaya_Completion_Code__c);
            }
            String key = (String.isNotBlank(each.Contact_Status__c)? each.Contact_Status__c : '') + (String.isNotBlank(each.Uncontact_Reason__c)? ' ' + each.Uncontact_Reason__c : '') + (String.isNotBlank(each.Lead_Survey__c)? each.Lead_Survey__c : '');
            mapAvayaCode.put(key, each.Avaya_Completion_Code__c);
        }
        System.debug(mapAvayaCode);
        return mapAvayaCode;
    }

    @AuraEnabled
    public static void saveForm(String leadId, String infoWrapper){
        try 
        {
            System.debug(infoWrapper);
            InitInfoWrapper info = (InitInfoWrapper)System.JSON.deserialize(infoWrapper, InitInfoWrapper.class);
            Map<String, String> mapAvayaCode = mapAvayaCode();
            // Map<String, String> mapAvayaCode = new Map<String, String>();
            // List<Business_Outcome_Mapping__c> outcomeMappings = [SELECT Avaya_Completion_Code__c, Contact_Status__c, Uncontact_Reason__c, Offer_Result__c, Reason__c, Sub_Unqualified_Reason__c FROM Business_Outcome_Mapping__c WHERE IsActive__c = true AND Retail_Product_Group__c = 'Commercial' AND (Contact_Status__c != null OR Offer_Result__c != null)];
            // for(Business_Outcome_Mapping__c each :outcomeMappings){
            //     if(String.isNotBlank(each.Offer_Result__c)){
            //         String key = (String.isNotBlank(each.Offer_Result__c)? each.Offer_Result__c : '') + (String.isNotBlank(each.Reason__c)? ' ' + each.Reason__c : '') + (String.isNotBlank(each.Sub_Unqualified_Reason__c)? each.Sub_Unqualified_Reason__c : '');
            //         mapAvayaCode.put(key, each.Avaya_Completion_Code__c);
            //     }
            //     String key = (String.isNotBlank(each.Contact_Status__c)? each.Contact_Status__c : '') + (String.isNotBlank(each.Uncontact_Reason__c)? ' ' + each.Uncontact_Reason__c : '');
            //     mapAvayaCode.put(key, each.Avaya_Completion_Code__c);
            // }
            // System.debug(mapAvayaCode);
            Boolean saveLead = true;
            for(Product_Interest__c each :info.campaignProducts){
                String key = (String.isNotBlank(each.COM_Offer_Result__c)? each.COM_Offer_Result__c : '') + (String.isNotBlank(each.COM_Unqualified_Reason__c)? ' ' + each.COM_Unqualified_Reason__c : '') + (String.isNotBlank(each.COM_Sub_Unqualified_Reason__c)? each.COM_Sub_Unqualified_Reason__c : '');
                System.debug('Product key ' + key);
                each.Avaya_Completion_Code__c = mapAvayaCode.containsKey(key)? mapAvayaCode.get(key) : '';
                System.debug('Completion Code ' +  each.Avaya_Completion_Code__c);
                if(each.COM_Offer_Result__c == 'None'){
                    each.COM_Offer_Result__c = null;
                }
                if(each.COM_Offer_Result__c == 'Interested'){
                    saveLead = false;
                }
            }
        
            System.debug('campaignProducts:'+info.campaignProducts);
            System.debug('crossSellProducts:'+info.crossSellProducts);
            update info.campaignProducts;
            update info.crossSellProducts;

            String leadCodeKey = (String.isNotBlank(info.leadInfo.Status)? info.leadInfo.Status : '') + (String.isNotBlank(info.leadInfo.RTL_Uncontact_reason__c)? ' ' + info.leadInfo.RTL_Uncontact_reason__c : '');
            String completeCode = '';
            System.debug('Status:'+info.leadInfo.Status);
            if(info.leadInfo.Status == 'Contacted')
            {
                completeCode = calculateCompletionCode(info.leadInfo, info.campaignProducts);
            }
            else {
                completeCode = mapAvayaCode.containsKey(leadCodeKey)? mapAvayaCode.get(leadCodeKey) : '';
            }
            
            String recordTypeId_ComAcc = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
            if (info.leadInfo.Account__c != null && info.leadInfo.RecordTypeId == recordTypeId_ComAcc) {
                System.debug('RecordTypeId:'+info.leadInfo.RecordTypeId);
                System.debug('Account__c:'+info.leadInfo.Account__c);
                if (info.leadInfo.Status == 'Do Not Contact 1year') {
                    createDoNotContact(info.leadInfo.Account__c, '1 Year');
                }
                else if (info.leadInfo.Status == 'Do Not Contact 6 Months') {
                    createDoNotContact(info.leadInfo.Account__c, '6 Months');
                }  
                else if (info.leadInfo.Status == 'Do Not Contact LifeTime') {
                    createDoNotContact(info.leadInfo.Account__c, 'LifeTime');
                } 
            }

            if((info.leadInfo.Status != 'Call Back' && info.leadInfo.Status != 'Contacted') || (info.leadInfo.Status == 'Contacted' && saveLead == true && info.crossSellProducts.size() == 0)){
                String recordTypeId_Completed = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Completed').getRecordTypeId();
                info.leadInfo.RecordtypeId = recordTypeId_Completed;
                System.debug('Save Lead : Commercial Completed');
            }
            System.debug('completeCode:'+completeCode);
            info.leadInfo.COM_Complete_Code__c = completeCode;
            info.leadInfo.Interest_result__c = 'Yes';
            update info.leadInfo;
            
            List<String> userContactID = new List<String>();
            userContactID.add(info.leadInfo.Id);
            System.debug('Avaya Integration : ' + info.leadInfo.Avaya_Integration_Lead__c);
            if(info.leadInfo.Avaya_Integration_Lead__c){
                System.debug('Avaya Integration! ');
                AvayaCompletionCodeUtility.sendCompletionCodeToAvaya(info.leadInfo.COM_Complete_Code__c, userContactID );
            }

        } catch (Exception e) {
            System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
        }
    }

    @AuraEnabled
    public static ConvertResponse convertLead(String leadId, String surveyId){

        ConvertResponse res = new ConvertResponse();
        Boolean isRequiredOpp = false;
        Boolean IsownerAllowed = false;
        Boolean IsAllowToConvert = true;
        Boolean isDuplicatedbyAccount = false;
        Boolean isDuplicated = false;
        Boolean isCommercialLead = false;
        Boolean isMobilePage = false;
        Boolean launchNextPage = false;
        Boolean isFromSurvey = false;
        Boolean toggleScript = false;
        Boolean isOppNotCreated = false;
        Boolean isneedBackToLead = false;
        Boolean isCrossSell = false;
        List<ProductWrapper> ProductWrapperList = new List<ProductWrapper>();
        List<Product_Interest__c> ProductList = new List<Product_Interest__c>();
        List<Lead> oldvalueList = new List<Lead>();
        List<Lead> newvalueList = new List<Lead>();
        // Opportunity oppty = new Opportunity();
        Opportunity stdConvertOppty = new Opportunity();
        RecordType CommercialLeadRecordType = new RecordType();
        RecordType CompletedRecordType = new RecordType();
        RecordType AccountRecordType = new RecordType();
        Set<ID> AccountPermissionSet = new Set<ID>();
        Account originalAccount = new Account();

        Lead leadObj = [SELECT Name, Unqualified_Reasons__c, Remark__c, RecordType.Name, MobilePhone, Phone, Primary_Campaign__c,
        Customer_Type__c, Salutation, FirstName, LastName, company, Customer_Name_EN__c, ID_Type__c, 
        ID_Number__c, Exception_Flag__c, OwnerID, Contacted_Flag__c, Interest_result__c,
        Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ext__c, email, Email__c,
        RecordTypeId,Mobile_No__c, Office_No__c, Unqualified_Action__c, Parent_Company__c,
        Total_Expected_Revenue__c, LeadSource,Other_Source__c, Preferred_Branch__c, 
        Branch_Referred__c, Referral_Staff_ID__c, Referral_Staff_Name__c, Rating, 
        Industry__c, Account__c, Account__r.OwnerID, Account__r.Name, Owner_Segment__c,
        Title, Decision_Map__c, Phone__c, Province__c, Zipcode__c, Country__c,
        Sales_amount_per_year__c, No_of_Years_Business_Run__c, Group__c, Original_Referral_Staff_ID__c,
        Original_Referral_Staff__c, Suggested_Segment__c, Suggested_Team__c, Pre_screen_passed__c, Sub_Unqualified_Reason__c,
        FNA_Activity__c, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c, Fna_Product_Holding__c, Fna_Product_Interested__c,
        RTL_Referral__c, Link_Document__c, Other_Reason__c, Lead_Segment__c,COM_Expected_Complete_Date__c, COM_Expected_Submit_Date__c,COM_Complete_Code__c,Avaya_Integration_Lead__c
        FROM Lead WHERE Id =: leadId];
        System.debug(leadObj.Interest_result__c);
        
        ProductList = [SELECT Amount__c, Opportunity__c, Opportunity_Type__c, Product__c, Product__r.Name,Status__c,COM_Offer_Result__c,Lead__c, Cross_Sell__c 
                        FROM Product_Interest__c 
                        WHERE Lead__c =: leadobj.Id];
        System.debug('ProductList:'+ProductList);
        CommercialLeadRecordType = [SELECT id, Name FROM RecordType WHERE Name = 'Commercial Lead' AND sObjectType = 'Lead' LIMIT 1];
        CompletedRecordType = [SELECT id,Name FROM RecordType WHERE Name = 'Commercial Completed' AND sObjectType = 'Lead' LIMIT 1];
        AccountRecordType = [SELECT id,Name FROM RecordType WHERE Name = 'Commercial Account' AND sObjectType = 'Lead' LIMIT 1];

        List<String> userContactID = new List<String>();
        userContactID.add(leadobj.Id);

        if(leadObj.Interest_result__c == 'Yes'){
            //Check Criteria
            if(leadObj.Account__c != null){
                List<AccountTeamMember> acctteam = [SELECT ID, AccountId, UserId FROM AccountTeamMember
                            WHERE AccountId =: leadObj.Account__c
                            AND UserId =: leadobj.OwnerId LIMIT 1];
                                          
                //Owner Or Account Owner or Account Team allow
                if((leadObj.ownerID == leadObj.Account__r.OwnerID) || (acctTeam.size() > 0)){
                   IsownerAllowed = true;
                }
                else{
                    //RMC Allow
                    List<Account__c> privilegeList = Account__c.getall().values();
                    User LeadOwner = [SELECT Id, UserRole.Name, Segment__c FROM User WHERE ID =:leadobj.OwnerId LIMIT 1];
                    for(Account__c eachPrivilege : privilegeList){
                        if(LeadOwner.UserRole.Name == eachPrivilege.Role__c ){
                            IsownerAllowed = true;
                        }                    
                    }
                }
            }
            else{
                IsownerAllowed = true;
            }

            if(leadobj.RecordType.Name == 'Commercial Lead'){
                isCommercialLead = true;
            }
                
            //Check Opportunity Condition to Create
            Boolean isValidOppStage = true;
            List<Product_Interest__c> CreditProductList = new List<Product_Interest__c>();
            List<Product_Interest__c> NonCreditProductList = new List<Product_Interest__c>();
            List<Opportunity> UpdateLinkToOppList = new List<Opportunity>();
            Set<ID> Product2List = new Set<ID>();
            Map<ID,ID> LinkToOppMap = new Map<Id,ID>();
            boolean isCreateNewCreditOpp = false;
            boolean isCreateNewNonCreditOpp = false;
            String NewCreditOpptyName;

            for(Product_Interest__c PI : ProductList){
                if(PI.COM_Offer_Result__c == 'Interested')
                {
                    if(PI.Opportunity_Type__c == 'Credit'){
                        CreditProductList.add(PI);
                        if(PI.Opportunity__c != null){
                            LinkToOppMap.Put(PI.id, PI.Opportunity__c);
                        }
                        else
                        {
                            if(NewCreditOpptyName == null)
                            {
                                NewCreditOpptyName = PI.Product__r.Name;
                            }
                            isCreateNewCreditOpp = true;
                        }
                    }
                    else if(PI.Opportunity_Type__c == 'Non-Credit')
                    {
                        NonCreditProductList.add(PI);
                        if(PI.Opportunity__c != null){
                            LinkToOppMap.Put(PI.Id, PI.Opportunity__c);
                        }
                        else
                        {
                            isCreateNewNonCreditOpp = true;
                        }
                    }
                    Product2List.add(PI.Product__c);
                }
            }
            
            if(CreditProductList.size() > 0 || NonCreditProductList.size() > 0){
                isRequiredOpp = true; 
            }
            else {
                isRequiredOpp = false; 
            }

            if(!IsownerAllowed  && isRequiredOpp){
                res.success = false;
                res.type = 'error';
                res.message = Status_Code__c.GetValues('6011').Status_Message__c;
                IsAllowToConvert = false; 
            }

            if(isAllowToConvert){
                oldvalueList = new List<Lead>();
                newvalueList = new List<Lead>();
                oldvalueList.add(new Lead());
                newvaluelist.add(leadObj);
                //New Check dup 
                Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,leadObj);
                CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
                System.debug('results : '+LeadWrapper);
                System.debug('results : '+LeadWrapper.isfoundDuplicate);
                System.debug('results : '+LeadWrapper.OrgininalrecordType);
                System.debug('results : '+LeadWrapper.Originalrecord);

                if(LeadWrapper.isfoundDuplicate && IsAllowToConvert && leadObj.RecordTypeID == CommercialLeadRecordType.id){
                    //DUPLICATED WITH EXISTING ACCOUNT IN THE SYSTEM
                    if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType == 'Account' ){
                        String AcctID = String.valueof(LeadWrapper.Originalrecord.get('ID'));
                        //Query Account detail for populate data
                        originalAccount = [SELECT ID, Customer_Type__c, Customer_Name_PE_ENg__c, ParentId, Suggested_Sub_Segment__c  
                                            ,Name, Mobile_Number_PE__c, phone, ID_Type_PE__c, OwnerID
                                            ,ID_Number_PE__c, Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, Primary_Address_Line_3_PE__c
                                            ,Province_Primary_PE__c, Zip_Code_Primary_PE__c, Country_Primary_PE__c
                                            ,Industry, Sales_amount_per_year__c, No_of_years_business_run__c
                                            ,TMB_Employee_ID__c, TMB_Employee_Name__c, Remark__c, Rating,Industry__c
                                            ,Group__c, Branch_Referred__c, Suggested_Segment__c
                                            ,Email_Address_PE__c, Primary_Phone_Ext_PE__c
                                            FROM Account
                                            WHERE ID =:AcctID
                                            LIMIT 1];
                        //Add OwnerID to permissionset    
                        AccountPermissionSet.add(originalAccount.OwnerId);
                            
                        for(AccountTeamMember acctTeam :[SELECT ID,AccountId, UserId FROM  AccountTeamMember WHERE AccountId =: originalAccount.id]){
                            AccountPermissionSet.add(acctTeam.UserId); 
                        }

                        isDuplicatedbyAccount = true;
                        isDuplicated = true;
                    }
                } 
                System.debug('isDuplicatedbyAccount: '+isDuplicatedbyAccount);  
                System.debug('IsAllowToConvert: '+IsAllowToConvert);
                //EndCheck Criteria
            }
            
            if(isDuplicatedbyAccount){
                //Populate Data from Original Account record
                leadObj.Company = originalAccount.Name;
                leadObj.Customer_Name_EN__c = originalAccount.Customer_Name_PE_Eng__c;
                leadObj.Customer_Type__c = originalAccount.Customer_Type__c;
                leadobj.ID_Type__c = originalAccount.ID_Type_PE__c;
                leadobj.ID_Number__c = originalAccount.ID_Number_PE__c;
                //leadobj.TMB_Cust_ID__c = originalAccount.TMB_Customer_ID_PE__c;
                leadobj.Account__c = originalAccount.id;
                leadObj.Mobile_No__c = originalAccount.Mobile_Number_PE__c;
                leadobj.Office_No__c = originalAccount.Phone;
                leadobj.Ext__c = originalAccount.Primary_Phone_Ext_PE__c;
                leadobj.Email__c = originalAccount.Email_Address_PE__c;
                leadobj.Address_Line_1__c = originalAccount.Primary_Address_Line_1_PE__c=='None'?'':originalAccount.Primary_Address_Line_1_PE__c;
                leadobj.Address_Line_2__c = originalAccount.Primary_Address_Line_2_PE__c=='None'?'':originalAccount.Primary_Address_Line_2_PE__c;
                leadobj.Address_Line_3__c = originalAccount.Primary_Address_Line_3_PE__c=='None'?'':originalAccount.Primary_Address_Line_3_PE__c;
                leadobj.Province__c = originalAccount.Province_Primary_PE__c;
                leadobj.Zipcode__c = originalAccount.Zip_Code_Primary_PE__c;
                leadobj.Country__c = originalAccount.Country_Primary_PE__c;
                //leadobj.Industry = originalAccount.Industry;
                leadobj.Industry__c = originalAccount.Industry__c;
                leadobj.Parent_Company__c = originalAccount.ParentId;
                leadobj.Sales_amount_per_year__c = originalAccount.Sales_amount_per_year__c;
                leadobj.Group__c = originalAccount.Group__c;
                leadobj.No_of_Years_Business_Run__c = originalAccount.No_of_years_business_run__c;
                    
                //If has permission or Exception Flag
                if(AccountPermissionSet.contains(Leadobj.OwnerId) || leadobj.Exception_Flag__c == true){
                    isCommercialLead = false;
                    leadObj.RecordTypeId = AccountRecordType.id;
                }else{
                    System.debug('UNQUALIFIED BY DUPLICATED');
                    //Unqualified because do not have permissions
                    leadObj.Status = 'Unqualified';
                    leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                    leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                    leadObj.RecordTypeId = CompletedRecordType.id;
                    IsAllowToConvert = false;
                }
                    
                if(!IsAllowToConvert){
                    update leadObj;
                    
                    res.success = false;
                    res.type = 'redirect';
                    return res;
                }
            }
            
            if(IsAllowToConvert){
                System.debug(' isRequiredOpp : ' + isRequiredOpp);
                if(isRequiredOpp){
                    System.debug(' isCommercialLead : ' + isCommercialLead);
                    if(!isCommercialLead){
                        res.success = false;
                        res.type = 'warning';
                        res.message = Status_Code__c.GetValues('6013').Status_Message__c;
                        //return res;
                    }
                }
                
                Set<String> ValidStageOppty = new Set<String>();
                    ValidStageOppty.add('Analysis');
                    ValidStageOppty.add('Develop & Propose Solution');
                    ValidStageOppty.add('Follow Up');
                    if(LinkToOppMap.values().size() > 0){
                        for(Opportunity opp : [SELECT ID, ownerID, StageName, CampaignID, Converted_Lead_ID__c FROM Opportunity WHERE ID IN: LinkToOppMap.values()]){
                            opp.Expected_submit_date__c = leadObj.COM_Expected_Submit_Date__c;
                            opp.CloseDate = leadObj.COM_Expected_Complete_Date__c;
                            opp.Converted_Lead_ID__c = leadObj.id;

                            if(leadobj.Primary_Campaign__c !=null){
                                for(Product_Interest__c PI : ProductList)
                                {
                                    if(LinkToOppMap.containsKey(PI.Id))
                                    {
                                        if(PI.Cross_Sell__c)
                                        {
                                            opp.Cross_Sell_By_Campaign__c  = leadobj.Primary_Campaign__c;  
                                        }
                                        else 
                                        {
                                            opp.CampaignId  = leadobj.Primary_Campaign__c;   
                                        }
                                    }
                                }                                                        
                            }
                            
                            if(ValidStageOppty.contains(opp.StageName)){
                                UpdateLinkToOppList.add(opp);
                            }else{
                                isValidOppStage = false;
                            }
                        }
                    }

                    if(Product2List.size() == 0 && isRequiredOpp){
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6012').Status_Message__c;
                        return res;
                    }
                    else if(isRequiredOpp && !isValidOppStage){
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6015').Status_Message__c;
                        return res;
                    }
                    else if(leadObj.COM_Expected_Submit_Date__c < System.today() &&isRequiredOpp){
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6022').Status_Message__c;
                        return res;
                    }
                    else if(leadObj.COM_Expected_Complete_Date__c < leadObj.COM_Expected_Submit_Date__c && isRequiredOpp){
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6023').Status_Message__c;
                        return res;
                    }
                    else if(Product2List.size()>20){
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6017').Status_Message__c;
                        return res;
                    }
                    else if(isDuplicatedbyAccount 
                        && !AccountPermissionSet.contains(leadobj.OwnerId)
                        &&(leadobj.Exception_Flag__c == false 
                            || (leadobj.Exception_Flag__c == true && (isCreateNewNonCreditOpp || isCreateNewCreditOpp || LinkToOppMap.size() > 0))
                        )
                    ){
                        leadobj.Interest_result__c = null;
                        leadobj.Remark__c = null;
                        update leadObj;
            
                        res.success = false;
                        res.type = 'error';
                        res.message = Status_Code__c.GetValues('6011').Status_Message__c;
                        return res;            
                    }
                    else
                    {
                        try
                        {
                            if(isDuplicatedbyAccount){
                                update leadObj;
                            }
                                
                            Account acct;
                            Contact con;
                            if(leadObj.RecordTypeId == CommercialLeadRecordType.Id){
                                acct = LeadToAccount(leadObj);
                                acct.OwnerID = leadobj.OwnerID;
                                
                                insert acct;
            
                                con =  LeadToContact(leadobj, acct.id);
                                System.debug('con : '+con);
                            }
                            else 
                            {
                                acct = [SELECT Id, Name FROM Account WHERE Id =: leadObj.Account__c LIMIT 1];
                                List<Contact> ExistingConList = [SELECT Id, FirstName, LastName, AccountID, IsActive__c, Recordtype.Name
                                                                FROM Contact WHERE AccountID =: leadObj.Account__c];
                                boolean isMatched = false;
                                for(contact existingCon : ExistingConList)
                                {
                                    if(existingCon.Recordtype.Name == 'Core bank' && !existingCon.IsActive__c) continue;
                                    if(existingCon.FirstName == Leadobj.FirstName && existingCon.LastName == Leadobj.LastName){
                                        isMatched = true;
                                        con = existingCon;
                                    }
                                }
                                
                                if(!isMatched)
                                {
                                    con =  LeadToContact(leadobj,acct.id);
                                    
                                } 
                            }

                            leadobj.Account__c = acct.id;
                            //Issue Pre-screen automated : Jantanee comment
                            //leadobj.Pre_screening_Result__c = 'Passed';
                            leadobj.Contacted_Flag__c = true;
                            leadobj.RecordTypeId = CompletedRecordType.id;
                            //leadObj.Uninterested_Reason__c =null;
                            update leadobj;
                            
                            //CONVERT PROCESS
                            Database.LeadConvert lc = new database.LeadConvert();

                            lc.setDoNotCreateOpportunity(false);                
                            lc.setLeadId(leadObj.id);
                            lc.setAccountId(acct.id);
                            lc.setContactId(con.id);
                            
                            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                            Database.LeadConvertResult lcr;     
                            
                            //Generate Opportunity
                            if(isRequiredOpp && isValidOppStage)
                            {
                                if(UpdateLinkToOppList.size()>0){
                                    update UpdateLinkToOppList;
                                }
                            
                                Id recordIdSECreditProduct;
                                Id recordIdSENonCreditProduct;
                                Id recordIdWBGCreditProduct;
                                Id recordIdWBGNonCreditProduct;
                                List<RecordType>  recordTypeList = [SELECT Id, Name 
                                                                    FROM RecordType 
                                                                    WHERE   Name IN ( 'SE Credit Product',
                                                                                    'Non-credit Product',
                                                                                    'WBG Credit Product')
                                                                            AND SobjectType = 'Opportunity'];
                                for( RecordType eachRecordType : recordTypeList ){
                                    if( eachRecordType.Name == 'SE Credit Product' ){
                                        recordIdSECreditProduct = eachRecordType.Id;
                                    }else if( eachRecordType.Name == 'Non-credit Product' ){
                                        recordIdSENonCreditProduct = eachRecordType.Id;
                                        recordIdWBGNonCreditProduct = eachRecordType.Id;
                                    }else if( eachRecordType.Name == 'WBG Credit Product' ){
                                        recordIdWBGCreditProduct = eachRecordType.Id;
                                    }
                                }
                            
                                lc.setConvertedStatus(convertStatus.MasterLabel);
                                    
                                lcr = Database.convertLead(lc);
                                //CONVERT PROCESS

                                //Query Temporary Opportunity
                                stdConvertOppty =[SELECT ID, Branch_Referred__c, Other_Source__c, LeadSource, OwnerId, Converted_Lead_ID__c, CampaignId, CloseDate
                                                        ,Lead_Expect_Revenue__c, Referral_Staff_Name__c, Referral_Staff_ID__c, AccountId, Expected_submit_date__c
                                                FROM Opportunity 
                                                WHERE ID =: lcr.getOpportunityID()
                                                LIMIT 1];
                        
                                /*********** CR Referral  *******************/
                                if(leadObj.RTL_Referral__c != null){
                                    RTL_Referral__c referral = [SELECT Id, Name, RTL_EmployeeId__c, RTL_Employee_Name__c, RTL_Stage__c,RTL_Type__c
                                                            FROM RTL_Referral__c 
                                                            WHERE ID =: leadObj.RTL_Referral__c LIMIT 1];

                                    System.debug('LEAD ::::: '+lcr.getAccountID());
                                    referral.RTL_Account_Name__c = lcr.getAccountID();

                                    //CH01:CR Refer within Commercial 9 May 2018 , do not auto update referral status to Closed(Interested) for Type = To Product Team
                                    if(referral.RTL_Stage__c != 'Closed (Interested)' && referral.RTL_Type__c != 'To Product Team (เพื่อส่งให้ทีม Product)'){
                                        referral.RTL_Stage__c = 'Closed (Interested)';
                                    }
                                    
                                    update referral;        
                                }

                                System.Debug('leadObj.FNA_Activity__c ' + leadObj.FNA_Activity__c ); 
                                if(leadObj.FNA_Activity__c != null){
                                    FNA_activity__c fna = new FNA_activity__c();
                                    fna.id = leadObj.FNA_Activity__c;
                                    fna.Customer__c = lcr.getAccountID();
                                    update fna;

                                    List<Account> account = [SELECT Id, RecordTypeId, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c,
                                                Fna_Product_Holding__c, Fna_Product_Interested__c FROM Account WHERE Id =:lcr.getAccountID()];
                                    System.Debug('account' + account ); 
                                    if(account.size() > 0){
                                        System.Debug('Fna_Avatar_Name__c afterUpdate' + leadObj.Fna_Avatar_Name__c ); 
                                        System.Debug('Fna_Avatar_Url__c afterUpdate' + leadObj.Fna_Avatar_Url__c ); 
                                        System.Debug('Fna_Create_Date__c afterUpdate' + leadObj.Fna_Create_Date__c ); 
                                        System.Debug('Fna_Have_Referral__c afterUpdate' + leadObj.Fna_Have_Referral__c ); 
                                        System.Debug('Fna_Product_Holding__c afterUpdate' + leadObj.Fna_Product_Holding__c ); 
                                        System.Debug('Fna_Product_Interested__c afterUpdate' + leadObj.Fna_Product_Interested__c ); 

                                        if(account[0].Fna_Avatar_Name__c == null || account[0].Fna_Avatar_Name__c == ''){
                                            if(leadObj.Fna_Avatar_Name__c != null){
                                                account[0].Fna_Avatar_Name__c = leadObj.Fna_Avatar_Name__c; //Avatar Name
                                            }
                                        }

                                        if(account[0].Fna_Avatar_Url__c == null || account[0].Fna_Avatar_Url__c == ''){
                                            if(leadObj.Fna_Avatar_Url__c != null){
                                                account[0].Fna_Avatar_Url__c = leadObj.Fna_Avatar_Url__c; //URL Avatar Image
                                            }
                                        }

                                        if(account[0].Fna_Create_Date__c == null ){
                                            if(leadObj.Fna_Create_Date__c != null){
                                                account[0].Fna_Create_Date__c = leadObj.Fna_Create_Date__c; //FNA Create date
                                            }
                                        }

                                        account[0].Fna_Have_Referral__c = leadObj.Fna_Have_Referral__c; //FNA Have Referral

                                        if(account[0].Fna_Product_Holding__c == null || account[0].Fna_Product_Holding__c == ''){
                                            if(leadObj.Fna_Product_Holding__c != null){
                                                account[0].Fna_Product_Holding__c = leadObj.Fna_Product_Holding__c; //FNA Product Holding
                                            }
                                        }
                                        if(account[0].Fna_Product_Interested__c == null || account[0].Fna_Product_Interested__c == ''){
                                            if(leadObj.Fna_Product_Interested__c != null){
                                                account[0].Fna_Product_Interested__c = leadObj.Fna_Product_Interested__c; //FNA Interested Product
                                            }
                                        }

                                        update account;
                                    }
                                }

                                //Get 2 values from Screen//
                                stdConvertOppty.CloseDate = leadObj.COM_Expected_Complete_Date__c;

                                System.debug('stdConvertOppty.CloseDate::'+stdConvertOppty.CloseDate);
                                //System.debug('stdConvertOppty.CloseDate Year::'+stdConvertOppty.CloseDate.year());
                                
                                stdConvertOppty.Expected_submit_date__c = leadObj.COM_Expected_Submit_Date__c;
                                stdConvertOppty.StageName = 'Analysis';
                                if(leadobj.Primary_Campaign__c != null){                               
                                    stdConvertOppty.CampaignId  = leadobj.Primary_Campaign__c;   
                                }
                            
                                //Opportunity Field Mapping
                                stdConvertOppty.AccountId = acct.id;
                                stdConvertOppty.OwnerId = leadobj.OwnerID;
                                stdConvertOppty.Lead_Expect_Revenue__c  = leadobj.Total_Expected_Revenue__c;
                                stdConvertOppty.LeadSource = leadobj.LeadSource;
                                stdConvertOppty.Other_Source__c = leadobj.Other_Source__c;
                                stdConvertOppty.Branch_Referred__c = leadobj.Branch_Referred__c;
                                stdConvertOppty.Referral_Staff_ID__c = leadobj.Referral_Staff_ID__c;
                                stdConvertOppty.Referral_Staff_Name__c = leadobj.Referral_Staff_Name__c;
                                stdConvertOppty.Converted_Lead_ID__c = leadobj.id;
                                
                                /*********** CR Referral  *******************/
                                stdConvertOppty.RTL_Referral__c = leadobj.RTL_Referral__c;
                                
                                //Get PricebookEntry
                                // Mapping Product with PricebookEntry ID
                                    
                                Map<ID,pricebookentry> ProductWithPEMap = new  Map<ID,pricebookentry>();
                                
                                User currentUser = [SELECT ID,Segment__c from User Where ID =: Userinfo.getUserId() LIMIT 1];
                                String PricebookAccessName;
                                if(currentUser.Segment__c != null){
                                    PricebookAccessName = currentUser.Segment__c;
                                }else{
                                    PricebookAccessName = 'Default';
                                }
                                Pricebook2 Pricebook = [SELECT ID,Name from Pricebook2
                                                        WHERE IsStandard = false
                                                        AND Name =: Price_book_access__c.GetValues(PricebookAccessName).PricebookItem__c
                                                        LIMIT 1];

                                for(pricebookentry Pe : [SELECT id,product2id,pricebook2id from pricebookentry 
                                                        WHERE product2id IN:Product2List AND pricebook2id =: pricebook.id]
                                ){
                                    ProductWithPEMap.put(Pe.Product2Id,Pe);            
                                }                                                           

                                //Query VisitPlan for Create Visit Report Opportunities
                                List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c
                                                FROM Call_report__c 
                                                WHERE Lead__c =: leadobj.id];
                                List<opportunityLineitem> CreditOpplineInsertList = new List<opportunityLineitem>();
                                //Credit Opportunity 1:N
                                if(CreditProductList.size() > 0){
                                    List<Visit_Report_Opportunity__c> newVisitOppTyList = new List<Visit_Report_Opportunity__c>();
                                    //Link VisitPlan Oppty
                                    for(Call_Report__c visitplan : VisitPlanList){
                                        Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
                                        visitopp.Customer__c  = visitplan.id;
                                        newVisitOppTyList.add(visitopp);
                                    }
                                
                                    //Set Name
                                    String OppName = Acct.Name + ' : ' + NewCreditOpptyName;
                                    stdConvertOppty.Name = OppName.left(180);

                                    //Add Remark to Oppty 
                                    stdConvertOppty.Remark__c = leadObj.Remark__c;
                                    
                                    //Set RecordType following Segment
                                    /********** change condition following BAU Issue 2017-06-26 *****************
                                     if(leadobj.Owner_Segment__c =='SE'){
                                         stdConvertOppty.RecordTypeId = recordIdSECreditProduct;
                                    }else{
                                            stdConvertOppty.RecordTypeId = recordIdWBGCreditProduct;
                                    }
                                    */
                                    Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Opportunity;    
                                    List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
                                    for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                                        if(rtInfo.isDefaultRecordTypeMapping()) {               
                                            stdConvertOppty.RecordTypeId = rtInfo.getRecordTypeId();
                                        }
                                    }
                                
                                    // Insert Oppty before references to Oppline
                                    if(isCreateNewCreditOpp){
                                        for(Visit_Report_Opportunity__c visitopp : newVisitOppTyList){
                                            //visitopp.Opportunity__c = oppty.id;
                                            visitopp.Opportunity__c = stdConvertOppty.id;
                                        }
                                        insert newVisitOppTyList;
                                    }
                                    

                                    //Create oppline
                                    Id pricebookEntryID;
                                    for(Product_Interest__c PI : CreditProductList){

                                        if(PI.Cross_Sell__c)
                                        {
                                            stdConvertOppty.Cross_Sell_By_Campaign__c = leadobj.Primary_Campaign__c;  
                                            stdConvertOppty.CampaignId = null;
                                        }
                                        else 
                                        {
                                            stdConvertOppty.CampaignId  = leadobj.Primary_Campaign__c;  
                                            stdConvertOppty.Cross_Sell_By_Campaign__c = null; 
                                        }

                                        opportunityLineitem oppLine = new opportunityLineitem();
                                        
                                        if(ProductWithPEMap.containsKey(Pi.Product__c)){
                                            oppLine.PricebookEntryId = ProductWithPEMap.get(Pi.Product__c).id;
                                            pricebookEntryID = ProductWithPEMap.get(Pi.Product__c).id;
                                        }
                                        oppLine.Quantity = 1;
                                        Oppline.Expected_Revenue__c = pi.amount__c==null?0:pi.amount__c;
                                        oppLine.UnitPrice = 0;
                                        //oppline.TotalPrice = pi.amount__c==null?0:pi.amount__c;

                                        // ************** CR Modify Opportunity Template ************** //
                                        map<integer,string> mapMonth = new map<integer,string>();
                                        mapMonth.put(1,'Jan');
                                        mapMonth.put(2,'Feb');
                                        mapMonth.put(3,'Mar');
                                        mapMonth.put(4,'Apr');
                                        mapMonth.put(5,'May');
                                        mapMonth.put(6,'Jun');
                                        mapMonth.put(7,'Jul');
                                        mapMonth.put(8,'Aug');
                                        mapMonth.put(9,'Sep');
                                        mapMonth.put(10,'Oct');
                                        mapMonth.put(11,'Nov');
                                        mapMonth.put(12,'Dec');
                                        
                                        oppLine.RevisedStartMonth__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                                        oppLine.RevisedStartMonthFee__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                                        //*********** Becuase CloseDate.year() = B.E. **********/
                                        if(Userinfo.getLocale() == 'th_TH'){
                                            oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                                            oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                                            System.debug('getLocale :: th_TH');
                                        }else{
                                            oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year());
                                            oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year());
                                            System.debug('getLocale :: else');
                                        }

                                        System.debug('oppLine.RevisedStartYear__c ::'+oppLine.RevisedStartYear__c);
                                        System.debug('oppLine.RevisedStartYearFee__c ::'+oppLine.RevisedStartYearFee__c);
                                        oppLine.Frequency__c = 'Monthly';
                                        oppLine.FrequencyFee__c = 'Monthly';
                                        // ************** CR Modify Opportunity Template ************** //
                                                                
                                        CreditOpplineInsertList.add(oppline);
                                        PI.status__c = 'Opp Created';
                                        
                                        if(LinkToOppMap.containsKey(PI.id)){
                                                PI.Opportunity__c = LinkToOppMap.get(PI.id);
                                                oppline.OpportunityId = LinkToOppMap.get(PI.id);
                                        }else{
                                            // PI.Opportunity__c = oppty.id;
                                                oppline.OpportunityId =stdConvertOppty.id;
                                                PI.Opportunity__c = stdConvertOppty.id;
                                                oppline.OpportunityId =stdConvertOppty.id;
                                        }
                                    }
                                }

                                update stdConvertOppty;
                                //Create Opp  1:1
                                List<opportunityLineitem> NonCreditOpplineInsertList = new List<opportunityLineitem>();
                                List<Opportunity> NonCreditOpptyInsertList = new List<Opportunity>();

                                if(NonCreditProductList.size()>0){
                                    List< Visit_Report_Opportunity__c > newVisitOppTyList = new List<Visit_Report_Opportunity__c>();
                                
                                    Integer countOpptyIndex = 1;
                                    for(Product_Interest__c PI : NonCreditProductList){
                                        //SetOppty
                                        if(!LinkToOppMap.containsKey(PI.ID)){
                                            Opportunity eachopp;
                                            if(countOpptyIndex==1 && !isCreateNewCreditOpp){
                                                eachopp = new Opportunity(id=stdConvertOppty.id);
                                            }else{
                                                eachopp = new Opportunity();
                                            }
                                            countOpptyIndex++;
                                            
                                            //eachopp.CloseDate = oppty.CloseDate;
                                            eachopp.CloseDate = stdConvertOppty.CloseDate;
                                            eachopp.StageName = 'Analysis';
                                            eachopp.Converted_Lead_ID__c = leadobj.id;
                                            if(leadobj.Primary_Campaign__c !=null)
                                            {
                                                if(PI.Cross_Sell__c)
                                                {
                                                    eachOpp.Cross_Sell_By_Campaign__c  = leadobj.Primary_Campaign__c;  
                                                }
                                                else {
                                                    eachOpp.CampaignId  = leadobj.Primary_Campaign__c;  
                                                }                             
                                            }

                                            eachopp.AccountId = acct.id;
                                            eachopp.Lead_Expect_Revenue__c  = leadobj.Total_Expected_Revenue__c;
                                            eachopp.LeadSource = leadobj.LeadSource;
                                            eachopp.Other_Source__c = leadobj.Other_Source__c;
                                            eachopp.Branch_Referred__c = leadobj.Branch_Referred__c;
                                            eachopp.Referral_Staff_ID__c = leadobj.Referral_Staff_ID__c;
                                            eachopp.Referral_Staff_Name__c = leadobj.Referral_Staff_Name__c;
                                            //eachopp.Expected_submit_date__c = oppty.Expected_submit_date__c;
                                            eachopp.Expected_submit_date__c = stdConvertOppty.Expected_submit_date__c;
                                            eachOpp.OwnerID = leadobj.OwnerID;
                                            eachOpp.AccountId = acct.id;
                                            
                                            /*********** CR Referral  *******************/
                                            eachOpp.RTL_Referral__c = leadobj.RTL_Referral__c;
                                                
                                            if(Test.isRunningTest()){
                                                eachOpp.Pricebook2Id = [SELECT ID,Name from Pricebook2 WHERE Name ='Commercial Pricebook' LIMIT 1 ].ID;
                                            }
                                                
                                            if(leadobj.Owner_Segment__c =='SE'){
                                                eachOpp.RecordTypeId = recordIdSENonCreditProduct;
                                            }else{
                                                eachOpp.RecordTypeId = recordIdWBGNonCreditProduct;
                                            }

                                                //Set Name
                                            // String OppName = Acct.Name + ' : ' + PI.Product__r.Name;
                                            // eachOpp.Name = OppName.left(180);
                                            eachOpp.Name = PI.Product__c;
                                            NonCreditOpptyInsertList.add(eachOpp); 
                                        }
                                    }

                                    upsert NonCreditOpptyInsertList;
                                
                                    if(NonCreditOpptyInsertList.size()>0){
                                        //get First Non-credit Oppty
                                        Opportunity NonCreditOpp = NonCreditOpptyInsertList.get(0);
                                    }

                                    //CR link to Opportunity Lead
                                    Map<String,Opportunity> ProductIDwithOppMap = new Map<String,Opportunity>();
                                    for(Opportunity each : NonCreditOpptyInsertList){
                                        ProductIDwithOppMap.put(each.Name, each);
                                        //Link Visit Oppty
                                        for(Call_Report__c visitplan : VisitPlanList){
                                            Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
                                            visitopp.Customer__c  = visitplan.id;
                                            visitopp.Opportunity__c = each.id;
                                            newVisitOppTyList.add(visitopp);
                                        }
                                    }
                                                                                    
                                    insert newVisitOppTyList;
                                    for(Product_Interest__c PInterest : NonCreditProductList){
                                        //SetOppLine
                                        opportunityLineitem oppLine = new opportunityLineitem();
                                        if(ProductWithPEMap.containsKey(PInterest.Product__c)){
                                            oppLine.PricebookEntryId = ProductWithPEMap.get(PInterest.Product__c).id;
                                        }
                                        oppLine.Quantity = 1;
                                        oppline.Expected_Revenue__c = PInterest.amount__c == null? 0: PInterest.amount__c;
                                        oppLine.UnitPrice = 0;
                                        // oppLine.TotalPrice= PInterest.amount__c==null?0:PInterest.amount__c;
                                        if(LinktoOppMap.containsKey(PInterest.id)){
                                            oppline.OpportunityId = LinktoOppMap.get(PInterest.id);
                                            PInterest.Opportunity__c = LinktoOppMap.get(PInterest.id);
                                        }else{
                                            oppline.OpportunityId = ProductIDwithOppMap.get(PInterest.Product__c).id;
                                            PInterest.Opportunity__c = ProductIDwithOppMap.get(PInterest.Product__c).id;

                                            Opportunity oppty = ProductIDwithOppMap.get(PInterest.Product__c);
                                            String OppName = Acct.Name + ' : ' + PInterest.Product__r.Name;
                                            oppty.Name = OppName.left(180);
                                        }
                                        PInterest.status__c = 'Opp Created';

                                        // ************** CR Modify Opportunity Template ************** //
                                        map<integer,string> mapMonth = new map<integer,string>();
                                        mapMonth.put(1,'Jan');
                                        mapMonth.put(2,'Feb');
                                        mapMonth.put(3,'Mar');
                                        mapMonth.put(4,'Apr');
                                        mapMonth.put(5,'May');
                                        mapMonth.put(6,'Jun');
                                        mapMonth.put(7,'Jul');
                                        mapMonth.put(8,'Aug');
                                        mapMonth.put(9,'Sep');
                                        mapMonth.put(10,'Oct');
                                        mapMonth.put(11,'Nov');
                                        mapMonth.put(12,'Dec');
                                        
                                        oppLine.RevisedStartMonth__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                                        oppLine.RevisedStartMonthFee__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                                        if(Userinfo.getLocale() == 'th_TH'){
                                            oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                                            oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                                            System.debug('getLocale :: th_TH');
                                        }else{
                                            oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year());
                                            oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year());
                                            System.debug('getLocale :: else');
                                        }
                                        oppLine.Frequency__c = 'Monthly';
                                        oppLine.FrequencyFee__c = 'Monthly';
                                        // ************** CR Modify Opportunity Template ************** //
                                                                
                                        NonCreditOpplineInsertList.add(oppLine);
                                    }
                                }
                            
                                //DML Oprations
                                if(CreditOpplineInsertList.size()>0){
                                    insert CreditOpplineInsertList;
                                    update CreditProductList;
                                }
                                
                                
                                if(NonCreditProductList.size() >0){
                                    update NonCreditOpptyInsertList;
                                    insert NonCreditOpplineInsertList;
                                    update NonCreditProductList;
                                }
                            }
                            else
                            {
                                lc.setDoNotCreateOpportunity(true);
                                lc.setConvertedStatus(convertStatus.MasterLabel);
                                lcr = Database.convertLead(lc);
                                //CONVERT PROCESS
                                /*********** CR Referral  *******************/
                                if(leadObj.RTL_Referral__c != null){
                                    RTL_Referral__c referral = [SELECT Id, Name, RTL_EmployeeId__c, RTL_Employee_Name__c, RTL_Stage__c
                                                                FROM RTL_Referral__c 
                                                                WHERE ID =: leadObj.RTL_Referral__c LIMIT 1];
            
                                    System.debug('LEAD ::::: '+lcr.getAccountID());
                                    referral.RTL_Account_Name__c = lcr.getAccountID();
                                    referral.RTL_Stage__c = 'In progress_Contacted';
                                    update referral;        
                                }
            
                                System.debug('FNA ::::: '+ leadObj.FNA_Activity__c);
                                if(leadObj.FNA_Activity__c != null){
                                    FNA_activity__c fna = new FNA_activity__c();
                                    fna.id = leadObj.FNA_Activity__c;
                                    fna.Customer__c = lcr.getAccountID();
                                    update fna;
            
                                    List<Account> account = [SELECT Id, RecordTypeId, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c,
                                            Fna_Product_Holding__c, Fna_Product_Interested__c FROM Account WHERE Id =:lcr.getAccountID()];
                                    System.debug('FNA account::::: '+ account);
                                    if(account.size() > 0){
                                        System.Debug('Fna_Avatar_Name__c afterUpdate' + leadObj.Fna_Avatar_Name__c ); 
                                        System.Debug('Fna_Avatar_Url__c afterUpdate' + leadObj.Fna_Avatar_Url__c ); 
                                        System.Debug('Fna_Create_Date__c afterUpdate' + leadObj.Fna_Create_Date__c ); 
                                        System.Debug('Fna_Have_Referral__c afterUpdate' + leadObj.Fna_Have_Referral__c ); 
                                        System.Debug('Fna_Product_Holding__c afterUpdate' + leadObj.Fna_Product_Holding__c ); 
                                        System.Debug('Fna_Product_Interested__c afterUpdate' + leadObj.Fna_Product_Interested__c ); 
                                        if(account[0].Fna_Avatar_Name__c == null || account[0].Fna_Avatar_Name__c == ''){
                                            if(leadObj.Fna_Avatar_Name__c != null){
                                                account[0].Fna_Avatar_Name__c = leadObj.Fna_Avatar_Name__c; //Avatar Name
                                            }
                                        }
            
                                        if(account[0].Fna_Avatar_Url__c == null || account[0].Fna_Avatar_Url__c == ''){
                                            if(leadObj.Fna_Avatar_Url__c != null){
                                                account[0].Fna_Avatar_Url__c = leadObj.Fna_Avatar_Url__c; //URL Avatar Image
                                            }
                                        }
            
                                        if(account[0].Fna_Create_Date__c == null ){
                                            if(leadObj.Fna_Create_Date__c != null){
                                                account[0].Fna_Create_Date__c = leadObj.Fna_Create_Date__c; //FNA Create date
                                            }
                                        }
            
                                        account[0].Fna_Have_Referral__c = leadObj.Fna_Have_Referral__c; //FNA Have Referral
            
                                        if(account[0].Fna_Product_Holding__c == null || account[0].Fna_Product_Holding__c == ''){
                                            if(leadObj.Fna_Product_Holding__c != null){
                                                account[0].Fna_Product_Holding__c = leadObj.Fna_Product_Holding__c; //FNA Product Holding
                                            }
                                        }
                                        if(account[0].Fna_Product_Interested__c == null || account[0].Fna_Product_Interested__c == ''){
                                            if(leadObj.Fna_Product_Interested__c != null){
                                                account[0].Fna_Product_Interested__c = leadObj.Fna_Product_Interested__c; //FNA Interested Product
                                            }
                                        }
            
                                        update account;
                                    }
                                }
                                
                                for(Product_Interest__c PI : ProductList){
                                    PI.Status__c  = 'Opp Not Created';
                                    
                                }
                                
                                update ProductList;
                            } 
            
                            List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c FROM Call_report__c WHERE Lead__c =: leadobj.id];
                            for(Call_report__c visit : VisitPlanList){
                                visit.Customer_name__c = leadobj.Account__c;
                            }
                            
                            update VisitPlanList;
            
                            System.debug('Convert Success');
                            if(lcr.isSuccess()){
                                System.debug('Redirect to Customer');
                                if(surveyId != '' && surveyId != null){
                                    try{
                                        // Survey__c surveyobj = [SELECT Id,Customer__c FROM Survey__c WHERE Id =: surveyId LIMIT 1];
                                        Survey__c surveyobj = new Survey__c();
                                        surveyobj.Id = surveyId;
                                        surveyobj.Customer__c = lcr.getAccountId();
                                        surveyobj.RecordTypeId = CompletedSurvey.id;
                                        surveyobj.result__c = 'Completed';
                                        update surveyobj;
                                    }catch(Exception e){
                                        System.debug('Update Survey Err : '+ e.getMessage());
                                        System.debug('Update Survey Err : '+ e.getLineNumber());
                                    }

                                }
                                Account accOb = [SELECT Id FROM Account WHERE Id =: leadobj.Account__c];
                                res.success = true;
                                res.accountId = accOb.Id;
                                return res;
                            }else{
                                System.debug(lcr.getErrors() + '');
                                res.success = false;
                                res.type = 'error';
                                res.message = lcr.getErrors() + ''; 
                                return res;
                            }                           
                        }
                        catch(Exception ex)
                        {
                            System.debug('line : '+ex.getLineNumber());
                            System.debug('errormessage : '+ex.getMessage());
                            res.success = false;
                            res.type = 'error';
                            res.message = ex.getMessage(); 
                            return res;    
                        }
                    }
            }
            if(leadObj.Avaya_Integration_Lead__c){
                AvayaCompletionCodeUtility.sendCompletionCodeToAvaya(leadobj.COM_Complete_Code__c, userContactID );
            }
            return res;
        }
        //Not Interested
        else{
            try{
                if(leadObj.Unqualified_Reasons__c ==null || leadObj.Unqualified_Reasons__c==''){
                    res.success = false;
                    res.type = 'error';
                    res.message = Status_Code__c.GetValues('6016').Status_Message__c;
                    return res;
                }else{
                    leadObj.Status = 'Not Converted';
                    leadobj.RecordTypeId = CompletedRecordType.id;
                
                    update leadObj;

                    //Update Product Interest
                    for(Product_Interest__c PI : ProductList){
                        PI.status__c = 'Not Interested';
                    }
                    update ProductList;
                
                    //Update Visit Plan/Report
                    if(leadobj.Account__c !=null){
                        List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c FROM Call_report__c WHERE Lead__c =: leadobj.Id];
                        for(Call_report__c visit : VisitPlanList){
                            visit.Customer_name__c = leadobj.Account__c;
                        }
                        update VisitPlanList;
                    }
                
                    res.success = false;
                    res.type = 'redirect';

                }
            }catch(DMLException e){
                System.debug(e.getMessage());
                res.success = false;
                res.type = 'redirect';
                res.message = e.getMessage();
            }
            if(leadObj.Avaya_Integration_Lead__c){
                AvayaCompletionCodeUtility.sendCompletionCodeToAvaya(leadobj.COM_Complete_Code__c, userContactID );
            }
            return res;
        }

    }

    public static Contact LeadToContact(Lead leadrecord, ID AccountID){
        Contact con = new Contact();
        con.Title = leadrecord.Salutation;
        con.FirstName = leadrecord.FirstName;
        con.LastName = leadrecord.LastName;
        con.Last_Name__c = leadrecord.LastName;
        con.Position__c = leadrecord.Title;
        con.Decision_Map__c = leadrecord.Decision_Map__c;
        con.MobilePhone = leadrecord.Phone__c;
        con.OwnerId = leadrecord.OwnerId;
        con.AccountId = AccountID;
        //fix issues 23/08/2016
        con.Account__c = AccountID;
        //fix issues 23/08/2016
        con.C_Country_PE__c = 'Thailand';
        insert con;
        
        return con;
    }
    
    public static Account LeadToAccount(Lead leadObj){
        Account acct = new Account();
        acct.Customer_Type__c = leadObj.Customer_Type__c;
        acct.OwnerId = leadObj.OwnerId;
        acct.Account_Type__c  = 'Qualified Prospect';
        acct.Name = leadObj.Company;
        acct.Customer_Name_PE_Eng__c = leadObj.Customer_Name_EN__c;
        acct.ID_Type_PE__c = leadobj.ID_Type__c ;
        acct.ID_Number_PE__c = leadobj.ID_Number__c;
        acct.Mobile_Number_PE__c = leadObj.Mobile_No__c;
        acct.Phone = leadobj.Office_No__c;
        acct.Primary_Phone_Ext_PE__c = leadobj.Ext__c;
        acct.Primary_Address_Line_1_PE__c = leadobj.Address_Line_1__c=='None'?'':leadobj.Address_Line_1__c;
        acct.Primary_Address_Line_2_PE__c = leadobj.Address_Line_2__c=='None'?'':leadobj.Address_Line_2__c;
        acct.Primary_Address_Line_3_PE__c = leadobj.Address_Line_3__c=='None'?'':leadobj.Address_Line_3__c;
        acct.Province_Primary_PE__c = leadobj.Province__c;
        acct.Zip_Code_Primary_PE__c = leadobj.Zipcode__c;
        acct.Country_Primary_PE__c = leadobj.Country__c;
        acct.Rating = leadobj.Rating;
        acct.Industry__c =  leadobj.Industry__c;
        acct.ParentId = leadobj.Parent_Company__c;
        acct.Sales_amount_per_year__c = leadobj.Sales_amount_per_year__c;
        acct.Group__c = leadobj.Group__c;
        acct.No_of_years_business_run__c = leadobj.No_of_Years_Business_Run__c;
        acct.Branch_Referred__c = leadobj.Branch_Referred__c;
        acct.TMB_Employee_ID__c  = leadobj.Original_Referral_Staff_ID__c ;
        acct.TMB_Employee_Name__c = leadobj.Original_Referral_Staff__c;
        acct.Remark__c = leadobj.Remark__c;
        acct.Suggested_Segment__c = leadobj.Suggested_Segment__c;
        acct.Suggested_Sub_Segment__c = leadobj.Suggested_Team__c;
        acct.Branch_and_Zone__c = leadobj.Preferred_Branch__c;
        //(Lead)Email__c = Email_Address_PE__c (Account) 
        //(Lead)Parent_Company__c = Parent (Account)
        acct.ParentId = leadobj.Parent_Company__c;
        acct.Email_Address_PE__c = Leadobj.Email__c;
                       
        return acct;
    }

    public class InitInfoWrapper{
        @AuraEnabled
        public Lead leadInfo {get; set;}
        @AuraEnabled
        public List<Product_Interest__c> campaignProducts {get; set;}
        @AuraEnabled
        public List<Product_Interest__c> crossSellProducts {get; set;}
        @AuraEnabled
        public List<PicklistOption> contactStatusPicklist {get; set;}
        @AuraEnabled
        public List<PicklistOption> uncontactReasonPicklist {get; set;}
        @AuraEnabled
        public Set<String> offerResultPicklist {get; set;}
        @AuraEnabled
        public Map<String, Set<String>> unqualReasonPicklist {get; set;}
        @AuraEnabled
        public Map<String, Set<String>> subUnqualReasonPicklist {get; set;}
        @AuraEnabled
        public Boolean isCommercialAcc {get;set;}
        
        InitInfoWrapper(){
            leadInfo = new Lead();
            campaignProducts = new List<Product_Interest__c>();
            crossSellProducts = new List<Product_Interest__c>();
            contactStatusPicklist = new List<PicklistOption>();
            uncontactReasonPicklist = new List<PicklistOption>();
            offerResultPicklist = new Set<String>();
            unqualReasonPicklist = new Map<String, Set<String>>();
            subUnqualReasonPicklist = new Map<String, Set<String>>();
        }
    }

    public class PicklistOption{
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String label {get;set;}

        PicklistOption(String value, String label){
            this.value = value;
            this.label = label;
        }
    }

    public class ConvertResponse{
        @AuraEnabled
        public Boolean success {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
    }

    public class ProductWrapper {
        public Product_Interest__c productIn {get;set;}
        public boolean isSelected {get;set;}
    }

    public static String calculateCompletionCode(Lead leadObj,List<Product_Interest__c> productList)
    {
        Integer numberOfProduct = 0;
        Integer count_Of_YES_Complete_Sale = 0;
        Integer count_Of_NIN_Not_Interest = 0;
        Integer count_Of_NQF_Not_Qualify = 0;
        Integer count_Of_Not_Interest_Recall = 0;
        String completionCode;
        System.debug('leadObj:'+leadObj);
        System.debug('productList:'+productList);
        if(leadObj.Status == 'Contacted')
        {
            //Check Number Of Product
            if(productList.size() > 0)
            {
                for(Product_Interest__c product : productList)
                {     
                    if(product.Avaya_Completion_Code__c == 'YES')
                    {
                        count_Of_YES_Complete_Sale++;
                    }
                    else if(product.Avaya_Completion_Code__c == 'NIN')
                    {
                        count_Of_NIN_Not_Interest++;
                    }
                    else if(product.Avaya_Completion_Code__c == 'NQF')
                    {
                        count_Of_NQF_Not_Qualify++;
                    }
                    else if(product.Avaya_Completion_Code__c == 'NIN_Recall')
                    {
                        count_Of_Not_Interest_Recall++;
                    }
                    numberOfProduct++;
                }
                System.debug('count_Of_YES_Complete_Sale:'+count_Of_YES_Complete_Sale);
                System.debug('count_Of_NIN_Not_Interest:'+count_Of_NIN_Not_Interest);
                System.debug('count_Of_NQF_Not_Qualify:'+count_Of_NQF_Not_Qualify);
                System.debug('count_Of_Not_Interest_Recall:'+count_Of_Not_Interest_Recall);
                completionCode = BusinessOutcomeMappingUtil.calculateCompletionCode(numberOfProduct,count_Of_YES_Complete_Sale,count_Of_NIN_Not_Interest,count_Of_NQF_Not_Qualify,count_Of_Not_Interest_Recall);
            }
            else {
                completionCode = null;
            }
        }

        System.debug('completionCode:'+completionCode);
        return completionCode;
    }

    public static void createDoNotContact(Id customer, String period){
        try{ 
            RTL_Do_not_Contact_Info__c doNotContact = new RTL_Do_not_Contact_Info__c();
            Date dateNow = Date.today();
            doNotContact.Product_Group__c = 'All';
            doNotContact.Channel__c = 'All';
            doNotContact.Start_Date__c = dateNow;
            doNotContact.Customer__c = customer;
            if (period == '1 Year') 
            {
                doNotContact.Period__c = '1 Year';
                doNotContact.End_Date__c = dateNow.addYears(1);
            } else if(period == '6 Months'){
                doNotContact.Period__c = '	6 Months';
                doNotContact.End_Date__c = dateNow.addMonths(6);
            }
            else if(period == 'LifeTime')
            {
                doNotContact.Period__c = 'Life Time';
                Integer maxValue = Integer.valueOf(365.2425*100);
                doNotContact.End_Date__c = dateNow.addDays(maxValue);
            }
            insert doNotContact;
        }
        catch( Exception e ){
            System.debug('CRM : '+e.getMessage());
            throw new AuraHandledException(e.getMessage().unescapeHtml4());
        }
    }
    
   
}