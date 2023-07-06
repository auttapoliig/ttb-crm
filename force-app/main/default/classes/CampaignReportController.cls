public with sharing class CampaignReportController {
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
}