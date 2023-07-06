global class ClearSocialPostRejectedCaseBatch implements Database.Batchable<sObject>{

    private String query;

    private static Datetime batchDate = DateTime.now();
    private static Datetime batchStartTime = DateTime.now();
    private static Datetime batchEndTime = null;

    private static String sobjectName = 'Warroom Social Post';
    private static String jobDailyName = 'Warroom Social Post purge Reject';
    private static String CSV_BODY = '';
    private static String csvHeaderStr = '';

    private static Set<Id> recordAll = new Set<Id>();
    private static Set<Id> recordSuccess = new Set<Id>();
    private static Set<Id> recordFail = new Set<Id>();
    private static Map<Id,String> mapCampaignIdwithErrorMsg = new Map<Id,String>();
    
    public static String X_MONTH{
            get{
                if(X_MONTH == null){
                    List<App_Config__mdt> appConfigList = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Warroom Clear Post x Months'];           
                    if (appConfigList != null && appConfigList.size() > 0) {
                        X_MONTH = appConfigList.get(0).Value__c;
                    }  else {
                        X_MONTH = '-3';
                    }
                }
                return X_MONTH;
                
            }set;
    }

    global ClearSocialPostRejectedCaseBatch() {
        this.query = getBatchQuery();
    }

    private String getBatchQuery() {
        String strQuery = '';
		if(Test.isRunningTest()){
            strQuery  = 'SELECT id, status__c, Case__c FROM Social_Post__c WHERE status__c =:rejectStatus limit 1'; 
       	} else {
      		strQuery  = 'SELECT id, status__c, Case__c FROM Social_Post__c WHERE status__c =:rejectStatus and LastModifiedDate<=:dateOverXMonth';      
       	}
        
        System.debug('Query --> ' + strQuery);
        return strQuery ;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		Integer months = Integer.valueOf(X_MONTH);
        
        String rejectStatus = 'Reject';
        Datetime dtTime = System.now();
        Date dt = Date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        Date dateOverXMonth = dt.addMonths(months);
        System.debug('dateOverXMonth-->' + dateOverXMonth);
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){

        System.debug('Query --> ' + scope.size());
        List<Id> caseDeleteList = new List<Id>();
        List<Id> postDeleteList = new List<Id>();

        for(sObject obj : scope) {
            Social_Post__c socialPost = (Social_Post__c) obj;

            postDeleteList.add(socialPost.Id);
            recordAll.add(socialPost.Id);

            Id caseId = socialPost.Case__c;
            if (caseId != null) {
                caseDeleteList.add(caseId);
            }
        }

        System.debug('Post ID for delete -->' + postDeleteList);
        System.debug('Case ID for delete -->' + caseDeleteList);

        // Delete records
        Database.DeleteResult[] postDeleteListResult = Database.delete(postDeleteList, false);
        Database.DeleteResult[] caseDeleteListResult = Database.delete(caseDeleteList, false);
        
        String errorMsg = '';
        for(Database.DeleteResult dr : postDeleteListResult) {
            if (dr.isSuccess()) {
                recordSuccess.add(dr.getId());
            } else {
                for(Database.Error err : dr.getErrors()) {
                    errorMsg += err.getMessage();
                }
                mapCampaignIdwithErrorMsg.put(dr.getId(),errorMsg);
            }
        }
        for(Database.DeleteResult dr : caseDeleteListResult) {
            System.debug('Case delete result ' + dr.getId() + ' --> ' + dr.isSuccess());
        }

        sendemailnotification(mapCampaignIdwithErrorMsg, recordSuccess);
    }

    global void finish(Database.BatchableContext BC) {

    }

    private static void sendemailnotification(Map<Id,String> mapCampaignIdwithErrorMsg, Set<Id> recordSuccess){
        System.debug('Size all records : ' + recordAll.size());
        System.debug('Size recordSuccess : ' + recordSuccess.size());

        for(Id eachId : recordAll){
            if(!recordSuccess.contains(eachId)){
                recordFail.add(eachId);
            }
        }
        
        batchEndTime = DateTime.now();
        Integer recordsFailed = recordFail.size();
        System.debug('Size recordsFailed : ' + recordsFailed);
        System.debug('mapCampaignIdwithErrorMsg size : ' + mapCampaignIdwithErrorMsg.size());
        try {

            // if(mapCampaignIdwithErrorMsg.size() > 0)
            // {             

                csvHeaderStr = csvHeaderStr + 
                        'Social Post Id' + ',' +
                        'Error Message';
                List<String> emailOpsList = new List<String>();
                for(Id ID : recordFail){
                    
                    String errorMsg = mapCampaignIdwithErrorMsg.get(ID); 
                    
                    System.debug(errorMsg);           

                    CSV_BODY = CSV_BODY + 
                        ID + ',' +
                        mapCampaignIdwithErrorMsg.get(ID) + ',' + '\n';
                }

           
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                                , batchStartTime
                                                                , batchEndTime
                                                                , recordSuccess.size()
                                                                , recordsFailed
                                                                , csvHeaderStr
                                                                , jobDailyName
                                                                , sobjectName
                                                                , emailOpsList
                                                                , CSV_BODY);
            // }
        } catch (Exception e) {
            system.debug('Cannot send email' + e.getMessage());
        }
    }
}