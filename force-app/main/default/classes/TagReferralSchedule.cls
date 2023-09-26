global without sharing class TagReferralSchedule implements Schedulable {
    public TagReferralSchedule() {

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
        Set<String> uniqueRefId = new Set<String>();
        
        System.debug('Datetime.now() --> ' + Datetime.now());

        // 1. Find marketing code with end call in last 15 mins
        List<Task> listTask1 = [SELECT Id, Call_Log_ID__c, Related_Object__c FROM Task 
                                WHERE Call_End_Time__c != null and Call_Log_ID__c != null  AND RecordType.Name = 'Call Log Record Type' 
                                and LastModifiedDate > :Datetime.now().addMinutes(lastTime) and Related_Object__c != null and Related_Object__c LIKE 'a2S%' and RTL_Channel__c like 'Outbound%'];
                                  
        // List<String> idList = new List<String>();
        if(listTask1.size() > 0){
            for(Task t : listTask1){
                
                // uniqueCallLogId.add(t.Call_Log_ID__c);
                uniqueRefId.add(t.Related_Object__c);
            }
            // System.debug('Referral 1 :: uniqueCallLogId-->' + uniqueCallLogId);
            System.debug('Referral 1 :: uniqueRefId-->' + uniqueRefId);
        }

        List<RTL_Referral__c> RefList = [SELECT Id, RTL_Interested_Product__c, RTL_Stage__c, RTL_Reason__c 
        FROM RTL_Referral__c 
        WHERE LastModifiedDate > :Datetime.now().addMinutes(lastTime)
        ORDER BY CreatedDate ASC];

        Set<String> RefId = new Set<String>();
        if(!RefList.isEmpty()){
            for(RTL_Referral__c ref : RefList){
                RefId.add(ref.Id);
            }
            System.debug('Selected Ref for last modify from ' + Datetime.now().addMinutes(lastTime) + '-->' + RefId);
        }


        List<Task> listTask2 = [SELECT Id, Call_Log_ID__c, Related_Object__c, LastModifiedDate FROM Task WHERE Related_Object__c in :RefId and Call_End_Time__c != null and RTL_Channel__c like 'Outbound%' AND RecordType.Name = 'Call Log Record Type' ];
        if(!RefId.isEmpty()){
            for(Task t : listTask2){
                uniqueRefId.add(t.Related_Object__c);
            }

            System.debug('Case 2 :: uniqueRefId-->' + uniqueRefId);
        }

        if (!uniqueRefId.isEmpty()) {
            System.debug('uniqueRefId-->' + uniqueRefId);
            String idString = '(\''+String.join(new List<String>(uniqueRefId), '\',\'')+'\')';
            //Within last 30 minutes - Batch runs every 15 minutes
            
            String query = 'SELECT Id, RTL_Interested_Product__c, RTL_Stage__c, RTL_Reason__c ' +                     
                            'FROM RTL_Referral__c ' +
                            'WHERE Id IN ' + idString +
                            // 'AND Recordtype.Name = \'Commercial Lead\'' +
                            ' ORDER BY CreatedDate ASC';

            System.debug('query-->' + query);
    
            // TagBODBatch tbb = new TagBODBatch(query);
            // Database.executeBatch(tbb);

            List<RTL_Referral__c> listRef = Database.query(query);
            //List<Case> inputlist = new List<Case>();
            System.debug('ALL size ' + listRef.size());
            
            Decimal roundPerSize = listRef.size() < 100 ? 1 : Decimal.valueOf(listRef.size()).divide(100, 2);
            Integer num = Integer.valueOf(roundPerSize);
            if(roundPerSize/num != 1){
                num++;
            }
            system.debug('Size/100 = '+ roundPerSize);
            system.debug('Round = ' + num);
         
            for(Integer i = 0 ; i<num ; i++){
                List<RTL_Referral__c> inputlist = new List<RTL_Referral__c>();

                Integer limitSize = 100;
                if(listRef.size() < 100){
                    limitSize = listRef.size();
                }
                System.debug('listRef size :' + limitSize);
                    for(Integer j = 0 ; j < limitSize ; j++){
                        System.debug(j + 'listRef ' + listRef[j]);
                        inputlist.add(listRef[j]);
                }
                System.debug('end');
                
                    for(Integer j = limitSize-1 ; j >= 0 ; j--){
                        System.debug(j + 'listRef ');
                        listRef.remove(j);
                }         
    
                TagReferralBatch tlb = new TagReferralBatch(inputlist);
                Database.executeBatch(tlb);
            }
        } 
    }
}