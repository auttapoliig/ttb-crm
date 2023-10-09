public virtual class ETEAPIService {
    /***
     * To call API service via ETE
     *      Noted:
     *          # Secret Key store in Name Credential by:
     *              - Identity Type = Named Principal
     *              - Authentication Protocol = Password Authentication
     *              - Username = <Any Value> - we do not use these value in apex code
     *              - Password = <Secret Key>
     *      Step:
     *          1. Get secret key via silverlake service (Salesforce APEX Rest - SilverlakeService Class)
     *          2. Encrypt API request body via ETEAPIService.encryptMessage function
     *              In ETE body, there are 2 parameters (initial_vector and encrypted_data)
     *          3. Send through API with SmartBDM_Utility.tokenKeyEnliteGateWay
     *          4. If there is respose message, the message will be encrypted.
     *          5. Decrypted message by using ETEAPIService.decryptMessage function
     */
    private static final String ALGORITHYM = 'AES256'; //encryption method
    public STring nameCredentialGetKey = null;  //name credential that store secret key

    public virtual String encryptMessage(String rawData){
        /**
         * encryptMessage function to encrypt the pain data with secret key
         * return : ETE encrypt string (JSON with initial_vector and encrypted_data)
         */
        String encryptionKey = this.getEncrptionKey();
        ETEEncryptStructure eteRequest = this.getETEEncryptedData(rawData,EncodingUtil.convertFromHex(encryptionKey));
        return eteRequest.getJSONBody();
    }

    public virtual String decryptMessage(String encryptedData){
        /**
         * decryptMessage function to decrypt the encrypt data with secret key
         * return : decrypted string
         */
        String encryptionKey = this.getEncrptionKey();
        ETEEncryptStructure eteResponse = (ETEAPIService.ETEEncryptStructure) JSON.deserialize(encryptedData,ETEAPIService.ETEEncryptStructure.class);
        return this.getETEDecryptData(eteResponse,EncodingUtil.convertFromHex(encryptionKey));   
    }

    private virtual ETEEncryptStructure getETEEncryptedData(String rawData,Blob secretKey){
        /**
         * getETEEncryptedData function to do encryption process and set to ETE Structure
         * return : ETE Encrypted Structure
         */
        Blob initializationVector = Crypto.generateAesKey(128);
        Blob blobRawData = Blob.valueOf(rawData);
        Blob encryptedData = Crypto.encrypt(ALGORITHYM, secretKey, initializationVector, blobRawData);
        return new ETEEncryptStructure(initializationVector,encryptedData);
    }

    private virtual String getETEDecryptData(ETEEncryptStructure eteEncrypt,Blob secretKey){
        /**
         * getETEDecryptData function to do decryption process and retrun decrypted string
         * return : decrypted string
         */
        Blob initializationVector = EncodingUtil.convertFromHex(eteEncrypt.initial_vector);
        Blob encryptedBlob = EncodingUtil.convertFromHex(eteEncrypt.encrypted_data);
        Blob decryptText = Crypto.decrypt(ALGORITHYM, secretKey, initializationVector, encryptedBlob);
        return decryptText.toString();
    }

    public class ETEEncryptStructure{
        /**
         * ETE Encrypt Structure which required initial vector and encrypted data
         */
        public String initial_vector;
        public String encrypted_data;
        public ETEEncryptStructure(Blob initialVector,Blob encryptedData){
            initial_vector = EncodingUtil.convertToHex(initialVector);
            encrypted_data= EncodingUtil.convertToHex(encryptedData);
        }

        public String getJSONBody(){
            //convert obj to json string
            return JSON.serialize(this);
        }
    }
    public String getEncrptionKey(){
        //To get encrypteion key from name credential
        Http http = new Http();
        HttpResponse response = http.send(this.getProtectKeyRequest());
        return response.getBody().replace('"',''); //remove dobule quote from response body
    }

    private HttpRequest getProtectKeyRequest(){
        /*
        *   get protection key from silverlake service
        */
        Uuid uuid = new Uuid();
        String uuidValue = uuid.getValue();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setEndpoint(nameCredentialGetKey+'?uuid=' + uuidValue);
        req.setBody('{"api_key":"{!HTMLENCODE($Credential.Password)}"}');
        req.setTimeout(120000);
        Datetime startTime = Datetime.Now();
        /* Add header for validation */
        String header = '{'+
            '"name" : "'+UserInfo.getName()+'",'+
            '"callDt" : "'+startTime.format('dd/MM/yyyy hh:mm:ss')+'",'+
            '"username" : "'+UserInfo.getUserName()+'",'+
            '"uuid" : "'+uuidValue+'"'+
        '}';
        String result = EncodingUtil.Base64Encode( Blob.valueOf( header ) );
        req.setHeader('X-Salesforce-EHD', 'EHD ' + result);
        return req;
    }

    private void createOnlineLog(){

    }
}