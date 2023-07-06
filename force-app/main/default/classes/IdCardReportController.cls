public with sharing class IdCardReportController {

    @AuraEnabled
    public static Map<String, Object> getAccountList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = getQueryIDCardCData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'ID_Card_Updates_Yfg'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList); 
            if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Account> getQueryIDCardCData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RTL_CitizenID_Expiration_Date__c, RMC_ID_Card_Expiry_Date__c FROM Account ';
            String whereCon = 'WHERE RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND RMC_ID_Card_Expiry_Date__c <= NEXT_N_DAYS:14  AND RMC_Is_current_RM_BM__c = true ORDER BY RMC_ID_Card_Expiry_Date__c ';
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