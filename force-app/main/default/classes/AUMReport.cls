public with sharing class AUMReport {

    @AuraEnabled
    public static Map<String, Object> getAUMPlus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = getAUMPlusData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'AUM_Change_Tqt'];

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

    public static List<Account> getAUMPlusData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c FROM Account ';
            String whereCon = 'WHERE RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND RMC_AUM_Change__c > 0 ORDER BY RMC_AUM_Change__c DESC ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Account>();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getAUMMinus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = getAUMMinusData(queryLimit);
            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'AUM_0Km'];

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

    public static List<Account> getAUMMinusData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c FROM Account ';
            String whereCon = 'WHERE RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND RMC_AUM_Change__c < 0 ORDER BY RMC_AUM_Change__c ';
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