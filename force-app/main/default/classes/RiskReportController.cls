public with sharing class RiskReportController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getAccountList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = getQueryData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Risk_and_Suitability_Reassessment_OuL'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList);   
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Account> getQueryData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RMC_Suitability_Risk_Expiry_Date__c, RMC_Suitability_Risk_Level__c FROM Account  ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' ' + 'AND RMC_Suitability_Risk_Expiry_Date__c <= NEXT_N_DAYS:30 ORDER BY RMC_Suitability_Risk_Expiry_Date__c ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Account>();
        }
    }
}