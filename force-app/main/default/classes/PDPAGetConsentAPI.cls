public class PDPAGetConsentAPI extends ETEAPIService{

    public PDPAGetConsentAPI() {
        this.nameCredentialGetKey = 'callout:get_pdpa_key';
    }

    public PDPAGetConsentAPI.PDPAConsentDetail callRequest(String rmID){
        Http http = new Http();
        HttpRequest req = this.getHttpRequest(rmID);
        HttpResponse response = http.send(req);
        System.debug('response :: ' + response);
        System.debug('response body :: '+response.getBody());
        String decryptMessage = this.decryptMessage(response.getBody());
        PDPAGetConsentAPI.PDPAConsentDetail consentDetail = (PDPAGetConsentAPI.PDPAConsentDetail) JSON.deserialize(decryptMessage,PDPAGetConsentAPI.PDPAConsentDetail.class);
        system.debug(consentDetail);
        return consentDetail;
    }

    public void getKey(){
        this.getEncrptionKey();
    }

    public HttpRequest getHttpRequest(String rmID){
        Uuid uuidGenerateor = new Uuid();
        String uuid = uuidGenerateor.getValue();
        DateTime currentDateTime = Datetime.now();
        String formatted = currentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ','Asia/Bangkok');
        PDPAConsentBody consentBody = new PDPAConsentBody();
        consentBody.searchByRMId(rmID);

        String encryptionMessage = this.encryptMessage(consentBody.getJSON());
        String token = SmartBDM_Utility.tokenKeyEnliteGateWay;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('service-name', 'customers-pdpa-get');
        req.setHeader('request-uid', uuid);
        req.setHeader('request-app-id', 'A0291');
        req.setHeader('request-datetime',formatted);
        req.setEndpoint('callout:PDPA_GET_Consents');
        req.setBody(encryptionMessage);
        return req;
    }

    public class PDPAConsentBody{
        public PDPAConsentQuery query;
        
        public PDPAConsentBody(){

        }

        public void searchByRMId(String rmID){
            this.query = new PDPAConsentQuery('rm-id',rmID);
        }

        public String getJSON(){
            return JSON.serialize(this);
        }
    }

    public class PDPAConsentQuery{
        public String search_type;
        public String search_value;

        public PDPAConsentQuery(){

        }
        public PDPAConsentQuery(String searchType, String searchValue){
            this.search_type = searchType;
            this.search_value = searchValue;
        }
    }

    public class PDPAConsentDetail{
        public PDPAConsentDetailStatus status {get;set;}
        public PDPAConsentDetailCustomer customer {get;set;}

        public PDPAConsentDetail(){

        }
    }

    public class PDPAConsentDetailStatus{
        public String code {get;set;}
        public String description {get;set;}

        public PDPAConsentDetailStatus(){

        }
    }

    public class PDPAConsentDetailCustomer{
        public PDPAConsentDetailCustomerProfile profile {get;set;}
        public List<PDPAConsentDetailCustomerConsent> consents {get;set;}

        public PDPAConsentDetailCustomer(){

        }
    }

    public class PDPAConsentDetailCustomerProfile{
        public String cc_id {get;set;}
        public String rm_id {get;set;}

        public PDPAConsentDetailCustomerProfile(){

        }
    }

    public class PDPAConsentDetailCustomerConsent{
        @AuraEnabled
        public String type_of_consent {get;set;}
        @AuraEnabled
        public String flag {get;set;}
        @AuraEnabled
        public String version_number {get;set;}
        @AuraEnabled
        public String channel {get;set;}
        @AuraEnabled
        public String user_id {get;set;}
        @AuraEnabled
        public Date signup_date {get;set;}
        @AuraEnabled
        public Datetime system_date {get;set;}
        @AuraEnabled
        public String need_update_flag {get;set;}
        @AuraEnabled
        public String need_update_flag_reason {get;set;}
        @AuraEnabled
		public String decriptionEN {get;set;}
        @AuraEnabled
        public String decriptionTH {get;set;}
        @AuraEnabled
        public String wsCurrentFlag {get;set;}
        
        public PDPAConsentDetailCustomerConsent(){

        }
    }
}