public with sharing class AvayaCompletionCodeUtility {
    public AvayaCompletionCodeUtility() {

    }

    @future(callout = true)
    public static void sendCompletionCodeToAvaya(String completionCode, List<String> userContactIDList ){

        Map<String, Object> result_map = new Map<String, Object>();
        Integer RETRY_MAX = 3;
        Integer retryCount = 0;    
        String errorMsg = '';
        
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'Telephony_Avaya_Completion_Code' LIMIT 1];
        
        String endpoint = NameCredentialObj.Endpoint ;    
        String agentId = '';        
        String pimSessionID = '';
        String userContactID = '';
        String contactListID = '';
        String ucid = '';

        
        List<Task> taskObj = [SELECT Id,Call_Log_ID__c,Call_Agent_Id__c,Call_Number__c,Call_Start_Datetime__c,RTL_Channel__c,Related_Object__c,RecordType.Name FROM Task WHERE Related_Object__c IN: userContactIDList AND RecordType.Name = 'Call Log Record Type' AND RTL_Channel__c like 'Outbound%' ORDER BY LastModifiedDate DESC LIMIT 1];
        System.debug('CampaignMember || sendCompletionCodeToAvaya || ' + taskObj.size());
        List<Task_Extension__c> taskExt = new List<Task_Extension__c>();
        if(taskObj.size() > 0)
        { 
            System.debug('taskObj:'+taskObj);
            if(taskObj[0].Related_Object__c != null)
            {
                userContactID = taskObj[0].Related_Object__c;
            }
            taskExt = [SELECT Id, Name, AVY_Agent_id__c, AVY_Campaign_Name__c, AVY_Contact_List_ID__c, AVY_Contact_List_Name__c, AVY_pim_sessionid__c, Callback_Date__c, Callback_ID__c, Callback_Mode__c, Callback_Notes__c, Callback_Phone_Number__c, Callback_Time__c, Task_Id__c 
                                                FROM Task_Extension__c WHERE Task_Id__c =: taskObj[0].Id ORDER BY LastModifiedDate DESC LIMIT 1];
        

            agentId = taskExt.size() > 0 ? ((taskExt[0].AVY_Agent_id__c == null) ? '' : taskExt[0].AVY_Agent_id__c) : '';
            pimSessionID = taskExt.size() > 0 ? ((taskExt[0].AVY_pim_sessionid__c == null) ? '' : taskExt[0].AVY_pim_sessionid__c) : '';
            contactListID = taskExt.size() > 0 ? ((taskExt[0].AVY_Contact_List_ID__c == null) ? '' : taskExt[0].AVY_Contact_List_ID__c) : '';
            ucid = taskObj.size() > 0 ? ((taskObj[0].Call_Log_ID__c == null) ? '' : taskObj[0].Call_Log_ID__c) : '';

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Telephony_Avaya_Completion_Code');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + CampaignMemberCallBackCtrl.AvayaGetToken());
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Requested-With', 'rest');
            request.setBody('{'+
                                '"Agent ID": "'+agentId+'",'+
                                '"PimSessionID": "'+pimSessionID+'",'+
                                '"CompletionCode": "'+completionCode+'",'+
                                '"UserContactID": "'+userContactID+'",'+ //LeadID ,salesforce ,cam = mar
                                '"ContactListID": "'+contactListID+'",'+
                                '"UCID": "'+ucid+'"'+
                        '}');

            System.debug(request.getBody());      

            HttpResponse response = new HttpResponse();
            Boolean isSuccess = false;
            Datetime startDate = Datetime.now();

            while(retryCount < RETRY_MAX && !isSuccess ) {//issuesss
                // if(!Test.isRunningTest()){
                    response = http.send(request);
                // }
                //for test get response
                // response = mockRes;

                // If the request is successful, parse the JSON response.
                System.debug(response.getBody());
                System.debug('getStatusCode:'+response.getStatusCode());
                // Deserialize the JSON string into collections of primitive data types.
                result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

                if (response.getStatusCode() == 200) {      
                    isSuccess = true;            
                
                }
                else {
                    errorMsg = String.valueOf(result_map.get('errMessage'));
                    isSuccess = false;   
                    retryCount++;

                }
            }
            System.debug('errorMsg:'+errorMsg);
            //save online service log
            if(isSuccess && errorMsg == ''){
                RTL_CampaignUtil.saveToOnlineLog(
                    true,
                    '', // customerName
                    '' ,//error message
                    '',// msLogId
                    // requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '',
                    //requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', 
                    UserInfo.getName(),
                    '',
                    endpoint,//name 
                    request.getBody(), // Request Body
                    JSON.serializePretty(response.getBody()), // Response Body
                    null,
                    startDate,
                    Datetime.now() // End datetime
                );
            }else{
                RTL_CampaignUtil.saveToOnlineLog(
                    false,
                    '', // customerName
                    errorMsg,
                    '',// msLogId
                    // requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '',
                    //requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', // msLogId
                    UserInfo.getName(),
                    '',
                    endpoint,//name 
                    request.getBody(), // Request Body
                    response.getBody(), // Response Body
                    null,
                    startDate,
                    Datetime.now() // End datetime
                );
            }
        }
    }
}