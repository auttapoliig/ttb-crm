public with sharing class PowerBiUtils {
    private static final String ALGORITHYM ='SHA-256';
    
    @AuraEnabled(cacheable=true)
    public static String encryptCustomerId(String strParam){
        try {
            String encryptedString ='';
            Blob tmbBlob = Blob.valueOf(strParam);
            Blob hash = Crypto.generateDigest(ALGORITHYM, tmbBlob);
            encryptedString = EncodingUtil.convertToHex(hash);
            return encryptedString;
        } catch (Exception e) {
            return 'error';
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getAccount(String accId){
        try {
            Account acc =   [select id,TMB_Customer_ID_PE__c from ACCOUNT WHERE Id =:accId];
            return acc.TMB_Customer_ID_PE__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Power_Bi_Report__mdt getMetaPowerbi(){
        try {
            Power_Bi_Report__mdt metdaBi =  [select  Id, DeveloperName, ReportId__c, ReportName__c, URL_Report__c from Power_Bi_Report__mdt where Report_Type__c ='HOLDING' limit 1];
            return metdaBi;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //Copy function from RTL_ProductHoldingSummaryController
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getFieldVisibilityByPage(String recordId, String pageName){
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        String dataHidden = Label.Data_Condition_Hidden_Text;
        String profileName = currentUserProfile.Name;
        Boolean isAuth = false;
        List<Security_Matrix__mdt> autoLoan = [SELECT Field__c, Section__c FROM Security_Matrix__mdt WHERE Page__c LIKE :pageName];
        Map<String, String> mapFieldSection = new Map<String, String>();
        List<String> sectionList = new List<String>();
        for(Security_Matrix__mdt each : autoLoan){
            if(sectionList.contains(each.Section__c) == false){
                sectionList.add(each.Section__c);
            }
            mapFieldSection.put(each.Field__c, each.Section__c);
        }
        List<Data_Security_Matrix__c> dataSecMat = [SELECT Id, Access_Type__c, Section_Name__c FROM Data_Security_Matrix__c WHERE Section_Name__c IN:sectionList  AND Profile_Name__c =:profileName];
        Map<String, String> sectionAccessMap = new Map<String, String>();
        Boolean isVisibleForAuth = Test.isRunningTest() ? true : SecurityScan.verifyForAuth(recordId);
        for(Data_Security_Matrix__c i : dataSecMat){
            sectionAccessMap.put(i.Section_Name__c, i.Access_Type__c);
        }
        Map<String, Boolean> fieldAcess = new Map<String, Boolean>();
        for(String i : mapFieldSection.keySet()){
            Boolean isVisible = false;
            String section = mapFieldSection.get(i);
            String accessType = sectionAccessMap.get(section);
            if(accessType == 'All'){
                isVisible = true;
                isAuth = true;
            }
            else if(accessType == 'Authorize Only'){
                isVisible = isVisibleForAuth;
                if(isVisible == true){
                    isAuth = true;
                }
            }
            else {
                isVisible = false;
            }
            fieldAcess.put(i, isVisible);
        }
        fieldAcess.put('Authorize', isAuth);           
        return fieldAcess;
    }
}