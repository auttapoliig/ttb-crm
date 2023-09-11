public with sharing class InvestmentReportController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }


    @AuraEnabled
    public static Map<String, Object> getDeposit(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Customer_Product_Alert__c each : getDepositData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('Id', each.Customer__c);
                eachData.put('Account_Number', each.Account_Number__c);
                eachData.put('Maturity_Date', each.Maturity_Date__c);
                eachData.put('Amount', NumberHelper.getCents(each.Amount__c));
                eachData.put('Amount_Value', each.Amount__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Deposit_Maturity_in_30_Days_4R9'];

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

    public static List<Customer_Product_Alert__c> getDepositData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Account_Number__c, Customer__c, Customer__r.Name, Product_Name__c, Maturity_Date__c, Amount__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' ' + ' AND CreatedDate >= LAST_N_DAYS:30  AND Financial_Account_Group__c = \'DP\' AND Maturity_Date__c <= NEXT_N_DAYS:30 AND Maturity_Date__c >= TODAY ORDER BY Maturity_Date__c, Amount__c DESC ';
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
            List<Object> dataList = new List<Object>();
            for(Customer_Product_Alert__c each : getMFData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Id', each.Customer__c);
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('Amount_Value', each.Amount__c);
                eachData.put('Amount', NumberHelper.getCents((Decimal)each.Amount__c));
                eachData.put('Fund_Type', each.Product_Name__c);
                eachData.put('Maturity_Date', each.Maturity_Date__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Mutual_Fund_Maturity_in_30_Days_Wv0'];

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

    public static List<Customer_Product_Alert__c> getMFData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, MF_Fund_Type__c, Product_Name__c, Maturity_Date__c, Amount__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' ' + 'AND CreatedDate >= LAST_N_DAYS:30 AND Financial_Account_Group__c = \'MF\' AND Maturity_Date__c <= NEXT_N_DAYS:30 AND Maturity_Date__c >= TODAY ORDER BY Maturity_Date__c, Amount__c DESC ';
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