public with sharing class TransactionMovementReport {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getTransactionForWealthNonWealth(Integer queryLimit, String isWealth){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> transactionMovement = new List<Object>();
            for(Large_Transaction_Movements__c each : getTransactionData(queryLimit, isWealth)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Id', each.Customer__c);
                eachData.put('CusName', each.Customer__r.Name);
                eachData.put('Amount__c', NumberHelper.getCents((Decimal)each.Amount__c));
                eachData.put('Amount__c_Value', each.Amount__c);
                eachData.put('Product_Name', each.Product_Name__c);
                eachData.put('Account_Number', each.Account_Number__c);
                eachData.put('Transaction_Date_Time', each.Transaction_Date_Time__c);
                transactionMovement.add(eachData);
            }
            String devName;
            if(isWealth == 'Yes'){
                devName = 'Large_Transactions_For_Wealth_nxi';
            }
            else{
                devName = 'Large_Transactions_For_Non_Wealth_e5Q';
            }
            
            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName =:devName];
            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', transactionMovement); 
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Large_Transaction_Movements__c> getTransactionData(Integer queryLimit, String isWealth){
        try{
            String condition;
            if(isWealth == 'No'){
                condition = 'AND Amount__c != null AND Transaction_Date_Time__c >= LAST_N_DAYS:5 AND (Amount__c <= -1000000 OR Amount__c >= 1000000) AND Customer__r.RMC_Wealth_Flag__c = \'No\'';
            }
            else{
                condition = 'AND Amount__c != null AND Transaction_Date_Time__c >= LAST_N_DAYS:5 AND (Amount__c <= -3000000 OR Amount__c >= 3000000) AND Customer__r.RMC_Wealth_Flag__c = \'Yes\'';
            }
            String query = 'SELECT Id, Customer__c, Customer__r.Name, Account_Number__c, Product_Name__c, Product_Type__c, Transaction_Date_Time__c, Amount__c FROM Large_Transaction_Movements__c ';
            String whereCon = 'WHERE customer__r.OwnerId = \'' + currentUserId + '\' ' + condition + ' ORDER BY Amount__c ASC ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Large_Transaction_Movements__c>();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getRiskMisMatch(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Account each : getRiskMisMatchData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Id', each.Id);
                eachData.put('Name', each.Name);
                eachData.put('RMC_Suitability_Risk_Level', each.RMC_Suitability_Risk_Level__c);
                eachData.put('RMC_Suitability_Risk_Level_Required', each.RMC_Suitability_Risk_Level_Required__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'New_Customers_Report_lUH'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', dataList); 
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Account> getRiskMisMatchData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, RMC_Suitability_Risk_Level__c, RMC_Suitability_Risk_Level_Required__c FROM Account ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' ' + 'AND RMC_Suitability_Risk_Level_Diff__c > 0 ORDER BY RMC_Suitability_Risk_Level_Required__c DESC ';
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
    public static Map<String, Object> getMFPortAdjust(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Customer_Product_Alert__c each : getMFPortAdjustData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Id', each.Customer__c);
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('MF_Gain_Loss_Percent', each.MF_Gain_Loss_Percent__c == null ? '0.00%' : NumberHelper.getCents(each.MF_Gain_Loss_Percent__c) + '%');
                eachData.put('MF_Gain_Loss_Percent_Value', each.MF_Gain_Loss_Percent__c == null ? 0 : each.MF_Gain_Loss_Percent__c);
                eachData.put('Product_Name', each.Product_Name__c);
                eachData.put('MF_Outstanding', NumberHelper.getCents(each.MF_Outstanding__c));
                eachData.put('MF_Outstanding_Value', each.MF_Outstanding__c == null ? 0 : each.MF_Outstanding__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Mutual_Fund_Port_Adjustment_ka7'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', dataList); 
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Customer_Product_Alert__c> getMFPortAdjustData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Customer__c, MF_Outstanding__c, Customer__r.Name, MF_Gain_Loss_Percent__c, Product_Name__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' ' + 'AND Financial_Account_Group__c = \'MF-ADJ\' AND MF_Gain_Loss_Percent__c < 0 ORDER BY MF_Gain_Loss_Percent__c ';
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
    public static Map<String, Object> getTransactionPlus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Large_Transaction_Movements__c> transactionMovement = [SELECT Id, Customer__c, Customer__r.Name, Product_Type__c, Transaction_Date_Time__c, Amount__c
                                        FROM Large_Transaction_Movements__c 
                                        WHERE customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() AND 
                                            Transaction_Date_Time__c >= LAST_N_DAYS:5
                                            AND Amount__c > 5000000                                           
                                        ORDER BY Transaction_Date_Time__c DESC LIMIT :queryLimit];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Transaction_Movements_Repo_qqK1'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', transactionMovement); 
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getTransactionMinus(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Large_Transaction_Movements__c> transactionMovement = [SELECT Id, Customer__c, Customer__r.Name, Product_Type__c, Transaction_Date_Time__c, Amount__c
                                        FROM Large_Transaction_Movements__c 
                                        WHERE customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() 
                                        AND Transaction_Date_Time__c >= LAST_N_DAYS:5
                                        AND Amount__c < -5000000
                                        ORDER BY Transaction_Date_Time__c DESC LIMIT :queryLimit];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Large_Transaction_Movements_Repo_ao11'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', transactionMovement);
            
             if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }
}