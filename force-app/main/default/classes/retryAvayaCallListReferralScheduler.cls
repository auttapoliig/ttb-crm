global class retryAvayaCallListReferralScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {

        String leadQuery = 'SELECT Id, LeadId, Lead.Name, Lead.FirstName, Lead.LastName, Lead.RTL_Product_Name__c, Lead.RTL_Mobile_Number__c, Lead.RTL_Lead_Campaign_Outbound__c, Lead.RTL_Lead_Channel_Outbound__c, Lead.RTL_Call_Back_Date_time__c, Lead.RTL_Lead_Assigned_By_Rule__c, Lead.RTL_Web_Unique_ID_c__c, Lead.RTL_Call_Me_Now_Status__c, Lead.RTL_Call_Me_Now_Retry_Count__c, Lead.web_business01__c, Lead.web_business02__c, Lead.web_business03__c, Lead.web_business04__c, Lead.web_business05__c, Lead.web_business06__c, Lead.web_business07__c, Lead.web_business08__c, Lead.web_business09__c, Lead.web_business10__c ,Lead.RTL_Contact_Method__c, Lead.RTL_Remark__c FROM CampaignMember WHERE Lead.RTL_Call_Me_Now_Status__c = \'fail\' AND Lead.RTL_Call_Me_Now_Retry_Count__c > 2 AND Lead.RTL_Call_Me_Now_Retry_Count__c < 5 AND (CreatedDate = TODAY OR CreatedDate = YESTERDAY)';
        Set<Id> leadIdset = new Set<Id>();

        String referralQuery = 'SELECT Id, Name, RTL_FirstName__c, Assigned_Pool__c, RTL_LastName__c, RTL_RecordType_Name__c, RTL_Product_Name_Str__c, FNA_Product_Name__c, RTL_Interested_Product__c, RTL_Sub_Product__c, RTL_Mobile1__c, RTL_Channel_Segment__c, RTL_Campaign__c, RTL_Call_Me_Now_Request_Count__c, web_business01__c, web_business02__c, web_business03__c, web_business04__c, web_business05__c, web_business06__c, web_business07__c, web_business08__c, web_business09__c, web_business10__c, RTL_Remark_from_Online_Loan__c FROM RTL_Referral__c WHERE OwnerId != null AND RTL_Send_To_Call_Me_Now_Flag__c = \'Avaya\' AND RTL_Call_Me_Now_Request_Count__c > 2 AND RTL_Call_Me_Now_Request_Count__c < 5 AND RTL_Call_Me_Now_Status__c = \'fail\' AND (CreatedDate = TODAY OR CreatedDate = YESTERDAY)';
        Set<Id> referralId = new Set<Id>();
        
        //EXECUTE DATA IN QUERY CONDITION 
        DataBase.executeBatch(new avayaCallListLeadBatch(leadQuery, leadIdset), 100);
        DataBase.executeBatch(new avayaCallListReferralBatch(referralQuery, referralId), 100);
    }
}