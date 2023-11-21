public without sharing class SocialPostMainComponentController {
    
    @AuraEnabled
    public static List<Object> getAccountList(String recordId) {
        List<Object> rtnValue = new List<Object>();

        List<Social_Post__c> thisPost = [
            SELECT Id, Thread_Type__c
            FROM Social_Post__c
            WHERE Id = :recordId
        ];

        Datetime startTime = System.now();
        String requestBody;
        String responseBody;
        Boolean isSuccess = false;
        String userName = UserInfo.getName();
        try {
            String token = SocialPostMainComponentController.getToken();
            String threadType = thisPost.get(0).Thread_Type__c;
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Get_Social_Account_List/' + threadType);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            Http http = new Http();
            requestBody = req.getBody();
            HTTPResponse res = http.send(req);
            // System.debug('token: ' + token);
            // System.debug('threadType: ' + threadType);
            // System.debug('resBody: ' + res.getBody());
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> accounts = (List<Object>) jsonMap.get('accounts');
            responseBody = res.getBody();
            System.debug('responseBody: ' + responseBody);
            for (Object acc : accounts) {
                Map<String, Object> accountDetails = (Map<String, Object>) acc;
                // System.debug('accountDetails: ' + accountDetails);
                Map<String, Object> account = new Map<String, Object>();
                account.put('id', String.valueOf(accountDetails.get('social_id')));
                // account.put('id', String.valueOf(accountDetails.get('id')));
                account.put('name', String.valueOf(accountDetails.get('name')));
                rtnValue.add(account);
            }
            isSuccess = true;
            OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  '',  '' ,  userName, '' ,  'Get_Social_Account_List' , requestBody , responseBody, null, startTime,  System.now(),  '');
        } catch (Exception e) {
            isSuccess = false;
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  e.getMessage(),  '' ,  userName, '' ,  'Get_Social_Account_List' , requestBody , responseBody, null, startTime,  System.now(),  '');
        }
        if (!isSuccess) {
            throw new AuraHandledException('');
        }
        return rtnValue;
    }

    @AuraEnabled
    public static Map<String, Object> getPostInfo(String recordId) {
        Social_Post__c thisPost = [
            SELECT Id, Post_Body__c, Status__c, OwnerId, Message_Type__c, Reply_to_Social_Post__r.Post_Body__c, Reply_to_Social_Post__c, Reply_to_Social_Post__r.Reply_Social_ID__c, Default_Social_Account__c
            FROM Social_Post__c
            WHERE Id = :recordId
        ];
        Map<String, Object> rtnValue = new Map<String, Object>();
        rtnValue.put('message', thisPost.Post_Body__c);
        Boolean isDisableInput = thisPost.Message_Type__c != 'Inbound' ? true : false;
        if (thisPost.Status__c == 'Close' || thisPost.Status__c == 'Reject') {
            isDisableInput = true;
        } else if (thisPost.OwnerId != UserInfo.getUserId()) {
            isDisableInput = true;
        }

        rtnValue.put('messageType', isDisableInput);
        String replyMsg;
        String replyId;
        if (thisPost.Reply_to_Social_Post__c != null) {
            replyMsg = thisPost.Reply_to_Social_Post__r.Post_Body__c;
            replyId = thisPost.Reply_to_Social_Post__r.Reply_Social_ID__c;
        }
        rtnValue.put('replyMessage', replyMsg);
        rtnValue.put('replyId', replyId);
        rtnValue.put('rejectList', getPicklistValues());
        rtnValue.put('default_acc', thisPost.Default_Social_Account__c);
        return rtnValue;
    }

    @AuraEnabled
    public static Map<String, Object> getThreadIdentity(String recordId) {
        Map<String, Object> rtnValue = new Map<String, Object>();
        // String rtnValue;

        List<Social_Post__c> thisPost = [
            SELECT Id, Thread_ID__c, Thread_Identity_ID__c
            FROM Social_Post__c
            WHERE Id = :recordId
        ];
        System.debug('recordId: ' + recordId);

        Datetime startTime = System.now();
        String requestBody;
        String responseBody;
        Boolean isSuccess = false;
        String userName = UserInfo.getName();
        try {
            String token = WarroomPageController.getWarroomToken();
            System.debug('token: ' + token);
            String threadId = thisPost.get(0).Thread_ID__c;
            System.debug('threadId: ' + threadId);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Get_Thread_Identity/' + threadId);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            Http http = new Http();
            requestBody = req.getBody();
            HTTPResponse res = http.send(req);
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('resBody: ' + res.getBody());
            responseBody = res.getBody();
            rtnValue = jsonMap;
            isSuccess = true;
            OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  '',  '' ,  userName, '' ,  'Get_Thread_Identity' , requestBody , responseBody, null, startTime,  System.now(),  '');
        } catch (Exception e) {
            isSuccess = false;
            System.debug('err: ' + e.getMessage());
            OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  e.getMessage(),  '' ,  userName, '' ,  'Get_Thread_Identity' , requestBody , responseBody, null, startTime,  System.now(),  '');
        }
        if (!isSuccess) {
            throw new AuraHandledException('');
        }
        return rtnValue;
    }

    @AuraEnabled
    public static String replyMessage(String recordId, String threadIdentityId, String socialId, String messageBody) {
        String rtnValue;

        List<Social_Post__c> thisPost = [
            SELECT
                Id,
                Post_ID__c,
                Thread_ID__c,
                Thread_Identity_ID__c,
                Post_Identity_ID__c,
                Source_Channel__c,
                External_Link__c,
                Thread_Type__c,
                Social_Post_Author__c,
                Case__c,
                Subject_Name__c,
                Status__c,
                Reply_to_Social_Post__c,
                End_DateTime__c,
                Topic_Profile_Name__c
            FROM Social_Post__c
            WHERE Id = :recordId
        ];
        System.debug('recordId: ' + recordId);
        Map<String, Object> jsonMap = new Map<String, Object>();

        Datetime startTime = System.now();
        String requestBody;
        String responseBody;
        Boolean isSuccess = false;
        String userName = UserInfo.getName();
        try {
            String token = WarroomPageController.getWarroomToken();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Reply_Message');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Authorization', 'Bearer ' + token);

            // create reqBody
            Map<String, Object> reqBody = new Map<String, Object>();
            reqBody.put('sna_id', socialId);
            reqBody.put('post_identity_id', thisPost.get(0).Post_Identity_ID__c);

            // message
            Map<String, Object> msgPayload = new Map<String, Object>();
            msgPayload.put('type', 'text');
            msgPayload.put('text', messageBody);
            List<Object> finalPayload = new List<Object>();
            finalPayload.add(msgPayload);
            reqBody.put('message_payload', finalPayload);

            reqBody.put('thread_type', thisPost.get(0).Thread_Type__c);
            reqBody.put('website', thisPost.get(0).Thread_Type__c);
            reqBody.put('thread_id', thisPost.get(0).Thread_ID__c);
            // reqBody.put('thread_identity_id', thisPost.get(0).Thread_Identity_ID__c);
            reqBody.put('thread_identity_id', threadIdentityId);
            req.setBody(JSON.serializePretty(reqBody));
            Http http = new Http();
            requestBody = req.getBody();
            System.debug('reqBody' + JSON.serializePretty(reqBody));
            HTTPResponse res = http.send(req);
            // Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('resBody: ' + res.getBody());
            responseBody = res.getBody();
            String status = String.valueOf(jsonMap.get('status'));
            if (status == 'success') {
                isSuccess = true;
                OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  '',  '' ,  userName, '' ,  'Reply_Message' , requestBody , responseBody, null, startTime,  System.now(),  '');
                // insert new post
                Social_Post__c replyPost = new Social_Post__c();
                replyPost.Source_Channel__c = thisPost.get(0).Source_Channel__c;
                replyPost.Post_Author_Type__c = 'Agent';
                replyPost.External_Link__c = thisPost.get(0).External_Link__c;
                replyPost.Post_ID__c = String.valueOf(thisPost.get(0).Post_ID__c) + 'R';
                replyPost.Post_Body__c = messageBody;
                replyPost.Post_Type__c = 'comment';
                replyPost.Post_Date__c = System.now();
                replyPost.Status__c = 'Close';
                replyPost.Thread_ID__c = thisPost.get(0).Thread_ID__c;
                replyPost.Thread_Type__c = thisPost.get(0).Thread_Type__c;
                replyPost.Social_Post_Author__c = thisPost.get(0).Social_Post_Author__c;
                replyPost.Reply_Social_ID__c = socialId;
                replyPost.Case__c = thisPost.get(0).Case__c;
                replyPost.Message_Type__c = 'Outbound';
                replyPost.Post_Identity_ID__c = String.valueOf(jsonMap.get('id'));
                replyPost.Subject_Name__c = thisPost.get(0).Subject_Name__c;
                replyPost.Topic_Profile_Name__c = thisPost.get(0).Topic_Profile_Name__c;
                System.debug('replyPost: ' + JSON.serializePretty(replyPost));
                insert replyPost;
                
                thisPost.get(0).Reply_to_Social_Post__c = replyPost.Id;
                thisPost.get(0).End_DateTime__c = System.now();
                thisPost.get(0).Status__c = 'Close';
                update thisPost;
            } else {
                isSuccess = false;
                Map<String, Object> error = (Map<String, Object>) jsonMap.get('error');
                String errMsg = String.valueOf(error.get('message'));
                System.debug('error: ' + errMsg);
                OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  errMsg,  '' ,  userName, '' ,  'Reply_Message' , requestBody , responseBody, null, startTime,  System.now(),  '');
            }
        } catch (Exception e) {
            isSuccess = false;
            System.debug('err: ' + e.getMessage());
            OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '',  e.getMessage(),  '' ,  userName, '' ,  'Reply_Message' , requestBody , responseBody, null, startTime,  System.now(),  '');
        }
        if (!isSuccess) {
            throw new AuraHandledException('');
        }
        return rtnValue;
    }

    @AuraEnabled
    public static void rejectPost(String recordId, String rejectReason, String rejectComment) {
        List<Social_Post__c> thisPost = [SELECT Id, Status__c, End_DateTime__c, Case__c, Reject_Reason__c, Reject_Comment__c FROM Social_Post__c WHERE Id = :recordId];
        try {
            Case thisCase = [SELECT Id, FCR__c, Root_Cause__c, Root_Cause_List__c, Resolution__c, Resolution_List__c FROM Case WHERE Id = :thisPost.get(0).Case__c LIMIT 1];
            thisCase.FCR__c = true;
            thisCase.Root_Cause_List__c = 'Other';
            thisCase.Resolution_LIst__c = 'Other';
            thisCase.Root_Cause__c = 'Reject Post';
            thisCase.Resolution__c = 'Reject Post';
            update thisCase;
        } catch (Exception e) {
            System.debug('Case not found');
        }
        
        thisPost.get(0).End_DateTime__c = System.now();
        thisPost.get(0).Status__c = 'Reject';
        thisPost.get(0).Reject_Reason__c = rejectReason;
        thisPost.get(0).Reject_Comment__c = rejectComment;
        update thisPost;
    }

    @AuraEnabled
    public static void clearTransfer(String recordId) {
        List<Social_Post__c> thisPost = [SELECT Id, Status__c, LastTransferUser__c FROM Social_Post__c WHERE Id = :recordId];
        thisPost.get(0).LastTransferUser__c = null;
        update thisPost;
    }

    public static String getToken() {
        String token;
        String jsonBody =  '{"username": "{!$Credential.Username}",'+
                           '"password": "{!$Credential.Password}",'+
                           '"expire": 900}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Warroom_Get_Token_2');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        HttpResponse response;
        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            String body = '{"status":"success","data":"xxx"}';
            response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);
        }
 
        System.debug('Get Token status code --->' + response.getStatusCode());
        System.debug('Get response' + response.getBody());

        if (response.getStatusCode() == 200) 
        {
            Map<String, Object> getTokenMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            //token = JSON.serialize(getTokenMap.get('api_token'));
            token = getTokenMap.containsKey('data') ? getTokenMap.get('data').ToString() : null;
            System.debug('token:'+getTokenMap.get('data'));
        } else {
            System.debug('Get Token status body --->' + response.getStatusCode() + ' ' + response.getBody());
        }
       
        return token;
    }

    public static List<String> getPicklistValues() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Social_Post__c.Reject_Reason__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            options.add(entry.getValue());
        }
        return options;
    }
}