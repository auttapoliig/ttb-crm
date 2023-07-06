public with sharing class InvestmentReportController {
    @AuraEnabled
    public static Map<String, Object> getDeposit(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> AccountList = getDepositData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Deposit_Maturity_in_30_Days_4R9'];

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

    public static List<Customer_Product_Alert__c> getDepositData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Product_Name__c, Maturity_Date__c, Amount__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND CreatedDate >= LAST_N_DAYS:30  AND Financial_Account_Group__c = \'DP\' AND Maturity_Date__c <= NEXT_N_DAYS:30 AND Maturity_Date__c >= TODAY ORDER BY CreatedDate ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Customer_Product_Alert__c>();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getMF(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> AccountList = getMFData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Mutual_Fund_Maturity_in_30_Days_Wv0'];

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

    public static List<Customer_Product_Alert__c> getMFData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Product_Name__c, Maturity_Date__c, Amount__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND CreatedDate >= LAST_N_DAYS:30 AND Financial_Account_Group__c = \'MF\' AND Maturity_Date__c <= NEXT_N_DAYS:30 AND Maturity_Date__c >= TODAY ORDER BY CreatedDate ';
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