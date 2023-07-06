/* ================
Auther : NobNab
================ */
public class MyCustomerControllerClass {

    public static Map<String, Object> fieldNameTypeMap{
        get{
            if(fieldNameTypeMap == null){
                fieldNameTypeMap = new Map<String, Object>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                Schema.SObjectType ctype = gd.get('Account'); 
                Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();   
                for(String fieldName: fmap.keySet()) {
                    Map<String, Object> describeMap = new Map<String, Object>();
                    describeMap.put('type', fmap.get(fieldName).getDescribe().getType() + '');
                    describeMap.put('encrypted', fmap.get(fieldName).getDescribe().encrypted);
                    fieldNameTypeMap.put(fieldName, describeMap);
                }
            }
            return fieldNameTypeMap;
        }set;
    }

    public static String currentUserId{
        get{
            if(currentUserId == null){
                currentUserId = UserInfo.getUserId();
                // currentUserId = '0050o00000WiY9LAAV';
            }
            return currentUserId;
        }set;
    }

    public static String currentUserName{
        get{
            if(currentUserName == null){
                User u = [SELECT id,Name FROM User WHERE id =: currentUserId];
                currentUserName = u.Name;
            }
            return currentUserName;
        }set;
    }

    public static List<String> currentWealthRmCustomer = new List<String>();

    public static List<String> dormantAccountIdList{
        get
        {
            if(dormantAccountIdList == null){ 
                dormantAccountIdList = new List<String>();
                for(Customer_Product_Alert__c each : DormantAccountController.getDormantAccountData(0)){
                    dormantAccountIdList.add(each.Customer__c);
                }
            }
            return dormantAccountIdList;
            
        }set;
    }

    public static List<String> depositInvestmentList {
        get{
            if(depositInvestmentList == null){
                depositInvestmentList = new List<String>();
                for(Customer_Product_Alert__c each : InvestmentReportController.getDepositData(0)){
                    depositInvestmentList.add(each.Customer__c);
                }
            }
            return depositInvestmentList;
        }set;
    }

    public static List<String> mfMaturityList {
        get{
            if(mfMaturityList == null){
                mfMaturityList = new List<String>();
                for(Customer_Product_Alert__c each : InvestmentReportController.getMFData(0)){
                    mfMaturityList.add(each.Customer__c);
                }
            }
            return mfMaturityList;
        }set;
    }

    public static List<String> insuranceAnniList{
        get{
            if(insuranceAnniList == null){
                insuranceAnniList = new List<String>();
                for(Customer_Product_Alert__c each : InsuranceReportController.getAnniversaryInsuranceData(0)){
                    insuranceAnniList.add(each.Customer__c);
                }
            }
            return insuranceAnniList;
        }set;
    }

    public static List<String> insuranPaidUpList{
        get{
            if(insuranPaidUpList == null){
                insuranPaidUpList = new List<String>();
                for(Customer_Product_Alert__c each : InsuranceReportController.getPaidUpInsuranceData(0)){
                    insuranPaidUpList.add(each.Customer__c);
                }
            }
            return insuranPaidUpList;
        }set;
    }

    public static List<String> insuranMaturityList{
        get{
            if(insuranMaturityList == null){
                insuranMaturityList = new List<String>();
                for(Customer_Product_Alert__c each : InsuranceReportController.getMatureInsuranceData(0)){
                    insuranMaturityList.add(each.Customer__c);
                }
            }
            return insuranMaturityList;
        }set;
    }

    public static List<String> lastTransPlusList{
        get{
            if(lastTransPlusList == null){
                lastTransPlusList = new List<String>();
                for(Large_Transaction_Movements__c each : TransactionMovementReport.getTransactionPlusData(0)){
                    lastTransPlusList.add(each.Customer__c);
                }
            }
            return lastTransPlusList;
        }set;
    }

