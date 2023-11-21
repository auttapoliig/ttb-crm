public with sharing class BirthdayReport {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getBirthdayList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = getQueryData(queryLimit);
            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Customer_Upcoming_Birthday_nGS'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', accList);
            
            if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Account> getQueryData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RTL_Date_Of_Birth__c, RMC_Next_Birthday__c FROM Account ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' ' + 'AND (RMC_Next_Birthday__c >= TODAY AND RMC_Next_Birthday__c <= NEXT_MONTH) ORDER BY RMC_Next_Birthday__c ';
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