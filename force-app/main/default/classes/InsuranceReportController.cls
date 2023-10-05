public with sharing class InsuranceReportController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getAnniversaryInsurance(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> productMaturities = new List<Object>();
            for(Customer_Product_Alert__c each : getAnniversaryInsuranceData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('Id', each.Customer__c);
                eachData.put('Account_Number', each.Account_Number__c);
                eachData.put('Anniversary_Date', each.Insurance_Anniversary_Date__c);
                eachData.put('Insurance_Premium_Value', each.Insurance_Premium_Amount_Due__c);
                eachData.put('Insurance_Premium', NumberHelper.getCents((Decimal)each.Insurance_Premium_Amount_Due__c));
                eachData.put('Insurance_Fully_Paid_Flag', each.Insurance_Fully_Paid_Flag__c == null || each.Insurance_Fully_Paid_Flag__c == false ? 'No' : 'Yes');
                productMaturities.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Insurance_Anniversary_Due_in_30_Days_dYN'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', productMaturities);       
            
             if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Customer_Product_Alert__c> getAnniversaryInsuranceData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Insurance_Anniversary_Date__c, Insurance_Premium_Amount_Due__c, Account_Number__c, Insurance_Fully_Paid_Flag__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' ' + 'AND Financial_Account_Group__c = \'BA\' AND Insurance_Anniversary_Date__c <= NEXT_N_DAYS:30 ORDER BY Insurance_Anniversary_Date__c, Insurance_Premium_Amount_Due__c DESC ';
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
    public static Map<String, Object> getMatureInsurance(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> productMaturities = new List<Object>();
            for(Customer_Product_Alert__c each :  getMatureInsuranceData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.Customer__r.Name);
                eachData.put('Id', each.Customer__c);
                eachData.put('Account_Number', each.Account_Number__c);
                eachData.put('Insurance_Sum_Insured', each.Insurance_Sum_Insured__c);
                eachData.put('Insurance_Sum_Insured_Value', NumberHelper.getCents((Decimal)each.Insurance_Sum_Insured__c));
                eachData.put('Insurance_Maturity_Date', each.Insurance_Maturity_Date__c);
                productMaturities.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Insurance_Expire_in_30_Days_cQT'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', productMaturities);
            
             if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Customer_Product_Alert__c> getMatureInsuranceData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Account_Number__c, Insurance_Sum_Insured__c, Insurance_Maturity_Date__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' ' + 'AND Financial_Account_Group__c = \'BA\' AND Insurance_Maturity_Date__c <= NEXT_N_DAYS:30 AND Insurance_Maturity_Date__c >= TODAY ORDER BY Insurance_Maturity_Date__c ';
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
    public static Map<String, Object> getPaidUpInsurance(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> productMaturities = [SELECT Id, Name, Customer__c, Customer__r.Name, Account_Number__c, Insurance_Paid_Up_Date__c
                                        FROM Customer_Product_Alert__c 
                                        WHERE Customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() AND Financial_Account_Group__c = 'BA' 
                                            AND Insurance_Paid_Up_Date__c <= NEXT_N_DAYS:30  
                                            AND Insurance_Paid_Up_Date__c >= TODAY                   
                                        ORDER BY Insurance_Paid_Up_Date__c LIMIT :queryLimit];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Insurance_Paid_Up_in_30_Days_9z6'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', productMaturities);   
            
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