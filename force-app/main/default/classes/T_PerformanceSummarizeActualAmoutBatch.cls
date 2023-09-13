public class T_PerformanceSummarizeActualAmoutBatch implements Database.Batchable<sObject>, Database.stateful {

    private String query;
    private Map<String, Decimal> actualMap = new Map<String, Decimal>();
    private Integer targetUpsertSize = 0;
    private List<T_Performance_Target_Product_by_Team__c> targetList = new List<T_Performance_Target_Product_by_Team__c>();

    private String currentLevel;
    private String year;
    private String month;
    private String recordTypeIdBranch = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_branch').getRecordTypeId();
    private String recordTypeIdZone = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_zone').getRecordTypeId();
    private String recordTypeIdRegion = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_region').getRecordTypeId();
    private String recordTypeIdChannel = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_channel').getRecordTypeId();
    private String recordTypeIdGOC = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_group_of_channel').getRecordTypeId();
    private String recordTypeIdRetail = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_retail').getRecordTypeId();

    private Integer recordToSum = 0;
    private Integer recordUpsertProcessed = 0;
    private Integer recordUpsertSuccessful = 0;
    private Integer recordUpsertFailed = 0;

	private Datetime batchDate = datetime.now(); 
	private Datetime batchStartTime = datetime.now();
	private Datetime batchEndTime = null;

    private Integer BATCH_CHUNK_SIZE = 2000;
    private List<Summary_Team_and_Product__c> productActual = new List<Summary_Team_and_Product__c>();

    public T_PerformanceSummarizeActualAmoutBatch(String level, String year, String month, Integer BATCH_CHUNK_SIZE, List<Summary_Team_and_Product__c> productActual){
        // this.query = q;
        this.currentLevel = level;
        this.year = year;
        this.month = month;
        this.BATCH_CHUNK_SIZE = BATCH_CHUNK_SIZE;
        this.productActual = productActual;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Start Summarize '+this.currentLevel);
        this.recordUpsertSuccessful = 0;
        this.targetUpsertSize = 0;
        this.actualMap.clear();

        if(this.productActual == null) { //first time
            this.productActual = [SELECT Id,Year__c,Month__c,Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c,Indicator_Code__c,Actual_Amount__c FROM Summary_Team_and_Product__c WHERE Month__c =: month and Year__c =: year];
        }    
        String actualKey;
        if(this.currentLevel == 'branch') {
            for(Summary_Team_and_Product__c product : this.productActual) {
                actualKey = product.Year__c+product.Month__c+product.Channel_Name__c+product.Region_Code__c+product.Zone_Code__c+product.Branch_Team_Code__c+product.Indicator_Code__c;
                this.actualMap.put(actualKey,product.Actual_Amount__c);
            }
        } else if(this.currentLevel == 'zone') {
            for(Summary_Team_and_Product__c product : this.productActual) {
                actualKey = product.Year__c+product.Month__c+product.Channel_Name__c+product.Region_Code__c+product.Zone_Code__c+product.Indicator_Code__c;
                product.Actual_Amount__c = product.Actual_Amount__c == null ? 0 : product.Actual_Amount__c;
                if(this.actualMap.containsKey(actualKey)) {
                    Decimal old_act_amount = this.actualMap.get(actualKey);
                    this.actualMap.put(actualKey,old_act_amount + product.Actual_Amount__c);
                } else {
                    this.actualMap.put(actualKey,product.Actual_Amount__c);
                }
            }

        } else if(this.currentLevel == 'region') {
            for(Summary_Team_and_Product__c product : this.productActual) {
                actualKey = product.Year__c+product.Month__c+product.Channel_Name__c+product.Region_Code__c+product.Indicator_Code__c;
                product.Actual_Amount__c = product.Actual_Amount__c == null ? 0 : product.Actual_Amount__c;
                if(this.actualMap.containsKey(actualKey)) {
                    Decimal old_act_amount = this.actualMap.get(actualKey);
                    this.actualMap.put(actualKey,old_act_amount + product.Actual_Amount__c);
                } else {
                    this.actualMap.put(actualKey,product.Actual_Amount__c);
                }
            }
        } else if(this.currentLevel == 'channel') {
            for(Summary_Team_and_Product__c product : this.productActual) {
                actualKey = product.Year__c+product.Month__c+product.Channel_Name__c+product.Indicator_Code__c;
                product.Actual_Amount__c = product.Actual_Amount__c == null ? 0 : product.Actual_Amount__c;
                if(this.actualMap.containsKey(actualKey)) {
                    Decimal old_act_amount = this.actualMap.get(actualKey);
                    this.actualMap.put(actualKey,old_act_amount + product.Actual_Amount__c);
                } else {
                    this.actualMap.put(actualKey,product.Actual_Amount__c);
                }
            }
        }
        

        if( this.currentLevel == 'branch'){
            this.query = 'SELECT Id, Product_Group_Name__c, Actual_Amount__c, Cap_Max_Pct__c, Target_Unit_Month__c, Target_Unit_Year__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c, Branch_Point_Engine__c FROM T_Performance_Target_Product_by_Team__c WHERE Year__c = \'' + this.year +  '\' AND Month__c = \'' + this.month + '\' AND RecordTypeId=\'' + this.recordTypeIdBranch + '\'';
        } else if(this.currentLevel == 'zone'){
            this.query = 'SELECT Id, Product_Group_Name__c, Actual_Amount__c, Cap_Max_Pct__c, Target_Unit_Month__c, Target_Unit_Year__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c, Branch_Point_Engine__c FROM T_Performance_Target_Product_by_Team__c WHERE Year__c = \'' + this.year +  '\' AND Month__c = \'' + this.month + '\' AND RecordTypeId=\'' + this.recordTypeIdZone + '\'';
        }
        else if(this.currentLevel == 'region'){
            this.query = 'SELECT Id, Product_Group_Name__c, Actual_Amount__c, Cap_Max_Pct__c, Target_Unit_Month__c, Target_Unit_Year__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c, Branch_Point_Engine__c FROM T_Performance_Target_Product_by_Team__c WHERE Year__c = \'' + this.year +  '\' AND Month__c = \'' + this.month + '\' AND RecordTypeId=\'' + this.recordTypeIdRegion + '\'';
        }
        else if(this.currentLevel == 'channel'){
            this.query = 'SELECT Id, Product_Group_Name__c, Actual_Amount__c, Cap_Max_Pct__c, Target_Unit_Month__c, Target_Unit_Year__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c, Branch_Point_Engine__c FROM T_Performance_Target_Product_by_Team__c WHERE Year__c = \'' + this.year +  '\' AND Month__c = \'' + this.month + '\' AND RecordTypeId=\'' + this.recordTypeIdChannel + '\'';
        }
        else if(this.currentLevel == 'group of channel'){
            this.query = 'SELECT Id, Product_Group_Name__c, Actual_Amount__c, Cap_Max_Pct__c, Target_Unit_Month__c, Target_Unit_Year__c, Branch_Team_Code__c, Region_Code__c, Indicator_Level1__c, Zone_Code__c, Year__c, Month__c, Product_Group_Code__c, Product_List__c, Group_Channel__c, Channel_Name__c, Rank__c, Branch_Point_Engine__c FROM T_Performance_Target_Product_by_Team__c WHERE Year__c = \'' + this.year +  '\' AND Month__c = \'' + this.month + '\' AND RecordTypeId=\'' + this.recordTypeIdChannel + '\'';
        }

        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<T_Performance_Target_Product_by_Team__c> scope){
        this.recordToSum += scope.size();
        List<T_Performance_Target_Product_by_Team__c> listTargetToUpsert = new List<T_Performance_Target_Product_by_Team__c>();
        Map<String, T_Performance_Target_Product_by_Team__c> mapTargetToUpsert = new Map<String, T_Performance_Target_Product_by_Team__c>();
        if( this.currentLevel == 'branch' || this.currentLevel == 'zone' || this.currentLevel == 'region' || this.currentLevel == 'channel'){
            for(T_Performance_Target_Product_by_Team__c eachTarget : scope){
                Decimal newValue = 0;
                // List<String> splitKey = String.valueOf(eachTarget.get('')).split(';');
                String mapProductKey;
                String targetMainKey;
                if(this.currentLevel == 'branch') {
                    mapProductKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Region_Code__c')) + String.valueOf(eachTarget.get('Zone_Code__c')) + String.valueOf(eachTarget.get('Branch_Team_Code__c'));
                } else if(this.currentLevel == 'zone') {
                    // targetMainKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Group_Channel__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Region_Code__c')) + String.valueOf(eachTarget.get('Zone_Code__c')) + String.valueOf(eachTarget.get('Product_Group_Code__c'));
                    mapProductKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Region_Code__c')) + String.valueOf(eachTarget.get('Zone_Code__c'));
                } else if(this.currentLevel == 'region') {
                    // targetMainKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Group_Channel__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Region_Code__c')) + String.valueOf(eachTarget.get('Product_Group_Code__c'));
                    mapProductKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Region_Code__c'));
                } else if(this.currentLevel == 'channel') {
                    // targetMainKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Group_Channel__c')) + String.valueOf(eachTarget.get('Channel_Name__c')) + String.valueOf(eachTarget.get('Product_Group_Code__c'));
                    mapProductKey = String.valueOf(eachTarget.get('Year__c')) + String.valueOf(eachTarget.get('Month__c')) + String.valueOf(eachTarget.get('Channel_Name__c'));
                }
                List<String> indiList =  String.valueOf(eachTarget.get('Product_List__c')).split(';');
                for(String indicatorCode : indiList){
                    String sumKey = mapProductKey + indicatorCode;
                    System.debug('Debug get product amount key = '+sumKey+' result='+this.actualMap.get(sumKey));
                    if(this.actualMap.get(sumKey) != null){
                        newValue += this.actualMap.get(sumKey);
                    }
                }
                System.debug('Debug new value '+newValue);
                eachTarget.Actual_Amount__c = newValue; // actual amount without cap max
                // this.targetToUpsertList.add(eachTarget);
                listTargetToUpsert.add(eachTarget);
            }

        } else if(this.currentLevel == 'group of channel'){ // sum up
            Map<String, T_Performance_Target_Product_by_Team__c> targetMap = new Map<String, T_Performance_Target_Product_by_Team__c>();
            Map<String, Decimal> targetMonthMap = new Map<String, Decimal>();
            Map<String, Decimal> targetYearMap = new Map<String, Decimal>();
            for(T_Performance_Target_Product_by_Team__c each : scope){
                String mainKey = String.valueOf(each.get('Year__c')) + String.valueOf(each.get('Month__c')) + String.valueOf(each.get('Group_Channel__c')) + String.valueOf(each.get('Product_Group_Code__c'));

                if(mapTargetToUpsert.containsKey(mainKey)) {
                    mapTargetToUpsert.get(mainKey).Actual_Amount__c += each.Actual_Amount__c;
                } else {
                    T_Performance_Target_Product_by_Team__c upsertTarget = new T_Performance_Target_Product_by_Team__c(); 
                    upsertTarget.Actual_Amount__c = each.Actual_Amount__c == null ? 0 : each.Actual_Amount__c;
                    upsertTarget.Unique_External_Key__c = mainKey;
                    mapTargetToUpsert.put(mainKey,upsertTarget);
                }
            }
        }


        if(listTargetToUpsert.size() > 0){
            System.debug('::::::::: Finish T-Performance Summarize Target ::::::::::::::::');
            this.targetUpsertSize = this.targetUpsertSize + listTargetToUpsert.size();
            for(T_Performance_Target_Product_by_Team__c record : listTargetToUpsert) {
                record.Actual_Amount__c = record.Actual_Amount__c;
                // .setscale(2,RoundingMode.HALF_UP);
            }
            Database.SaveResult[] logUpsertResult = Database.update(new List<T_Performance_Target_Product_by_Team__c>(listTargetToUpsert), false);
            for (Database.SaveResult logUpsert : logUpsertResult) {
                if (logUpsert.isSuccess()) {
                    this.recordUpsertSuccessful++;
                } 
                List<Database.Error> errors = logUpsert.getErrors();
                for(Database.Error theError:Errors) {
                    System.debug(theError);
                }
            } 
        } else if(mapTargetToUpsert.size() > 0){
            System.debug(this.currentLevel);
            System.debug('::::::::: Finish T-Performance Summarize Target ::::::::::::::::');
            this.targetUpsertSize = this.targetUpsertSize + mapTargetToUpsert.size();
            // System.debug('New Target '+ this.targetToUpsertMap.values());
            for(T_Performance_Target_Product_by_Team__c record : mapTargetToUpsert.values()) {
                record.Actual_Amount__c = record.Actual_Amount__c;
                // .setscale(2,RoundingMode.HALF_UP);
            }
            Schema.SObjectField fToken = T_Performance_Target_Product_by_Team__c.Fields.Unique_External_Key__c;
            Database.UpsertResult[] logUpsertResult = Database.upsert(mapTargetToUpsert.values(), fToken, false);
            for (Database.UpsertResult logUpsert : logUpsertResult) {
                if (logUpsert.isSuccess()) {
                    this.recordUpsertSuccessful++;
                } 
                List<Database.Error> errors = logUpsert.getErrors();
                for(Database.Error theError:Errors) {
                    System.debug(theError);
                }
            } 
        }
    }

    public void finish(Database.BatchableContext bc){ 
        if(this.targetUpsertSize > 0) {
            this.recordUpsertFailed = this.targetUpsertSize - this.recordUpsertSuccessful;
        }

        batchEndTime = datetime.now();

        String filename = 'T-Performance Summarize Data '+this.month+'/'+this.year+' ('+this.currentLevel+')';
        String sObjectName = 'T_Performance_Target_Product_by_Team__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');
        // sendToEmail.add('sry@ii.co.th'); // **********************

        String csvHeaderStr = '';
        String CSV_BODY = '';

        System.debug('check send mail '+this.recordUpsertFailed + ' + ' + this.recordUpsertSuccessful);
        if(this.recordUpsertFailed + this.recordUpsertSuccessful > 0){
            System.debug('Send email '+this.currentLevel);
            RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , this.recordUpsertSuccessful
                                                        , this.recordUpsertFailed
                                                        , csvHeaderStr
                                                        , filename
                                                        , sObjectName
                                                        , sendToEmail
                                                        , CSV_BODY);
        }
        String nextLevel = null;
        if(this.recordUpsertSuccessful == this.targetUpsertSize && this.targetUpsertSize != 0){
            if(this.currentLevel == 'branch') {
                nextLevel = 'zone';
            }
            else if(this.currentLevel == 'zone'){
                nextLevel = 'region';
            }
            else if(this.currentLevel == 'region'){
                nextLevel = 'channel';
            }
            else if(this.currentLevel == 'channel'){
                nextLevel = 'group of channel';
            }
        }

        if(nextLevel != null) {
            Database.executeBatch(new T_PerformanceSummarizeActualAmoutBatch(nextLevel, this.year, this.month, this.BATCH_CHUNK_SIZE, this.productActual), this.BATCH_CHUNK_SIZE); 
        } // disabled for phasing 1.2
    }

}