public with sharing class CampaignMemberCallBackCtrl {

    static String errorMsg = '';

    public class CallBackWrapper{
        @AuraEnabled
        public String result {get;set;}
        @AuraEnabled
        public String errorMsg {get;set;}
    }
    
    @AuraEnabled
    public static Boolean checkBusinessHours(Map<String, Object> values,String businessName){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name =: businessName];
        DateTime dt;
        if(values.get('datetime') != null)
        {
            dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
        }
        else 
        {
            errorMsg = Label.CallBack_BusinessHours_ErrorMsg;
            throw new AuraHandledException(Label.CallBack_BusinessHours_ErrorMsg);
        }
        
        System.debug(BusinessHours.isWithin(bh.Id, dt));
        System.debug(dt <= datetime.now());
        if(!BusinessHours.isWithin(bh.Id, dt)){
            errorMsg = Label.CallBack_BusinessHours_ErrorMsg;
            throw new AuraHandledException(Label.CallBack_BusinessHours_ErrorMsg);
        }

        return true;     
    }
    @AuraEnabled
    public static CallBackWrapper insertTask(String recordId, Map<String, Object> values,String marketingCode,String businessName){

        Boolean checkBusinessHours = checkBusinessHours(values,businessName);

        // recordId = '00v1s000000iBkqAAE';
        try 
        {          
            if(checkBusinessHours)
            {
                DateTime dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
                System.debug('marketingCode ------------------------------------> '+ marketingCode);
                System.debug('DateTime:'+dt);
                System.debug('Number:'+values.get('number'));
                System.debug('Note:'+values.get('note'));
                System.debug('Mode:'+values.get('mode'));
                Id object_id = Id.valueOf(recordId);
                String remark = '';
                if(values.get('note') != null)
                {
                    remark = String.valueOf(values.get('note')).replaceAll('\r\n|\n|\r',' ');
                }
                System.debug('remark:'+remark);

                List<User> currentUser = [SELECT Id, Employee_Id__c FROM User WHERE Id = :UserInfo.getUserId()];

                Task newTask = new Task();
                
                String sfId = String.valueOf(values.get('sfId'));
                System.debug('Related Object : ' + sfId);
                List<Task> listLogaCall = [SELECT Id,Related_Object__c FROM Task WHERE Related_Object__c =: sfId AND RecordType.Name = 'Call Log Record Type' AND RTL_Channel__c like 'Outbound%'];
                System.debug('Log A Call size : ' + listLogaCall.size());
                Map<String, Object> result_map = new Map<String,Object>();
                if(listLogaCall.size() > 0 && sfId != null){
                    result_map = scheduleCallback(values);
                }
                    CallBackWrapper callBackWrapper = new CallBackWrapper();
                    
                    System.debug('result_map:'+result_map);
                    // System.debug('errorCode:'+result_map.get('errorCode'));
                    // System.debug('errorMessage:'+result_map.get('errorMessage'));
                    // if(result_map.get('callbackID') != null)
                    // {               
                        newTask.IsReminderSet = true;
                        newTask.ReminderDateTime = dt.addMinutes(-15);
                        newTask.TaskSubtype = 'Call';
                        newTask.Type = 'Outbound';
                        newTask.Subject = 'Call Back';
                        newTask.Call_Number__c = values.get('number')+'';
                        newTask.Description = remark;
                        newTask.Call_Back_Mode__c = values.get('mode')+'';
                        newTask.Call_Start_Datetime__c = dt;
                        newTask.OwnerId = currentUser.get(0).Id;
                        newTask.Call_Agent_Id__c = currentUser.get(0).Employee_Id__c;
                        newTask.Related_Object__c = recordId;
                        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Back').getRecordTypeId();
                        //For testing while Avaya API is not working
                        //newTask.Call_Log_ID__c = '000000';
                        newTask.Call_Log_ID__c = values.get('callLogID')+'';
                        newTask.ActivityDate = dt.date();
                        newTask.Marketing_Code__c = marketingCode;
        
                        if(object_id.getSObjectType().getDescribe().getName() == 'CampaignMember'){
        
                            List<CampaignMember> member = [SELECT Id, LeadId, ContactId, Customer__r.Id FROM CampaignMember WHERE Id = :recordId LIMIT 1];
                            if(!member.isEmpty()){
        
                                //Campaign Member related to account
                                if(!String.isBlank(member.get(0).ContactId)){
                                    newTask.WhatId = member.get(0).Customer__r.Id;
                                }
                                //Campaign Member related to lead
                                else if(!String.isBlank(member.get(0).LeadId)){
                                    newTask.WhoId = member.get(0).LeadId;
                                }
                                //Somrthing else
                                // else {
        
                                // }
                            }
                        }
                        else if(object_id.getSObjectType().getDescribe().getName() == 'RTL_Referral__c'){
                            newTask.WhatId = object_id;
                        }
                        else if (object_id.getSObjectType().getDescribe().getName() == 'Lead'){
                            newTask.WhoId = object_id;
                        }
                        // if(result_map.get('callbackID') != null)
                        // {
                        try{
                            insert newTask;
                            Task_Extension__c newTaskExtension = new Task_Extension__c();
                            newTaskExtension.AVY_Agent_id__c = String.valueOf(values.get('agentId'));
                            newTaskExtension.AVY_Contact_List_Name__c = String.valueOf(values.get('contactListName'));
                            newTaskExtension.AVY_Campaign_Name__c = String.valueOf(values.get('campaignName'));
                            newTaskExtension.Task_Id__c = newTask.Id;
                            if(result_map != null && result_map.get('callbackID') != null)
                            {
                                newTaskExtension.Callback_ID__c = result_map.get('callbackID')+'';    
                            }
                            insert newTaskExtension;    
                            
                            callBackWrapper.result = newTask.Id;

                        }catch(DmlException e){
                            errorMsg = e.getMessage();
                        }
                       
                    // }
                    // else
                    // {
                        if(result_map != null && result_map.get('callbackID') == null && result_map.get('errorCode') != 200)
                        {
                            errorMsg = String.valueOf(result_map.get('errorMessage'));
                            //throw new AuraHandledException(errorMsg);
                        }
                    // }           

                    // Task_Extension__c newTaskExtension = new Task_Extension__c();
                    // newTaskExtension.Task_Id__c = newTask.Id;
                    
                    // insert newTaskExtension;
                    callBackWrapper.errorMsg = errorMsg;
                    return callBackWrapper;
                
            }
            return null;
        }   
        catch(Exception e)
        {
            System.debug('Error:'+e + ' Line:'+ e.getLineNumber());
            if(errorMsg == '')
            {
                errorMsg = e.getMessage();
            }
            throw new AuraHandledException(errorMsg);
        }

    }

    public static String transformDateTime(String unix_timestamp){

        DateTime dt = Datetime.newInstance(long.valueOf(unix_timestamp));
        String dt_str = dt.format('yyyy/MM/dd HH:mm:ss');

        return dt_str;
    }

    @AuraEnabled
    public static Map<String, Object> scheduleCallback(Map<String, Object> values){
        Map<String, Object> result_map = new Map<String, Object>();
        Integer RETRY_MAX = 3;
        Integer retryCount = 0;
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'Telephony_Avaya_Schedule_Callback' LIMIT 1];
        
        String endpoint = NameCredentialObj.Endpoint ;            
        String notes = '';
        String agentId = values.get('agentId') != null ? '"'+values.get('agentId')+'"' : '""';
        if(values.get('note') != null){
            notes = String.valueof(values.get('note')).replaceAll('\r\n|\n|\r',' ');
        }
        System.debug('notes:'+notes);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + AvayaGetToken());
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{'+
                            '"userContactID": "'+values.get('sfId')+'",'+//LeadID ,salesforce ,cam = mar
                            '"contactListName": "'+values.get('contactListName')+'",'+
                            '"campaignName": "'+values.get('campaignName')+'",'+
                            '"startTime": "'+transformDateTime(''+values.get('datetime'))+'",'+
                            '"endTime": "",'+
                            '"timeZone": "GMT+07:00",'+
                            '"address": "'+values.get('number')+'",'+
                            '"notes": "'+ notes + '",'+
                            '"callbackType": "'+String.valueOf(values.get('mode')).replace(' ','')+'",'+
                            '"agentID": '+agentId+','+
                            '"contactAttributeName": "",'+
                            //'"handlerState": "initial",'+
                            '"actionName": "Call_100"'+
                    '}');

        System.debug(request.getBody());      

        HttpResponse response = new HttpResponse();
        Boolean isSuccess = false;
        Datetime startDate = Datetime.now();
        String errMessage = '' ;
        while(retryCount < RETRY_MAX && !isSuccess ) {//issuesss
            // if(!Test.isRunningTest()){
                response = http.send(request);
            // }
            //for test get response
            // response = mockRes;

            // If the request is successful, parse the JSON response.
            System.debug(response.getBody());
            System.debug('getStatusCode:'+response.getStatusCode());
            if(response.getStatusCode() == 500)
            {
                if((Map<String, Object>)JSON.deserializeUntyped(response.getBody()) != null)
                {
                    result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    errorMsg = result_map.containsKey('failureReason') ? String.valueOf(result_map.get('failureReason')) : '';
                    if(errorMsg == '' && result_map.containsKey('errorMessage')) errorMsg = String.valueOf(result_map.get('errorMessage'));
                    errMessage = errorMsg;
                    retryCount++;
                }
                else {
                    result_map.put('errorMessage','The service is temporarily unavailable. Please try again later.');
                    result_map.put('errorCode',500);
                    errMessage = String.valueOf(result_map.get('errorMessage'));
                    retryCount++; 
                }         
            }
            else if(response.getStatusCode() == 404)
            {
                result_map.put('errorMessage','HTTP Status 404 – Not Found.');
                result_map.put('errorCode',404);
                errMessage = String.valueOf(result_map.get('errorMessage'));
                retryCount++;
                
            }
            else if(response.getStatusCode() == 400)
            {
                result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                errorMsg = result_map.containsKey('failureReason') ? String.valueOf(result_map.get('failureReason')) : '';
                if(errorMsg == '' && result_map.containsKey('errorMessage')) errorMsg = String.valueOf(result_map.get('errorMessage'));
                result_map.put('errorMessage',errorMsg);
                result_map.put('errorCode',400);
                errMessage = errorMsg;
                retryCount++;
            } 
            else if (response.getStatusCode() == 200) 
            {      
                result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());           
                // System.debug('result_map:'+result_map);
                // System.debug(result_map.get('callbackID'));
                // if(result_map.get('callbackID') != null){
                //     // List<Task> cbTask = [SELECT Id, Call_Log_ID__c 
                //     //                         FROM Task
                //     //                         WHERE Id = :values.get('task_id')+'' 
                //     //                         AND RecordType.Name = 'Call Back' 
                //     //                         LIMIT 1];
                //     // cbTask.get(0).Call_Log_ID__c = result_map.get('callbackID')+'';
        
                //     // update cbTask;
        
                //     system.debug(values.get('task_id'));
                //     List<Task_Extension__c> cbTask = [SELECT Id, Callback_ID__c ,Task_Id__c
                //                             FROM Task_Extension__c
                //                             WHERE Task_Id__c = :values.get('task_id')+'' 
                //                             LIMIT 1];
                                    
                //     system.debug(cbTask);
                //     if(cbTask.size() > 0){
                //         cbTask.get(0).Callback_ID__c = result_map.get('callbackID')+'';            
                //         update cbTask;
                //     }  
            
                // }else{
                //     errMessage = result_map.get('errorCode') + ' ' + result_map.get('errorMessage');
                // }

                errMessage = '';
                isSuccess = true;   
            }
            else
            {       
                if((Map<String, Object>)JSON.deserializeUntyped(response.getBody()) != null)     
                {     
                    result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    errorMsg = result_map.containsKey('failureReason') ? String.valueOf(result_map.get('failureReason')) : '';
                    if(errorMsg == '' && result_map.containsKey('errorMessage')) errorMsg = String.valueOf(result_map.get('errorMessage'));
                    errMessage = errorMsg;
                }
                // result_map.put('errorMessage',result_map.containsKey('errorMessage') ? String.valueOf(result_map.get('errorMessage')) : '');
                // result_map.put('errorCode',result_map.containsKey('errorCode') ? String.valueOf(result_map.get('errorCode')) : '');
                retryCount++;
                // result_map.put('error', response.getStatusCode());
                // System.debug(result_map);
                // List<Task> searchTask = [SELECT Id, Call_Log_ID__c
                //                          FROM Task
                //                         WHERE Id = :values.get('task_id')+''
                //                         AND RecordType.Name = 'Call Back'
                //                         LIMIT 1];
    
                // if(searchTask.size() > 0){
                //     searchTask.get(0).Call_Log_ID__c = '00000';
                //     update searchTask;
                // }
            }
            System.debug('retryCount:'+retryCount);
            
        }
        //save online service log
        if(isSuccess && errMessage == ''){
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
                response.getBody(), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
        }else{
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                errMessage,
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

      

        System.debug('result_map:'+ result_map);
        return result_map;

    }

    // @future(callout=true)
    // public static void cancelCallbackAsync(String calllog_id){

    //     // terminateCallback(calllog_id);
    //     // deleteCallback(calllog_id);

    // }
    // @future(callout=true)
    // public static void scheduleCallbackAsync(String jsonString){

    //     Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    //     // scheduleCallback(values);

    // }*/
    @AuraEnabled
    public static void cancelCallback(String task_id){
        try {
            List<Task> searchTask = [SELECT Id, Status, Call_Log_ID__c, Marketing_Code__c FROM Task WHERE Id = :task_id LIMIT 1];
            if(searchTask.size() > 0){
            Task updateTask = new Task(Id = searchTask.get(0).Id);
            updateTask.Status = 'Cancelled';
            update updateTask;
            }
        } 
        catch(Exception e)
        {
            System.debug('Error:'+e);
            if(errorMsg == '')
            {
                errorMsg = e.getMessage();
            }
            throw new AuraHandledException(errorMsg);
        }
    }
    @AuraEnabled
    public static CallBackWrapper rescheduleCallback(Map<String, Object> values,String businessName){

        System.debug('values ' + values);
        CallBackWrapper callBackWrapper = new CallBackWrapper();
        try{
            List<Task> searchTask = [SELECT Id, Status, Call_Log_ID__c, Marketing_Code__c FROM Task WHERE Id = :values.get('task_id')+'' LIMIT 1];
            if(searchTask.size() > 0){
    
                // String calllog_id = searchTask.get(0).Call_Log_ID__c;
                // String newTaskId = insertTask(values.get('recordId')+'', values, searchTask.get(0).Marketing_Code__c);
    
                // values.put('task_id', newTaskId);
    
                // String jsonString = JSON.serialize(values);
    
                // cancelCallbackAsync(calllog_id);
                // scheduleCallbackAsync(jsonString);
    
                // searchTask.get(0).Status = 'Cancelled';
    
                Boolean checkBusinessHours = checkBusinessHours(values,businessName);
                // recordId = '00v1s000000iBkqAAE';
                if(checkBusinessHours)
                {
                    DateTime dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
                    System.debug('DateTime:'+dt);
                    System.debug('Number:'+values.get('number'));
                    System.debug('Note:'+values.get('note'));
                    System.debug('Mode:'+values.get('mode'));
                    String remark = '';
                    if(values.get('note') != null)
                    {
                        remark = String.valueOf(values.get('note')).replaceAll('\r\n|\n|\r',' ');
                        System.debug('remark:'+remark);
                    }
    
                    List<User> currentUser = [SELECT Id, Employee_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
                    
                    String sfId = String.valueOf(values.get('sfId'));
                    System.debug('Related Object : ' + sfId);
                    List<Task> listLogaCall = [SELECT Id,Related_Object__c FROM Task WHERE Related_Object__c != null AND Related_Object__c =: sfId AND RecordType.Name = 'Call Log Record Type' AND RTL_Channel__c like 'Outbound%'];
                    System.debug('Log A Call size : ' + listLogaCall.size());



                    if(listLogaCall.size() > 0 && sfId != null){
                        try{
                            Map<String, Object> result_map = scheduleCallback(values);    
                            if(result_map.get('callbackID') != null){
                                system.debug(values.get('task_id'));
                                List<Task_Extension__c> cbTask = [SELECT Id, Callback_ID__c ,Task_Id__c
                                                        FROM Task_Extension__c
                                                        WHERE Task_Id__c = :values.get('task_id')+'' 
                                                        LIMIT 1];
                                                
                                system.debug(cbTask);
                                if(cbTask.size() > 0){
                                    cbTask.get(0).Callback_ID__c = result_map.get('callbackID')+'';            
                                    update cbTask;
                                }                      
                            }
                            else 
                            {
                                System.debug('errorCode:'+result_map.get('errorCode'));
                                System.debug('errorMessage:'+result_map.get('errorMessage'));
                                if(result_map.get('errorCode') != 200)
                                {
                                    errorMsg = String.valueOf(result_map.get('errorMessage'));
                                    //throw new AuraHandledException(errorMsg);
                                }
                                callBackWrapper.result = null;
                            }
                        }catch (Exception e){
                            errorMsg = e.getMessage();
                            // callBackWrapper.errorMsg = errorMsg;
                            // return callBackWrapper;
                        }
                    }
                    Task updateTask = new Task(Id = searchTask.get(0).Id);
                    updateTask.IsReminderSet = true;
                    updateTask.ReminderDateTime = dt.addMinutes(-15);
                    updateTask.Call_Number__c = values.get('number')+'';
                    updateTask.Description = remark;
                    updateTask.Call_Back_Mode__c = values.get('mode')+'';
                    updateTask.Call_Start_Datetime__c = dt;
                    updateTask.ActivityDate = dt.date();
    
                    update updateTask;
                    callBackWrapper.result = updateTask.Id;
                    callBackWrapper.errorMsg = errorMsg;
                    return callBackWrapper;
                    

                }
            }
            return null;
        }
        catch(Exception e)
        {
            System.debug('Error:'+e);
            System.debug('Error Line:'+e.getLineNumber());

            if(errorMsg == '')
            {
                errorMsg = e.getMessage();
                
            }
            callBackWrapper.errorMsg = errorMsg;
            return callBackWrapper;
            //throw new AuraHandledException(errorMsg);
        }
       
    }

    /*@AuraEnabled
    public static Map<String, Map<String, Object>> terminateCallback(String callback_id){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Terminate_Callback');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{"callbackIdList":[20048,20052]}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        
        System.debug(response);
        
        Map<String, Object> result_map = new Map<String, Object>();
        Map<String, Map<String, Object>> return_map = new Map<String, Map<String, Object>>();

        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(result_map);
            
            for(String key : result_map.keySet()){
                
                return_map.put(key, (Map<String, Object>)result_map.get(key));
            }
            
            System.debug(return_map);
            
        }
        else{
            return_map.put('error', new Map<String, Object>{'error_code' => response.getStatusCode()});
        }

        return return_map;

    }

    @AuraEnabled
    public static Map<String, Map<String, Object>> deleteCallback(String callback_id){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Delete_Callback');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{"callbackIdList":[20048,20052]}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        
        System.debug(response);

        Map<String, Object> result_map = new Map<String, Object>();
        Map<String, Map<String, Object>> return_map = new Map<String, Map<String, Object>>();
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(result_map);
            
            for(String key : result_map.keySet()){
                
                return_map.put(key, (Map<String, Object>)result_map.get(key));
            }
            
            System.debug(return_map);
            
        }
        else{
            return_map.put('error', new Map<String, Object>{'error_code' => response.getStatusCode()});
        }

        return return_map;

    }*/

    @AuraEnabled
    public static Task searchExistingCallback(String recordId){

        Task returnTask = new Task();
        List<Task> searchTask = [SELECT Id, Call_Start_Datetime__c, Call_Number__c, Call_Back_Mode__c, Call_Log_ID__c, Description, Call_Agent_Id__c
                                    FROM Task 
                                    WHERE Related_Object__c = :recordId
                                    AND RecordType.Name = 'Call Back'
                                    AND Status != 'Completed' AND Status != 'Cancelled'
                                    ORDER BY CreatedDate DESC];

        if(searchTask.size() > 0){
            returnTask = searchTask.get(0);
        }
        System.debug('searchTask:'+searchTask);
        return returnTask;
    }

    @AuraEnabled
    public static Boolean getAvayaIntegrationLead(Id recordId) {
        Lead lead = [SELECT Avaya_Integration_Lead__c FROM Lead WHERE Id =:recordId LIMIT 1 ];
        system.debug(recordId); 
        return lead.Avaya_Integration_Lead__c ;       
    }

    @AuraEnabled
    public static Task searchExistingLogCall(String recordId, String marketingCode){

        Task returnTask = new Task();
        List<Task> searchTask = null;
        if (String.isNotEmpty(marketingCode)) {
            searchTask = [SELECT Id,Call_Log_ID__c,Call_Start_Datetime__c,Call_End_Time__c,Related_Object__c
            FROM Task 
            WHERE (Related_Object__c = :recordId OR Related_Object__c = :marketingCode)
            AND RecordType.Name = 'Call Log Record Type'
            ORDER BY CreatedDate DESC];
        } else {
            searchTask = [SELECT Id,Call_Log_ID__c,Call_Start_Datetime__c,Call_End_Time__c,Related_Object__c,Call_Agent_Id__c
            FROM Task 
            WHERE Related_Object__c = :recordId
            AND RecordType.Name = 'Call Log Record Type'
            ORDER BY CreatedDate DESC];
        }
        

        if(searchTask.size() > 0){
            returnTask = searchTask.get(0);
        }
        
        return returnTask;
    }

    @AuraEnabled
    public static Task_Extension__c getTaskExtension(String taskId){
        System.debug(taskId);
        Task_Extension__c returnTaskExtension = new  Task_Extension__c();
        List< Task_Extension__c> searchTask = [SELECT Id,AVY_Agent_id__c,AVY_Contact_List_Name__c,AVY_Campaign_Name__c FROM  Task_Extension__c 
                                    WHERE Task_Id__c = :taskId
                                    ORDER BY CreatedDate DESC];

        if(searchTask.size() > 0){
            returnTaskExtension = searchTask.get(0);
        }
        System.debug(returnTaskExtension);
        return returnTaskExtension;
    }

    @AuraEnabled
    public static User getCurrentUser(){
        try {
            User currentUser = [SELECT Id,Profile.Name,LanguageLocaleKey,Employee_Id__c FROM User WHERE Id =:UserInfo.getUserId()];
            return currentUser;
        } catch (Exception e) {
            System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            return null;
        }
        
    }

    @AuraEnabled
    public static String getSalesforceId(String recordId){
        Id object_id = Id.valueOf(recordId);
        if(object_id.getSObjectType().getDescribe().getName() == 'CampaignMember'){

            List<CampaignMember> member = [SELECT Id,LeadId, ContactId, Customer__r.Id,RTL_Marketing_code__c FROM CampaignMember WHERE Id = :recordId LIMIT 1];
            if(!member.isEmpty()){
                return member.get(0).RTL_Marketing_code__c ;
            }
        }
        else { 
            return recordId ;
        }
        return null;
    }

    @AuraEnabled
    public static Boolean isCampaignMember(String recordId){
        Id object_id = Id.valueOf(recordId);
        if(object_id.getSObjectType().getDescribe().getName() == 'CampaignMember'){
            return true ;
        }
        else { 
            return false ;
        }
    }

    public static String AvayaGetToken()
    {
        String token;
        String jsonBody =  '{"username": "{!$Credential.Username}",'+
                            '"rememberMe": true,'+
                            '"password": "{!$Credential.Password}"}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Centralize_Token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        System.debug('Get Token status code --->' + response.getStatusCode());

        if (response.getStatusCode() == 200) 
        {
            Map<String, Object> getTokenMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            //token = JSON.serialize(getTokenMap.get('api_token'));
            System.debug('token:'+getTokenMap);
            token = getTokenMap.containsKey('id_token') ? getTokenMap.get('id_token').ToString() : token;
        } else {
            System.debug('Get Token status body --->' + response.getBody());
        }
       
        return token;
    }

    @AuraEnabled
    public static Boolean CheckCallBackPermission(String recordId){
        try {
            Boolean callback_permission = false;
            User currentUser = getCurrentUser();
            Task task = searchExistingLogCall(recordId,null);
            List<RTL_Referral__c> refList = [SELECT Id,Avaya_Integration_Lead__c FROM RTL_Referral__c WHERE Id =: recordId LIMIT 1];
            System.debug('Call_Agent_Id__c:'+task.Call_Agent_Id__c);
            System.debug('Employee_Id__c:'+currentUser.Employee_Id__c);
            if(currentUser.Employee_Id__c != null && task.Call_Agent_Id__c != null && refList.size() > 0)
            {
                if(currentUser.Employee_Id__c == task.Call_Agent_Id__c && refList[0].Avaya_Integration_Lead__c == true)
                {
                    callback_permission = true;
                }
            }
            return callback_permission;
        } catch (Exception e) {
            System.debug('Error:'+e);
            return false;
        }

    }


}