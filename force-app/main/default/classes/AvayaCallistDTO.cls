global class AvayaCallistDTO {

    global Request request;
    global Response response;

    global AvayaCallistDTO(){
        request = new Request();
        response = new Response();
    }

    global class Request{
        
        private String request_id { get; set;} //Id, Referral_Key__c
        private String first_name {get;set;} //RTL_FirstName__c
        private String last_name {get;set;} //RTL_LastName__c
        private String product_name { get; set;} //RTL_Interested_Product__c/RTL_Product_Name__r.Name
        private String sub_product { get; set;} //RTL_Sub_Product__c
        private String mobile {get;set;} //RTL_Mobile1__c
        private String campaign {get;set;} //RTL_Campaign__c
        private String dial_time { get; set;} //RTL_Referred_Date_time__c
        private String channel_name { get; set;} //RTL_Channel_Segment__c
        private String sf_id { get; set;} //Salesforce Record Id For telephony

        private String business1 {get;set;} //web_business01_c
        private String business2 {get;set;} //web_business02_c
        private String business3 {get;set;} //web_business03_c
        private String business4 {get;set;} //web_business04_c
        private String business5 {get;set;} //web_business05_c
        private String business6 {get;set;} //web_business06_c
        private String business7 {get;set;} //web_business07_c
        private String business8 {get;set;} //web_business08_c
        private String business9 {get;set;} //web_business09_c
        private String business10 {get;set;} //web_business10_c

        private String remark {get;set;} //remark__c
        private String url_field {get;set;} //Salesforce URL for telephony popup record
        

        global Request(){
            request_id = '';
            first_name = '';
            last_name = '';
            product_name = '';
            sub_product = '';
            mobile = '';
            campaign = '';
            dial_time = '';
            channel_name = '';
            sf_id = '';
            business1 = '';
            business2 = '';
            business3 = '';
            business4 = '';
            business5 = '';
            business6 = '';
            business7 = '';
            business8 = '';
            business9 = '';
            business10 = '';
            remark = '';
            url_field = '';
        }

        // request id getter / setter
        global void setRequestId(String inRequestId){
            this.request_id = inRequestId;
        }

        global String getRequestId(){
            return request_id;
        }

        // first name getter / setter
        global void setFirstName(String inFirstName){
            this.first_name = inFirstName;
        }

        global String getFirstName(){
            return first_name;
        }

        global String getTruncateFirstName(){
            return RTL_Utility.truncateString(first_name,40);
        }

        // last name getter / setter
        global void setLastName(String inLastName){
            this.last_name = inLastName;
        }

        global String getLastName(){
            return last_name;
        }

        global String getTruncateLastName(){
            return RTL_Utility.truncateString(last_name,40);
        }

        // product name getter / setter
        global void setProductName(String inProductName){
            this.product_name = inProductName;
        }

        global String getProductName(){
            return product_name;
        }

        global String getTruncateProductName(){
            return RTL_Utility.truncateString(product_name, 40);
        }

        // product name getter / setter
        global void setSub_ProductName(String inSub_ProductName){
            this.sub_product = inSub_ProductName;
        }

        global String getSub_ProductName(){
            return sub_product;
        }

        global String getTruncateSub_ProductName(){
            return RTL_Utility.truncateString(sub_product, 40);
        }

        // Mobile getter / setter
        global void setMobile(String inMobile){
            this.mobile = inMobile;
        }

        global String getMobile(){
            return mobile;
        }

        // Campaign getter / setter
        global void setCampaign(String inCampaign){
            this.campaign = inCampaign;
        }

        global String getCampaign(){
            return campaign;
        }

        // dial_time getter / setter
        global void setDial_time(String inDial_time){
            this.dial_time = inDial_time;
        }

        global String getDial_time(){
            return dial_time;
        }

        // Channel_name getter / setter
        global void setChannel_name(String inChannel_name){
            this.channel_name = inChannel_name;
        }

        global String getChannel_name(){
            return channel_name;
        }

        // sf_id getter / setter
        global void setSf_id(String inSf_id){
            this.sf_id = inSf_id;
        }

        global String getSf_id(){
            return sf_id;
        }

        // business1 getter / setter
        global void setBusiness1(String inBusiness1){
            this.business1 = inBusiness1;
        }

        global String getBusiness1(){
            return business1;
        }

        global String getTruncateBusiness1(){
            return RTL_Utility.truncateString(business1, 150);
        }

        // business2 getter / setter
        global void setBusiness2(String inBusiness2){
            this.business2 = inBusiness2;
        }

        global String getBusiness2(){
            return business2;
        }

        global String getTruncateBusiness2(){
            return RTL_Utility.truncateString(business2, 150);
        }

        // business3 getter / setter
        global void setBusiness3(String inBusiness3){
            this.business3 = inBusiness3;
        }

        global String getBusiness3(){
            return business3;
        }

        global String getTruncateBusiness3(){
            return RTL_Utility.truncateString(business3, 150);
        }

        // business4 getter / setter
        global void setBusiness4(String inBusiness4){
            this.business4 = inBusiness4;
        }

        global String getBusiness4(){
            return business4;
        }

        global String getTruncateBusiness4(){
            return RTL_Utility.truncateString(business4, 150);
        }

        // business5 getter / setter
        global void setBusiness5(String inBusiness5){
            this.business5 = inBusiness5;
        }

        global String getBusiness5(){
            return business5;
        }

        global String getTruncateBusiness5(){
            return RTL_Utility.truncateString(business5, 150);
        }

        // business6 getter / setter
        global void setBusiness6(String inBusiness6){
            this.business6 = inBusiness6;
        }

        global String getBusiness6(){
            return business6;
        }

        global String getTruncateBusiness6(){
            return RTL_Utility.truncateString(business6, 150);
        }

        // business7 getter / setter
        global void setBusiness7(String inBusiness7){
            this.business7 = inBusiness7;
        }

        global String getBusiness7(){
            return business7;
        }

        global String getTruncateBusiness7(){
            return RTL_Utility.truncateString(business7, 150);
        }

        // business8 getter / setter
        global void setBusiness8(String inBusiness8){
            this.business8 = inBusiness8;
        }

        global String getBusiness8(){
            return business8;
        }

        global String getTruncateBusiness8(){
            return RTL_Utility.truncateString(business8, 150);
        }

        // business9 getter / setter
        global void setBusiness9(String inBusiness9){
            this.business9 = inBusiness9;
        }

        global String getBusiness9(){
            return business9;
        }

        global String getTruncateBusiness9(){
            return RTL_Utility.truncateString(business9, 150);
        }

        // business10 getter / setter
        global void setBusiness10(String inBusiness10){
            this.business10 = inBusiness10;
        }

        global String getBusiness10(){
            return business10;
        }

        global String getTruncateBusiness10(){
            return RTL_Utility.truncateString(business10, 150);
        }

        // Remark getter / setter
        global void setRemark(String inRemark){
            this.remark = inRemark;
        }

        global String getRemark(){
            return remark;
        }

        global String getTruncateRemark(){
            return RTL_Utility.truncateString(remark, 150);
        }

        // SF URL getter / setter
        global void setURL(String inURL){
            this.url_field = inURL;
        }

        global String getURL(){
            return url_field;
        }

        global String getTruncateURL(){
            return RTL_Utility.truncateString(url_field, 256);
        }
    }

    global class Response{
        global String systemContactID {get;set;}
        global String inserted {get;set;}
        global String errorCode {get;set;}
        global String failureReason {get;set;}
        global List<String> emptiedAttributes {get;set;}

        global String message {get;set;} /* message return from service or internal error message */
        global String rawResponse {get;set;}
    }

    global String generateJSONContent(){
        JSONGenerator gen = JSON.createGenerator(true);
        String jsonString = '';
        
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('request_id', RTL_Utility.checkNull(request.getRequestId(),''));
        gen.writeStringField('first_name', RTL_Utility.checkNull(request.getTruncateFirstName(),''));
        gen.writeStringField('last_name',RTL_Utility.checkNull(request.getTruncateLastName(),''));
        gen.writeStringField('product_name',RTL_Utility.checkNull(request.getTruncateProductName(),'') );
        gen.writeStringField('sub_product',RTL_Utility.checkNull(request.getTruncateSub_ProductName(),'') );
        gen.writeStringField('mobile', RTL_Utility.checkNull(request.getMobile(),''));
        gen.writeStringField('campaign',RTL_Utility.checkNull(request.getCampaign(),'') );
        gen.writeStringField('dial_time',RTL_Utility.checkNull(request.getDial_time(),'') );
        gen.writeStringField('channel_name',RTL_Utility.checkNull(request.getChannel_name(),'') );
        gen.writeStringField('sf_id',RTL_Utility.checkNull(request.getSf_id(),'') );
        gen.writeStringField('business1',RTL_Utility.checkNull(request.getBusiness1(),'') );
        gen.writeStringField('business2',RTL_Utility.checkNull(request.getBusiness2(),'') );
        gen.writeStringField('business3',RTL_Utility.checkNull(request.getBusiness3(),'') );
        gen.writeStringField('business4',RTL_Utility.checkNull(request.getBusiness4(),'') );
        gen.writeStringField('business5',RTL_Utility.checkNull(request.getBusiness5(),'') );
        gen.writeStringField('business6',RTL_Utility.checkNull(request.getBusiness6(),'') );
        gen.writeStringField('business7',RTL_Utility.checkNull(request.getBusiness7(),'') );
        gen.writeStringField('business8',RTL_Utility.checkNull(request.getBusiness8(),'') );
        gen.writeStringField('business9',RTL_Utility.checkNull(request.getBusiness9(),'') );
        gen.writeStringField('business10',RTL_Utility.checkNull(request.getBusiness10(),'') );
        gen.writeStringField('remark',RTL_Utility.checkNull(request.getTruncateRemark(),'') );
        gen.writeStringField('url_field',RTL_Utility.checkNull(request.getTruncateURL(),'') );
        
        gen.writeEndObject();
        
        // Get the JSON string.
        jsonString = gen.getAsString();
        
        return jsonString;
    }
}