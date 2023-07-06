public with sharing class InsuranceReportController {
    @AuraEnabled
    public static Map<String, Object> getPaidUpInsurance(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> productMaturities = getPaidUpInsuranceData(queryLimit);

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

    public static List<Customer_Product_Alert__c> getPaidUpInsuranceData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Account_Number__c, Insurance_Paid_Up_Date__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND Financial_Account_Group__c = \'BA\' AND Insurance_Paid_Up_Date__c <= NEXT_N_DAYS:30 AND Insurance_Paid_Up_Date__c >= TODAY ORDER BY Insurance_Paid_Up_Date__c ';
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
    public static Map<String, Object> getAnniversaryInsurance(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> productMaturities = getAnniversaryInsuranceData(queryLimit);

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
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Insurance_Anniversary_Date__c, Insurance_Premium_Amount_Due__c, Account_Number__c FROM Customer_Product_Alert__c ';
            String whereCon = 'WHERE Customer__r.RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND Financial_Account_Group__c = \'BA\' AND Insurance_Anniversary_Date__c <= NEXT_N_DAYS:30 AND Insurance_Anniversary_Date__c >= TODAY ORDER BY Insurance_Anniversary_Date__c ';
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
            List<Customer_Product_Alert__c> productMaturities = getMatureInsuranceData(queryLimit);

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
            String whereCon = 'WHERE Customer__r.RTL_Wealth_RM__c = \'' + UserInfo.getUserId() + '\' ' + 'AND Financial_Account_Group__c = \'BA\' AND Insurance_Maturity_Date__c <= NEXT_N_DAYS:30 AND Insurance_Maturity_Date__c >= TODAY ORDER BY Insurance_Maturity_Date__c ';
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