    public static List<String> lastTransMinusList{
        get{
            if(lastTransMinusList == null){
                lastTransMinusList = new List<String>();
                for(Large_Transaction_Movements__c each : TransactionMovementReport.getTransactionMinusData(0)){
                    lastTransMinusList.add(each.Customer__c);
                }
            }
            return lastTransMinusList;
        }set;
    }

    public static List<String> birthDayList{
        get{
            if(birthDayList == null){
                birthDayList = new List<String>();
                for(Account a : BirthdayReport.getQueryData(0)){
                    birthDayList.add(a.Id);
                }
            }
            return birthDayList;
        }set;
    }

    public static List<String> riskList{
        get{
            if(riskList == null){
                riskList = new List<String>();
                for(Account a : RiskReportController.getQueryData(0)){
                    riskList.add(a.Id);
                }
            }
            return riskList;
        }set;
    }

    public static List<String> pdpaList{
        get{
            if(pdpaList == null){
                pdpaList = new List<String>();
                for(Account a : PDPAReportController.getPDPAQueryData(0)){
                    pdpaList.add(a.Id);
                }
            }
            return pdpaList;
        }set;
    }

    public static List<String> marketConductList{
        get{
            if(marketConductList == null){
                marketConductList = new List<String>();
                for(Account a : PDPAReportController.getMarketConductQueryData(0)){
                    marketConductList.add(a.Id);
                }
            }
            return marketConductList;
        }set;
    }

    public static List<String> kycList{
        get{
            if(kycList == null){
                kycList = new List<String>();
                for(Account a : KYCReportController.getQueryKYCData(0)){
                    kycList.add(a.Id);
                }
            }
            return kycList;
        }set;
    }

    public static List<String> idCardList{
        get{
            if(idCardList == null){
                idCardList = new List<String>();
                for(Account a : IdCardReportController.getQueryIDCardCData(0)){
                    idCardList.add(a.Id);
                }
            }
            return idCardList;
        }set;
    }

    public static List<String> aumPlusList{
        get{
            if(aumPlusList == null){
                aumPlusList = new List<String>(); 
                for(Account a : AUMReport.getAUMPlusData(0)){
                    aumPlusList.add(a.Id);
                }
            }
            return aumPlusList;
        }set;
    }

    public static List<String> aumMinusList{
        get{
            if(aumMinusList == null){
                aumMinusList = new List<String>();
                for(Account a : AUMReport.getAUMMinusData(0)){
                    aumMinusList.add(a.Id);
                }
            }
            return aumMinusList;
        }set;
    }

    public static Map<String, String> subsegmentMap{
        get{
            if(subsegmentMap == null){
                List<Sub_Segment_Code_Mapping__mdt> subsegmentList = [SELECT Description__c, Sub_Segment_Code__c FROM Sub_Segment_Code_Mapping__mdt];
                subsegmentMap = new Map<String, String>();
                for(Sub_Segment_Code_Mapping__mdt each : subsegmentList){
                    subsegmentMap.put(each.Sub_Segment_Code__c, each.Description__c);
                }
            }
            return subsegmentMap;
        }set;
    }

