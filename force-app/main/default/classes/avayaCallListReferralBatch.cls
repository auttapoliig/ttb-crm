global class avayaCallListReferralBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    String query;

    private List<RTL_Referral__c> updateReferralList;
    private Set<Id> queryReferralIdset;
    private Map<String, RTL_Online_Service_Log__c> mapWebUnioslog;
    private Map<String, OnlineServiceLog> mapWebUnioslogDetail;
    private BusinessHours bh;

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

    public avayaCallListReferralBatch(Set<Id> referralIdSet) {
        mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
        updateReferralList = new List<RTL_Referral__c>();

        bh = [SELECT Id FROM BusinessHours WHERE Name = 'Call Me Now'];

        queryReferralIdset = referralIdSet;

        query = 'SELECT Id, Name, RTL_FirstName__c, Assigned_Pool__c, RTL_LastName__c, RTL_RecordType_Name__c, RTL_Product_Name_Str__c, FNA_Product_Name__c, RTL_Interested_Product__c, RTL_Sub_Product__c, RTL_Mobile1__c, RTL_Channel_Segment__c, RTL_Campaign__c, RTL_Call_Me_Now_Request_Count__c, web_business01__c, web_business02__c, web_business03__c, web_business04__c, web_business05__c, web_business06__c, web_business07__c, web_business08__c, web_business09__c, web_business10__c, RTL_Remark_from_Online_Loan__c, RTL_Campaign_Reference__c FROM RTL_Referral__c WHERE Id IN :queryReferralIdset';
    }

    public avayaCallListReferralBatch(String queryStr, Set<Id> referralIdSet) {
        mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
        updateReferralList = new List<RTL_Referral__c>();

        bh = [SELECT Id FROM BusinessHours WHERE Name = 'Call Me Now'];

        query = queryStr;
        queryReferralIdset = referralIdSet;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Datetime dateTimeNow = Datetime.now();
        
        for(sObject obj : scope){
            RTL_Referral__c referral = (RTL_Referral__c)obj;
            
            // if(!BusinessHours.isWithin(bh.Id, dateTimeNow) && referral.RTL_RecordType_Name__c != 'Refer from Digital Channel'){
            //     referral.RTL_Call_Me_Now_Status__c = 'fail';
            //     referral.RTL_From_Call_Me_Now__c = true;
            // }else{
                avayaCallistDTO callMeNowObj = new avayaCallistDTO();

                DateTime now = System.now();
                String rtlDateTime = '';
                String strDateTime = '';
                String interestedProduct = '';
                String referralRecordTypeName = referral.RTL_RecordType_Name__c;

                //CR Refer from branch to any channel
                if (referralRecordtypeName == 'Retail Cross Channel Referral') {
                    interestedProduct = referral.RTL_Product_Name_Str__c;
                }else if(referralRecordtypeName == 'Refer from Digital Channel'){
                    interestedProduct = referral.FNA_Product_Name__c;
                    if(referral.Assigned_Pool__c == 'OUTBOUND'){
                        rtlDateTime = checkBusinessHour('Retail Outbound', Datetime.now());
                    }else{
                        rtlDateTime = checkBusinessHour('Call Me Now', Datetime.now());
                    }
                }else{
                    interestedProduct = referral.RTL_Interested_Product__c;
                }
               
                if(rtlDateTime != '' && rtlDateTime != null){
                    strDateTime = rtlDateTime;
                }else if (referralRecordTypeName == 'Retail Cross Channel Referral') {
                    strDateTime = RTL_ReferralAssignUtility.getNextnBSDate().addHours(7).formatGMT('dd/MM/yyyy HH:mm:ss');
                }else if(referral.RTL_Campaign_Reference__c == 'Call Me Now'){
                    strDateTime = System.now().addHours(7).formatGMT('dd/MM/yyyy HH:mm:ss');
                }else{
                    strDateTime = '';
                }
                
                AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
                String sfdcBaseLightningURL = lightCF == null ? 'https://tmbbank--uat.lightning.force.com' : lightCF.Value__c;

                callMeNowObj.request.setRequestId(referral.Id);
                callMeNowObj.request.setFirstName(referral.RTL_FirstName__c == null || referral.RTL_FirstName__c == '' ? '-' : referral.RTL_FirstName__c);
                callMeNowObj.request.setLastName(referral.RTL_LastName__c);
                callMeNowObj.request.setProductName(interestedProduct);
                callMeNowObj.request.setSub_ProductName(referral.RTL_Sub_Product__c);
                callMeNowObj.request.setMobile(referral.RTL_Mobile1__c);
                callMeNowObj.request.setCampaign(referral.RTL_Campaign__c);
                callMeNowObj.request.setDial_time(strDateTime);//'dd/MM/yyyy HH:mm:ss';
                callMeNowObj.request.setChannel_name(referral.RTL_Channel_Segment__c);
                callMeNowObj.request.setSf_id(referral.Id);
                
                callMeNowObj.request.setBusiness1(referral.web_business01__c);
                callMeNowObj.request.setBusiness2(referral.web_business02__c);
                callMeNowObj.request.setBusiness3(referral.web_business03__c);
                callMeNowObj.request.setBusiness4(referral.web_business04__c);
                callMeNowObj.request.setBusiness5(referral.web_business05__c);
                callMeNowObj.request.setBusiness6(referral.web_business06__c);
                callMeNowObj.request.setBusiness7(referral.web_business07__c);
                callMeNowObj.request.setBusiness8(referral.web_business08__c);
                callMeNowObj.request.setBusiness9(referral.web_business09__c);
                callMeNowObj.request.setBusiness10(referral.web_business10__c);
        
                callMeNowObj.request.setRemark(referral.RTL_Remark_from_Online_Loan__c);
                callMeNowObj.request.setURL(sfdcBaseLightningURL + '/lightning/r/RTL_Referral__c/' + referral.Id + '/view');

                System.debug(callMeNowObj.generateJSONContent());

                OnlineServiceLog oslogDetail = CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');

                System.debug(oslogDetail);
                
                referral.Call_Me_Now_Interested_Product__c = callMeNowObj.request.getTruncateProductName();
                referral.Call_Me_Now_Datetime__c = callMeNowObj.request.getDial_time();
                referral.Call_Me_Now_URL__c = callMeNowObj.request.getTruncateURL();

                referral.RTL_Call_Me_Now_Request__c = callMeNowObj.generateJSONContent();
                referral.RTL_Call_Me_Now_Response__c = callMeNowObj.response.rawResponse;
                referral.RTL_From_Call_Me_Now__c = true;
                referral.RTL_Call_Me_Now_Status__c = 'success';
                
                if(!oslogDetail.isSuccess){
                    referral.RTL_Call_Me_Now_Status__c = 'fail';

                    System.debug('Call Me Now Retry Count -->' + referral.RTL_Call_Me_Now_Request_Count__c);

                    referral.RTL_Call_Me_Now_Request_Count__c = referral.RTL_Call_Me_Now_Request_Count__c == null ? 0 : referral.RTL_Call_Me_Now_Request_Count__c;
                    referral.RTL_Call_Me_Now_Request_Count__c += 1;

                    if(referral.RTL_Call_Me_Now_Request_Count__c >= 3){
                        referral.RTL_Call_Me_Now_Status__c = 'fail';
                    }
                }

                RTL_Online_Service_Log__c oslog = new RTL_Online_Service_Log__c();
                oslog.RTL_Customer_Name__c = referral.Id;
                oslog.RTL_Name_of_User__c = currentUser.Name;
                oslog.RTL_RM_ID__c = currentUser.Employee_ID__c;
                
                if (mapNamedCredentiallURL.get('WsCallMeNow_Avaya') != null) {
                    oslog.RTL_Service_Name__c = mapNamedCredentiallURL.get('WsCallMeNow_Avaya').Endpoint;
                }
                oslog.RTL_Is_Success__c = oslogDetail.isSuccess;
                oslog.RTL_Start_DateTime__c = oslogDetail.startTime;
                oslog.RTL_End_DateTime__c = oslogDetail.endTime;
                
                if(oslogDetail.isSuccess){
                    osLog.Remark__c = oslogDetail.errorMesssage;
                }else{
                    oslog.RTL_Error_Message__c = oslogDetail.errorMesssage;
                }

                String key = referral.Id + '_' + referral.RTL_Call_Me_Now_Request_Count__c;

                mapWebUnioslog.put(key, oslog);
                mapWebUnioslogDetail.put(key, oslogDetail);
            // }

            updateReferralList.add(referral);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug(':::: avayaCallListReferralBatch finish ::::');

        if(mapWebUnioslog.size() > 0){
            RTL_CampaignUtil.insertOnlineServiceLogMultiWithAttach(mapWebUnioslog, mapWebUnioslogDetail);
        }

        System.debug('updateReferralList : ' + updateReferralList);
        if(updateReferralList.size() > 0){
            update updateReferralList;
        }
    }

    private static String checkBusinessHour (String businessName, Datetime targetTime){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name =: businessName];
        String nextStart = BusinessHours.nextStartDate(bh.id, targetTime).addHours(7).formatGMT('dd/MM/yyyy HH:mm:ss');
        return nextStart;
    }
}