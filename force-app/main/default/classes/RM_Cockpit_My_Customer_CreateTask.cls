public class RM_Cockpit_My_Customer_CreateTask {

    public static Map<String, String> fieldLabelMap{
        get{
            if(fieldLabelMap == null){
                fieldLabelMap = new Map<String, String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                Schema.SObjectType ctype = gd.get('Task'); 
                Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();   
                for(String fieldName: fmap.keySet()) {
                    fieldLabelMap.put(fieldName, fmap.get(fieldName).getDescribe().getLabel());
                }
            }
            return fieldLabelMap;
        }set;
    }

    public static Map<String, Object> appConfig{
        get{
            if(appConfig == null){
                appConfig = new Map<String, Object>();
                List<String> labelList = new List<String>{'RMC_My_Customer_Task_Activity_Days', 'RMC_My_Customer_Task_Priority', 'RMC_My_Customer_Task_Status', 'RMC_My_Customer_Task_Subject'};
                List<App_Config__mdt> configList = [SELECT MasterLabel, Value__c FROM App_Config__mdt WHERE MasterLabel IN:labelList];
                for(App_Config__mdt each : configList){
                    appConfig.put(each.MasterLabel, each.Value__c);
                }         
            }
            return appConfig;
        }set;
    }

    public static Id taskRecordTypeId{
        get{
            if(taskRecordTypeId == null){
                List<RecordType> listRecordType = [SELECT Id FROM RecordType WHERE name = 'Retail Task'];
                taskRecordTypeId = listRecordType[0].Id; 
            }
            return taskRecordTypeId;
        }set;
    }

    public static List<Object> createTaskHelper(List<String> accIdList){
        List<Task> taskToInsert = prepTaskForInsert(accIdList);
        List<Object> resultList = new List<Object>();
        List<String> acctIdForUpdate = new List<String>();
        if(taskToInsert!=null && taskToInsert.size()>0){
            Database.SaveResult[] srList = Database.insert(taskToInsert, false);
            resultList = getResultList(srList, taskToInsert);

            for(Integer i = 0 ; i < resultList.size() ; i++){
                Map<String, Object> each  = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resultList.get(i)));
                if(String.valueOf(each.get('IsSuccess')) == 'true'){
                    acctIdForUpdate.add(each.get('Customer_Id') + '');
                }
            }
            if(acctIdForUpdate.size() > 0){
                updateSelectedDate(acctIdForUpdate);
            }
        }
        return resultList;
    }

    public static List<Object> getResultList(List<Database.SaveResult> srList, List<Task> taskToInsert){
        List<Object> outputList = new List<Object>();
        String msg;
        for(Integer i = 0 ; i < srList.size() ; i++){
            Map<String, String> resultMap = new Map<String, String>();
            Database.SaveResult each = srList.get(i);
            Task eachTask = taskToInsert.get(i);
            resultMap.put('SubJect_Label', fieldLabelMap.get('subject'));
            resultMap.put('Priority_Label', fieldLabelMap.get('priority'));
            resultMap.put('Activitydate_Label', fieldLabelMap.get('activitydate'));
            resultMap.put('IsSuccess', each.isSuccess() + '');
            resultMap.put('Customer_Id', eachTask.get('WhatId') + '');
            resultMap.put('Customer_Name', eachTask.get('Customer_Name__c') + '');
            if(!each.isSuccess()) {
                msg = 'Error '+ each.getErrors()[0].getMessage();
            }
            else {
                resultMap.put('Task_Subject', eachTask.get('Subject') + '');
                resultMap.put('Task_Due_Date', eachTask.get('ActivityDate') + '');
                resultMap.put('Task_Priority', eachTask.get('Priority') + '');
                resultMap.put('Task_Id', each.id);
                msg = '';
            }
            resultMap.put('Message', msg);
            outputList.add(resultMap);
        }
        return outputList;
    }

    public static List<Task> prepTaskForInsert(List<String> accIdList){
        List<Account> accountList = [SELECT Id, Name, RTL_Wealth_RM__c FROM Account WHERE Id IN :accIdList];
        Date toDay = date.today();
        List<Task> tskList = new List<Task>();
        for(Account accObj : accountList){
            Task tsk = new Task();
            tsk.Subject = appConfig.get('RMC_My_Customer_Task_Subject') +'';
            tsk.RTL_Task_Subject__c = appConfig.get('RMC_My_Customer_Task_Subject') +'';
            tsk.Status = appConfig.get('RMC_My_Customer_Task_Status') + '';
            tsk.Priority = appConfig.get('RMC_My_Customer_Task_Priority') + '';
            tsk.WhatId = accObj.Id;
            tsk.OwnerId = accObj.RTL_Wealth_RM__c;
            tsk.ActivityDate = date.today()+ Integer.valueOf(appConfig.get('RMC_My_Customer_Task_Activity_Days'));
            tsk.Customer_Name__c = accObj.Name;
            tsk.RecordTypeId = taskRecordTypeId;
            tskList.add(tsk);
        }
        return tskList;
    }

    @Future
    public static void updateSelectedDate(List<String> acctIdList){
        List<Account> accoutToUpdate = new List<Account>();
        for(Account a : [SELECT Id, Date_of_First_Account_Opening__c, RMC_Number_of_Selected__c, TMB_Customer_ID_PE__c FROM Account WHERE Id IN :acctIdList]){
            a.Last_Selected_Date__c = datetime.now();
            a.RMC_Number_of_Selected__c = a.RMC_Number_of_Selected__c == null ? 1 : a.RMC_Number_of_Selected__c + 1;
            accoutToUpdate.add(a);
        }
        Database.SaveResult[] srList = Database.update(accoutToUpdate, false);
    }
}