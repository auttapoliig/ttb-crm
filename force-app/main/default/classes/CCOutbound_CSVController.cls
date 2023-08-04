public with sharing class CCOutbound_CSVController extends AbstractCoreClass {
    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                return productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static final User currUser {
        get {
            if(currUser == null){
                currUser = [SELECT Id,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()].get(0);
            }
            return currUser;
        }
        set;
    }

    private static final List<String> monthTH {
        get {
            if(monthTH == null || monthTH.size() < 12) {
                monthTH = new List<String>{'ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.'};
            }
            return monthTH;
        }
        set;
    }

    private static final  Map<String, Schema.SObjectField> sObjectField {
        get {
            if(sObjectField == null) {
                sObjectField = Schema.SObjectType.Account.fields.getMap();
            }
            return sObjectField;
        }
        set;
    }

    @AuraEnabled
    public static Object getDescribeFieldFromOSC07(String accountId) {

        Map<String, Map<String,Object>> respObj = new Map<String, Map<String,Object>>();
        Map<String, Object> oscResponse = new Map<String, Object>();

        // System.debug();
        oscResponse.put('StatusCode',200);
        oscResponse.put('StatusDesc','No Access');
        respObj.put('oscResponse',oscResponse);

        Map<String, Object> privilege = new Map<String, Object>();
        privilege.put('isAccessible',verifyFieldSecurity('RTL_Privilege1__c',accountId));
        privilege.put('inlineHelpText',System.Label.Privilege_Start_End_Date);
        privilege.put('type','STRING');
        privilege.put('label',sObjectField.get('RTL_Privilege1__c').getDescribe().getLabel());
        privilege.put('value','');
        privilege.put('name','RTL_Privilege1__c');
        respObj.put('RTL_Privilege1__c',privilege);

        Map<String, Object> ttbTouch = new Map<String, Object>();
        ttbTouch.put('isAccessible',verifyFieldSecurity('TTB_Touch_Flag',accountId));
        ttbTouch.put('inlineHelpText','ttbTouch');
        ttbTouch.put('type','STRING');
        ttbTouch.put('label','ttb touch');
        ttbTouch.put('value','');
        ttbTouch.put('name','TTB_Touch_Flag');
        respObj.put('TTB_Touch_Flag',ttbTouch);

        Map<String, Object> aum = new Map<String, Object>();
        aum.put('isAccessible',verifyFieldSecurity('RTL_Average_AUM__c',accountId));
        aum.put('inlineHelpText','');
        aum.put('type','CURRENCY');
        aum.put('label',sObjectField.get('RTL_Average_AUM__c').getDescribe().getLabel());
        aum.put('value','');
        aum.put('name','RTL_Average_AUM__c');
        respObj.put('RTL_Average_AUM__c',aum);

        // Map<String, Map<String,Object>> respObj = new Map<String, Map<String,Object>>();
        try {
            Boolean hasAccess = false;
            for(String key : respObj.keySet()) {
                Boolean isAccessible = (Boolean)respObj.get(key).get('isAccessible');
                if(isAccessible == true) {
                    hasAccess = isAccessible;
                } else {
                    respObj.get(key).put('value',System.Label.Data_Condition_Hidden_Text);
                }
            }

            if(hasAccess) {
                Account acc = getAccountField(accountId);
                String rmId = acc.TMB_Customer_ID_PE__c;
                HttpResponse res = RetailCSVCustomerChartController.callCVSAnalyticsData(accountId, acc);

                Map<String, Object> oscResult = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                respObj.put('oscResponse',(Map<String, Object>)oscResult.get('Status'));

                Map<String, Object> result = new Map<String, Object>();
                
                if(oscResult.get('GetCVSAnalyticsDataResponse') != null) {
                    result = (Map<String, Object>)((Map<String, Object>)oscResult.get('GetCVSAnalyticsDataResponse')).get('Result') == null ? new Map<String, Object>() : (Map<String, Object>)((Map<String, Object>)oscResult.get('GetCVSAnalyticsDataResponse')).get('Result');
                }
                if(respObj.get('RTL_Privilege1__c').get('isAccessible') == true) {
                    String privValue = acc.RTL_Privilege1__c + (result.get('csProfWealthExpDt') == null ?  '' : ' [' + result.get('csProfWealthExpDt') + ']');
                    privValue = privValue == null ? '-' : privValue;
                    respObj.get('RTL_Privilege1__c').put('value',privValue);
                }

                if(respObj.get('TTB_Touch_Flag').get('isAccessible') == true) {
                    String ttbTouchValue;
                    if(result.get('touchStatus') == 'YES' && result.get('LastLoginSuccessDate') != null){
                        // 2022-02-08
                        String date_format = ''; // for testing only
                        Date loginDate = Date.valueOf(String.valueOf(result.get('LastLoginSuccessDate')));
                        Datetime loginDatetime = DateTime.newInstance(loginDate.year(),loginDate.month(),loginDate.day());
                        String month = monthTH.get(loginDate.month()-1);
                        String year = String.valueOf((Integer.valueOf(loginDatetime.format('yyyy'))+543)).right(2);
                        String day = String.valueOf(Integer.valueOf(loginDate.day()));
                        date_format = day + ' ' + month + ' ' + year;
                        ttbTouchValue = 'มี (เข้าใช้งานล่าสุด '+ date_format + ')';
                    } else {
                        ttbTouchValue = 'ไม่มี';
                        respObj.get('TTB_Touch_Flag').put('class','redColor');
                    }
                    ttbTouchValue = ttbTouchValue == null ? '' : ttbTouchValue;
                    respObj.get('TTB_Touch_Flag').put('value',ttbTouchValue);
                } 
                if(respObj.get('RTL_Average_AUM__c').get('isAccessible') == true) {
                    String aumValue = (result.get('csProfAvgaum12m') == null ? String.valueOf(acc.RTL_Average_AUM__c) : String.valueOf(result.get('csProfAvgaum12m')));
                    aumValue = aumValue == null ? '0' : aumValue;
                    respObj.get('RTL_Average_AUM__c').put('value',aumValue);
                }
            }
        } catch (Exception e) {
            respObj.get('oscResponse').put('StatusCode',500);
            respObj.get('oscResponse').put('StatusDesc',e.getMessage());
        }
        return respObj;
    }

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields, List<String> fields_translate) {
        return RetailCSVLightningUtil.getDescribeFieldResultAndValue(recordId, fields, fields_translate);
    }

    @AuraEnabled(cacheable=true)
    public static Object getReference(Id recordId)
    {
        if(recordId == null) return null;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Object sObj = Database.query('SELECT Id, Name FROM ' + sObjName + ' WHERE Id = :recordId LIMIT 1');
        Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)sObj).get(0)));
        return ((Map<String, Object>)tempObj).containsKey('Name') ? ((Map<String, Object>)tempObj).get('Name') : null;
    }

    @AuraEnabled
    public static Account getAccountField(Id accId)
    {
        try{
            return [ SELECT Id, TMB_Customer_ID_PE__c, Name, Core_Banking_Suggested_Segment__c, RTL_Wealth_RM__c, RTL_Commercial_RM__c, Consolidate_Status__c, RTL_CC_STMT_status__c, RTL_RDC_STMT_status__c, RTL_C2G_STMT_status__c, RTL_Privilege1__c, RTL_Average_AUM__c FROM Account WHERE Id = :accId ];
        }catch( Exception e ){
            return new Account(Id=accId);
        }      
    }

    @AuraEnabled (cacheable=true)
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;
    }

    /* Setup format for segment coloring */
    @AuraEnabled
    public static String getSetUpFormat(String formatName){
        String retResult = SetUpFormat.getSetupFormat(formatname);
        return retResult; 
    }

    @AuraEnabled
    public static Object getDescribeFieldFromPDPA(String accountId) {
        Account acc = getAccountField(accountId);
        String rmId = acc.TMB_Customer_ID_PE__c;
        Map<String, Map<String,Object>> respObj = new Map<String, Map<String,Object>>();
        Map<String, Object> wsResponse = new Map<String, Object>();
        wsResponse.put('isSuccess','true');
        wsResponse.put('errorMessage','No Access');
        respObj.put('wsResponse',wsResponse);

        Map<String, Object> pdpaDetail = new Map<String, Object>();
        pdpaDetail.put('isAccessible',verifyFieldSecurity('pdpaDetail',acc.Id));
        pdpaDetail.put('inlineHelpText','');
        pdpaDetail.put('type','STRING');
        pdpaDetail.put('label','PDPA');
        pdpaDetail.put('value','');
        pdpaDetail.put('name','pdpaDetail');
        respObj.put('pdpaDetail',pdpaDetail);

        Map<String, Object> ttbTouch = new Map<String, Object>();
        ttbTouch.put('isAccessible',verifyFieldSecurity('marketDetail',acc.Id));
        ttbTouch.put('inlineHelpText','');
        ttbTouch.put('type','STRING');
        ttbTouch.put('label','Market Conduct');
        ttbTouch.put('value','');
        ttbTouch.put('name','marketDetail');
        respObj.put('marketDetail',ttbTouch);

        // Map<String, Map<String,Object>> respObj = new Map<String, Map<String,Object>>();
        try {
            Boolean hasAccess = false;
            for(String key : respObj.keySet()) {
                Boolean isAccessible = (Boolean)respObj.get(key).get('isAccessible');
                if(isAccessible == true) {
                    hasAccess = isAccessible;
                } else {
                    respObj.get(key).put('value',System.Label.Data_Condition_Hidden_Text);
                }
            }
            if(hasAccess) {
                // Account acc = getAccount(rmId);
                String res = pdpaCalloutUtil.getFagPdpa(rmId,'PDPA_GET_CONSENT_FAG_CSV_CC_PAGE');
                Map<String, Object> pdpaResultObj = (Map<String, Object>)JSON.deserializeUntyped(res);
                respObj.put('wsResponse',pdpaResultObj);

                if(pdpaResultObj.get('isSuccess') == 'true') {
                    if(respObj.get('pdpaDetail').get('isAccessible') == true) {
                        if (pdpaResultObj.get('PDPAFag') == 'Y') {
                            respObj.get('pdpaDetail').put('value',System.Label.PDPA_Accept_YES);
                            respObj.get('pdpaDetail').put('class','greenBackgroundColor');
                        } else if (pdpaResultObj.get('PDPAFag') == 'N') {
                            respObj.get('pdpaDetail').put('value',System.Label.PDPA_Accept_NO + '<br/>' + System.Label.PDPA_Flag_No_Message);
                            respObj.get('pdpaDetail').put('class','redBackgroundColor');
                        }
                    }
        
                    if(respObj.get('marketDetail').get('isAccessible') == true) {
                        if (pdpaResultObj.get('MARKETFag') == 'Y') {
                            respObj.get('marketDetail').put('value',System.Label.PDPA_Accept_YES);
                        } else if (pdpaResultObj.get('MARKETFag') == 'N') {
                            respObj.get('marketDetail').put('value',System.Label.PDPA_Accept_NO);
                        }
                    }
                }
            }
        } catch (Exception e) {
            respObj.get('wsResponse').put('isSuccess',false);
            respObj.get('wsResponse').put('errorMessage',e.getMessage());
        }
        return respObj;
    }

    @AuraEnabled
    public static Map<String, Object> getSubDebtTransaction(String accountId){
        Map<String, Object> subDebt = new Map<String, Object>();
        subDebt.put('isAccessible',verifyFieldSecurity('subDebtTran',accountId));
        // subDebtTran.put('inlineHelpText',System.Label.Privilege_Start_End_Date);
        subDebt.put('type','STRING');
        subDebt.put('label',System.Label.Sub_Debt_Transaction_Flag);
        subDebt.put('value',System.Label.Data_Condition_Hidden_Text);
        subDebt.put('name','subDebtTran');
        
        if(subDebt.get('isAccessible') == true) {
            List<Sub_Debt_Transaction__c> subDebtTran = [SELECT Id, Name,Customer__c FROM Sub_Debt_Transaction__c WHERE Customer__c =: accountId];
            String subDebtTransDetail = subDebtTran.size()> 0 ? System.Label.Sub_Debt_Transaction_Yes_Message : System.Label.Sub_Debt_Transaction_No_Message;
            subDebt.put('value',subDebtTransDetail);
        }
        return subDebt;  
    }

    @AuraEnabled
    public static String getInstantLendingDetail(Id accId){
        String instantLendingDetail = '';
        List<Retail_Instant_Lending__c> retailLending = [SELECT Id, Name, Customer__c, Instant_lending_detail__c, Expiry_Date__c FROM Retail_Instant_Lending__c WHERE Customer__c =: accId];
        instantLendingDetail = retailLending.size()>0? retailLending[0].Instant_lending_detail__c : '';
        return instantLendingDetail;
    }


    @AuraEnabled
    public static String getSubSegmentDesc(String recordId){
        try{
            List<Account> subSegmentCode = [SELECT Id, Sub_segment__c FROM Account WHERE Id=:recordId LIMIT 1];
            return AccountUtility.getSubSegment(subSegmentCode.get(0).Sub_segment__c);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean verifyFieldSecurity(String field, String accountId) {
        List<Security_Matrix__mdt> matrix = [SELECT Section__c FROM Security_Matrix__mdt WHERE Field__c =: field];
        String section;

        if(matrix.size() > 0) {
            section = matrix[0].Section__c;
        }
        return RTL_AccountUtility.verifyFieldSecurity(section, currUser.Profile.Name, accountId);
    }
}