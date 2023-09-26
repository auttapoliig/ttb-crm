global class avayaCallListLeadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    String query;

    private List<Lead> updateleadlst;
    private Set<Id> queryLeadIdlst;
    private Map<String, RTL_Online_Service_Log__c> mapWebUnioslog;
    private Map<String, OnlineServiceLog> mapWebUnioslogDetail;
    private Lead obj = null;

    private static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Employee_ID__c FROM User WHERE Id = :System.UserInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    private static Map<String, NamedCredential> mapNamedCredentiallURL {
        get{
            if(mapNamedCredentiallURL == null){
                mapNamedCredentiallURL = new Map<String, NamedCredential>();
                for(NamedCredential namedCre : [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName LIKE 'WsCallMeNow%']){
                    mapNamedCredentiallURL.put(namedCre.DeveloperName, namedCre);
                }
            }
            System.debug('mapNamedCredentiallURL : ' + mapNamedCredentiallURL);
            return mapNamedCredentiallURL;
        }
        set;
    }

    private static Map<String, RTL_Lead_Assignment_Rule__c> mapLeadAssignmentRules {
        get{
            if(mapLeadAssignmentRules == null){
                mapLeadAssignmentRules = new Map<String, RTL_Lead_Assignment_Rule__c>();
                for(RTL_Lead_Assignment_Rule__c rule : [select id, RTL_Integration_Type__c from RTL_Lead_Assignment_Rule__c]){
                    mapLeadAssignmentRules.put(rule.Id, rule);
                }
            }
            System.debug('mapLeadAssignmentRules : ' + mapLeadAssignmentRules);
            return mapLeadAssignmentRules;
        }
        set;
    }

    private static Integer SLATime{
        get{
            if(SLATime == null ){
                Integer slaT;
                AppConfig__c cf = AppConfig__c.getValues('SLATime');
                slaT = (cf == null ? 1 : (cf.Value__c == null ? 1 : integer.valueof(cf.Value__c)));

                SLATime = slaT;
                
            }
            return SLATime;

        }set;
    }

    private static BusinessHours callMeNowBusinessHours{
        get{
            if(callMeNowBusinessHours == null ){
                String bhName;
                AppConfig__c cf = AppConfig__c.getValues('RetailOutboundBH');
                bhName = (cf == null ? 'Retail Outbound' : cf.Value__c);
                List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours WHERE Name =: bhName];
                if(businessHours.size() > 0){
                    callMeNowBusinessHours = businessHours[0];
                }
                
            }
            return callMeNowBusinessHours;

        }set;
    }

	global avayaCallListLeadBatch(Set<Id> leadIdlst) {
        System.debug(':::: avayaCallListLeadBatch ::::');
        updateleadlst = new List<Lead>();
        mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
         
        queryLeadIdlst = leadIdlst;
        
        query = 'SELECT Id, LeadId, Lead.Name, Lead.FirstName, Lead.LastName, Lead.RTL_Product_Name__c, Lead.RTL_Mobile_Number__c, Lead.RTL_Lead_Campaign_Outbound__c, Lead.RTL_Lead_Channel_Outbound__c, Lead.RTL_Call_Back_Date_time__c, Lead.RTL_Lead_Assigned_By_Rule__c, Lead.RTL_Web_Unique_ID_c__c, Lead.RTL_Call_Me_Now_Status__c, Lead.RTL_Call_Me_Now_Retry_Count__c, Lead.web_business01__c, Lead.web_business02__c, Lead.web_business03__c, Lead.web_business04__c, Lead.web_business05__c, Lead.web_business06__c, Lead.web_business07__c, Lead.web_business08__c, Lead.web_business09__c, Lead.web_business10__c ,Lead.RTL_Contact_Method__c, Lead.RTL_Remark__c FROM CampaignMember WHERE LeadId IN :queryLeadIdlst';
    }

	global avayaCallListLeadBatch(String q, Set<Id> leadIdlst) {
        System.debug(':::: avayaCallListLeadBatch ::::');
        updateleadlst = new List<Lead>();
        mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
         
        queryLeadIdlst = leadIdlst;
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::: avayaCallListLeadBatch start ::::');
        System.debug('Query :::: '+query);
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        System.debug(':::: avayaCallListLeadBatch execute ::::');
        //for(Lead obj : scope){
        for(CampaignMember cm : scope){
            AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
            String strDateTime = cm.lead.RTL_Call_Back_Date_time__c != null ? cm.lead.RTL_Call_Back_Date_time__c.format('dd/MM/yyyy HH:mm:ss') : cm.lead.RTL_Contact_Method__c == 'Call Me Now' ? System.now().format('dd/MM/yyyy HH:mm:ss') : null; //FOR AYAVA Service will Send Blank instade

            AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
            String sfdcBaseLightningURL = lightCF == null ? 'https://tmbbank--uat.lightning.force.com' : lightCF.Value__c;
            
            // AL Enhancement
            Blob cmUrl = Blob.valueOf('{"componentDef":"c:CampaignMember_Main","attributes":{"recordId":"' + cm.Id + '","mode":"Edit"},"state":{}}');
            String encUrl = EncodingUtil.base64Encode(cmUrl);
            String CMNURL = sfdcBaseLightningURL + '/one/one.app#' + encUrl;

            callMeNowObj.request.setRequestId(cm.lead.RTL_Web_Unique_ID_c__c);
            callMeNowObj.request.setFirstName(cm.lead.FirstName);
            callMeNowObj.request.setLastName(cm.lead.LastName);
            callMeNowObj.request.setProductName(cm.lead.RTL_Product_Name__c);
            callMeNowObj.request.setSub_ProductName('');
            callMeNowObj.request.setMobile(cm.lead.RTL_Mobile_Number__c);
            callMeNowObj.request.setCampaign(cm.lead.RTL_Lead_Campaign_Outbound__c);
            callMeNowObj.request.setDial_time(strDateTime);
            callMeNowObj.request.setChannel_name(cm.lead.RTL_Lead_Channel_Outbound__c);
            callMeNowObj.request.setSf_id(cm.Id);

            callMeNowObj.request.setBusiness1(cm.lead.web_business01__c);
            callMeNowObj.request.setBusiness2(cm.lead.web_business02__c);
            callMeNowObj.request.setBusiness3(cm.lead.web_business03__c);
            callMeNowObj.request.setBusiness4(cm.lead.web_business04__c);
            callMeNowObj.request.setBusiness5(cm.lead.web_business05__c);
            callMeNowObj.request.setBusiness6(cm.lead.web_business06__c);
            callMeNowObj.request.setBusiness7(cm.lead.web_business07__c);
            callMeNowObj.request.setBusiness8(cm.lead.web_business08__c);
            callMeNowObj.request.setBusiness9(cm.lead.web_business09__c);
            callMeNowObj.request.setBusiness10(cm.lead.web_business10__c);

            callMeNowObj.request.setRemark(cm.lead.RTL_Remark__c);
            callMeNowObj.request.setURL(CMNURL);
            
            System.debug('callMeNowObj : ' + callMeNowObj);

            RTL_Lead_Assignment_Rule__c leadAssignmentRule = mapLeadAssignmentRules.get(cm.lead.RTL_Lead_Assigned_By_Rule__c);
            OnlineServiceLog oslogDetail = CallMeNowService.addToAvayaCallist(callMeNowObj, leadAssignmentRule.RTL_Integration_Type__c);

            System.debug('callMeNowObj : ' + callMeNowObj);

            // AL Enhancement
            obj = new Lead();
            obj.Id = cm.leadId;
            obj.RTL_Call_Me_Now_Status__c = 'success';
            obj.Call_Me_Now_Dial_time__c = strDateTime;
            obj.Call_Me_Now_SF_rec_Id__c = cm.Id;
            obj.Call_Me_Now_URL__c = CMNURL;
            
            if(!oslogDetail.isSuccess){
                obj.RTL_Call_Me_Now_Status__c = '';
                obj.RTL_Call_Me_Now_Retry_Count__c = cm.Lead.RTL_Call_Me_Now_Retry_Count__c == null ? 0 : cm.Lead.RTL_Call_Me_Now_Retry_Count__c;
                System.debug('Call Me Now Retry Count -->' + obj.RTL_Call_Me_Now_Retry_Count__c);
               
                obj.RTL_Call_Me_Now_Retry_Count__c += 1;
                if(obj.RTL_Call_Me_Now_Retry_Count__c >= 3){
                    obj.RTL_Call_Me_Now_Status__c = 'fail';
                }
            }
            updateleadlst.add(obj);

            RTL_Online_Service_Log__c oslog = new RTL_Online_Service_Log__c();
            oslog.RTL_Customer_Name__c = obj.RTL_Web_Unique_ID_c__c;
            oslog.RTL_Name_of_User__c = currentUser.Name;
            oslog.RTL_RM_ID__c = currentUser.Employee_ID__c;

            if (mapNamedCredentiallURL.get('WsCallMeNow_' + leadAssignmentRule.RTL_Integration_Type__c) != null) {
                oslog.RTL_Service_Name__c = mapNamedCredentiallURL.get('WsCallMeNow_' + leadAssignmentRule.RTL_Integration_Type__c).Endpoint;
            }

            oslog.RTL_Is_Success__c = oslogDetail.isSuccess;
            oslog.RTL_Start_DateTime__c = oslogDetail.startTime;
            oslog.RTL_End_DateTime__c = oslogDetail.endTime;
            
            if(oslogDetail.isSuccess){
                osLog.Remark__c = oslogDetail.errorMesssage;
            }else{
                oslog.RTL_Error_Message__c = oslogDetail.errorMesssage;
            }

            System.debug('oslog::' + oslogDetail);

            String key = cm.Lead.RTL_Web_Unique_ID_c__c + cm.Lead.RTL_Call_Me_Now_Retry_Count__c;

            mapWebUnioslog.put(key, oslog);
            mapWebUnioslogDetail.put(key, oslogDetail);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(':::: avayaCallListLeadBatch finish ::::');
        System.debug(mapWebUnioslog);
        if(mapWebUnioslog.size() > 0){
            RTL_CampaignUtil.insertOnlineServiceLogMultiWithAttach(mapWebUnioslog, mapWebUnioslogDetail);
        }
        System.debug('updateleadlst : ' + updateleadlst);
		if(updateleadlst.size() > 0){
			update updateleadlst;
		}
    }

    public static Datetime getNextnBSDate(){
        Datetime now;
        Date nowDate = System.now().adddays(SLATime).date();
        
        now = SLATime == 0 ? System.now() :  Datetime.newInstance(nowDate.year(), nowDate.month(), nowDate.day(), 1, 0, 0);

        Datetime nextStart = BusinessHours.nextStartDate(callMeNowBusinessHours.id, now);
        return nextStart;
    }
}