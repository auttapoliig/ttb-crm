public with sharing class UpdateCaseForCCEmailService implements Messaging.InboundEmailHandler {

    private String query;
    private Map<String,Map<String,String>> CASEMAP;
 
    private Integer recordsSuccessful = 0;
    private Integer recordsFailed = 0;
    private Datetime batchStartTime = datetime.now();
    private List<String> COLLST;
    private List<String> FIELDEXCLDE;
    private String SENDEREMAIL;
    private String errorMessageForEmail = '';
    private Integer BATCHSIZE = 50;
 
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){ 
         Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();  
         try {
             String SendersEmail = env.fromAddress;
             //get Attachment
             Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
                      
             if (bAttachments == null || bAttachments.size() <= 0) {
                 result.message = RTL_ReportUtility.INVALID_ATTACHMENT_NUMBERS;
                 result.success = false;
                 return result;
             }
 
             // Messaging.InboundEmail.BinaryAttachment btt = bAttachments.get(0);
             Messaging.InboundEmail.BinaryAttachment btt;
 
             Boolean isTargetFile = false;
             for(Integer i=0;i<bAttachments.size();i++)
             {
                 btt = bAttachments.get(i);                
                 if(btt.filename.endsWithIgnoreCase('.csv'))
                 {
                     isTargetFile=true;
                     break;
                 }
             }
 
             // if(!btt.filename.endsWithIgnoreCase('.csv')){ 
             //     result.message = RTL_ReportUtility.INVALID_CSV_EXTENTSION;
             //     result.success = false;
             //     return result;
             // }
             if(!isTargetFile){ 
                 result.message = RTL_ReportUtility.INVALID_CSV_EXTENTSION;
                 result.success = false;
                 return result;
             }
             

             List<String> developerNameKeys = new List<String>();
             developerNameKeys.add('BATCH_SIZE');
             List<RTL_CXM_Config__mdt> appConfigs = this.getAppConfigMeta(developerNameKeys);
             if(appConfigs != null )
             {
                for(RTL_CXM_Config__mdt appConfig : appConfigs)
                {
                    System.debug('this.BATCHSIZE=>'+ appConfig.Value__c);
                    this.BATCHSIZE = Integer.valueOf(appConfig.Value__c);
                }
             }

             Integer totalRecord = 0;
 
             List<String> sendToEmailList = new List<String>();
             sendToEmailList.add(SendersEmail);
             sendToEmailList.add('CRM Admin 2');
 
             RTL_Utility.UploadDataEmail uploadDataEmail
                     = RTL_Utility.getDataForUploadEmail('Upload_Case',btt.body.toString());
 
             if (uploadDataEmail.result) {
                 
                 Map<String,List<Map<String,String>>> valListMap = uploadDataEmail.dataMap;
                 Map<String,List<String>> fieldValidate = uploadDataEmail.fieldValidateMap;
 
                 Integer iCase = 0;
                 for (String key : valListMap.keyset() ) {
                         List<Map<String,String>> scopeLst = (List<Map<String,String>>)valListMap.get(key);
 
                         String qry = 'SELECT '+String.join(uploadDataEmail.colHeaderList,',')+ ' FROM CASE Where Id in (';
                         Map<String,Map<String,String>> caseMap = new Map<String,Map<String,String>>();
                         
                         for (Map<String,String> caseObj : scopeLst) {                            

                             for (String keyCase : caseObj.keySet()) {
                                 if (keyCase.endsWithIgnoreCase('casenumber')) {
                                     caseObj.remove(keyCase);
                                 }else if (keyCase.endsWithIgnoreCase('id')) {
                                     String caseId = caseObj.get(keyCase);
                                     caseMap.put('\''+caseId+'\'',caseObj);                                    
                                 }
                             }

                             if(iCase == this.BATCHSIZE-1 || (totalRecord == scopeLst.size()-1))
                             {
                                System.debug('iCase=>' + String.valueOf(iCase));
                                 qry += String.join(new List<String>(caseMap.keySet()),',')+')';                                

                                DailyScheduleBatch updateCaseCCBatch = new DailyScheduleBatch(qry
                                            ,DailyScheduleBatch.UPDATE_CASE_BY_CONTACT_CENTER
                                            ,'Case'
                                            ,caseMap
                                            ,uploadDataEmail.colHeaderList
                                            ,sendToEmailList
                                            ,fieldValidate
                                            );

                                updateCaseCCBatch.executeQuery();

                                if(totalRecord == scopeLst.size()-1)
                                {
                                    updateCaseCCBatch.finish(null);
                                }

                                iCase=0;
                                qry = 'SELECT '+String.join(uploadDataEmail.colHeaderList,',')+ ' FROM CASE Where Id in (';
                                                                
                            }else{
                                 iCase++;
                            } 
                             totalRecord++;
                         }
                 }
 
                 result.message = 'Upload Successfully! \n'
                                     +'Your File '
                                     +btt.filename+' has been processing with total '
                                     + totalRecord+ ' Records';
 
                 result.success = true;
             }else {
                 result.message = uploadDataEmail.description;
                 result.success = uploadDataEmail.result;
                 return result;
             }
 
         }catch (Exception e) {
             //send email to admin
             result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                 + '\n'
                                                 +e.getStackTraceString();
             result.success = false;
         }
         return result;  
    }

    private List<RTL_CXM_Config__mdt> getAppConfigMeta(List<String> developerNameKeys)
    {
        return [SELECT DeveloperName, Value__c FROM RTL_CXM_Config__mdt WHERE DeveloperName IN :developerNameKeys];        
    }


}