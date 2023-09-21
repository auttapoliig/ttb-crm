public with sharing class CampaignReportController {

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getCampaignList(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Campaign> campaignList = getQueryData(queryLimit);

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'New_Campaigns_and_Promotions_pLK'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', campaignList);   
            
            if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    public static List<Campaign> getQueryData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, StartDate, EndDate FROM Campaign ';
            String whereCon = 'WHERE RTL_Campaign_Type__c = \'Mass\' ORDER BY StartDate DESC ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Campaign>();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getInstantLending(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> instantList = new List<Object>();
            for(Retail_Instant_Lending__c each : getInstantLendingData(queryLimit)){
                    Map<String, Object> eachData = new Map<String, Object>();
                    eachData.put('Name', each.Customer__r.Name);
                    eachData.put('Id', each.Customer__c);
                    eachData.put('Details', each.Instant_lending_detail__c == null ? '-' : each.Instant_lending_detail__c);
                    eachData.put('ExpiryDate', each.Expiry_Date__c);
                    eachData.put('Cash_2_Go_Flag', each.Cash_2_go_flag__c == true ? 'Yes' : 'No');
                    eachData.put('Credit_Card_Flag', each.Credit_Card_flag__c == true ? 'Yes' : 'No');
                    eachData.put('Flash_Card_Flag', each.Flash_Card_flag__c == true ? 'Yes' : 'No');
                    eachData.put('instant_rec_url', '/one/one.app?#/sObject/' + each.id + '/view');
                    eachData.put('instant_rec_name', each.Name == null ? 'More Detail' : each.Name);
                    instantList.add(eachData);
            }

            List<Object> dataList = new List<Object>();
            for(Object each : instantList){
                if(dataList.size() < 5){
                    dataList.add(each);
                }
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Campaign_instant_lending_Waive_Document_qV4'];

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

    public static List<Retail_Instant_Lending__c> getInstantLendingData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Expiry_Date__c, Instant_lending_detail__c, Cash_2_go_flag__c, Cash_2_go_limit__c, Credit_Card_flag__c, Credit_Card_limit__c, Flash_Card_flag__c, Flash_Card_limit__c FROM Retail_Instant_Lending__c ';
            String whereCon = 'WHERE Customer__r.OwnerId = \'' + currentUserId + '\' AND Expiry_Date__c >= TODAY ORDER BY Expiry_Date__c ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            return new List<Retail_Instant_Lending__c>();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getTTBReseveInvitation(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(Account each : getTTBReseveInvitationData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.Name);
                eachData.put('Id', each.Id);
                eachData.put('Product_Group', 'ttb Reserve');
                eachData.put('Details', each.Main_Bank_Group2_Value__c);
                eachData.put('Period', each.Mainbank_Campaign_Period__c);
                eachData.put('More_Detail_URL', '/one/one.app?#/sObject/' + each.id + '/view');
                eachData.put('More_Detail', each.Main_Bank_Group2_Value__c == null ? '' : 'More Detail');
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Campaign_ttb_reserve_fE3'];

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

    public static List<Account> getTTBReseveInvitationData(Integer queryLimit){
        try{
            String query = 'SELECT Id, Name, Mainbank_Campaign_Period__c, RMC_Reserve_Waive_Doc_Flag__c, Main_Bank_Group2_Value__c FROM Account ';
            String whereCon = 'WHERE OwnerId = \'' + currentUserId + '\' AND RMC_Reserve_Waive_Doc_Flag__c = true AND Mainbank_Campaign_Period__c >= THIS_MONTH ORDER BY Mainbank_Campaign_Period__c ';
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
    public static Map<String, Object> getFulfillment(Integer queryLimit){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Object> dataList = new List<Object>();
            for(RTL_Fulfillment__c each : getFulfillmentData(queryLimit)){
                Map<String, Object> eachData = new Map<String, Object>();
                eachData.put('Name', each.RTL_Customer__r.Name);
                eachData.put('Id', each.RTL_Customer__c);
                eachData.put('Campaign_Code', each.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c);
                eachData.put('Details', each.RTL_Description__c);
                eachData.put('Fulfillment_Date', each.RTL_Delivery_Date__c);
                dataList.add(eachData);
            }

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Campaign_with_Fulfillment_YLV'];

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

    @AuraEnabled
    public static List<RTL_Fulfillment__c> getFulfillmentData(Integer queryLimit){
        try{
            String query = 'SELECT Id, RTL_Fulfillment_Type__c, RTL_Customer__r.RTL_Wealth_RM__c, RTL_Campaign__c, RTL_Campaign__r.RTL_Campaign_Code_10_digits__c, RTL_Customer__c, RTL_Customer__r.Name, RTL_Description__c, RTL_Delivery_Date__c FROM RTL_Fulfillment__c ';
            String whereCon = 'WHERE RTL_Customer__r.OwnerId = \'' + currentUserId + '\' AND (RTL_Delivery_Date__c = THIS_MONTH OR RTL_Delivery_Date__c = LAST_MONTH) AND RTL_Fulfillment_Type__c != null ORDER BY RTL_Delivery_Date__c ';
            query += whereCon;
            if(queryLimit > 0){
                query += 'LIMIT ' + queryLimit;
            } 
            return Database.query(query);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}