    public static Map<String, Double> insuranceThisMonth{
        get{
            if(insuranceThisMonth == null){
                insuranceThisMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : insuranceAlertList){
                    if(checkMaturityMonth(each.Insurance_Anniversary_Date__c) == 0){
                        insuranceThisMonth.put(each.Customer__c, insuranceThisMonth.get(each.Customer__c) == null ? each.Insurance_Premium_Amount_Due__c : insuranceThisMonth.get(each.Customer__c) + each.Insurance_Premium_Amount_Due__c);
                    }
                }
            }
            return insuranceThisMonth;
        }set;
    }

    public static Map<String, Double> insuranceNextMonth{
        get{
            if(insuranceNextMonth == null){
                insuranceNextMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : insuranceAlertList){
                    if(checkMaturityMonth(each.Insurance_Anniversary_Date__c) == 1){
                        insuranceNextMonth.put(each.Customer__c, insuranceNextMonth.get(each.Customer__c) == null ? each.Insurance_Premium_Amount_Due__c : insuranceNextMonth.get(each.Customer__c) + each.Insurance_Premium_Amount_Due__c);
                    }
                }
            }
            return insuranceNextMonth;
        }set;
    }

    public static Map<String, Double> depositMaturThisMonth{
        get{
            if(depositMaturThisMonth == null){
                depositMaturThisMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : depositAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 0){
                        depositMaturThisMonth.put(each.Customer__c, depositMaturThisMonth.get(each.Customer__c) == null ? each.Amount__c : depositMaturThisMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return depositMaturThisMonth;
        }set;
    }

    public static Map<String, Double> depositMaturNextMonth{
        get{
            if(depositMaturNextMonth == null){
                depositMaturNextMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : depositAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 1){
                        depositMaturNextMonth.put(each.Customer__c, depositMaturNextMonth.get(each.Customer__c) == null ? each.Amount__c : depositMaturNextMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return depositMaturNextMonth;
        }set;
    }

    public static Map<String, Double> mfMaturThisMonth{
        get{
            if(mfMaturThisMonth == null){
                mfMaturThisMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : mfAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 0){
                        mfMaturThisMonth.put(each.Customer__c, mfMaturThisMonth.get(each.Customer__c) == null ? each.Amount__c : mfMaturThisMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return mfMaturThisMonth;
        }set;
    }

    public static Map<String, Double> mfMaturNextMonth{
        get{
            if(mfMaturNextMonth == null){
                mfMaturNextMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : mfAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 1){
                        mfMaturNextMonth.put(each.Customer__c, mfMaturNextMonth.get(each.Customer__c) == null ? each.Amount__c : mfMaturNextMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return mfMaturNextMonth;
        }set;
    }

    public static Map<String, Double> debMaturThisMonth{
        get{
            if(debMaturThisMonth == null){
                debMaturThisMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : debAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 0){
                        debMaturThisMonth.put(each.Customer__c, debMaturThisMonth.get(each.Customer__c) == null ? each.Amount__c : debMaturThisMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return debMaturThisMonth;
        }set;
    }

    public static Map<String, Double> debMaturNextMonth{
        get{
            if(debMaturNextMonth == null){
                debMaturNextMonth = new Map<String, Double>();
                for(Customer_Product_Alert__c each : debAlertList){
                    if(checkMaturityMonth(each.Maturity_Date__c) == 1){
                        debMaturNextMonth.put(each.Customer__c, debMaturNextMonth.get(each.Customer__c) == null ? each.Amount__c : debMaturNextMonth.get(each.Customer__c) + each.Amount__c);
                    }
                }
            }
            return debMaturNextMonth;
        }set;
    }

    public static List<Customer_Product_Alert__c> debAlertList{
        get{
            if(debAlertList == null){
                debAlertList = new List<Customer_Product_Alert__c>();
                for(Customer_Product_Alert__c each : dpmfdebAlertList){
                    if(each.Financial_Account_Group__c == 'DEB'){
                        debAlertList.add(each);
                    } 
                }
            }
            return debAlertList;
        }set;
    }

    public static List<Customer_Product_Alert__c> mfAlertList{
        get{
            if(mfAlertList == null){
                mfAlertList = new List<Customer_Product_Alert__c>();
                for(Customer_Product_Alert__c each : dpmfdebAlertList){
                    if(each.Financial_Account_Group__c == 'MF'){
                        mfAlertList.add(each);
                    } 
                }
            }
            return mfAlertList;
        }set;
    }

    public static List<Customer_Product_Alert__c> depositAlertList{
        get{
            if(depositAlertList == null){
                depositAlertList = new List<Customer_Product_Alert__c>();
                for(Customer_Product_Alert__c each : dpmfdebAlertList){
                    if(each.Financial_Account_Group__c == 'DP'){
                        depositAlertList.add(each);
                    }
                }
            }
            return depositAlertList;
        }set;
    }

    public static List<Customer_Product_Alert__c> insuranceAlertList{
        get{
            if(insuranceAlertList == null){
                insuranceAlertList = [SELECT Id, Customer__c, Insurance_Anniversary_Date__c, Insurance_Premium_Amount_Due__c FROM Customer_Product_Alert__c WHERE (Customer__r.RTL_Wealth_RM__c =:currentUserId OR Customer__r.OwnerId =:currentUserId) AND Financial_Account_Group__c = 'BA' AND (Insurance_Anniversary_Date__c = THIS_MONTH OR Insurance_Anniversary_Date__c = NEXT_MONTH) LIMIT 50000];
            }
            return insuranceAlertList;
        }set;
    }

    public static List<Customer_Product_Alert__c> dpmfdebAlertList{
        get{
            if(dpmfdebAlertList == null){
                dpmfdebAlertList = [SELECT Id, Customer__c, Maturity_Date__c, Financial_Account_Group__c, Amount__c FROM Customer_Product_Alert__c WHERE (Customer__r.RTL_Wealth_RM__c =:currentUserId OR Customer__r.OwnerId =:currentUserId) AND (Financial_Account_Group__c = 'DP' OR Financial_Account_Group__c = 'MF' OR Financial_Account_Group__c = 'DEB') AND (Maturity_Date__c = THIS_MONTH OR Maturity_Date__c = NEXT_MONTH) LIMIT 50000];
            }
            return dpmfdebAlertList;
        }set;
    }

    public static Map<String, Object> accIdLastActivityDate{
        get{
            if(accIdLastActivityDate == null){
                accIdLastActivityDate = new Map<String, Object>();
                List<Task> taskList = [SELECT Id, Subject, LastModifiedDate, AccountId FROM Task WHERE AccountId IN :currentWealthRmCustomer AND LastModifiedDate <= Last_N_Days:90 ORDER BY LastModifiedDate DESC LIMIT 50000];
                for(Task t : taskList){
                    Map<String, Object> lastTaskNameDateMap = new Map<String, Object>();
                    lastTaskNameDateMap.put('taskName', t.Subject + '');
                    lastTaskNameDateMap.put('lastModifiedString', t.LastModifiedDate.format());
                    lastTaskNameDateMap.put('lastModifiedDate', t.LastModifiedDate);
                    if(accIdLastActivityDate.get(t.AccountId) == null){
                        accIdLastActivityDate.put(t.AccountId, lastTaskNameDateMap);
                    }
                }
            }
            return accIdLastActivityDate;
        }set;
    }

    private class FilterWrapper {
        @AuraEnabled
        public Id filterId;
        @AuraEnabled
        public String fieldApi;
        @AuraEnabled
        public String filterLabel;
        @AuraEnabled
        public List<My_Customer_Filter_Option__c> optionList;
    }

    @AuraEnabled
    public static List<FilterWrapper> getFilters() {
        try{
            List<My_Customer_Filter__c> filters = [SELECT Id, Name, Field_API__c FROM My_Customer_Filter__c WHERE Active__c = TRUE ORDER BY Order__c LIMIT 10];
            Set <Id> filterIdSet = new Set<Id>();
            for (My_Customer_Filter__c eachFilter : filters) {
                filterIdSet.add(eachFilter.Id);
            }
            List<My_Customer_Filter_Option__c> filterOption = [SELECT Id, Name, Filter_Value__c, Filter_Max__c, Filter_Min__c, My_Customer_Filter__c, RecordType.Name FROM My_Customer_Filter_Option__c WHERE Active__c = TRUE AND My_Customer_Filter__c IN :filterIdSet ORDER BY Order__c];
            
            List<FilterWrapper> filterList = new List<FilterWrapper>();
            
            Map<Id, List<My_Customer_Filter_Option__c>> mapOptionFilterId = new Map<Id, List<My_Customer_Filter_Option__c>>(); 
            for (My_Customer_Filter_Option__c option : filterOption) {
                
                if (mapOptionFilterId.containsKey(option.My_Customer_Filter__c)) {
                    mapOptionFilterId.get(option.My_Customer_Filter__c).add(option);
                } else {
                    mapOptionFilterId.put(option.My_Customer_Filter__c ,new List<My_Customer_Filter_Option__c>{option});
                }
            }
            
            for (My_Customer_Filter__c filter : filters) {
                FilterWrapper newFilterWrapper = new FilterWrapper();
                newFilterWrapper.filterId = filter.Id;
                newFilterWrapper.fieldApi = filter.Field_API__c;
                newFilterWrapper.filterLabel = filter.Name;
                newFilterWrapper.optionList = mapOptionFilterId.get(filter.Id);
                filterList.add(newFilterWrapper);
            }
            
            return filterList;
        }catch(Exception e){
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Object> getCustomerTableData(List<Object> params) {
        String message = checkFilterField(params);
        if(checkFilterField(params) != 'Success'){
            throw newMessageException(message);
        }

        try{
            String query = 'SELECT ';
            List<String> fieldList = new List<String>{
                'Id,',
                'TMB_Customer_ID_PE__c,',
                'First_name_PE__c,', 
                'RMC_Next_Birthday__c,',
                'RMC_Sum_of_Deposit_Amount__c,',
                'RMC_Suitability_Risk_Expiry_Date__c,',
                'RMC_AUM__c,',
                'RMC_Has_PDPA__c,',
                'KYC_next_review_date__c,',
                'RMC_ID_Card_Expiry_Date__c,',
                'RMC_Has_Market_Conduct__c,',
                'RMC_AUM_Change__c,',
                'RMC_Sum_of_MF_Current_Amount__c,',
                'RTL_Date_Of_Birth__c,',
                'RMC_Relationship_Level__c,',
                'RTL_Age__c,',
                'Sub_segment__c,',
                'RMC_NFX_Rate__c,',
                'RMC_Allfree_OS__c,',
                'RMC_TD_OS__c,',
                'RMC_NFX_OS__c,',
                'RMC_OtherDP_OS__c,',
                'RMC_Suitability_Risk_Level__c,',
                'RMC_MF_Gain_Loss_Percent__c,',
                'CC_Reserve_Eligible__c,',
                'CC_Reserve_Anual_Point__c,',
                'CC_Other_Point_Balance__c,',
                'CC_Reserve_Point__c,',
                'RMC_Wealth_Flag__c,',
                'Sub_Segment_Key__c,',
                'RTL_Age_Range__c,',
                'RMC_AUM_RANGE__c,',
                'RMC_Shareholder_Flag__c,',
                'RMC_MOU_Payroll_Flag__c,',
                'Last_Selected_Date__c,',
                'RMC_Sub_Debt_Flag__c,',
                'RMC_Suitability_Risk_Level_Required__c'
            };
            for(String field : fieldList){
                query += field + ' ';
            }
            query += 'FROM Account ';        
            String whereSOQl = 'WHERE (OwnerId = \'' + currentUserId + '\' OR RTL_Wealth_RM__c = \'' + currentUserId + '\')';
            for (Object obj : params) {
                Map<String, Object> selectedFilter = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                whereSOQL += ' AND';
                if (selectedFilter.get('recordType') == 'Text Equals') {
                    Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldNameTypeMap.get(String.valueOf(selectedFilter.get('fieldApi')).toLowercase()))); 
                    String type = attributeMap.get('type') + '';
                    if(type == 'STRING' || type == 'TEXTAREA' || type == 'ADDRESS' || type == 'PICKLIST' || type == 'REFERENCE' || type == 'BOOLEAN'){
                        whereSOQL += ' ' + selectedFilter.get('fieldApi') + ' = \'' + selectedFilter.get('value') + '\'';
                    }
                    else{
                        whereSOQL += ' ' + selectedFilter.get('fieldApi') + ' = ' + selectedFilter.get('value');
                    }
                } else if (selectedFilter.get('recordType') == 'Range Number') {
                    if (selectedFilter.get('min') != null && selectedFilter.get('max') != null) {
                        whereSOQL += ' (' + selectedFilter.get('fieldApi') + ' >= ' + selectedFilter.get('min')
                            + ' AND ' + selectedFilter.get('fieldApi') + ' <= ' + selectedFilter.get('max') + ')';
                    } else if (selectedFilter.get('min') != null) {
                        whereSOQL += ' (' + selectedFilter.get('fieldApi') + ' >= ' + selectedFilter.get('min') + ')';
                    } else {
                        whereSOQL += ' (' + selectedFilter.get('fieldApi') + ' <= ' + selectedFilter.get('max') + ')';
                    }
                }
            }
            query += whereSOQL;
            List<Object> outputList = prepCustomerTableData(query);
            return outputList;
        }catch(Exception e){
            throw newMessageException(e.getMessage());
        }
    }

    public static String checkFilterField(List<Object> paramsList){
        List<String> fieldSet = new List<String>(fieldNameTypeMap.keySet());
        for(Object each : paramsList){
            Map<String, Object> per = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(each));
            String currentField = String.valueOf(per.get('fieldApi')).toLowercase();
            String currentLabel = String.valueOf(per.get('filterLabel')).toLowercase();
            if(!fieldSet.contains(currentField)){
                return String.format(System.Label.My_Customer_Filter_Validation_Message, new List<Object>{ currentLabel, 'Account', currentField });
            }
            else{
                Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldNameTypeMap.get(currentField)));
                if(attributeMap.get('encrypted') == true){
                    return String.format(System.Label.My_Customer_Filter_Validation_Message, new List<Object>{ currentLabel, 'Account', currentField });
                }
            }
        }
        return 'Success';
    }


    private static List<Object> prepCustomerTableData(String query){
        List<Object> outputList = new List<Object>();
        List<String> accountIdList = new List<String>();
        try{
            List<Account> accountList = Database.query(query);
            accountList.sort();
            for(Account each : accountList){
                currentWealthRmCustomer.add(each.Id);
            }
            for(Account each : accountList){
                Double amoutInsThisMonth = insuranceThisMonth.get(each.Id) == null ? 0 : insuranceThisMonth.get(each.Id);
                Double amountDPThisMonth = depositMaturThisMonth.get(each.Id) == null ? 0 : depositMaturThisMonth.get(each.Id);
                Double amoutMFThisMonth = mfMaturThisMonth.get(each.Id) == null ? 0 : mfMaturThisMonth.get(each.Id);
                Double amountDEBThisMonth = debMaturThisMonth.get(each.Id) == null ? 0 : debMaturThisMonth.get(each.Id);
                Double allMaturityThisMonth = amoutInsThisMonth + amountDPThisMonth + amoutMFThisMonth + amountDEBThisMonth;
    
                Double amoutInsNextMonth = insuranceNextMonth.get(each.Id) == null ? 0 : insuranceNextMonth.get(each.Id);
                Double amountDPNextMonth = depositMaturNextMonth.get(each.Id) == null ? 0 : depositMaturNextMonth.get(each.Id);
                Double amoutMFNextMonth = mfMaturNextMonth.get(each.Id) == null ? 0 : mfMaturNextMonth.get(each.Id);
                Double amountDEBNextMonth = debMaturNextMonth.get(each.Id) == null ? 0 : debMaturNextMonth.get(each.Id);
                Double allMaturityNextMonth = amoutInsNextMonth + amountDPNextMonth + amoutMFNextMonth + amountDEBNextMonth;
    
                Map<String, Object> taskSubjectLastModifyMap = (Map<String, Object>)accIdLastActivityDate.get(each.Id);

                Map<String, Object> perCust = new Map<String, Object>();
                perCust.put('id', each.Id);
                perCust.put('tmb_cust_id', each.TMB_Customer_ID_PE__c);
                perCust.put('candidate', false);
                perCust.put('name', each.First_name_PE__c);
                perCust.put('product_trigger', dormantAccountIdList.contains(each.Id) || depositInvestmentList.contains(each.Id) || mfMaturityList.contains(each.Id) || insuranceAnniList.contains(each.Id) || insuranPaidUpList.contains(each.Id) || insuranMaturityList.contains(each.Id) ? 'Yes' : 'No');
                perCust.put('moment_trigger', birthDayList.contains(each.Id) ? 'Yes' : 'No');
                perCust.put('regulartion_trigger', riskList.contains(each.Id) || marketConductList.contains(each.Id) || pdpaList.contains(each.Id) || kycList.contains(each.Id) || idCardList.contains(each.Id) ? 'Yes' : 'No');
                perCust.put('portfolio_trigger', aumMinusList.contains(each.Id) || aumPlusList.contains(each.Id) || lastTransMinusList.contains(each.Id) || lastTransPlusList.contains(each.Id) ? 'Yes' : 'No');
                perCust.put('campaign_trigger', 'No');
                perCust.put('last_activity', taskSubjectLastModifyMap == null ? '-' : taskSubjectLastModifyMap.get('taskName'));
                perCust.put('last_activity_dateTime', taskSubjectLastModifyMap == null ? '-' : taskSubjectLastModifyMap.get('lastModifiedString'));
                perCust.put('aum_is', getCents(each.RMC_AUM__c));
                perCust.put('dp_op', getCents(each.RMC_Sum_of_Deposit_Amount__c));
                perCust.put('mf_os', getCents(each.RMC_Sum_of_MF_Current_Amount__c));
                perCust.put('age', each.RTL_Age__c == null ? '' : each.RTL_Age__c + '');
                perCust.put('relationship', each.RMC_Relationship_Level__c == null ? '-' : each.RMC_Relationship_Level__c);
                perCust.put('mfGainLoss', each.RMC_MF_Gain_Loss_Percent__c == null ? '0.00%' : each.RMC_MF_Gain_Loss_Percent__c + '%');
                perCust.put('suit_score', each.RMC_Suitability_Risk_Level__c == null ? '-' : each.RMC_Suitability_Risk_Level__c + '');
                perCust.put('debenture_flag', each.RMC_Sub_Debt_Flag__c == null ? 'No' : each.RMC_Sub_Debt_Flag__c);
                perCust.put('cust_sub_segment', each.Sub_segment__c == null ? '-' : subsegmentMap.get(each.Sub_segment__c));
                perCust.put('insurnace_anni_this_month', insuranceThisMonth.get(each.Id) == null ? '0.00' : getCents(insuranceThisMonth.get(each.Id)));
                perCust.put('insurnace_anni_next_month', insuranceNextMonth.get(each.Id) == null ? '0.00' : getCents(insuranceNextMonth.get(each.Id)));
                perCust.put('deposit_matur_this_month', depositMaturThisMonth.get(each.Id) == null ? '0.00' : getCents(depositMaturThisMonth.get(each.Id)));
                perCust.put('deposit_matur_next_month', depositMaturNextMonth.get(each.Id) == null ? '0.00' : getCents(depositMaturNextMonth.get(each.Id)));
                perCust.put('mf_matur_this_month', mfMaturThisMonth.get(each.Id) == null ? '0.00' : getCents(mfMaturThisMonth.get(each.Id)));
                perCust.put('mf_matur_next_month', mfMaturNextMonth.get(each.Id) == null ? '0.00' : getCents(mfMaturNextMonth.get(each.Id)));
                perCust.put('deb_matur_this_month', debMaturThisMonth.get(each.Id) == null ? '0.00' : getCents(debMaturThisMonth.get(each.Id)));
                perCust.put('deb_matur_next_month', debMaturNextMonth.get(each.Id) == null ? '0.00' : getCents(debMaturNextMonth.get(each.Id)));
                perCust.put('all_matur_this_month', getCents(allMaturityThisMonth));
                perCust.put('all_matur_next_month', getCents(allMaturityNextMonth));
                perCust.put('nfx_rate', each.RMC_NFX_Rate__c == null ? '0.00%' : each.RMC_NFX_Rate__c + '%');
                perCust.put('nfx_os', getCents(each.RMC_NFX_OS__c));
                perCust.put('td_os', getCents(each.RMC_TD_OS__c));
                perCust.put('allFree_os', getCents(each.RMC_Allfree_OS__c));
                perCust.put('wealth_flag', each.RMC_Wealth_Flag__c == null ? 'No' : each.RMC_Wealth_Flag__c);
                perCust.put('cc_reserve_eligible', each.CC_Reserve_Eligible__c == null ? 'No' : each.CC_Reserve_Eligible__c);
                perCust.put('cc_other_point_balance', getCents(each.CC_Other_Point_Balance__c));
                perCust.put('cc_reserve_annual_point', getCents(each.CC_Reserve_Anual_Point__c));
                perCust.put('cc_reserve_point', getCents(each.CC_Reserve_Point__c));
                perCust.put('age_range', each.RTL_Age__c == null ? '' : each.RTL_Age_Range__c);
                perCust.put('aum_range', each.RMC_AUM_RANGE__c);
                perCust.put('other_deposit_os', getCents(each.RMC_OtherDP_OS__c));
                perCust.put('shareholder_flag', each.RMC_Shareholder_Flag__c == null ? 'No' : each.RMC_Shareholder_Flag__c);
                perCust.put('mou_payroll_flag', each.RMC_MOU_Payroll_Flag__c == null ? 'No' : each.RMC_MOU_Payroll_Flag__c);
                perCust.put('last_selected_date', each.Last_Selected_Date__c == null ? '-' : each.Last_Selected_Date__c.format());

                //for sorting
                perCust.put('aum_is_double', each.RMC_AUM__c == null ? 0 : each.RMC_AUM__c);
                perCust.put('dp_op_double', each.RMC_Sum_of_Deposit_Amount__c == null ? 0 : each.RMC_Sum_of_Deposit_Amount__c);
                perCust.put('mf_os_double', each.RMC_Sum_of_MF_Current_Amount__c == null ? 0 : each.RMC_Sum_of_MF_Current_Amount__c);
                perCust.put('mfGainLoss_double', each.RMC_MF_Gain_Loss_Percent__c == null ? 0 : each.RMC_MF_Gain_Loss_Percent__c);
                perCust.put('cc_ttb_reserve_invitation_value', each.CC_Reserve_Eligible__c == 'Yes' ? 0 : 1);
                perCust.put('last_selected_date_value', each.Last_Selected_Date__c == null ? null : each.Last_Selected_Date__c);
                perCust.put('last_activity_dateTime_value', taskSubjectLastModifyMap == null ? null : taskSubjectLastModifyMap.get('lastModifiedDate'));
                outputList.add(perCust);
            }
            return outputList;
        }catch(Exception e){
            throw newMessageException(e.getMessage()); 
        }
    }

    private static String getCents(Decimal x){
        try{
            String i = String.valueOf(x);
            if(i.contains('.')){
                String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
                String p = s.substring(0,s.length()-1);
                return p;
            }
            else{
                List<String> args = new String[]{'0','number','###,###,##0.00'};
                String s = String.format(x.format(), args);
                return s + '.00';
            }
        }
        catch(Exception e){
            return '0.00';
        }
    }

    private static Integer checkMaturityMonth(Date maturityDate){
        try{
            Date toDay = date.today();
            return toDay.monthsBetween(maturityDate);
        }catch(Exception e){
            return -1;
        }
    }

    @AuraEnabled
    public static List<Object> createTaskForSelectedAccount(List<String> accIdList){
        return RM_Cockpit_My_Customer_CreateTask.createTaskHelper(accIdList);
    }

    public static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    @AuraEnabled
    public static String getCurrentUserName(){
        try {
            return currentUserName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getFieldLabelTaskMap(){
        return RM_Cockpit_My_Customer_CreateTask.fieldLabelMap;
    }

    @AuraEnabled
    public static Map<String, Object> getTaskCustomSetting(){
        return RM_Cockpit_My_Customer_CreateTask.appConfig;
    }
}