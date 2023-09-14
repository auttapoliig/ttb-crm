global without sharing class TagBODBatch implements Database.Batchable<sObject>
                                        , Database.Stateful
                                        , Database.AllowsCallouts{
    
    public String query;
    public List<CampaignMember> listcm;
    public List<CampaignMember> campaignModified = new List<CampaignMember>();
    public String auth_token = '';
    public Map<String, List<CampaignMember>> campaignOwners = new Map<String, List<CampaignMember>>();
    public Map<String, List<CampaignMember>> campaignMap = new Map<String, List<CampaignMember>>();
    public Map<String, Map<String,List<CampaignMember>>> campaignMap_bySwitchCallId = new Map<String, Map<String,List<CampaignMember>>> ();
    public Map<String,List<CampaignMember>> campaignMap_byCallId = new Map<String,List<CampaignMember>>(); 
    public Set<String> callLogIdList = new Set<String>();
    public Set<String> callLogIdChannelList = new Set<String>();
    public Set<String> marketingCodeIdList = new Set<String>();
    public Map<String,Id> mapCmIdwithMktCode = new Map<String,Id>();

    public Set<String> setmktcode = new Set<String>();

    public Map<String, Map<String,Map<String, Object>>> dasMap = new Map<String, Map<String,Map<String, Object>>> ();
    static private Map<String,String> private_dataMap = new Map<String,String>();
    private String sobjectName = 'Campaign Member';
    private String jobDailyName = 'Error_Summary_Inquiry_API_'+ Datetime.now().format('YYYYMMdd_hh:mm');
    private String CSV_BODY = '';
    private String csvHeaderStr = '';
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    public Map<String, String> marketingCodeCallLogIdMap = new Map<String, String>();
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = DateTime.now();
    global Datetime batchStartTime = DateTime.now();
    global Datetime batchEndTime = null;
    private String transGroup;

    private static List<Voice_Tagging__c> listVoiceTagging = new List<Voice_Tagging__c>();
    public static Integer countAll = 0;
    public static Integer countSuccess = 0;
    public static Integer countError = 0;
    public static Map<String, String> cmErrorMsgMap = new Map<String, String>();

    public TagBODBatch(List<CampaignMember> listcm) {
        //this.query = query;
        this.listcm = listcm;
    }

    
    //Batchable Section
    global List<CampaignMember> start(Database.BatchableContext bc){

        this.auth_token = getAuthToken();
        System.debug(this.auth_token);
        return this.listcm;
    }

    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        this.campaignModified = scope;
        System.debug(scope);
        for(CampaignMember c : scope){
            // callLogIdList.add(c.Call_Log_ID__c);

            // If RTL_Web_Unique_ID__c null send RTL_Marketing_Code__c
            // if (!String.isBlank(c.RTL_Web_Unique_ID__c)) {
            //     marketingCodeIdList.add(c.RTL_Web_Unique_ID__c);
            // } else {
            //     marketingCodeIdList.add(c.RTL_Marketing_Code__c);
            // }
            setmktcode.add(c.RTL_Marketing_Code__c);
            marketingCodeIdList.add(c.Id);
            mapCmIdwithMktCode.put(c.RTL_Marketing_Code__c,c.Id);
        }

        // List<Task> callLogTaskList = [SELECT Id, Call_Log_ID__c, Marketing_Code__c, RTL_Channel__c FROM Task WHERE Marketing_Code__c IN: marketingCodeIdList AND Call_Log_ID__c != null ORDER BY CreatedDate DESC];
        List<Task> callLogTaskList = [SELECT Id, Call_Log_ID__c, Related_Object__c, RTL_Channel__c FROM Task WHERE (Related_Object__c IN: marketingCodeIdList OR Related_Object__c IN: setmktcode) AND Related_Object__c != null AND Call_Log_ID__c != null AND RTL_Channel__c like 'Outbound%' ORDER BY LASTMODIFIEDDATE DESC];
        System.debug('callLogTaskList Size '+ callLogTaskList.size());
        for (Task t : callLogTaskList) {
            String related_obj = t.Related_Object__c;
            callLogIdChannelList.add(t.Call_Log_ID__c + ',' + t.RTL_Channel__c + ',' + t.RTL_Channel__c);
            if(!related_obj.startsWith('00v')){
                related_obj = mapCmIdwithMktCode.get(t.Related_Object__c);
            }
            if(!marketingCodeCallLogIdMap.containsKey(related_obj)){
                marketingCodeCallLogIdMap.put(related_obj, t.Call_Log_ID__c);
                callLogIdList.add(t.Call_Log_ID__c);
            }
        }

        // dasMap = dasQuery(
        //     this.auth_token,
        //     callLogIdList
        // );

        System.debug('callLogIdChannelList -> ' + callLogIdChannelList);
        dasMap = dasQuery(
            this.auth_token,
            //callLogIdChannelList
            callLogIdList
        );

        System.debug('dasMap -> ' + dasMap);
        System.debug('marketingCodeCallLogIdMap -> ' + marketingCodeCallLogIdMap);

        Map<String,Task> taskMap = new Map<String,Task>();
        List<task> taskList = [SELECT Id, Call_Log_ID__c, Call_Agent_Id__c, Agent_Extension_Number__c, Marketing_Code__c, Related_Object__c FROM Task 
        WHERE Call_Log_ID__c IN: callLogIdList AND Agent_Extension_Number__c != null AND  RTL_Channel__c like 'Outbound%' ORDER BY LASTMODIFIEDDATE DESC];
        //Map<String,String> uniqueIdwithCallAgentId = new Map<String,String>();

        for(Task task : taskList)
        {
            if(dasMap.containsKey(task.Call_Log_ID__c))
            {
                System.debug(task );
                for(String call_id: dasMap.get(task.Call_Log_ID__c).keySet())
                {
                    // if(!taskMap.containsKey(task.Call_Log_ID__c+call_id+task.Call_Agent_Id__c))
                    // {
                    //     taskMap.put(task.Call_Log_ID__c+call_id+task.Call_Agent_Id__c,task);
                    // }
                    String related_obj = task.Related_Object__c;
                    if(!related_obj.startsWith('00v')){
                        related_obj =  mapCmIdwithMktCode.get(task.Related_Object__c);
                    }
                    if(!taskMap.containsKey(task.Call_Log_ID__c+call_id+related_obj))
                    {
                        if(String.valueOf(dasMap.get(task.Call_Log_ID__c).get(call_id).get('extension')) == String.valueOf(task.Agent_Extension_Number__c))
                        {
                            taskMap.put(task.Call_Log_ID__c+call_id+related_obj,task);
                            System.debug('Put taskmap: '+call_id + ' Agentnumber :' + task.Agent_Extension_Number__c);
                        }
                        //uniqueIdwithCallAgentId.put(task.Call_Log_ID__c+call_id,task.Call_Agent_Id__c);
                    }
                }
            }
        }
        System.debug('taskMap Size-> ' + taskMap.size());
        System.debug('taskMap -> ' + taskMap);
        System.debug('dasMap Size: '+dasMap.size());
        System.debug('dasMap: '+dasMap);

        for(CampaignMember c : scope)
        {
            System.debug('CampaignMember: '+c);
       
            if (!String.isBlank(c.RTL_Marketing_Code__c)) 
            {
                if (dasMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)))
                {
                    System.debug('dasMap switchcall : '+ marketingCodeCallLogIdMap.get(c.Id)+ ' Size: ' + dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).size());
                    for(String call_id: dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).keySet())
                    {
                        if(dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).containsKey(call_id))
                        {
                            if(taskMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id))
                            {
                                System.debug('Extension: '+dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).get(call_id).get('extension'));
                                System.debug('Agent_Extension_Number__c: '+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c);

                                if(String.valueOf(dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).get(call_id).get('extension')) == String.valueOf(taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c))
                                {
                                    System.debug('Id: '+c.Id);
                                    System.debug('Related_Object__c: '+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c);
                                    String related_obj = taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c;
                                    if(!related_obj.startsWith('00v')){
                                        related_obj = mapCmIdwithMktCode.get(taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c);
                                    }
                                    if(c.Id == related_obj)
                                    {
                                        // Call_Log_ID__c + call_id + Agent_Extension_Number__c
                                        if(campaignMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c))
                                        {
                                            // if(campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).size() < 4)
                                            // {
                                            //     campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).add(c);
                                            // }
                                            campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).add(c);
                                        }
                                        else
                                        {
                                            campaignMap.put(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c, new List<CampaignMember>{c});
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } 
            else if (!String.isBlank(c.RTL_Web_Unique_ID__c)) 
            {
                System.debug(marketingCodeCallLogIdMap.get(c.Id));
                System.debug(dasMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)));
                if (dasMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)))
                {
                    for(String call_id: dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).keySet())
                    {
                        System.debug(call_id);
                        if(dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).containsKey(call_id))
                        {
                            System.debug(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id);
                            System.debug(taskMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id));
                            if(taskMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id))
                            {
                                System.debug('Extension: '+dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).get(call_id).get('extension'));
                                System.debug('Agent_Extension_Number__c: '+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c);

                                if(String.valueOf(dasMap.get(marketingCodeCallLogIdMap.get(c.Id)).get(call_id).get('extension')) == String.valueOf(taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c))
                                {
                                    System.debug('Id: '+c.Id);
                                    System.debug('Related_Object__c: '+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c);
                                    String related_obj = taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c;
                                    if(!related_obj.startsWith('00v')){
                                        related_obj = mapCmIdwithMktCode.get(taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Related_Object__c);
                                    }
                                    if(c.Id == related_obj)
                                    {
                                        // Call_Log_ID__c + call_id + Related_Object__c
                                        if(campaignMap.containsKey(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c))
                                        {
                                            // if(campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).size() < 4)
                                            // {
                                            //     campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).add(c);
                                            // }
                                            campaignMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c).add(c);
                                        }
                                        else
                                        {
                                            campaignMap.put(marketingCodeCallLogIdMap.get(c.Id)+call_id+taskMap.get(marketingCodeCallLogIdMap.get(c.Id)+call_id+c.Id).Agent_Extension_Number__c, new List<CampaignMember>{c});
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // if(caseOwners.containsKey(c.Created_Email__c)){
            //     caseOwners.get(c.Created_Email__c).add(c);
            // }
            // else{
            //     caseOwners.put(c.Created_Email__c, new List<Case>{c});
            // }
            
        }
        
        System.debug('campaignMap: '+campaignMap);
        for(String call_log_id : callLogIdList)
        {        
            if(dasMap.containsKey(call_log_id))
            {             
                if(dasMap.get(call_log_id).size() > 0 && campaignMap.size() > 0)
                {
                    System.debug('Do some callouts');
                    tagAudioData(dasMap.get(call_log_id), campaignMap, call_log_id);
                }
            }
        }     

        transGroup = batchDate.format('\'OB_\'yyyy-MM-dd\'_\'HH:ss');
        System.debug('transGroupId Date ' + transGroup);
        if(listVoiceTagging.size() > 0){
            for(Voice_Tagging__c vt : listVoiceTagging){
                vt.Transaction_Group_Id__c = transGroup;
                if(vt.Verint_Call_ID__c != null){
                    String mapkey = vt.Call_Log_ID__c + vt.Verint_Call_ID__c + vt.Extension__c;
                    //String callAgentId = uniqueIdwithCallAgentId.get(mapkey);
                    //vt.Unique_Id__c = mapkey + callAgentId;
                        if(private_dataMap.containsKey(mapkey)){
                            vt.private_data__c = private_dataMap.get(mapkey);
                        }else{
                            vt.Error_Message__c = 'Extension Not match';
                        }
                }
            }
            System.debug('listVoiceTagging Size' + listVoiceTagging.size());
            try{
                upsert listVoiceTagging Unique_Id__c;
            }catch(Exception e){
                System.debug('Insert listVoiceTagging ' + e);
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        //Send mail
        //List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        batchEndTime = DateTime.now();
        recordsSuccessful = countAll - countError;
        recordsFailed = countError;

        try {
            // Insert online log
            // if (logList != null && logList.size() > 0) {
            //     insert logList;
            // }
            System.debug('cmErrorMsgMap:'+cmErrorMsgMap);
            if(cmErrorMsgMap.size() > 0)
            {             

                csvHeaderStr = csvHeaderStr + 
                        'Switch Call Id' + ',' +
                        'Error Message';
                List<String> emailOpsList = new List<String>();
                for(String ID : cmErrorMsgMap.keySet()){
                    System.debug(ID + ' : ' + cmErrorMsgMap.get(ID));
                    
                    String errorMsg = cmErrorMsgMap.get(ID); 
                    
                    System.debug(errorMsg);           

                    CSV_BODY = CSV_BODY + 
                        ID + ',' +
                        cmErrorMsgMap.get(ID) + ',' + '\n';
                }

           
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                                , batchStartTime
                                                                , batchEndTime
                                                                , recordsSuccessful
                                                                , recordsFailed
                                                                , csvHeaderStr
                                                                , jobDailyName
                                                                , sobjectName
                                                                , emailOpsList
                                                                , CSV_BODY);
            }
            TagAudioDataBatch tag = new TagAudioDataBatch(transGroup);
            Database.executeBatch(tag);                

        } catch (Exception e) {
            system.debug('Cannot insert online log' + e.getMessage());
        }
        // System.debug(this.caseOwners);

        // for(String owner_email : this.caseOwners.keySet()){

        //     String caseInfo = '';
        //     String[] toAddresses = new String[]{};
        //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //     List<Case> case_list = this.caseOwners.get(owner_email);
        //     toAddresses.add(owner_email);
        //     for(Case c : case_list){
        //         caseInfo += c.Id + ' <br> ';
        //     }


        //     mail.setToAddresses(toAddresses);
        //     mail.setSenderDisplayName('Salesforce Support');
        //     mail.setSubject('Case sent to voice recorder.');
    
        //     mail.setHtmlBody(case_list.size() + ' Case(s) sent to voice recorder.<br>' + caseInfo);
        //     mailList.add(mail);
        // }

        // Messaging.sendEmail(mailList);

    }
    //End batchable section

    public static String getAuthToken(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        String return_token = '';
        
        req.setEndpoint('callout:Telephony_Verint_getToken');
        // req.setEndpoint('https://wfo.avayacloudthailand.com:9443/wfo/rest/core-api/auth/token');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        String bodyJson = '{"user": "{!$Credential.Username}", "password":"{!$Credential.Password}"}';
        req.setBody(bodyJson);

        HttpResponse res = http.send(req);
        
        if(res.getStatus() == 'OK'){
            Map<String, Object> token_map = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String token = JSON.serialize(token_map.get('AuthToken'));
            Map<String, Object> token_result = (Map<String, Object>)JSON.deserializeUntyped(token);

            return_token = token_result.get('token').toString();
        }

        return return_token;
    }

    private static Map<String, Map<String,Map<String, Object>>> dasQuery(String auth_token, /*String user_id,*/ Set<String> switchCallIdList){
        Map<String,List<String>> mapCallIdwithSwitchCallId = new Map<String,List<String>>();
        Map<String,Map<String, Object>> callIdMap = new Map<String,Map<String, Object>>();
        Set<String> responseCallId = new Set<String>();
        Map<String, Map<String,Map<String, Object>>>  returnMap = new Map<String, Map<String,Map<String, Object>>> ();

        String requestCallId = '' ;
        Integer count = 0;
        for(String switchcallId : switchCallIdList){
            requestCallId += 'SWITCH_CALL_ID = ' + switchcallId;
            if(count != switchCallIdList.size() - 1){
                requestCallId += ' OR ';
            }
            count++;
        }

        System.debug('switchCallIdList:'+switchCallIdList);
        System.debug('requestCallId : '+ requestCallId);

        // for(String switch_call_id : switchCallIdList)
        // {
        //     String[] temp = switch_call_id.split(',');
        //     String channel = temp[1];
        //     switch_call_id = temp[0];
            
            //Map<String, Object> returnMap = new Map<String, Object>();
            
            // System.debug(JSON.serialize(DateTime.now().addYears(-1)).remove('"'));
            // System.debug(JSON.serialize(DateTime.now()).remove('"'));
        try
        {
            DataAccessService.PageScrollingStatus pss = new DataAccessService.PageScrollingStatus();
            pss.RequestedPage = 'FirstPage';
            pss.CurrentPageBegin = JSON.serialize(DateTime.now().addYears(-1)).remove('"');
            pss.CurrentPageEnd = JSON.serialize(DateTime.now()).remove('"');
            
            DataAccessService.Period p = new DataAccessService.Period();
            p.BeginPeriod = JSON.serialize(DateTime.now().addYears(-1)).remove('"');
            p.EndPeriod = JSON.serialize(DateTime.now()).remove('"');
            p.Type_x = Voice_Tagging_Setting__c.getValues('Period_Type').Value__c;
            p.Days = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('Period_Days').Value__c);
            
            DataAccessService.Field f = new DataAccessService.Field();
            f.name = Voice_Tagging_Setting__c.getValues('Field_Name').Value__c;
            f.SequentialId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('Field_SequentialId').Value__c);
            f.AggregationOperator = Voice_Tagging_Setting__c.getValues('Field_AggregationOperator').Value__c;
            
            DataAccessService.Field reqf = new DataAccessService.Field();
            reqf.name = Voice_Tagging_Setting__c.getValues('RequestedData_Field').Value__c;
            reqf.SequentialId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('RequestedData_SequentialId').Value__c);
            reqf.AggregationOperator = Voice_Tagging_Setting__c.getValues('AggregationOperator').Value__c;
            
            DataAccessService.ArrayOfField aof = new DataAccessService.ArrayOfField();
            aof.Field = new List<DataAccessService.field>{f};
                
            DataAccessService.ArrayOfField aorf = new DataAccessService.ArrayOfField();
            aorf.Field = new List<DataAccessService.field>{reqf};
            
            DataAccessService.SortOrder so = new DataAccessService.SortOrder();
            so.Direction = Voice_Tagging_Setting__c.getValues('Direction').Value__c;
            so.Fields = aof;
            
            DataAccessService.RestrictionFlags rf = new DataAccessService.RestrictionFlags();
            rf.ETMFilters = 'Inactive';
            rf.MultiChannel = 'Active';
            rf.PersonalTag = 'Active';
            
            DataAccessService.Visibility v = new DataAccessService.Visibility();
            v.Database = Voice_Tagging_Setting__c.getValues('Database').Value__c;
            v.UserRole = Voice_Tagging_Setting__c.getValues('Visibility_UserRole').Value__c;
            v.Application = Voice_Tagging_Setting__c.getValues('Application').Value__c;
            v.QueryPurpose = Voice_Tagging_Setting__c.getValues('QueryPurpose').Value__c;
            v.RestrictionFlagsSet = rf;
            
            DataAccessService.Display disp = new DataAccessService.Display();
            disp.QueryTime = Voice_Tagging_Setting__c.getValues('QueryTime').Value__c;
            disp.PageSize = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('PageSize').Value__c);
            disp.HasEmotion = Boolean.ValueOf(Voice_Tagging_Setting__c.getValues('HasEmotion').Value__c);
            disp.ExtraEvaluationInfo = '';
            disp.RandomSampling = Boolean.ValueOf(Voice_Tagging_Setting__c.getValues('RandomSampling').Value__c);
            disp.QueryPeriod = p;
            disp.SortOrder = so;
            
            DataAccessService.RequestedData rd = new DataAccessService.RequestedData();
            rd.Fields = aorf;
            
            DataAccessService.QueryDefinition qd = new DataAccessService.QueryDefinition();
            qd.GUID = Voice_Tagging_Setting__c.getValues('GUID').Value__c;
            // qd.UserId = Integer.valueOf(user_id);
            qd.UserId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('UserId').Value__c);
            qd.PresentationProperties = disp;
            qd.Visibility = v;
            //qd.ConditionsStr = 'SWITCH_CALL_ID = '+switch_call_id;
            qd.ConditionsStr = requestCallId;
            // change condition here if channel = outbound call and mode = preview/predictive then CUSTOM_DATA_STRING 21
            // if (channel == 'Outbound Call') {
            //     qd.ConditionsStr = 'CUSTOM_DATA_STRING 21 = '+switch_call_id;
            // } else {
            //     qd.ConditionsStr = 'SWITCH_CALL_ID = '+switch_call_id;
            // }

            qd.RequestedData = rd;
            
            DataAccessService.AgWebServiceSoap awss = new DataAccessService.AgWebServiceSoap();
            awss.endpoint_x = 'callout:Telephony_Verint_DAS_API';
            // awss.endpoint_x = 'https://webhook.site/e7bc8163-3665-4111-bd72-2abb2acb2de0';

            awss.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};
            // System.debug(JSON.serializePretty(pss));
            String errMsg;
            Integer retry = 0;
            DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element[] result = null;
            do{
                try{
                    result = awss.ExecuteUnifiedSessionQuery_Http(qd, pss).diffgram.newdataset.Sessions;
                    // System.debug(JSON.serializePretty(qd));
                }catch (Exception e){
                    System.debug('Retry: ' + retry + ' || Err: ' + e.getMessage());
                    errMsg = e.getMessage();
                    if(errMsg != 'Read timed out'){
                        throw new OtherException(errMsg);
                    }
                    else if(retry == 2 && errMsg == 'Read timed out'){
                        throw new OtherException(errMsg);
                    }
                    retry++;
                }
            }while(retry < 3 && errMsg == 'Read timed out');

            System.debug('result: '+result);
            System.debug('result Size : '+result.size());

            if(result != null)
            {
                if(result.size() > 0)
                {
                    for(DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element r : result)
                    {
                        //System.debug('result: '+r);

                        r.audio_end_time = r.audio_end_time.addHours(-7);
                        // System.debug('sid: '+r.sid);
                        // System.debug('audio_start_time_gmt: '+r.audio_start_time_gmt);
                        // System.debug('audio_end_time: '+r.audio_end_time);
                        // System.debug('audio_module_num: '+r.audio_module_num);
                        // System.debug('audio_ch_num: '+r.audio_ch_num);
                        // System.debug('call_id: '+r.call_id);
                        // System.debug('extension: '+r.extension);
                        // System.debug(formatDateTime(r.audio_start_time_gmt));
                        // System.debug(formatDateTime(r.audio_end_time));

                        Map<String, Object> resultMap = new Map<String, Object>();
                            
                        resultMap.put('audio_start_time_gmt', formatDateTime(r.audio_start_time_gmt));
                        resultMap.put('audio_end_time', formatDateTime(r.audio_end_time));
                        resultMap.put('audio_module_num', r.audio_module_num);
                        resultMap.put('audio_ch_num', r.audio_ch_num);
                        resultMap.put('call_id', r.call_id);
                        resultMap.put('extension', r.extension);
                        callIdMap.put(String.valueOf(r.call_id)+String.valueOf(r.extension),resultMap);
                        if(r.switch_call_id != null){
                        if(mapCallIdwithSwitchCallId.containsKey(String.valueOf(r.switch_call_id))){
                            List<String> listcallId =  mapCallIdwithSwitchCallId.get(String.valueOf(r.switch_call_id));
                            listcallId.add(String.valueOf(r.call_id)+String.valueOf(r.extension));
                            mapCallIdwithSwitchCallId.put(String.valueOf(r.switch_call_id),listcallId);

                        }else{
                            List<String> listcallId = new List<String>();
                            listcallId.add(String.valueOf(r.call_id)+String.valueOf(r.extension));
                            mapCallIdwithSwitchCallId.put(String.valueOf(r.switch_call_id),listcallId);

                        }
                            responseCallId.add(String.valueOf(r.switch_call_id));
                        }

                        Voice_Tagging__c vt = new Voice_Tagging__c();
                        vt.Unique_Id__c = String.valueOf(r.switch_call_id) + String.valueOf(r.call_id) + String.valueOf(r.sid);
                        vt.Call_Log_ID__c = String.valueOf(r.switch_call_id);
                        vt.Audio_Start_Time__c = formatDateTime(r.audio_start_time_gmt);
                        vt.Audio_End_Time__c = formatDateTime(r.audio_end_time);
                        vt.Audio_Module_Num__c = String.valueOf(r.audio_module_num);
                        vt.Audio_Channel_Num__c = String.valueOf(r.audio_ch_num);
                        vt.Verint_Call_ID__c = String.valueOf(r.call_id);
                        vt.Channel__c = 'Outbound';
                        vt.Import_Result__c = false;
                        vt.Error_Message__c = null;
                        vt.Import_Datetime__c = Datetime.now();
                        vt.Import_Type__c = 'Campaign Member';
                        vt.Extension__c = String.valueOf(r.extension);
                        listVoiceTagging.add(vt);
                    } 
                }
                countSuccess++;
                //returnMap.put(switch_call_id,callIdMap);
                for(String Id : switchCallIdList){
                    if(!responseCallId.contains(Id)){
                        countError++;
                        Voice_Tagging__c vt = new Voice_Tagging__c();
                        vt.Unique_Id__c = Id;
                        vt.Call_Log_ID__c = Id; 
                        vt.Channel__c = 'Outbound';
                        vt.Import_Result__c = false;
                        vt.Import_Datetime__c = Datetime.now();
                        vt.Import_Type__c = 'Campaign Member';
                        vt.Error_Message__c = 'Not Found';
                        vt.Extension__c = null;
                        listVoiceTagging.add(vt);
                    }
                }
                for(String switchcallId : mapCallIdwithSwitchCallId.keySet()){
                    List<String> verintId = mapCallIdwithSwitchCallId.get(switchcallId);
                    Map<String,Map<String, Object>> newMap = new Map<String,Map<String, Object>>();
                    //System.debug('verintId Size' + verintId.size());
                    for(String vId : verintId){
                        Map<String, Object> mapId = callIdMap.get(vId);
                        newMap.put(vId,mapId);
                    }
                    returnMap.put(switchcallId,newMap) ;
                    //newMap.clear();
                }
            }
        } catch (Exception e) {
            countError = switchCallIdList.size();
            String errorMsg = '';              
            errormsg = e.getMessage();           
            System.debug('switch_call_id: ' + requestCallId + ' Error:'+ errormsg);
            System.debug('Line error = ' + e.getLineNumber());
            for(String switchcallId : switchCallIdList){
                cmErrorMsgMap.put(switchcallId, errormsg);         
                Voice_Tagging__c vt = new Voice_Tagging__c();
                vt.Unique_Id__c = switchcallId;
                vt.Call_Log_ID__c = switchcallId;
                vt.Channel__c = 'Outbound';
                vt.Import_Result__c = false;
                vt.Import_Datetime__c = Datetime.now();
                vt.Import_Type__c = 'Campaign Member';
                vt.Error_Message__c = errormsg;
                vt.Extension__c = null;
                listVoiceTagging.add(vt);    
            }
        
        }      
        System.debug('returnMap' + returnMap.values());
        return returnMap;
}


    public static String formatDateTime(Object dt){
        String payload = JSON.serialize(dt);
        //System.debug(payload);
        String[] firstSplit = payload.remove('"').split('\\.');
        String secondSplit = firstSplit[1].remove('Z');
        //System.debug(firstSplit);
        //System.debug(secondSplit.rightPad(7, '0'));
        
        firstSplit[1] = secondSplit.rightPad(7, '0');
        
        String ms = String.join(firstSplit, '.') + '+00:00';
        //System.debug(ms);
        return ms;
    }

    //currently used to replace ampersand (&) in callouts as it cause callout to failed
    //if any field used in callout contains (&) it must be replaced
    private static String replaceSpecialChar(String text){
        String returntxt = text.replace('&', '&amp;');
        return returntxt;
    }

    private static void tagAudioData(Map<String,Map<String, Object>> dasMap, Map<String, List<CampaignMember>> campaignMap,String swict_call_id/*List<Case> caseList*/){
        String private_data = '';
		// String caseDetail = '';
        String campaignDetail = '';
        Integer pVar = 2;
        Integer pCaseId = 17;
        
        for(String call_id: dasMap.keySet())
        {
            //System.debug('dasMap: '+dasMap.get(call_id).get('audio_ch_num'));
            pVar = 2;
            pCaseId = 17;
            campaignDetail = '';
            private_data = '';
            if(campaignMap.containsKey(swict_call_id+call_id+dasMap.get(call_id).get('extension')))
            {
                if(campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size() > 0)
                {
                    for(Integer i = 0; i < campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size(); i++)
                    {
                        if(i > 0)
                        {
                            pVar += 1;    
                        }
                        System.debug('campaignMap: '+campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i]);
                        String cmProduct1 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Campaign_Product_1__r.Name;
                        String offer1 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_OfferResult_Product_1__c;
                        String reason1 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Not_Interest_Reason1__c;
                        String cmProduct2 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Campaign_Product_2__r.Name;
                        String offer2 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_OfferResult_Product_2__c;
                        String reason2 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Not_Interest_Reason2__c;
                        String cmProduct3 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Campaign_Product_3__r.Name;
                        String offer3 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_OfferResult_Product_3__c;
                        String reason3 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Not_Interest_Reason3__c;
                        String cmProduct4 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Campaign_Product_4__r.Name;
                        String offer4 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_OfferResult_Product_4__c;
                        String reason4 = campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Not_Interest_Reason4__c;

                        if (!String.isBlank(campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Marketing_Code__c))
                        {
                            campaignDetail += +'<P'+pVar+'>'+campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Marketing_Code__c+'</P'+pVar+'>'+
                                            '<P'+(pVar+1)+'>'+(cmProduct1 != null ? cmProduct1.escapeXml() : '') + '</P'+(pVar+1)+'>'+
                                            '<P'+(pVar+2)+'>'+(offer1 != null ? offer1.escapeXml() : '') + '</P'+ (pVar+2)+'>'+
                                            '<P'+(pVar+3)+'>'+(reason1 != null ? reason1.escapeXml() : '') + '</P'+(pVar+3)+'>'+
                                            '<P'+(pVar+4)+'>'+(cmProduct2 != null ? cmProduct2.escapeXml() : '') + '</P'+(pVar+4)+'>'+
                                            '<P'+(pVar+5)+'>'+(offer2 != null ? offer2.escapeXml() : '') + '</P'+(pVar+5)+'>'+
                                            '<P'+(pVar+6)+'>'+(reason2 != null ? reason2.escapeXml() : '') +'</P'+(pVar+6)+'>'+
                                            '<P'+(pVar+7)+'>'+(cmProduct3 != null ? cmProduct3.escapeXml() : '') +' </P'+(pVar+7)+'>'+
                                            '<P'+(pVar+8)+'>'+(offer3 != null ? offer3.escapeXml() : '') + '</P'+(pVar+8)+'>'+
                                            '<P'+(pVar+9)+'>'+(reason3 != null ? reason3.escapeXml() : '') + '</P'+(pVar+9)+'>'+
                                            '<P'+(pVar+10)+'>'+(cmProduct4 != null ? cmProduct4.escapeXml() : '') +'</P'+(pVar+10)+'>'+
                                            '<P'+(pVar+11)+'>'+(offer4 != null ? offer4.escapeXml() : '') + '</P'+(pVar+11)+'>'+
                                            '<P'+(pVar+12)+'>'+(reason4 != null ? reason4.escapeXml() : '') + '</P'+(pVar+12)+'>';
                        } 
                        else if (!String.isBlank(campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Web_Unique_ID__c))
                        {
                            campaignDetail += +'<P'+pVar+'>'+campaignMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].RTL_Web_Unique_ID__c+'</P'+pVar+'>'+
                                            '<P'+(pVar+1)+'>'+(cmProduct1 != null ? cmProduct1.escapeXml() : '') + '</P'+(pVar+1)+'>'+
                                            '<P'+(pVar+2)+'>'+(offer1 != null ? offer1.escapeXml() : '') + '</P'+ (pVar+2)+'>'+
                                            '<P'+(pVar+3)+'>'+(reason1 != null ? reason1.escapeXml() : '') + '</P'+(pVar+3)+'>'+
                                            '<P'+(pVar+4)+'>'+(cmProduct2 != null ? cmProduct2.escapeXml() : '') + '</P'+(pVar+4)+'>'+
                                            '<P'+(pVar+5)+'>'+(offer2 != null ? offer2.escapeXml() : '') + '</P'+(pVar+5)+'>'+
                                            '<P'+(pVar+6)+'>'+(reason2 != null ? reason2.escapeXml() : '') +'</P'+(pVar+6)+'>'+
                                            '<P'+(pVar+7)+'>'+(cmProduct3 != null ? cmProduct3.escapeXml() : '') +' </P'+(pVar+7)+'>'+
                                            '<P'+(pVar+8)+'>'+(offer3 != null ? offer3.escapeXml() : '') + '</P'+(pVar+8)+'>'+
                                            '<P'+(pVar+9)+'>'+(reason3 != null ? reason3.escapeXml() : '') + '</P'+(pVar+9)+'>'+
                                            '<P'+(pVar+10)+'>'+(cmProduct4 != null ? cmProduct4.escapeXml() : '') +'</P'+(pVar+10)+'>'+
                                            '<P'+(pVar+11)+'>'+(offer4 != null ? offer4.escapeXml() : '') + '</P'+(pVar+11)+'>'+
                                            '<P'+(pVar+12)+'>'+(reason4 != null ? reason4.escapeXml() : '') + '</P'+(pVar+12)+'>';
                        }
                    }
                        
                }
                System.debug('swict_call_id: '+swict_call_id);
                System.debug('campaignDetail: '+campaignDetail);
                if(campaignDetail != '')
                {
                    private_data = '<Extension name="PrivateData">'+ campaignDetail + '</Extension>';
                    //private_dataMap.put(call_id+dasMap.get(call_id).get('extension'),private_data);
                    private_dataMap.put(swict_call_id+call_id,private_data);
                }             
            }
            System.debug('private_data: '+private_data);
        
        }
    }
}