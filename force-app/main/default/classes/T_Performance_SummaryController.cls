public with sharing class T_Performance_SummaryController{
    @AuraEnabled
    public static string getWatermarkHTML(){
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c
                          From User
                          Where Id = :userId
                          Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;
    }

    public static User currUser{
        get{
            currUser = [SELECT Id, UserRoleName__c, Profile.Name, Region_Code__c, Zone_Code__c, RTL_Branch_Code__c
                        from User
                        WHERE Id = :UserInfo.getUserId()
                        LIMIT 1];
            return currUser;
        }

        set;
    }

    public static List<T_Performance_Permission__mdt> tperf_Permission{
        get{
            if (tperf_Permission == null){
                List<T_Performance_Permission__mdt> TperfMDT = new List<T_Performance_Permission__mdt>();
                List<T_Performance_Permission__mdt> TMDT = [SELECT Summary_Page__c, Group_of_Channel__c, Channel__c, SF_Role__c, SummaryByTypeFieldMapping__c
                                                            FROM T_Performance_Permission__mdt
                                                            WHERE SF_Profile__c = :currUser.Profile.Name AND SF_Profile__c != null AND SF_Role__c != null];
                System.debug(TMDT.size());
                for (T_Performance_Permission__mdt TperfPerm : TMDT){
                    // System.debug('user:' + currUser.UserRoleName__c);
                    // System.debug('1234' + TperfPerm);
                    if (currUser.UserRoleName__c.startsWith(TperfPerm.SF_Role__c)){
                        TperfMDT.add(TperfPerm);
                    }
                }
                tperf_Permission = TperfMDT;
            }
            return tperf_Permission;
        }

        set;
    }

    public class targetProductWrapper{
        @AuraEnabled
        public T_Performance_Onedown_Controller.chunkQueryWrapper targetProdList;
        @AuraEnabled
        public Boolean isData;
    }
    public class summaryPageWrapper{
        @AuraEnabled
        public List<String> summaryPageValue;
        @AuraEnabled
        public String summaryPage;
        @AuraEnabled
        public String channelValue;
        @AuraEnabled
        public String level;
        @AuraEnabled
        public String getActual;
        @AuraEnabled
        public List<String> getActualValue;
        @AuraEnabled
        public String queryField;
        @AuraEnabled
        public String onedownValue;
    }

    public class actualMapWrapper{
        @AuraEnabled
        public Map<String, Decimal> mapProductWithActual;
        @AuraEnabled
        public Map<String, Decimal> mapProductWithActualMTD;
        @AuraEnabled
        public Map<String, Decimal> mapActualWithRunrate;
    }

    public class summaryPagebyTypeWrapper{
        @AuraEnabled
        public String summaryPagebyTypeValue;
        @AuraEnabled
        public String summaryPagebyType;
    }

    @AuraEnabled
    public static summaryPageWrapper getSummaryPage(String summaryPage, String summaryPageValue, String channelName){
        System.debug('Start Apex --> ' + Datetime.Now());
        summaryPageWrapper SPW = new summaryPageWrapper();
        SPW.channelValue = channelName;

        system.debug('summaryPage' + summaryPage);
        system.debug('summaryPageValue' + summaryPageValue);
        system.debug('SPW.channelValue' + SPW.channelValue);
        if (summaryPage != null && summaryPageValue != null && summaryPage != '' && summaryPageValue != ''){
            List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
            SPW.queryField = summaryPage;
            if (summaryPage == 'Group_Channel__c'){
                SPW.summaryPage = 'Group of channel';
                SPW.onedownValue = 'Group of channel';
                SPW.level = 'level_group_of_channel';
                List<String> stringSpiltData = new List<String>();
                stringSpiltData.add('\'' + summaryPageValue + '\'');
                SPW.summaryPageValue = stringSpiltData;
                // if(channelName == null){
                //     SPW.channelValue = summaryPageValue;
                // }

            } else if (summaryPage == 'Channel_Name__c'){
                SPW.summaryPage = 'Channel';
                SPW.onedownValue = 'Channel';
                SPW.level = 'level_channel';
                List<String> stringSpiltData = new List<String>();
                stringSpiltData.add('\'' + summaryPageValue + '\'');
                SPW.summaryPageValue = stringSpiltData;
                if (channelName != null){
                    SPW.channelValue = '\'' + summaryPageValue + '\'';
                    system.debug('SPW.channelValue' + SPW.channelValue);
                }

            } else if (summaryPage == 'Region_Code__c'){
                SPW.summaryPage = 'Region';
                SPW.onedownValue = 'Region';
                SPW.level = 'level_region';
                List<String> stringSpiltData = new List<String>();
                stringSpiltData.add('\'' + summaryPageValue + '\'');
                SPW.summaryPageValue = stringSpiltData;

            } else if (summaryPage == 'Zone_Code__c'){
                SPW.summaryPage = 'Zone';
                SPW.onedownValue = 'Zone';
                SPW.level = 'level_zone';
                List<String> stringSpiltData = new List<String>();
                stringSpiltData.add('\'' + summaryPageValue + '\'');
                SPW.summaryPageValue = stringSpiltData;

            } else if (summaryPage == 'Branch_Team_Code__c'){
                SPW.summaryPage = 'Branch';
                SPW.onedownValue = 'Branch';
                SPW.level = 'level_branch';
                List<String> stringSpiltData = new List<String>();
                stringSpiltData.add('\'' + summaryPageValue + '\'');
                SPW.summaryPageValue = stringSpiltData;
            } else{
                throw new AuraHandledException('Meta data type does not match');
            }
        } else if (summaryPage == null && summaryPageValue == null){
            if (tperf_Permission.size() > 0){
                List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
                List<String> stringSpiltData = new List<String>();
                List<String> stringActualData = new List<String>();
                String FieldMapping = checkPerfMeta[0].SummaryByTypeFieldMapping__c;
                if (checkPerfMeta[0].Summary_Page__c == 'Retail'){
                    SPW.summaryPage = checkPerfMeta[0].Summary_Page__c;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_retail';
                    string checkGroupOfChannel = checkPerfMeta[0].Group_of_Channel__c;
                    string newData = checkGroupOfChannel.removeEnd(';');
                    List<string> splitData = newData.split(';');
                    stringSpiltData.add('\'' + newData + '\'');
                    for (String sd : splitData){
                        stringActualData.add('\'' + sd + '\'');
                    }
                    SPW.getActual = FieldMapping;
                    SPW.getActualValue = stringActualData;
                    SPW.summaryPageValue = stringSpiltData;
                } else if (checkPerfMeta[0].Summary_Page__c == 'Group of channel'){
                    SPW.summaryPage = FieldMapping;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_group_of_channel';
                    if (checkPerfMeta[0].Summary_Page__c != FieldMapping){
                        string channel = checkPerfMeta[0].Channel__c;
                        string channelData = channel.removeEnd(';');
                        List<string> splitData = channelData.split(';');
                        for (String sd : splitData){
                            stringActualData.add('\'' + sd + '\'');
                        }
                        stringSpiltData.add('\'' + channelData + '\'');
                        SPW.getActual = FieldMapping;
                        SPW.getActualValue = stringActualData;
                    } else{
                        string checkChannel = checkPerfMeta[0].Group_of_Channel__c;
                        string newData = checkChannel.removeEnd(';');
                        stringSpiltData.add('\'' + newData + '\'');
                    }
                    SPW.summaryPageValue = stringSpiltData;
                } else if (checkPerfMeta[0].Summary_Page__c == 'Channel'){
                    SPW.summaryPage = FieldMapping;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_channel';
                    string checkChannel = checkPerfMeta[0].Channel__c;
                    string newData = checkChannel.removeEnd(';');
                    List<string> splitData = newData.split(';');
                    stringSpiltData.add('\'' + newData + '\'');
                    SPW.summaryPageValue = stringSpiltData;
                    if (channelName == null){
                        SPW.channelValue = '\'' + newData + '\'';
                        system.debug('SPW.channelValue' + SPW.channelValue);
                    }
                } else if (checkPerfMeta[0].Summary_Page__c == 'Region'){
                    SPW.summaryPage = FieldMapping;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_region';
                    string regionCode = currUser.Region_Code__c;
                    string newData = regionCode.removeEnd(';');
                    List<string> splitData = newData.split(';');
                    for (String sd : splitData){
                        stringSpiltData.add('\'' + sd + '\'');
                    }
                    if (channelName == null){
                        string Channel = checkPerfMeta[0].Channel__c;
                        string ChannelData = Channel.removeEnd(';');
                        SPW.channelValue = '\'' + ChannelData + '\'';
                        system.debug('SPW.channelValue' + SPW.channelValue);
                    }
                    SPW.summaryPageValue = stringSpiltData;
                } else if (checkPerfMeta[0].Summary_Page__c == 'Zone'){
                    SPW.summaryPage = FieldMapping;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_zone';
                    string zoneCode = currUser.Zone_Code__c;
                    string newData = zoneCode.removeEnd(';');
                    List<string> splitData = newData.split(';');
                    for (String sd : splitData){
                        stringSpiltData.add('\'' + sd + '\'');
                    }
                    if (channelName == null){
                        string Channel = checkPerfMeta[0].Channel__c;
                        string ChannelData = Channel.removeEnd(';');
                        SPW.channelValue = '\'' + ChannelData + '\'';
                        system.debug('SPW.channelValue' + SPW.channelValue);
                    }
                    SPW.summaryPageValue = stringSpiltData;
                } else if (checkPerfMeta[0].Summary_Page__c == 'Branch'){
                    SPW.summaryPage = FieldMapping;
                    SPW.onedownValue = checkPerfMeta[0].Summary_Page__c;
                    SPW.level = 'level_branch';
                    string branchCode = currUser.RTL_Branch_Code__c;
                    string newData = branchCode.removeEnd(';');
                    List<string> splitData = newData.split(';');
                    for (String sd : splitData){
                        stringSpiltData.add('\'' + sd + '\'');
                    }
                    if (channelName == null){
                        string Channel = checkPerfMeta[0].Channel__c;
                        string ChannelData = Channel.removeEnd(';');
                        SPW.channelValue = '\'' + ChannelData + '\'';
                        system.debug('SPW.channelValue' + SPW.channelValue);
                    }
                    SPW.summaryPageValue = stringSpiltData;
                }
                System.debug('FieldMapping--> ' + FieldMapping);
                switch  on FieldMapping{
                    when 'Group of channel'{
                        SPW.queryField = 'Group_Channel__c';
                    }
                    when 'Channel'{
                        SPW.queryField = 'Channel_Name__c';
                    }
                    when 'Region'{
                        SPW.queryField = 'Region_Code__c';
                    }
                    when 'Zone'{
                        SPW.queryField = 'Zone_Code__c';
                    }
                    when 'Branch'{
                        SPW.queryField = 'Branch_Team_Code__c';
                    }
                    when else{
                        SPW.queryField = '';
                    }
                }
                System.debug('queryField--> ' + SPW.queryField);
            }
        }
        
        System.debug('End Apex 1--> ' + Datetime.Now());
        return SPW;
    }

    @AuraEnabled
    public static String getSummaryLabel(String summaryPage, String summaryPageValue){
        String summaryLabel;
        if (summaryPage != null && summaryPageValue != null){
            List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
            summaryLabel = summaryPageValue;
        } else{
            if (tperf_Permission.size() > 0){
                List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
                if (checkPerfMeta[0].Summary_Page__c == 'Retail'){
                    summaryLabel = checkPerfMeta[0].Summary_Page__c;

                } else if (checkPerfMeta[0].Summary_Page__c == 'Group of channel'){
                    summaryLabel = checkPerfMeta[0].Group_of_Channel__c;
                    summaryLabel = summaryLabel.removeEnd(';');

                } else if (checkPerfMeta[0].Summary_Page__c == 'Channel'){
                    summaryLabel = checkPerfMeta[0].Channel__c;
                    summaryLabel = summaryLabel.removeEnd(';');

                } else if (checkPerfMeta[0].Summary_Page__c == 'Region'){
                    summaryLabel = currUser.Region_Code__c;

                } else if (checkPerfMeta[0].Summary_Page__c == 'Zone'){
                    summaryLabel = currUser.Zone_Code__c;

                } else if (checkPerfMeta[0].Summary_Page__c == 'Branch'){
                    summaryLabel = currUser.RTL_Branch_Code__c;

                }
            }
            // else if (currUser.Profile.Name.contains('System Admin')){
            //     summaryLabel = 'Admin';
            // }
            else{
                throw new AuraHandledException('Meta data type does not match');
            }
        }
        return summaryLabel;
    }

    @AuraEnabled
    public static targetProductWrapper getTargetProductByTeam(String summaryPage, List<String> summaryPageValue, String selectedYear, String selectedMonth, String lastRecord, String level, String queryField){
        system.debug('summaryPage' + summaryPage);
        system.debug('summaryPageValue' + summaryPageValue);
        targetProductWrapper TPW = new targetProductWrapper();
        T_Performance_Onedown_Controller.chunkQueryWrapper chuckq = new T_Performance_Onedown_Controller.chunkQueryWrapper();
        String dataTimeCondition = '';
        String isDataQuery = '';

        // String queryObject = 'T_Performance_Target_Product_by_Team__c';
        // String fieldList = 'Year__c, Month__c, Group_Channel__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Product_Group_Code__c, Product_Group_Name__c, Target_Unit_Year__c, Target_Unit_Month__c, Product_List__c, Rank__c, Branch_Point_Engine__c, Indicator_Level1__c,Cap_Max_Pct__c';
        // String condition;
        List<T_Performance_Target_Product_by_Team__c> targetProdList;
        if (selectedYear != null && selectedMonth != null){
            dataTimeCondition = ' Year__c = \'' + selectedYear + '\' AND Month__c <=\'' + selectedMonth + '\' AND Month__c >= \'01\'';

            if (summaryPage != null && summaryPageValue != null){
                chuckq.queryObject = 'T_Performance_Target_Product_by_Team__c';
                chuckq.fieldList = 'Id, Year__c, Month__c, Group_Channel__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Product_Group_Code__c, Product_Group_Name__c, Target_Unit_Year__c, Target_Unit_Month__c, Rank__c, Branch_Point_Engine__c, Indicator_Level1__c, Actual_Amount__c, Volumn__c, RecordType.Name, Cap_Max_Pct__c';
                chuckq.lastRecordId = lastRecord;

                if (level != null){
                    if (queryField == 'Group_Channel__c'){
                        chuckq.condition = ' WHERE RecordType.Name = \'' + level + '\' AND ' + queryField + ' IN ' + summaryPageValue + ' AND Channel_Name__c = null ' + ' AND ' + dataTimeCondition;
                        isDataQuery = 'SELECT id FROM T_Performance_Target_Product_by_Team__c WHERE RecordType.Name = \'' + level + '\' AND ' + queryField + ' IN ' + summaryPageValue + ' AND Channel_Name__c = null ' + ' AND ' + 'Year__c = \'' + selectedYear + '\' AND Month__c =\'' + selectedMonth + '\'';
                    } else{
                        chuckq.condition = ' WHERE RecordType.Name = \'' + level + '\' AND ' + queryField + ' IN ' + summaryPageValue + ' AND ' + dataTimeCondition;
                        isDataQuery = 'SELECT id FROM T_Performance_Target_Product_by_Team__c WHERE RecordType.Name = \'' + level + '\' AND ' + queryField + ' IN ' + summaryPageValue + ' AND ' + 'Year__c = \'' + selectedYear + '\' AND Month__c =\'' + selectedMonth + '\'';
                    }
                } else{
                    throw new AuraHandledException('Invalid Parameter');
                }
                System.debug('Condition--> ' + chuckq.condition);
            } else{
                throw new AuraHandledException('Invalid Parameter');
            }
            // String query = 'SELECT ' + fieldList + ' FROM ' + queryObject + ' ' + condition + ' ORDER BY Rank__c ';
            // List<T_Performance_Target_Product_by_Team__c> ProdList = Database.query(query);

            // List<String> targetProdStr = new List<String>();
            // for (T_Performance_Target_Product_by_Team__c TP : ProdList){
            //     string newData = TP.Product_List__c.removeEnd(';');
            //     List<string> splitData = newData.split(';');
            //     for (string sd : splitData){
            //         targetProdStr.add('\'' + sd + '\'');
            //     }
            // }
            // TPW.prodList = targetProdStr;
            targetProdList = Database.query(isDataQuery);
            if(targetProdList.size() > 0 ){
                TPW.isData = true;
            }
            TPW.targetProdList = T_Performance_Onedown_Controller.chunkQuery(chuckq);

        } else{
            throw new AuraHandledException('Invalid Parameter');
        }
        return TPW;
    }

    // @AuraEnabled
    // public static T_Performance_Onedown_Controller.chunkQueryWrapper getSummaryTeamandProduct(List<String> prodList, String summaryPage, List<String> summaryPageValue, String selectedYear, String selectedMonth, String lastRecord){
    //     String dataTimeCondition = '';
    //     T_Performance_Onedown_Controller.chunkQueryWrapper chunkq = new T_Performance_Onedown_Controller.chunkQueryWrapper();
    //     chunkq.queryObject = 'Summary_Team_and_Product__c';
    //     chunkq.lastRecordId = lastRecord;
    //     chunkq.fieldList = 'Name, Actual_Amount__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Month__c, Unique_External_Key__c, Year__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c ';
    //     String prodString;
    //     if (prodList.size() > 0){
    //         prodString = '(' + String.join(new List<String>(prodList), ',') + ')';
    //     } else{
    //         prodString = '(\'\')';
    //     }
    //     if (selectedYear != null && selectedMonth != null){
    //         dataTimeCondition = ' Year__c = \'' + selectedYear + '\' AND Month__c <=\'' + selectedMonth + '\' AND Month__c >= \'01\'';
    //         System.debug('summaryPageValue :' + summaryPageValue);
    //         if (summaryPage != null && summaryPageValue != null){
    //             if (summaryPage == 'Retail'){
    //                 chunkq.condition = ' WHERE Channel_Name__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else if (summaryPage == 'Group of channel'){
    //                 chunkq.condition = ' WHERE Channel_Name__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else if (summaryPage == 'Channel'){
    //                 chunkq.condition = ' WHERE Channel_Name__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else if (summaryPage == 'Region'){
    //                 chunkq.condition = ' WHERE Region_Code__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else if (summaryPage == 'Zone'){
    //                 chunkq.condition = ' WHERE Zone_Code__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else if (summaryPage == 'Branch'){
    //                 chunkq.condition = ' WHERE Branch_Team_Code__c IN ' + summaryPageValue + ' AND Indicator_Code__c IN ' + prodString + ' AND' + dataTimeCondition;
    //             } else{
    //                 throw new AuraHandledException('Invalid Parameter');
    //             }
    //         }
    //     } else{
    //         throw new AuraHandledException('Invalid Parameter');
    //     }
    //     return T_Performance_Onedown_Controller.chunkQuery(chunkq);
    // }
    @AuraEnabled
    public static summaryPagebyTypeWrapper getSummaryPagebyType(String onedownValue, String summaryPage){
        summaryPagebyTypeWrapper SPTW = new summaryPagebyTypeWrapper();
        System.debug('Onedown Value: ' + onedownValue);
        System.debug('summarypage Value: ' + summaryPage);

        if (summaryPage != null && onedownValue != null && summaryPage != '' && onedownValue != ''){
            SPTW.summaryPagebyType = summaryPage;
            SPTW.summaryPagebyTypeValue = onedownValue;
        } else if (tperf_Permission.size() > 0){
            List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
            SPTW.summaryPagebyType = checkPerfMeta[0].SummaryByTypeFieldMapping__c;

            if (checkPerfMeta[0].SummaryByTypeFieldMapping__c == 'Group of channel'){

                SPTW.summaryPagebyTypeValue = checkPerfMeta[0].Group_of_Channel__c;

            } else if (checkPerfMeta[0].SummaryByTypeFieldMapping__c == 'Channel'){
                SPTW.summaryPagebyTypeValue = checkPerfMeta[0].Channel__c;

            } else if (checkPerfMeta[0].SummaryByTypeFieldMapping__c == 'Region'){
                SPTW.summaryPagebyTypeValue = currUser.Region_Code__c;

            } else if (checkPerfMeta[0].SummaryByTypeFieldMapping__c == 'Zone'){
                SPTW.summaryPagebyTypeValue = currUser.Zone_Code__c;

            } else if (checkPerfMeta[0].SummaryByTypeFieldMapping__c == 'Branch'){
                SPTW.summaryPagebyTypeValue = currUser.RTL_Branch_Code__c;

            }
        }
        return SPTW;
    }

    @AuraEnabled
    public static List<T_Performance_Summary_by_Type__c> getSummarybyType(String summaryPage, List<String> summaryPageValue, String selectedYear, String selectedMonth, String channelName){
        System.debug('Summary Page: ' + summaryPage);
        System.debug('summaryPageValue: ' + summaryPageValue);
        System.debug('selectedYear: ' + selectedYear);
        System.debug('selectedMonth: ' + selectedMonth);
        String condition;
        String query;
        String dataTimeCondition = '';
        String queryObject = 'T_Performance_Summary_by_Type__c';
        String fieldList = 'Group7_Unit__c, Group1_Name__c, Group1_weight_pct__c, Group1_Cap_Max_Pct__c, Group2_Name__c, Group2_weight_pct__c, Group2_Value__c, Group2_Unit__c, Group3_Name__c, Group3_weight_pct__c, Group3_Value__c, Group3_Unit__c, Group4_Name__c, Group4_weight_pct__c, Group4_Value__c, Group4_Unit__c, Group5_Name__c, Group5_weight_pct__c, Group5_Value__c, Group5_Unit__c, Group6_Name__c, Group6_weight_pct__c, Group6_Value__c, Group6_Unit__c, Group7_Name__c, Group7_weight_pct__c, Group7_Value__c, Group2_Min__c, Group3_Min__c, Group4_Min__c, Group5_Min__c, Group6_Min__c, Group7_Min__c';
        List<T_Performance_Summary_by_Type__c> TperfSBTList = new List<T_Performance_Summary_by_Type__c>();
        if (selectedYear != null && selectedMonth != null){
            dataTimeCondition = ' Year__c = \'' + selectedYear + '\' AND Month__c =\'' + selectedMonth + '\'';

            if (summaryPage != null && summaryPageValue != null){
                String currLevel;
                String underLevel;
                if (summaryPage == 'Retail'){
                    currLevel = 'Group_Channel__c';
                    underLevel = ' AND Channel_Name__c = NULL';
                } else if (summaryPage == 'Group of channel'){
                    currLevel = 'Group_Channel__c';
                    underLevel = ' AND Channel_Name__c = NULL';
                } else if (summaryPage == 'Channel'){
                    currLevel = 'Channel_Name__c';
                    underLevel = ' AND Region_Code__c = NULL';
                } else if (summaryPage == 'Region'){
                    currLevel = 'Region_Code__c';
                    underLevel = ' AND Zone_Code__c = NULL AND Channel_Name__c = ' + channelName;
                } else if (summaryPage == 'Zone'){
                    currLevel = 'Zone_Code__c';
                    underLevel = ' AND Branch_Team_Code__c = NULL AND Channel_Name__c = ' + channelName;
                } else if (summaryPage == 'Branch'){
                    currLevel = 'Branch_Team_Code__c';
                    underLevel = ' AND Channel_Name__c = ' + channelName;
                } else{
                    throw new AuraHandledException('Invalid Parameter');
                }

                String newCon = summaryPageValue[0].replaceAll('\\(.*\\)', '');
                condition = ' WHERE ' + currLevel + ' = ' + '\'' + newCon + '\'' + underLevel + ' AND' + dataTimeCondition + ' LIMIT 1';

                query = 'SELECT ' + fieldList + ' FROM ' + queryObject + condition;
                System.debug(condition);
                TperfSBTList = Database.query(query);

            }
        } else{
            throw new AuraHandledException('Invalid Parameter');
        }
        System.debug('End Apex 2--> ' + Datetime.Now());
        return TperfSBTList;
    }

    @AuraEnabled
    public static Boolean isNextButton(String channelName, String currentLevel, String zoneValue, String selectedYear, String selectedMonth){
        // System.debug('currentLevel: ' + currentLevel);
        // System.debug('zoneValue: ' + zoneValue);
        // System.debug('selectedYear: ' + selectedYear);
        // System.debug('selectedMonth: ' + selectedMonth);

        // if(currentLevel == 'Zone' || currentLevel == 'Zone_Code__c' && zoneValue != null){
        //     List<T_Performance_Target_Product_by_Team__c > STPList1 = [SELECT Id, Name, Month__c, Year__c, Zone_Code__c, Branch_Team_Code__c FROM T_Performance_Target_Product_by_Team__c  WHERE Zone_code__c = :zoneValue AND Branch_Team_Code__c = :zoneValue LIMIT 2];
        //     if(STPList1.size() > 0){
        //         List<T_Performance_Target_Product_by_Team__c > STPList2 = [SELECT Id, Name, Month__c, Year__c, Zone_Code__c, Branch_Team_Code__c FROM T_Performance_Target_Product_by_Team__c  WHERE Zone_code__c = :zoneValue AND Branch_Team_Code__c != :zoneValue AND Branch_Team_Code__c != null LIMIT 1];
        //         if(STPList2.size() == 0){
        //             isNext = false;
        //         }
        //     }
        // }
        Boolean isNext = true;
        List<T_Performance_Permission__mdt> checkPerfMeta = tperf_Permission;
        if (currentLevel == 'Zone' || currentLevel == 'Zone_Code__c' && zoneValue != null){

            if (channelName.contains('Telemarketing') || channelName.contains('Branch')){
                isNext = true;
            }else{
                isNext = false;
            }
        }

        return isNext;
    }
    
    @AuraEnabled
    public static String testtest() {
        return 'test';
    }

    @AuraEnabled
    public static actualMapWrapper getTarget(String summaryPage, List<String> summaryPageValue, String selectedYear, String selectedMonth){
        System.debug('Summary Page: ' + summaryPage);
        System.debug('summaryPageValue: ' + summaryPageValue);
        System.debug('selectedYear: ' + selectedYear);
        System.debug('selectedMonth: ' + selectedMonth);
        String condition;
        String query;
        String dataTimeCondition = '';
        String queryObject = 'T_Performance_Target_Product_by_Team__c';
        String fieldList = 'Id, Year__c, Month__c, Group_Channel__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Product_Group_Code__c, Product_Group_Name__c, Target_Unit_Year__c, Target_Unit_Month__c, Rank__c, Branch_Point_Engine__c, Indicator_Level1__c, Actual_Amount__c, Volumn__c, RecordType.Name, Cap_Max_Pct__c';
        List<T_Performance_Target_Product_by_Team__c> TperfTBTList = new List<T_Performance_Target_Product_by_Team__c>();

        if (selectedYear != null && selectedMonth != null){
            dataTimeCondition = ' Year__c = \'' + selectedYear + '\' AND Month__c <=\'' + selectedMonth + '\'';

            if (summaryPage != null && summaryPageValue != null){
                String currLevel;
                String recordType;
                if (summaryPage == 'Group of channel'){
                    currLevel = 'Group_Channel__c';
                    recordType = 'level_group_of_channel';
                } else if (summaryPage == 'Channel'){
                    currLevel = 'Channel_Name__c';
                    recordType = 'level_channel';
                } else{
                    return null;
                }

                String newCon = summaryPageValue[0].replaceAll('\\(.*\\)', '');
                if (currLevel == 'Group_Channel__c'){
                    condition = ' WHERE RecordType.Name = \'' + recordType + '\' AND ' + currLevel + ' IN ' + summaryPageValue + ' AND Channel_Name__c = null AND' + dataTimeCondition;
                } else{
                    condition = ' WHERE RecordType.Name = \'' + recordType + '\' AND ' + currLevel + ' IN ' + summaryPageValue + ' AND' + dataTimeCondition;
                }


                query = 'SELECT ' + fieldList + ' FROM ' + queryObject + condition;
                // System.debug(condition);
                // System.debug(query);
                TperfTBTList = Database.query(query);

            } else {
                return null;
            }
        } else{
            throw new AuraHandledException('Invalid Parameter');
        }
        // System.debug('---> '+TperfTBTList);
        actualMapWrapper ac = new actualMapWrapper();
        Map<String, Decimal> mapProductWithActual = new Map<string, Decimal>();
        Map<String, Decimal> mapProductWithActualMTD = new Map<string, Decimal>();
        Map<String, Decimal> mapProductWithVolume = new Map<string, Decimal>();
        Map<String, Decimal> mapActualWithRunrate = new Map<string, Decimal>();
        for (T_Performance_Target_Product_by_Team__c tb1 : TperfTBTList){
            String groupKey = tb1.Group_Channel__c + tb1.Product_Group_Name__c;
            if (tb1.Month__c == selectedMonth && tb1.Year__c == selectedYear){
                if (!mapProductWithVolume.containsKey(groupKey)){
                    mapProductWithVolume.put(groupKey, (tb1.volumn__c != null ? tb1.volumn__c : 1));
                }
            }
        }
        for (T_Performance_Target_Product_by_Team__c tb : TperfTBTList){
            String key = tb.Product_Group_Name__c;
            // System.debug('key : '+ key);
            Decimal volume = 1;
            if (mapProductWithVolume.containsKey(tb.Group_Channel__c + tb.Product_Group_Name__c)){
                volume = mapProductWithVolume.get(tb.Group_Channel__c + tb.Product_Group_Name__c);
            }
            
            if (mapProductWithActual.containsKey(key)){
                // System.debug('Map : '+ mapProductWithActual.get(key));
                // System.debug('Actual Amount : '+ tb.Actual_Amount__c);
                // System.debug('volume: '+ volume);
                
                Decimal newActual = mapProductWithActual.get(key) + ((tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
                mapProductWithActual.put(key, newActual);
            } else{
                mapProductWithActual.put(key, (tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
            }

            if (!mapProductWithActualMTD.containsKey(key)){
                if (tb.Month__c == selectedMonth){
                    mapProductWithActualMTD.put(key, (tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
                }
            } else{
                if (tb.Month__c == selectedMonth){
                    Decimal newActual = mapProductWithActualMTD.get(key) + ((tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
                    mapProductWithActualMTD.put(key, newActual);
                }
            }

            if (!mapActualWithRunrate.containsKey(key)){
                if (tb.Month__c != selectedMonth){
                    mapActualWithRunrate.put(key, (tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
                }
            } else{
                if (tb.Month__c != selectedMonth){
                    Decimal newActual = mapActualWithRunrate.get(key) + ((tb.Actual_Amount__c != null ? tb.Actual_Amount__c : 0) / volume);
                    mapActualWithRunrate.put(key, newActual);
                }
            }
        }

        ac.mapProductWithActual = mapProductWithActual;
        ac.mapProductWithActualMTD = mapProductWithActualMTD;
        ac.mapActualWithRunrate = mapActualWithRunrate;

        return ac;
    }

}