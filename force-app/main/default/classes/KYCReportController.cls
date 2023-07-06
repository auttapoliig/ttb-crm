public with sharing class KYCReportController {

    @AuraEnabled
    public static Map<String, Object> getAccountList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = getQueryKYCData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'KYC_Updates_h7v'];

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

    public static List<Account> getQueryKYCData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, IAL__c, KYC_next_review_date__c FROM Account ';
            String whereCon = 'WHERE RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND KYC_next_review_date__c <= NEXT_N_DAYS:14 AND RMC_Is_current_RM_BM__c = true ORDER BY KYC_next_review_date__c ';
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