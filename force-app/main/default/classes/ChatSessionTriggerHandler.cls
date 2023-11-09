public without sharing class ChatSessionTriggerHandler {

    @future(callout=true)
    public static void sendNoti(List<Id> chatSessionId) {
        System.debug('---chatSessionTrigger---3');

        List<RTL_Online_Service_Log__c> osLogList = new List<RTL_Online_Service_Log__c>();
        List<Attachment> importattachmentfileList = new List<Attachment>();
        Map<RTL_Online_Service_Log__c, Map<String, String>> osLogMap = new Map<RTL_Online_Service_Log__c, Map<String, String>>();

        Map<Id, iigproduct_2__ChatSession__c> chatSessionMap = new Map<Id, iigproduct_2__ChatSession__c>([SELECT Id, iigproduct_2__RMID__c, iigproduct_2__Social_ID__r.iigproduct_2__Account__c, iigproduct_2__Social_ID__r.iigproduct_2__Account__r.Core_Banking_Suggested_Segment__c FROM iigproduct_2__ChatSession__c WHERE Id IN :chatSessionId]);
        Map<String, String> body = new Map<String, String>();
        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        // List<iigproduct_2__ChatSession__c> chatSessionListEnoti = chatSessionMap.values();
        // List<iigproduct_2__ChatSession__c> chatSessionListEnoti = new List<iigproduct_2__ChatSession__c>();
        Map<Id, iigproduct_2__ChatSession__c> chatSessionListEnoti = new Map<Id, iigproduct_2__ChatSession__c>();

        List<iigproduct_2__ChatMessage__c> chatMsg = [SELECT Id, iigproduct_2__ChatSession__c, iigproduct_2__Status__c FROM iigproduct_2__ChatMessage__c WHERE iigproduct_2__ChatSession__c IN :chatSessionId AND iigproduct_2__Status__c = false];
        Map<String, String> mapChatNoti = new Map<String, String>();
        for (iigproduct_2__ChatMessage__c msg : chatMsg) {
            if (!mapChatNoti.containsKey(msg.iigproduct_2__ChatSession__c)) {
                chatSessionListEnoti.put(msg.iigproduct_2__ChatSession__c, chatSessionMap.get(msg.iigproduct_2__ChatSession__c));
            }
        }

        System.debug('chatSessionListEnoti: ' + chatSessionListEnoti.values());

        for (iigproduct_2__ChatSession__c chatSession : chatSessionListEnoti.values()) {
            Boolean isSuccess = false;
            String errorMsg = '';
            Datetime startTime = Datetime.now();
            String requestBody;
            String responseBody;
            
            Map<String, Object> reqBody = new Map<String, Object>();
            reqBody.put('office_code', '5160-Digital');
            reqBody.put('service_code', '');
            List<Object> record = new List<Object>();
            Map<String, Object> detail = new Map<String, Object>();
            detail.put('rm_id', chatSession.iigproduct_2__RMID__c);
            Map<String, Object> params = new Map<String, Object>();
            params.put('TEMPLATE_NAME', 'IN_APP_CHAT_001');
            params.put('deep_link', 'app_schema://linkaccess/chat?call_from=PushNotification');
            detail.put('params', params);
            Map<String, Object> noti = new Map<String, Object>();
            noti.put('endpoint', chatSession.iigproduct_2__RMID__c);
            noti.put('search', true);
            noti.put('force', false);
            detail.put('notification', noti);
            record.add(detail);
            reqBody.put('record', record);
            reqBody.put('deep_link', '${app-schema}://linkaccess/chat?call_from=PushNotification');

            try {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                Uuid uuidGenerateor = new Uuid();
        
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json; charset=utf-8');
        
                req.setHeader('Request-UID', uuidGenerateor.getValue());
                req.setHeader('Request-App-ID', 'A0291');
                req.setHeader('Request-Datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));

                System.debug('SmartBDM_Utility.tokenKeyEnliteGateWay: ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
                req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
                req.setEndpoint('callout:SMS_CASE_Notification');
                req.setBody(JSON.serializePretty(reqBody));
                req.setTimeout(10000);
                HttpResponse res = http.send(req);
                requestBody = req.getBody();
                responseBody = res.getBody();
                isSuccess = true;
            } catch (Exception e) {
                errorMsg = e.getMessage();
            }

            System.debug('Sent Noti: ' + chatSession.iigproduct_2__RMID__c);
            System.debug('requestBody: ' + requestBody);
            System.debug('responseBody: ' + responseBody);
            System.debug('Saving Log...');
            //RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
            
            osLog.RTL_Is_Success__c = isSuccess;  
            osLog.RTL_Customer_Name__c = '';
            osLog.RTL_Error_Message__c = errorMsg;
            osLog.RTL_Name_of_User__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            osLog.RTL_RM_ID__c = chatSession.iigproduct_2__RMID__c;
            osLog.RTL_Service_Name__c = 'SMS_CASE_Notification';
            
            Id accId = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Account__c;
            
            if (accId != null) {
                osLog.RTL_Account__c = accId;
                String customerSegment = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Account__r.Core_Banking_Suggested_Segment__c;
                osLog.RTL_Customer_Segment__c = customerSegment;
            }
            
            osLog.RTL_Start_DateTime__c = startTime;
            osLog.RTL_End_DateTime__c  = System.now();
            

            //Map<String, String> body = new Map<String, String>();
            body.put('requestBody', requestBody);
            body.put('responseBody', responseBody);
            osLogList.add(osLog);

        }

        insert osLogList;
        osLogMap.put(osLog, body);
        
        for (RTL_Online_Service_Log__c osLog2 : osLogMap.keySet()) {

            String requestBody = osLogMap.get(osLog2).get('requestBody');
            String responseBody = osLogMap.get(osLog2).get('responseBody');
            
            if (requestBody != '' && requestBody != null) { 
                Attachment requestAttachment = new Attachment();
                requestAttachment.parentId = osLog2.Id;
                requestAttachment.name = 'requestBody.txt';
                requestAttachment.IsPrivate = false;
                requestAttachment.body = Blob.valueOf(requestBody);
                importattachmentfileList.add(requestAttachment);
            }
            
            if (responseBody != '' && responseBody != null) { 
                Attachment responseAttachment = new Attachment();
                responseAttachment.parentId = osLog2.Id;
                responseAttachment.name = 'responseBody.txt';
                responseAttachment.IsPrivate = false;
                responseAttachment.body = Blob.valueOf(responseBody);
                importattachmentfileList.add(responseAttachment);
            }
        }      
        
        if(importattachmentfileList.size() > 0) {
            insert importattachmentfileList;
            System.debug('...Done');
        }
        System.debug('---chatSessionTrigger---3.1');

    }

    public static void setFirstCustomerMessage(List<Id> sessionIdList, Map<Id, iigproduct_2__ChatSession__c> chatSessionMap) {
        System.debug('starting setFirstCustomerMessage...');
        for (aggregateResult chatMsg : [SELECT iigproduct_2__ChatSession__r.Id id, MIN(CreatedDate) firstdate FROM iigproduct_2__ChatMessage__c WHERE iigproduct_2__ChatSession__r.Id IN :sessionIdList AND iigproduct_2__IsOutbound__c = false AND iigproduct_2__Is_System_Message__c = false
        GROUP BY iigproduct_2__ChatSession__r.Id
        ]) {
            Id ssid = (Id) chatMsg.get('id');
            ((iigproduct_2__ChatSession__c) Trigger.newMap.get(ssid)).First_Message_Datetime__c = Datetime.valueOf(chatMsg.get('firstdate'));
            System.debug('setFirstCustomerMessage successfully!');
        }
    }

    public static void AutoClosecase(List<Id> sessionIdList){
        if(!sessionIdList.isEmpty()){
            System.debug('[ChatSessionTriggerHandler.AutoClosecase]sessionIdList :' + sessionIdList);
            List<Case> CaseList = new List<Case>();
            List<iigproduct_2__ChatSession__c> caseSessionList = [
                SELECT Id , iigproduct_2__Case__c, iigproduct_2__Case__r.OwnerId , iigproduct_2__EndedBy__c
                FROM iigproduct_2__ChatSession__c
                WHERE Id IN :sessionIdList AND iigproduct_2__Case__c != NULL AND iigproduct_2__EndedBy__c != NULL AND iigproduct_2__Status__c != NULL
            ];
            for(iigproduct_2__ChatSession__c data : caseSessionList){
                Case assign_case = new Case(Id = data.iigproduct_2__Case__c);
                if(assign_case.Status != 'Resolved'){
                    assign_case.PTA_Segment__c = 'RBG';
                    assign_case.Category__c = 'Inquiry';
                    assign_case.Sub_Category__c = 'Contact Center';
                    assign_case.Product_Category__c = 'Others';
                    assign_case.Issue__c = 'Customer has left the chat';
                    assign_case.FCR__c = true;
                    assign_case.Status = 'Completed';
                    CaseList.add(assign_case);
                }
                update CaseList;
            }
            System.debug('[ChatSessionTriggerHandler.AutoClosecase]caseSessionList :' + caseSessionList.size());
        }
    }

}