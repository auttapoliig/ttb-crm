global with sharing class RTL_ReferralChangeOwner {
    @AuraEnabled
    webservice static String acceptReferral(String referralId){
        String result;
        try{
            //*************************************Deploy on 16 Nov 2023******************************
            //SCR0601724 : Automate update referral status when referee click “รับงาน” Dev by Attasit K.
            //Add fields RTL_RecordType_Name__c,RTL_Stage__c on query
            //Check condition update stage to 'Accepted & In Progress' only records type : Retail Order Transaction or Retail Cross Channel Referral
            RTL_Referral__c referral = [SELECT Id,Name,OwnerId,RTL_RecordType_Name__c,RTL_Stage__c FROM RTL_Referral__c WHERE Id=:referralId];
            if(referral.RTL_RecordType_Name__c == 'Retail Order Transaction' || referral.RTL_RecordType_Name__c == 'Retail Cross Channel Referral'){
                if(referral.OwnerId == System.UserInfo.getUserId()){
                    referral.RTL_Stage__c = 'Accepted & In Progress';
                }else if(referral.OwnerId != System.UserInfo.getUserId()){
                   referral.OwnerId = System.UserInfo.getUserId(); 
                   referral.RTL_Stage__c = 'Accepted & In Progress';         
                }
            	referral.RTL_Is_Accept_Button__c = true;
            }else{
                referral.OwnerId = System.UserInfo.getUserId();
            	referral.RTL_Is_Accept_Button__c = true;
            }
            
        	update referral;
            result = 'Success';
        }catch(DMLException e){
            result = e.getDmlMessage(0);
        }catch(Exception e){
            result = e.getMessage();
        }
        return result;
        
    }

    @AuraEnabled
    public static List<Lead> getLeadByReferralId(Id recordId) {
        return [SELECT Id, Name FROM Lead WHERE RTL_Referral__c = :recordId];
    }

    @AuraEnabled
    public static RTL_Referral__c getReferral(Id recordId) {
        return [SELECT RTL_AL_available_time__c,RTL_AL_car_bought_from__c,RTL_AL_car_brand__c,RTL_AL_car_gear__c,RTL_AL_car_group__c,RTL_AL_car_subtype__c,
        RTL_AL_car_type__c,RTL_AL_car_year__c,RTL_AL_comment__c,RTL_AL_contact_channel__c,RTL_AL_installment_amount__c,RTL_AL_installment_periods__c,
        RTL_AL_normal_price__c,RTL_AL_wanted_amount__c,RTL_AL_oa_ref_code__c,RTL_AL_car_plate_no__c,RTL_AL_Interested_Rate__c,RTL_AL_ContactDistrict__c,
        RTL_AL_ContactSubDistrict__c,RTL_AL_ContactZipcode__c,RTL_AL_ContactProvince__c,RTL_AL_max_set_up_amount__c,RTL_AL_ILA_AMT__c,RTL_AL_REMN_MTH__c,
        RTL_AL_OFFR_ILA_AMT__c,RTL_AL_OFFR_ILA_MTH__c,RTL_AL_BlueBook__c,Id, Name, RTL_Is_Owner__c, RTL_Stage__c, RTL_Type__c, RTL_Account_Name__c, RTL_RecordType_Name__c, 
        RTL_Account_Name__r.Id, RTL_Product_Name__r.Id, RTL_Product_Name__r.Name, RTL_Product_Name__r.Product_Group__c,RTL_Contact_Address__c,Avaya_Integration_Lead__c FROM RTL_Referral__c WHERE Id = :recordId];
    }

    @AuraEnabled
    public static Map<String, Object> getOptyRecordType() {
        Map<String, String> mapRecord = new Map<String, String>();
        for (RTL_Opty_RecordType_ProductGroup_Mapping__mdt obj : [SELECT Id,DeveloperName, MasterLabel,RTL_Product_Group__c,RTL_RecordTypeId__c FROM RTL_Opty_RecordType_ProductGroup_Mapping__mdt]) {
            mapRecord.put(obj.MasterLabel, obj.RTL_RecordTypeId__c);
        }
        return mapRecord;
    }

    //-- CR Outbound --
    @AuraEnabled
    public static Boolean checkPermissionByCompletionCode(RTL_Referral__c refObj){
        Boolean isPermission = true;
        User currentUser = [SELECT Id,Profile.Name,LanguageLocaleKey,Employee_Id__c FROM User WHERE Id =:UserInfo.getUserId()];
        List<Business_Outcome_Mapping__c> bomList = [SELECT Id, Name, Product_Group__c, Offer_Result__c, Unqualified_Reason__c, Sub_Unqualified_Reason__c, Lead_Survey__c, Uncontact_Reason__c, Reason__c, Avaya_Completion_Code__c, Business_Outcome_Mapping_Key__c, Contact_Status__c, Retail_Product_Group__c, Screen_type__c,IsActive__c 
                                                    FROM Business_Outcome_Mapping__c WHERE Screen_type__c = 'Referral'];
        
        List<Task> existingTask = [SELECT Id,Call_Log_ID__c,Call_Start_Datetime__c,Call_End_Time__c,Related_Object__c,Call_Agent_Id__c
            FROM Task 
            WHERE Related_Object__c =: refObj.Id
            AND RecordType.Name = 'Call Log Record Type'
            ORDER BY CreatedDate DESC];
        Map<String,Task> taskMap = new Map<String,Task>();
        
        for(Task task : existingTask)
        {
            taskMap.put(task.Call_Agent_Id__c,task);
        }
        
        Map<String,String> bomMap = new Map<String,String>();
        if(bomList.size() > 0)
        {
            for(Business_Outcome_Mapping__c bom : bomList)
            {
                bomMap.put(bom.Offer_Result__c+bom.Unqualified_Reason__c,bom.Avaya_Completion_Code__c);
            }
        }
 
        System.debug('key:'+refObj.RTL_Stage__c+refObj.RTL_Reason__c);
        String key = refObj.RTL_Stage__c+refObj.RTL_Reason__c;
        if(taskMap.containsKey(currentUser.Employee_Id__c) && refObj.Avaya_Integration_Lead__c == true)
        {                                   
            if(!bomMap.containsKey(key))
            {
                isPermission = false;
            }                   
        } 
        System.debug('isPermission:'+isPermission);
        return isPermission;                 
    }
}