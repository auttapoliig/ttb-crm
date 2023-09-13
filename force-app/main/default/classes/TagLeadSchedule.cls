global without sharing class TagLeadSchedule implements Schedulable {
    public TagLeadSchedule() {

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
        Set<String> uniqueLeadId = new Set<String>();
        
        System.debug('Datetime.now() --> ' + Datetime.now());

        // 1. Find marketing code with end call in last 15 mins
        List<Task> listTask1 = [SELECT Id, Call_Log_ID__c, Related_Object__c FROM Task 
                                WHERE Call_End_Time__c != null and Call_Log_ID__c != null  AND RecordType.Name = 'Call Log Record Type' 
                                and LastModifiedDate > :Datetime.now().addMinutes(lastTime) and Related_Object__c != null and Related_Object__c LIKE '00Q%' and RTL_Channel__c like 'Outbound%'];
                                  
        // List<String> idList = new List<String>();
        if(listTask1.size() > 0){
            for(Task t : listTask1){
                
                // uniqueCallLogId.add(t.Call_Log_ID__c);
                uniqueLeadId.add(t.Related_Object__c);
            }
            // System.debug('Lead 1 :: uniqueCallLogId-->' + uniqueCallLogId);
            System.debug('Lead 1 :: uniqueLeadId-->' + uniqueLeadId);
        }

        List<Lead> LeadList = [SELECT Id, Status, RTL_Uncontact_reason__c, COM_Complete_Code__c, COM_Expected_Complete_Date__c, COM_Expected_Submit_Date__c,Interest_result__c, Other_Reason__c,Account__c,RecordTypeId,
        (SELECT Id, Name, Opportunity_Type__c, COM_Offer_Result__c, COM_Unqualified_Reason__c, COM_Sub_Unqualified_Reason__c, Amount__c, Cross_Sell__c, Opportunity__c, Opportunity__r.Name, Related_Account__c FROM Product_Interest__r) 
        FROM Lead 
        WHERE LastModifiedDate > :Datetime.now().addMinutes(lastTime)
        ORDER BY CreatedDate ASC];

        Set<String> LeadId = new Set<String>();
        if(!LeadList.isEmpty()){
            for(Lead l : LeadList){
                LeadId.add(l.Id);
            }
            System.debug('Selected Lead for last modify from ' + Datetime.now().addMinutes(lastTime) + '-->' + LeadId);
        }


        List<Task> listTask2 = [SELECT Id, Call_Log_ID__c, Related_Object__c, LastModifiedDate FROM Task WHERE Related_Object__c in :LeadId and Call_End_Time__c != null and RTL_Channel__c like 'Outbound%' AND RecordType.Name = 'Call Log Record Type' ];
        if(!LeadId.isEmpty()){
            for(Task t : listTask2){
                uniqueLeadId.add(t.Related_Object__c);
            }

            System.debug('Case 2 :: uniqueLeadId-->' + uniqueLeadId);
        }

        if (!uniqueLeadId.isEmpty()) {
            System.debug('uniqueLeadId-->' + uniqueLeadId);
            String idString = '(\''+String.join(new List<String>(uniqueLeadId), '\',\'')+'\')';
            //Within last 30 minutes - Batch runs every 15 minutes
            List<String> listLeadrecordtype = new List<String>{'Commercial Completed','Commercial Account', 'Commercial Lead'};
            String query = 'SELECT Id, Status,' +
                            '(SELECT Id, Name, COM_Offer_Result__c, COM_Unqualified_Reason__c, Product__r.Name FROM Product_Interest__r WHERE Cross_Sell__c = FALSE ORDER BY CREATEDDATE ASC)' +
                            'FROM Lead ' +
                            'WHERE Id IN ' + idString +
                            'AND Recordtype.Name IN: listLeadrecordtype ' +
                            ' ORDER BY CreatedDate ASC';

            System.debug('query-->' + query);
    
            // TagBODBatch tbb = new TagBODBatch(query);
            // Database.executeBatch(tbb);

            List<Lead> listLead = Database.query(query);
            //List<Case> inputlist = new List<Case>();
            System.debug('ALL size ' + listLead.size());
            
            Decimal roundPerSize = listLead.size() < 100 ? 1 : Decimal.valueOf(listLead.size()).divide(100, 2);
            Integer num = Integer.valueOf(roundPerSize);
            if(roundPerSize/num != 1){
                num++;
            }
            system.debug('Size/100 = '+ roundPerSize);
            system.debug('Round = ' + num);
         
            for(Integer i = 0 ; i<num ; i++){
                List<Lead> inputlist = new List<Lead>();

                Integer limitSize = 100;
                if(listLead.size() < 100){
                    limitSize = listLead.size();
                }
                System.debug('listLead size :' + limitSize);
                    for(Integer j = 0 ; j < limitSize ; j++){
                        System.debug(j + 'listLead ' + listLead[j]);
                        inputlist.add(listLead[j]);
                }
                System.debug('end');
                
                    for(Integer j = limitSize-1 ; j >= 0 ; j--){
                        System.debug(j + 'listLead ');
                        listLead.remove(j);
                }         
    
                TagLeadBatch tlb = new TagLeadBatch(inputlist);
                Database.executeBatch(tlb);
            }
        } 
    }
}