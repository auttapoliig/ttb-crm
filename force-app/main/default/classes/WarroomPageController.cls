public with sharing class WarroomPageController {
    public static String WARROOM_URL{
        get{
            if(WARROOM_URL == null){
                List<App_Config__mdt> appConfigList = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Warroom URL'];           
                if (appConfigList != null && appConfigList.size() > 0) {
                    WARROOM_URL = appConfigList.get(0).Value__c;
                }  else {
                    WARROOM_URL = 'https://warroom.wisesight.com/thread/https://warroom.wisesight.com/thread/{thread_id}/{post_id}?verification_type=WARROOM_VERIFICATION&parent_url={parent_url}&client_id={client-id}&token={token}';
                }
            }
            return WARROOM_URL;
            
        }set;
    }

    public static String CLIENT_ID{
            get{
                if(CLIENT_ID == null){
                    List<App_Config__mdt> appConfigList = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Warroom Client Id'];           
                    if (appConfigList != null && appConfigList.size() > 0) {
                        CLIENT_ID = appConfigList.get(0).Value__c;
                    }  else {
                        CLIENT_ID = '682';
                    }
                }
                return CLIENT_ID;
                
            }set;
    }

    @AuraEnabled
    public static String getURLforIframe(String recordId) {
        String iframeUrl = WARROOM_URL;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String threadId = '';
        String postId = '';

        try {
            Social_Post__c socialPost = [SELECT Id,Post_ID__c,Thread_ID__c from Social_Post__c WHERE id=:recordId];
            threadId = socialPost.Thread_ID__c;
            postId = socialPost.Post_ID__c;
        } catch (Exception e) {
            System.debug('ERROR :: ' + e.getMessage());
        }

        // Get token
        String token = getWarroomToken();

        // Combine url
        iframeUrl = iframeUrl.replace('{parent_url}', sfdcBaseURL);
        iframeUrl = iframeUrl.replace('{thread_id}', threadId);
        iframeUrl = iframeUrl.replace('{post_id}', postId);
        iframeUrl = iframeUrl.replace('{client_id}', CLIENT_ID);
        iframeUrl = iframeUrl.replace('{token}', token);

        System.debug('iframe URL --> ' + iframeUrl);
        return iframeUrl;
    }

    public static String getWarroomToken() {
        String token;
        String jsonBody =  '{"username": "{!$Credential.Username}",'+
                           '"password": "{!$Credential.Password}",'+
                           '"expire": 900}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Warroom_Get_Token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        HttpResponse response;
        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            String body = '{"status":"success","data":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoid2Fycm9vbVVzZXIiLCJpZCI6NTxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}';
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
}