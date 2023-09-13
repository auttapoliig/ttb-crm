@RestResource(urlMapping='/outbound/popup/*')
global with sharing class OutboundPopup {

    global class task_wrapper{
        global String task_id {get;set;}
        global String call_id {get;set;}
        global String employee_id {get;set;}
        global String agent_id {get;set;}
        global String call_number {get;set;}
        global String unique_key {get;set;}
        global String agent_extension_number {get;set;}
        global DateTime call_start_datetime {get;set;}
        global String channel {get;set;}
        global String mode {get;set;} //Predictive, Preview
        global String callback_id {get;set;}
        global String contactlist_name {get;set;}
        global String campaign_name {get;set;}
        global String pim_Sessionid {get;set;}
        global String contactlist_id{get;set;}

        public Boolean isPreviewWithCallId(){
            return this.mode == 'preview' && String.isNotEmpty(this.call_id);
        }

        public Boolean isPreview(){
            return this.mode == 'preview';
        }

        public Boolean isPredictive(){
            return this.mode == 'predictive';
        }

        public Boolean isFromCallback(){
            return String.isNotBlank(this.callback_id);
        }
    }

    public static string insertTask(task_wrapper task){

        List<User> agent = [SELECT Id FROM User WHERE Employee_ID__c = :task.employee_id LIMIT 1];
        String ownerId = agent[0].Id;

        Task newTask = new Task();

        newTask.Call_Log_ID__c = task.call_id;
        newTask.Call_Agent_Id__c = task.employee_id;
        newTask.Call_Number__c = task.call_number;
        newTask.Call_Start_Datetime__c = task.call_start_datetime;
        newTask.RTL_Channel__c = task.channel;
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Call';
        newTask.Subject = 'Call';
        newTask.OwnerId = ownerId;
        newTask.Agent_Extension_Number__c = task.agent_extension_number;
        newTask.Status = 'In Progress';
        if(String.isNotEmpty(task.unique_key))
        {      
            if(task.unique_key.startsWith('00Q'))
            {
                newTask.Related_Object__c = task.unique_key;
                newTask.WhoId = task.unique_key;
                List<Lead> leadList = [SELECT Id,Avaya_Integration_Lead__c,Contacted_Flag__c,Status FROM Lead WHERE Id =: task.unique_key];
                List<Lead> updateLeadList = new  List<Lead>();
                if(leadList.size() > 0)
                {
                    for(Lead lead : leadList)
                    {
                        lead.Avaya_Integration_Lead__c = true;
                        lead.Contacted_Flag__c = true;
                        lead.Status = 'Contacted';
                        updateLeadList.add(lead);
                    }
                    System.debug('updateLeadList:'+updateLeadList);
                    if(updateLeadList.size() > 0)
                    {
                        update updateLeadList;
                    }
                }
            }
            else if(task.unique_key.startsWith('a2S'))
            {
                updateReferralOwner(task);
                newTask.Related_Object__c = task.unique_key;
            }
            else 
            {  
                List<CampaignMember> cmList = [SELECT Id,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c,Customer__c FROM CampaignMember WHERE RTL_Marketing_Code__c =: task.unique_key OR RTL_Web_Unique_ID__c =: task.unique_key ];  
                if(cmList.size() > 0)
                {
                    //newTask.Related_Object__c = cmList[0].Id; // <-- Change to marketing code
                    
                    if (String.isNotEmpty(cmList[0].RTL_Marketing_Code__c)) {
                        System.debug('Marketing Code -->' + cmList[0].RTL_Marketing_Code__c);
                        newTask.Related_Object__c = cmList[0].RTL_Marketing_Code__c;
                    } else {
                        System.debug('Web Unique ID -->' + cmList[0].RTL_Web_Unique_ID__c);
                        newTask.Related_Object__c = cmList[0].RTL_Web_Unique_ID__c;
                    }
                    
                    newTask.WhatId = cmList[0].Customer__c != null ? cmList[0].Customer__c : '';
                }            
                else {
                    newTask.Related_Object__c = task.unique_key; 
                }
                   
            }
        }
        // newTask.Related_Object__c = task.unique_key;
        // newTask.Status = 'Completed';

        insert newTask;

        Task_Extension__c newTaskExtension = new Task_Extension__c();
        newTaskExtension.Task_Id__c = newTask.Id;
        newTaskExtension.AVY_Agent_id__c = task.agent_id;
        newTaskExtension.AVY_Contact_List_Name__c = task.contactlist_name;
        newTaskExtension.AVY_Campaign_Name__c = task.campaign_name;
        newTaskExtension.AVY_pim_sessionid__c = task.pim_Sessionid;
        newTaskExtension.AVY_Contact_List_ID__c = task.contactlist_id;

        insert newTaskExtension;

        return newTask.Id;
    }

    public static String publishCustomerOutbound(task_wrapper task, String popupMode){
        System.debug('taskdebug: ' + task);

        //Start Trigger Platform Events
        /* c = new Customer_Outbound__e(
            Task_ID__c = task.task_id,
            Call_ID__c = task.call_id,
            Employee_ID__c = task.employee_id,
            Agent_ID__c = task.agent_id,
            Call_Number__c = task.call_number,
            Unique_Key__c = task.unique_key,
            Agent_Extension_Number__c = task.agent_extension_number,
            Call_Start__c = task.call_start_datetime,
            Type__c = task.channel,
            Mode__c = task.mode,
            Callback_ID__c = task.callback_id,
            Contact_List_Name__c = task.contactlist_name,
            Campaign_Name__c = task.campaign_name,
            Popup_Mode__c = popupMode
        );

        Database.SaveResult results = EventBus.publish(c);
        
        if(results.isSuccess()){
            System.debug('Successfully published event.');
            // if(Test.isRunningTest()){
            //     ci_list.add(c);
            // }
            //Stop Trigger Platform Events : Success
            return EventBus.getOperationId(results);
        }
        else{
            System.debug('Error returned: ' +
                        results.getErrors()[0].getStatusCode() +
                        ' - ' +
                        results.getErrors()[0].getMessage());

            //Stop Trigger Platform Events : Error
            return 'Error '+results.getErrors()[0].getStatusCode() +
            ' - ' +
            results.getErrors()[0].getMessage();
        }
        */

        // System.debug(task.task_id);
        Popup_Information__c popupInfo = new Popup_Information__c(
            Task_ID__c = task.task_id,
            Call_ID__c = task.call_id,
            Employee_ID__c = task.employee_id,
            Agent_ID__c = task.agent_id,
            Call_Number__c = task.call_number,
            Unique_Key__c = task.unique_key,
            Agent_Extension_Number__c = task.agent_extension_number,
            Call_Start__c = task.call_start_datetime,
            Type__c = task.channel,
            Mode__c = task.mode,
            Callback_ID__c = task.callback_id,
            Contact_List_Name__c = task.contactlist_name,
            Campaign_Name__c = task.campaign_name,
            Popup_Mode__c = popupMode,
            Channel__c = 'Outbound'
      
        );

        Database.SaveResult results = database.insert(popupInfo);
        
        if(results.isSuccess()){
            System.debug('Successfully published event.');
            if(Test.isRunningTest()){
               // ci_list.add(popupInfo);
            }
            //Stop Trigger Platform Events : Success
            return results.id;
        }
        else{
            System.debug('Error returned: ' +
                        results.getErrors()[0].getStatusCode() +
                        ' - ' +
                        results.getErrors()[0].getMessage());

            //Stop Trigger Platform Events : Error
            return 'Error '+results.getErrors()[0].getStatusCode() +
            ' - ' +
            results.getErrors()[0].getMessage();
        }

    }

    @HttpPost
    global static void handleOutbound(task_wrapper task){
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        String errorMessage = '';
        String customerName = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = '/outbound/popup';
        String requestBody = '';
        String responseBody = '';
        String requestBodyDecrypt = '';
        String reqId = '';
        String accForLog = '';
        String popupMode = 'popup';
        String msLogId = '';
        if (String.isNotEmpty(task.call_id)) {
            msLogId = task.call_id + task.call_start_datetime;
        } else {
            msLogId = task.unique_key;
        }

        System.debug(JSON.serializePretty(task));
        System.debug(task.isPredictive());
        requestBody = JSON.serialize(task);

        String requestBodyForLog = '';
        if (String.isNotEmpty(requestBody)) {
            requestBodyForLog = '{"task":' + JSON.serializePretty(task, true) + '}';
        }

        if(String.isEmpty(task.call_number)){
            responseBody = InboundUtility.restRespond(
                InboundUtility.HTTP_BAD_REQUEST,
                'Phone is required.',
                ''
            );
        }

        else if(String.isEmpty(task.employee_id)){
            responseBody = InboundUtility.restRespond(
                InboundUtility.HTTP_BAD_REQUEST,
                'Employee ID is required.',
                ''
            );
        }
        else{
 			System.debug('isPredictive:'+task.isPredictive());
            System.debug('isPreviewWithCallId:'+task.isPreviewWithCallId());
            System.debug('isPreview:'+task.isPreview());
            System.debug('isFromCallback:'+task.isFromCallback());
            try {
                if(task.isPredictive() || task.isPreviewWithCallId()){                    
                    List<Task> searchTask = [SELECT Id FROM Task WHERE Call_Log_ID__c = :task.call_id AND Call_Agent_Id__c = :task.employee_id AND Call_Start_Datetime__c =: task.call_start_datetime];
    
                    System.debug('searchTask:'+searchTask);
    
                    if(searchTask.isEmpty()){     
                        if(String.isEmpty(task.call_id))
                        {
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Call Log ID is required.',
                                ''
                            );
                            return ;
                        }
                        else if(String.isEmpty(task.agent_id))
                        {
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Call Agent Id is required.',
                                ''
                            );
                            return ;
                        }
                        else if(String.isEmpty(String.valueOf(task.call_start_datetime)))
                        {
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Call Start Datetime is required.',
                                ''
                            );
                            return ;
                        }
                        else if(String.isEmpty(task.channel))
                        {
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Call Type is required.',
                                ''
                            );
                            return ;
                        }
                        else if(String.isEmpty(task.agent_extension_number))
                        {
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Agent Extension Number is required.',
                                ''
                            );
                            return ;
                        }
                        else
                        {
                            task.task_id = insertTask(task);
                        }
                    }
                    else{
                        task.task_id = searchTask.get(0).Id;
                    }
                }
                else if(task.isPreview()){
                    task.task_id = '';
                    updateReferralOwner(task);
                }
    
                if(task.isFromCallback()){
                    /*List<Task> callbackTask = [SELECT Id, Call_Log_ID__c, Status
                                                FROM Task
                                                WHERE RecordType.Name = 'Call Back'
                                                AND Call_Log_ID__c = :task.callback_id
                                                AND Status != 'Completed'
                                                AND Status != 'Cancelled'
                                                LIMIT 1];
    
                    if(callbackTask.size() > 0){
                            
                        callbackTask.get(0).Status = 'Completed';
                        update callbackTask;
                    }*/
    
                    List<Task_Extension__c> callbackTaskEx = [SELECT Id, Callback_ID__c, Task_Id__c
                                                                 FROM Task_Extension__c
                                                                 WHERE Callback_ID__c =: task.callback_id
                                                                 LIMIT 1];
    
                    if(callbackTaskEx.size() > 0){
                        String taskId = callbackTaskEx[0].Task_Id__c;

                        List<Task> callbackTask = [SELECT Id, Call_Log_ID__c, Status
                                                    FROM Task
                                                    WHERE RecordType.Name = 'Call Back'
                                                    AND Id = :taskId
                                                    LIMIT 1];

                        callbackTask.get(0).Status = 'Completed';
                        update callbackTask;
                    }
                }
                System.debug('task:'+task);
                /* If preview mode create log a call no need to popup again */
                // if(!task.isPreviewWithCallId()){  
                    publishCustomerOutbound(task, popupMode);
                // }
    
                responseBody = InboundUtility.restRespond(
                                        InboundUtility.HTTP_CREATED,
                                        '',
                                        task.task_id
                                    );

                endTime = DateTime.now();
                // OnlineServiceLogUtils.saveToOnlineLog( true , customerName,  errorMessage,  msLogId ,  userName, 
                //                     rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                //                     startTime ,  endTime,  null );
                Boolean isSuccess = true;
                //OnlineServiceLogUtils.saveToOnlineLog(isSuccess, customerName, errorMessage, msLogId, userName, rmId,
                //                     serviceName, requestBodyForLog, responseBody, null, startTime, endTime, null);

                RTL_CampaignUtil.saveToOnlineLog(isSuccess, customerName, errorMessage, msLogId, userName, rmId,
                                     serviceName, requestBodyForLog, responseBody, null, startTime, endTime);
            } catch (Exception e) {
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Uncaught Exception',
                    e.getMessage() + ' : ' + e.getStackTraceString()
                );
                
                endTime = DateTime.now();
                errorMessage = e.getMessage();
                System.debug('Exception-->' + msLogId);
                System.debug('Exception-->' + serviceName);
                System.debug('Exception-->' + requestBodyForLog);
                System.debug('Exception-->' + responseBody);

                //OnlineServiceLogUtils.saveToOnlineLog(false , customerName,  errorMessage,  msLogId ,  userName, 
                //                                     rmId ,  serviceName , requestBodyForLog , responseBody ,  null , 
                //                                     startTime ,  endTime,  null);
                RTL_CampaignUtil.saveToOnlineLog(false , customerName,  errorMessage,  msLogId ,  userName, 
                                                     rmId ,  serviceName , requestBodyForLog , responseBody ,  null , 
                                                     startTime ,  endTime);
            }
            
        }
    }

    public static void updateReferralOwner(task_wrapper task)
    {
        List<RTL_Referral__c> refList = [SELECT Id,Avaya_Integration_Lead__c,OwnerId FROM RTL_Referral__c WHERE Id =: task.unique_key];
        List<User> userObj = [SELECT Id,Employee_ID__c FROM User WHERE Employee_ID__c =: task.employee_id LIMIT 1];
        List<RTL_Referral__c> updateRefList = new List<RTL_Referral__c>();
        if(refList.size() > 0)
        {
            for(RTL_Referral__c ref : refList)
            {
                ref.Avaya_Integration_Lead__c = true;
                if(userObj.size() > 0)
                {
                    if(userObj[0].Id != ref.OwnerId)
                    {
                        ref.OwnerId = userObj[0].Id;
                        updateRefList.add(ref);
                    }
                }
            }
            System.debug('updateRefList:'+updateRefList);
            if(updateRefList.size() > 0)
            {
                update updateRefList;
            }
        }
    }
}