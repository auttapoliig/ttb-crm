public without sharing class CommercialEditCrossSellProductController {
    
    @AuraEnabled
    public static ResponseWrapper upsertCrossSellProduct(String productJSON){
        ResponseWrapper res = new ResponseWrapper();
        try{
            System.debug(productJSON);
            Product_Interest__c product = (Product_Interest__c)System.JSON.deserialize(productJSON, Product_Interest__c.class);
            upsert product;
            res.success = true;
        } catch (Exception ex) {
            String message = 'Message: ' + ex.getMessage() + ' TypeName: ' + ex.getTypeName() + ' StackTrace: ' + ex.getStackTraceString();
            System.debug(message);
            res.type = 'error';
            res.success = false;
            res.message = ex.getMessage();
        }
        return res;
    }

    @AuraEnabled
    public static ResponseWrapper deleteCrossSellProduct(String productId){
        ResponseWrapper res = new ResponseWrapper();
        try{
            Product_Interest__c product = [SELECT Id FROM Product_Interest__c WHERE Id = :productId];
            delete product;
            res.success = true;
        } catch (Exception ex) {
            String message = 'Message: ' + ex.getMessage() + ' TypeName: ' + ex.getTypeName() + ' StackTrace: ' + ex.getStackTraceString();
            System.debug(message);
            res.type = 'error';
            res.success = false;
            res.message = ex.getMessage();
        }
        return res;
    }

    public class ResponseWrapper{
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean success {get;set;}
        @AuraEnabled
        public String message {get;set;}
    }
}