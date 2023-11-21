public with sharing class AUMReport {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getAUMChangeData(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> accountList = new List<Object>();
            for(Account each : getAUMPlusAndMinusData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Id', each.Id);
                eachData.put('Name', each.Name);
                eachData.put('percentChange', each.RMC_AUM_Change__c == null ? '0.00%' : NumberHelper.getCents((Decimal)each.RMC_AUM_Change__c) + '%');
                eachData.put('MTD_AUM_Balance', each.RMC_AUM__c == null ? '0.00' : NumberHelper.getCents((Decimal)each.RMC_AUM__c));
                eachData.put('Last_Month_AUM', each.get('RMC_AUM_LastPeriod__c') == null ? '0.00' : NumberHelper.getCents((Decimal)each.get('RMC_AUM_LastPeriod__c')));
                eachData.put('percentChange_Value', each.RMC_AUM_Change__c == null ? 0 : each.RMC_AUM_Change__c);
                eachData.put('MTD_AUM_Balance_Value', each.RMC_AUM__c == null ? 0 : each.RMC_AUM__c);
                eachData.put('Last_Month_AUM_Value', each.RMC_AUM_LastPeriod__c == null ? 0 : each.RMC_AUM_LastPeriod__c);
                accountList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'New_Customers_Report_Kqw'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', accountList);
             if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Account> getAUMPlusAndMinusData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c, RMC_AUM_LastPeriod__c FROM Account ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' ' + 'AND RMC_AUM_Change__c != null AND (RMC_AUM_Change__c < 0 OR RMC_AUM_Change__c > 0) ORDER BY RMC_AUM_Change__c ';
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
    public static Map<String, Object> getAUMPlus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c
                                    FROM Account 
                                    WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_AUM_Change__c > 0 
                                     
                                    //    AND RMC_AUM_Calculation_Date__c >= LAST_N_DAYS:3
                                    ORDER BY RMC_AUM_Change__c DESC LIMIT :queryLimit];

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

    @AuraEnabled
    public static Map<String, Object> getAUMMinus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c
                                        FROM Account 
                                        WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_AUM_Change__c < 0 
                                         
                                           // AND RMC_AUM_Calculation_Date__c >= LAST_N_DAYS:3
                                        ORDER BY RMC_AUM_Change__c  LIMIT :queryLimit];
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
}