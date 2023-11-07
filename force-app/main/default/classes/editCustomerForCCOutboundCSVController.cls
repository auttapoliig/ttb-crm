public without sharing class editCustomerForCCOutboundCSVController {
    @AuraEnabled
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields, List<String> fields_translate) {
        return RetailCSVLightningUtil.getDescribeFieldResultAndValue(recordId, fields, fields_translate);
    }

    @AuraEnabled
    public static Map<String, Object> getInitialData(String accId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String query = 'SELECT Id, Name FROM Account WHERE Id = \'' + accId + '\'';
            Account account = Database.query(query);
            response.put('account', account);

            response.put('preferredContactChannelOption', getPickListValuesIntoList('Account', 'RTL_Preferred_Contact_Channel__c'));
            response.put('alternativeContactChannelOption', getPickListValuesIntoList('Account', 'RTL_Alternative_Contact_Channel__c'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateAccountData(Account acct) {
        Map<String, Object> response = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Update acct;
            response.put('success', true);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    private static List<Map<String, String>> getPickListValuesIntoList(String objectName, String field) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(field).getDescribe().getPickListValues();

        List<Map<String, String>> picklist = new List<Map<String, String>>();
        Map<String, String> defaultValue = new Map<String, String>();
        defaultValue.put('label', '-- None --');
        defaultValue.put('value', '');

        picklist.add(defaultValue);
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Map<String, String> picklistMap = new Map<String, String>();
            picklistMap.put('label',objPickList.getLabel());
            picklistMap.put('value',objPickList.getValue());

            picklist.add(picklistMap);
        }
        return picklist;
    }
}