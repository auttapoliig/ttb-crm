public without sharing class PowerBiListComponentExtension {
    public static List<Power_Bi_Report__mdt> listReport {get;set;}
    public String encryptedString {get;set;}
    private static final String ALGORITHYM ='SHA-256';
    // public String tmbCustId{get;set;}
    public Account accountData{get;set;}
    public String accId {get;set;}
    public Boolean IsAccess {get;set;}
    public Boolean IsNoAccess {get;set;}


    public PowerBiListComponentExtension(ApexPages.StandardController controller) {
        //Get all Power Bi Report 
        IsAccess = false;
        IsNoAccess = false; 
        accId = ApexPages.currentpage().getparameters().get('id');
        this.verifyAccessPermission(accId,'PowerBiList');
        if(IsAccess){
            listReport = new List<Power_Bi_Report__mdt>([select  Id, DeveloperName, ReportId__c, ReportName__c, URL_Report__c from Power_Bi_Report__mdt where Report_Type__c ='CSV'order by ReportId__c asc]);

            accountData  = [select id,TMB_Customer_ID_PE__c from ACCOUNT WHERE Id =:accId];
            encryptCustomerId(accountData.TMB_Customer_ID_PE__c);
        }
        
    }

    private void encryptCustomerId(String tmbcustId ){
        // try{
            Blob tmbBlob = Blob.valueOf(tmbcustId);
            Blob hash = Crypto.generateDigest(ALGORITHYM, tmbBlob);
            encryptedString = EncodingUtil.convertToHex(hash);
            System.debug('hash :'+ encryptedString);
            // return encryptedString;
        // }catch {
        //     System.debug(LoggingLevel.Error, e.getMessage());
        //     return null;
        // }

    }

    private void verifyAccessPermission(String recordId, String pageName){
        Map<String, Boolean> fieldVisible =  PowerBiUtils.getFieldVisibilityByPage(recordId,pageName);
        IsAccess = fieldVisible.get('Authorize');
        if(!IsAccess){ //If user can not access assign IsNoAccess to True
            IsNoAccess = true;
        }
        
    } 
}