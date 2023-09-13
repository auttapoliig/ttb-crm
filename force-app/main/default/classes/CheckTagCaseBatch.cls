public class CheckTagCaseBatch {
    public static List<Case> getCaseList(Datetime batchDateTime) {
        List<Case> scope = new List<Case>();
        
        Integer lastTime = -15;
        Set<String> uniqueCallLogId = new Set<String>();
        //Datetime batchDateTime = Datetime.now();
        System.debug('Batch DateTime --> ' + batchDateTime);

        // 1. Find case with end call in last 15 mins
        List<Task> listTask1 = [SELECT Id, Call_Log_ID__c FROM Task WHERE Call_End_Time__c != null and Call_Log_ID__c != null and LastModifiedDate > :batchDateTime.addMinutes(lastTime)];
        
        List<String> idList = new List<String>();
        if(listTask1.size() > 0){
            for(Task t : listTask1){
                
                uniqueCallLogId.add(t.Call_Log_ID__c);
            }
            System.debug('Case 1 :: uniqueCallLogId-->' + uniqueCallLogId);
        }

        // 2. Find case with last modified in last 15 mins and call log id is not null and call log id have end time
        List<Case> caseList = [SELECT Id, Call_Log_ID__c, LastModifiedDate FROM Case WHERE Call_Log_ID__c != null and LastModifiedDate > :batchDateTime.addMinutes(lastTime)];
        Set<String> caseCallIdList = new Set<String>();
        if(!caseList.isEmpty()){
            for(Case c : caseList){
                caseCallIdList.add(c.Call_Log_ID__c);
            }
            System.debug('Selected case for last modify from ' + batchDateTime.addMinutes(lastTime) + '-->' + caseCallIdList);
        }

        List<Task> listTask2 = [SELECT Id, Call_Log_ID__c, LastModifiedDate FROM Task WHERE Call_Log_ID__c in :caseCallIdList and Call_End_Time__c != null];
        if(!caseList.isEmpty()){
            for(Task t : listTask2){
                
                uniqueCallLogId.add(t.Call_Log_ID__c);
            }

            System.debug('Case 2 :: uniqueCallLogId-->' + uniqueCallLogId);
        }

        if (!uniqueCallLogId.isEmpty()) {
            System.debug('uniqueCallLogId-->' + uniqueCallLogId);
            String idString = '(\''+String.join(new List<String>(uniqueCallLogId), '\',\'')+'\')';
            //Within last 30 minutes - Batch runs every 15 minutes
            
            String query = 'SELECT Id, Call_Log_ID__c, Owner_Employee_ID__c, CaseNumber, Category__c'+
                            ', Sub_Category__c, Product_Category__c, Issue__c, LastModifiedDate, Created_Email__c, Created_ID__c '+
                            'FROM Case '+
                            'WHERE Call_Log_ID__c IN '+idString+
                            ' ORDER BY CreatedDate ASC';

            System.debug('query-->' + query);
			scope = (List<Case>)Database.query(query);
            //res.
        } 
        
        
        
        return scope;
    }
    
    
	public static Map<String, Map<String,Map<String, Object>>> dasQuery(String auth_token, /*String user_id,*/ Set<String> switchCallIdList){

        Map<String, Map<String,Map<String, Object>>>  returnMap = new Map<String, Map<String,Map<String, Object>>> ();

        for(String switch_call_id : switchCallIdList)
        {
            //Map<String, Object> returnMap = new Map<String, Object>();
            
            // System.debug(JSON.serialize(DateTime.now().addYears(-1)).remove('"'));
            // System.debug(JSON.serialize(DateTime.now()).remove('"'));
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
            qd.ConditionsStr = 'SWITCH_CALL_ID = '+switch_call_id;
            qd.RequestedData = rd;
            System.debug('SWITCH_CALL_ID = '+switch_call_id);
            DataAccessService.AgWebServiceSoap awss = new DataAccessService.AgWebServiceSoap();
            awss.endpoint_x = 'callout:Telephony_Verint_DAS_API';
            // awss.endpoint_x = 'https://webhook.site/e7bc8163-3665-4111-bd72-2abb2acb2de0';

            awss.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};
            DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element[] result = awss.ExecuteUnifiedSessionQuery_Http(qd, pss).diffgram.newdataset.Sessions;
            // System.debug(JSON.serializePretty(qd));
            // System.debug(JSON.serializePretty(pss));
            //System.debug('result:'+result);
            if(result != null)
            {
                Map<String,Map<String, Object>> callIdMap = new Map<String,Map<String, Object>>();

                if(result.size() > 0)
                {
                    for(DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element r : result)
                    {
                        //System.debug('result:'+r);

                        r.audio_end_time = r.audio_end_time.addHours(-7);
                        System.debug('sid:'+r.sid);
                        System.debug('audio_start_time_gmt:'+r.audio_start_time_gmt);
                        System.debug('audio_end_time:'+r.audio_end_time);
                        System.debug('audio_module_num:'+r.audio_module_num);
                        System.debug('audio_ch_num:'+r.audio_ch_num);
                        System.debug('call_id:'+r.call_id);
                        System.debug('extension:'+r.extension);
                        // System.debug(formatDateTime(r.audio_start_time_gmt));
                        // System.debug(formatDateTime(r.audio_end_time));

                        Map<String, Object> resultMap = new Map<String, Object>();
                        System.debug('1audio_start_time_gmt ---> '+r.audio_start_time_gmt);
                        System.debug('1audio_end_time ---> '+r.audio_end_time);
                        System.debug('2audio_start_time_gmt ---> '+formatDateTime(r.audio_start_time_gmt));
                        System.debug('2audio_end_time ---> '+formatDateTime(r.audio_end_time));
                        
                        resultMap.put('audio_start_time_gmt', formatDateTime(r.audio_start_time_gmt));
                        resultMap.put('audio_end_time', formatDateTime(r.audio_end_time));
                        resultMap.put('audio_module_num', r.audio_module_num);
                        resultMap.put('audio_ch_num', r.audio_ch_num);
                        resultMap.put('call_id', r.call_id);
                        resultMap.put('extension', r.extension);

                        callIdMap.put(String.valueOf(r.call_id),resultMap);
                    
                    } 
                }
                returnMap.put(switch_call_id,callIdMap);
            }
        }
        return returnMap;
    }
    
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
    
    public static void tagAudioData(String auth_token, Map<String,Map<String, Object>> dasMap, Map<String, List<Case>> caseMap,String swict_call_id/*List<Case> caseList*/){
        datamodelwsVerintCom.BasicHttpBinding_IDataModelWS iad = new datamodelwsVerintCom.BasicHttpBinding_IDataModelWS();
        iad.endpoint_x = 'callout:Telephony_Verint_Import_Audio_Data_API';
        // iad.endpoint_x = 'https://webhook.site/6bc6eecc-44dd-4c46-b834-57fa6e16737a';
        
        iad.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};
        Map<String,String> private_dataMap = new Map<String,String>();
        String private_data = '';
		String caseDetail = '';
        Integer pVar = 3;
        Integer pCaseId = 17;
        
        for(String call_id: dasMap.keySet())
        {
            //System.debug('dasMap:'+dasMap.get(call_id).get('audio_ch_num'));
            pVar = 3;
            pCaseId = 17;
            caseDetail = '';
            private_data = '';
            if(caseMap.containsKey(swict_call_id+call_id+dasMap.get(call_id).get('extension')))
            {
                if( caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size() > 0)
                {
                    for(Integer i = 0; i < caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size(); i++)
                    {
                        if(i > 0)
                        {
                            pVar += 3;    
                        }
                        System.debug('caseMap:'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i]);
                        caseDetail += +'<P'+(pCaseId+i)+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].CaseNumber+'</P'+(pCaseId+i)+'>'+
                            '<P'+pVar+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Category__c+'</P'+pVar+'>'+
                            '<P'+(pVar+1)+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Sub_Category__c+'</P'+(pVar+1)+'>'+
                            '<P'+(pVar+2)+'>'+replaceSpecialChar(caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Product_Category__c)+'</P'+(pVar+2)+'>';
                    }
                        
                }
                System.debug('caseDetail:'+caseDetail);
                if(caseDetail != '')
                {
                    private_data = '<Extension name="PrivateData">'+ caseDetail + '</Extension>';
                    //private_dataMap.put(call_id+dasMap.get(call_id).get('extension'),private_data);
                }             
            }
            System.debug('private_data:'+private_data);
        
            schemasMicrosoftCom200310Serializat1.ArrayOfstring envelop = new schemasMicrosoftCom200310Serializat1.ArrayOfstring();
            
            //Real implementation to use after DAS API works
            String[] arrOfString = new String[]{
                    '<Envelope>'+
                        '<Header>'+
                            '<Source>ExternalSource</Source>'+
                            '<Operation>Session Insert</Operation>'+
                            '<Time>'+formatDateTime(DateTime.now())+'</Time>'+
                        '</Header>'+
                        '<Data>'+
                            '<Extensions>'+
                                '<Extension name="AudioAcquisition">'+
                                    '<Start>'+dasMap.get(call_id).get('audio_start_time_gmt')+'</Start>'+
                                    '<End>'+dasMap.get(call_id).get('audio_end_time')+'</End>'+
                                    '<Module>'+dasMap.get(call_id).get('audio_module_num')+'</Module>'+
                                    '<TimeOffset>420</TimeOffset>'+
                                    '<Channel>'+dasMap.get(call_id).get('audio_ch_num')+'</Channel>'+
                                '</Extension>'+
                                '<Extension name="TelephonyContact">'+
                                    '<ID>'+dasMap.get(call_id).get('call_id')+'</ID>'+
                                '</Extension>'+ private_data/*private_dataMap.get(call_id+dasMap.get(call_id).get('extension'))*/ +
                            '</Extensions>'+
                        '</Data>'+
                ' </Envelope>'
                }; 
             
            System.debug('Request Body:'+arrOfString);
            System.debug('Request Body:'+JSON.serializePretty(arrOfString));
            envelop.string_x = arrOfString;
            
            iad.ProcessEx(envelop, 'None');
        }
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
    
    private static String replaceSpecialChar(String text){
        String returntxt = text.replace('&', '&amp;');
        return returntxt;
    }
}