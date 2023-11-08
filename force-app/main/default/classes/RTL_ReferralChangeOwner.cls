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
        RTL_Account_Name__r.Id, RTL_Product_Name__r.Id, RTL_Product_Name__r.Name, RTL_Product_Name__r.Product_Group__c,RTL_Contact_Address__c FROM RTL_Referral__c WHERE Id = :recordId];
    }

    @AuraEnabled
    public static Map<String, Object> getOptyRecordType() {
        Map<String, String> mapRecord = new Map<String, String>();
        for (RTL_Opty_RecordType_ProductGroup_Mapping__mdt obj : [SELECT Id,DeveloperName, MasterLabel,RTL_Product_Group__c,RTL_RecordTypeId__c FROM RTL_Opty_RecordType_ProductGroup_Mapping__mdt]) {
            mapRecord.put(obj.MasterLabel, obj.RTL_RecordTypeId__c);
        }
        return mapRecord;
    }
}