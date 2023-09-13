/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to [Insert Summary Description Here].
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Puntawus Laonan   <ptl@ii.co.th>
* @version        1.0
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            atp@ii.co.th
* 2021-10-01      Initial version with comment to control version first time.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource(urlMapping='/data/V1.0/cryptographic/*')
global class CryptographicService extends WebserviceAbstract {

    class EncryptionException extends Exception {}
    
    /* get service timeout */
	public static Integer SERVICE_TIMEOUT_MILISEC{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(SERVICE_TIMEOUT_MILISEC == null){
                try{
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> cryptographic_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'CRYPTOGRAPHIC_TIMEOUT_MILLISEC' LIMIT 1];  
                    if (cryptographic_Timeout != null && cryptographic_Timeout.size() > 0) {
                        SERVICE_TIMEOUT_MILISEC = Integer.valueOf(cryptographic_Timeout.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                }
            }
            return SERVICE_TIMEOUT_MILISEC;
            
        }set;
    }
    
    @HttpPost
    global static void mappingService(){
        /* cast */
        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = '';
        String requestBody = '';
        String responseBody = '';
        String requestBodyDecrypt = '';
        String reqId = '';
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        
        Account accForLog = new Account();
        Boolean isSuccess = true;
        String processType;
        /* end cast */
        
        /* Additional get key specific from request */
        RestRequest request = RestContext.request;
        String encryptKey = '';
        try {
            encryptKey = getKeyFromSystem(request);
        } catch (WebserviceAbstract.MissingHeaderException e) {
        	encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
        }
        //String encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
        
        try{          
            /* get req id */
            System.debug('get header');
            Map<String, String> headerKeys = RestContext.request.headers;
            reqId = (String)headerKeys.get('ReqId');
            /* decrypt */
            System.debug('decrypt-->' + encryptKey);
            Map<String, Object> requestRawBodyMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(RestContext.request.requestBody.toString(), encryptKey);
            
            if (requestBodyDecrypt == null) {
                throw new EncryptionException('Cannot decrypt message');
            }
            /* Call API from WebserviceAbstract */
            Map<String, Object> result = callStandardAPI(requestBodyDecrypt, headerKeys, encryptKey);


            /* Get back result from service */
            isSuccess = (Boolean) result.get('isSuccess');
            errorMessage = (String) result.get('errorMessage');
            endTime = DateTime.Now();
            requestBody = headerKeys.toString() + '\n\n' + requestBodyDecrypt;
            responseBody = (String) result.get('responseBody');
            String endpoint = (String) result.get('endpoint');
            serviceName = '/services/apexrest/data/V1.0/cryptographic'+ '  (' + endpoint + ')';

            /* Save to online log */
            //OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
            //                                      rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
            //                                      startTime ,  endTime,  null );
            RTL_CampaignUtil.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime);                                     
                                                     
        }
        catch(exception e)
        {       
			/* catch error log */
            errorMessage = 'Message: ' + e.getMessage();
            isSuccess = false;
            endTime = DateTime.Now();
            
            serviceName = '/services/apexrest/data/V1.0/cryptographic';

            String reponseString = '{\n  "errorCode": "'+e.getTypeName()+'",\n  "message": "'+e.getMessage()+'"\n}';           
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(RestContext.request.requestBody.toString(), encryptKey);
            requestBody = RestContext.request.headers.toString() + '\n\n' +requestBodyDecrypt;
            responseBody = reponseString;
           
            /* return error response */
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            // if (String.isNotEmpty(reponseString)) {
            //     RestContext.response.responseBody = Blob.valueOf(reponseString); 
            // }
             
            System.debug('res-->' + errorMessage + ' ' + encryptKey);
            try {
                RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
            } catch (Exception ein) {
                System.debug('err-->' + ein.getMessage());
            }
            
			/* save error to online log */
            //OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
            //                                      rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
            //                                      startTime ,  endTime,  null );
            RTL_CampaignUtil.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
                                            rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                            startTime ,  endTime );
        }
        
	}
}