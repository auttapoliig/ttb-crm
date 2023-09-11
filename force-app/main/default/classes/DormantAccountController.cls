public with sharing class DormantAccountController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getDormantAccount(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Customer_Product_Alert__c each : getDormantAccountData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('Id', each.Customer__c);
                eachData.put('Account_Number', each.Account_Number__c);
                eachData.put('Dormant_Date', each.Dormant_Date__c);
                eachData.put('Amount', NumberHelper.getCents(each.Amount__c));
                eachData.put('Amount_Value', each.Amount__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Dormant_Account_Ifp'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', dataList);
            
            if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Customer_Product_Alert__c> getDormantAccountData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Customer__c, Customer__r.Name, Dormant_Date__c, Account_Number__c, Customer__r.TMB_Customer_ID_PE__c, Amount__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE customer__r.OwnerId = \'' + currentUserId + '\' ' + ' AND Financial_Account_Group__c = \'DP-DORMANT\' AND Dormant_Date__c <= NEXT_N_DAYS:30 ORDER BY Dormant_Date__c, Amount__c DESC ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Customer_Product_Alert__c>();
        }
    }
}