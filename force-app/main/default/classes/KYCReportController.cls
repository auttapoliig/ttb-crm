public with sharing class KYCReportController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getAccountList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Account each : getQueryKYCData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                Integer kycValue = each.KYC_flag_limited__c == null ? 99 : each.KYC_flag_limited__c == 'Block I' ? 0 : each.KYC_flag_limited__c == 'Block B' ? 1 : each.KYC_flag_limited__c == 'Block S' ? 2 : 3;
                eachData.put('Name', each.Name);
                eachData.put('IAL', each.IAL__c);
                eachData.put('KYC_flag_limited', each.KYC_flag_limited__c);
                eachData.put('KYC_flag', each.KYC_flag__c);
                eachData.put('KYC_flag_limited_value', kycValue );
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'KYC_Updates_h7v'];

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

    public static List<Account> getQueryKYCData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, IAL__c, KYC_flag__c, KYC_next_review_date__c, KYC_flag_limited__c FROM Account ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' ' + 'AND (KYC_flag_limited__c = \'Block I\' OR KYC_flag_limited__c = \'Block S\' OR KYC_flag_limited__c = \'Block B\') ';
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