global without sharing class TagBODSchedule implements Schedulable {
    public TagBODSchedule() {

    }
    public static Integer CALL_LASTTIME{
        get{
            Integer DEFAULT_LASTTIME = -10;
            if(CALL_LASTTIME == null){
                try{
                    CALL_LASTTIME = DEFAULT_LASTTIME;
                    List<App_Config__mdt> scheduleRuntime = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'TagBatch_Schedule_Runtime'];           
                        if (scheduleRuntime != null && scheduleRuntime.size() > 0) {
                            CALL_LASTTIME = -Integer.valueOf(scheduleRuntime.get(0).Value__c);
                        }           
                        
                    }catch( Exception e ){
                        CALL_LASTTIME = DEFAULT_LASTTIME;
                    }
            }
            return CALL_LASTTIME;
            
        }set;
    }
    //Schedulable Execute
    global void execute(SchedulableContext SC){

        /* Fixed for create case between call and create case after call */
        Integer lastTime = CALL_LASTTIME;
        // Set<String> uniqueCallLogId = new Set<String>();
        Set<String> uniqueMarketingCodeId = new Set<String>();
        
        System.debug('Datetime.now() --> ' + Datetime.now());

        // 1. Find marketing code with end call in last 15 mins
        List<Task> listTask1 = [SELECT Id, Call_Log_ID__c, Related_Object__c FROM Task 
                                WHERE Call_End_Time__c != null and Call_Log_ID__c != null AND RecordType.Name = 'Call Log Record Type' 
                                and LastModifiedDate > :Datetime.now().addMinutes(lastTime) and Related_Object__c != null and (NOT Related_Object__c LIKE '00Q%') and RTL_Channel__c like 'Outbound%'];
                                  
        // List<String> idList = new List<String>();
        if(listTask1.size() > 0){
            for(Task t : listTask1){
                
                // uniqueCallLogId.add(t.Call_Log_ID__c);
                uniqueMarketingCodeId.add(t.Related_Object__c);
            }
            // System.debug('Campaign member 1 :: uniqueCallLogId-->' + uniqueCallLogId);
            System.debug('Campaign member 1 :: uniqueMarketingCodeId-->' + uniqueMarketingCodeId);
        }

        // Find campaing member with last modified in last 15 mins 
        List<CampaignMember> campaignMemberList = [SELECT Id, RTL_Web_Unique_ID__c, RTL_Marketing_Code__c,RTL_Campaign_Product_1__r.Name, RTL_OfferResult_Product_1__c, Not_Interest_Reason1__c,
        RTL_Campaign_Product_2__r.Name, RTL_OfferResult_Product_2__c, Not_Interest_Reason2__c,RTL_Campaign_Product_3__r.Name, RTL_OfferResult_Product_3__c, Not_Interest_Reason3__c,
        RTL_Campaign_Product_4__r.Name, RTL_OfferResult_Product_4__c, Not_Interest_Reason4__c
        FROM CampaignMember 
        WHERE LastModifiedDate > :Datetime.now().addMinutes(lastTime)
        ORDER BY CreatedDate ASC];

        Set<String> cmList = new Set<String>();
        Map<String, String> idMarketingCodeMap = new Map<String, String>();
        if(!campaignMemberList.isEmpty()){
            for(CampaignMember cm : campaignMemberList){
                cmList.add(cm.Id);
                // Add case popup from marketing code
                if (String.isNotEmpty(cm.RTL_Marketing_Code__c)) {
                    idMarketingCodeMap.put(cm.RTL_Marketing_Code__c, cm.Id);
                    cmList.add(cm.RTL_Marketing_Code__c);
                }
            }
            System.debug('Selected campaign Member for last modify from ' + Datetime.now().addMinutes(lastTime) + '-->' + cmList);
        }

        System.debug('idMarketingCodeMap -->' + idMarketingCodeMap);

        List<Task> listTask2 = [SELECT Id, Call_Log_ID__c, Related_Object__c, LastModifiedDate FROM Task WHERE Related_Object__c in :cmList and Call_End_Time__c != null and RTL_Channel__c like 'Outbound%'  AND RecordType.Name = 'Call Log Record Type' ];
        if(!cmList.isEmpty()){
            for(Task t : listTask2){
                String relatedObject = t.Related_Object__c;
                if (relatedObject.startsWith('00v')) {
                    uniqueMarketingCodeId.add(t.Related_Object__c);
                } else {
                    uniqueMarketingCodeId.add( idMarketingCodeMap.get(relatedObject) );
                }
            }

            System.debug('CM 2 :: uniqueMarketingCodeId-->' + uniqueMarketingCodeId);
        }
        
        // Use for Call Log Id
        // if (!uniqueCallLogId.isEmpty()) {
        //     System.debug('uniqueCallLogId-->' + uniqueCallLogId);
        //     String idString = '(\''+String.join(new List<String>(uniqueCallLogId), '\',\'')+'\')';
        //     //Within last 30 minutes - Batch runs every 15 minutes
            
        //     String query = 'SELECT Id, Call_Log_ID__c, Owner_Employee_ID__c, CaseNumber, Category__c'+
        //                     ', Sub_Category__c, Product_Category__c, Issue__c, LastModifiedDate, Created_Email__c, Created_ID__c '+
        //                     'FROM Case '+
        //                     'WHERE Call_Log_ID__c IN '+idString+
        //                     ' ORDER BY CreatedDate ASC';

        //     System.debug('query-->' + query);
    
        //     TagBODBatch tbb = new TagBODBatch(query);
        //     Database.executeBatch(tbb);
        // } 

        // Find campaign member with marketing code
        if (!uniqueMarketingCodeId.isEmpty()) {
            System.debug('uniqueMarketingCodeId-->' + uniqueMarketingCodeId);

            // Convert marketing Code to Id
            Set<String> newUniqueMarketingCodeId = new Set<String>();
            List<String> marketingCodeList = new List<String>();
            for (String text : uniqueMarketingCodeId) {
                if (text.startsWith('00v')) {
                    newUniqueMarketingCodeId.add(text);
                } else {
                    marketingCodeList.add(text);
                }
            }
            System.debug('marketingCodeList-->' + marketingCodeList);

            // Get id from marketing code
            for (Campaignmember cmConvertList : [select id from campaignmember where RTL_Marketing_Code__c in :marketingCodeList]) {
                newUniqueMarketingCodeId.add(cmConvertList.Id);
            }
            System.debug('newUniqueMarketingCodeId-->' + newUniqueMarketingCodeId);
            String idString = '(\''+String.join(new List<String>(newUniqueMarketingCodeId), '\',\'')+'\')';
            //Within last 30 minutes - Batch runs every 15 minutes
            
            String query = 'SELECT Id, RTL_Web_Unique_ID__c, RTL_Marketing_Code__c, ' +
                            'RTL_Campaign_Product_1__r.Name, RTL_OfferResult_Product_1__c, Not_Interest_Reason1__c, ' +
                            'RTL_Campaign_Product_2__r.Name, RTL_OfferResult_Product_2__c, Not_Interest_Reason2__c, ' +
                            'RTL_Campaign_Product_3__r.Name, RTL_OfferResult_Product_3__c, Not_Interest_Reason3__c, ' +
                            'RTL_Campaign_Product_4__r.Name, RTL_OfferResult_Product_4__c, Not_Interest_Reason4__c ' +
                            'FROM CampaignMember ' +
                            'WHERE Id IN ' + idString +
                            ' ORDER BY CreatedDate ASC';

            System.debug('query-->' + query);
    
            // TagBODBatch tbb = new TagBODBatch(query);
            // Database.executeBatch(tbb);

            List<CampaignMember> listcm = Database.query(query);
            //List<Case> inputlist = new List<Case>();
            System.debug('ALL size ' + listcm.size());
            
            Decimal roundPerSize = listcm.size() < 100 ? 1 : Decimal.valueOf(listcm.size()).divide(100, 2);
            Integer num = Integer.valueOf(roundPerSize);
            if(roundPerSize/num != 1){
                num++;
            }
            system.debug('Size/100 = '+ roundPerSize);
            system.debug('Round = ' + num);
         
            for(Integer i = 0 ; i<num ; i++){
                List<CampaignMember> inputlist = new List<CampaignMember>();

                Integer limitSize = 100;
                if(listcm.size() < 100){
                    limitSize = listcm.size();
                }
                System.debug('listcm size :' + limitSize);
                    for(Integer j = 0 ; j < limitSize ; j++){
                        System.debug(j + 'listcm ' + listcm[j]);
                        inputlist.add(listcm[j]);
                }
                System.debug('end');
                
                    for(Integer j = limitSize-1 ; j >= 0 ; j--){
                        System.debug(j + 'listcm ');
                        listcm.remove(j);
                }         
    
                TagBODBatch tbb = new TagBODBatch(inputlist);
                Database.executeBatch(tbb);
            }
        } 
    }
}