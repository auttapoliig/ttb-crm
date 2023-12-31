public class T_Performance_Onedown_Controller {
    public T_Performance_Onedown_Controller() {

    }

    public class chunkQueryWrapper {
        @AuraEnabled
        public Integer chunkSize = 35000;
        @AuraEnabled
        public Id lastRecordId;
        @AuraEnabled
        public Boolean isEndRecord;
        @AuraEnabled
        public String fieldList;
        @AuraEnabled
        public String queryObject;
        @AuraEnabled
        public String condition;
        @AuraEnabled
        public List<sObject> resultRecords;
    }

    @AuraEnabled
    public static chunkQueryWrapper chunkQuery(Object queryWrapperObj) {
        // try {
            chunkQueryWrapper queryWrapper = (chunkQueryWrapper)JSON.deserialize(JSON.serialize(queryWrapperObj), chunkQueryWrapper.class);
            if(queryWrapper.fieldList != null && queryWrapper.queryObject != null) {
                String defaultQuery = 'SELECT '+queryWrapper.fieldList+' FROM '+queryWrapper.queryObject+' ';
                String query = defaultQuery;
                
                queryWrapper.isEndRecord = true;
                Integer chunkSize = queryWrapper.chunkSize;
                if(queryWrapper.lastRecordId == null) {
                    // first time
                    String condition = queryWrapper.condition == null ? '' : queryWrapper.condition;
                    query = query+condition+' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                } else {
                    if(queryWrapper.condition == null) {
                        query = query+' WHERE Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                    } else {
                        query = query+queryWrapper.condition+' AND Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                    }
                }
                List<sObject> resultRecords = Database.query(query);
                Integer dataRow = resultRecords.size();
                if(dataRow >= chunkSize) {
                    queryWrapper.lastRecordId = resultRecords[dataRow-1].Id;
                    List<Object> checkNext = new List<Object>();
                    String checkNextQuery = '';
                    if(queryWrapper.condition == null) { 
                        checkNextQuery = defaultQuery+' WHERE Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT 1';
                    } else {
                        checkNextQuery = defaultQuery+queryWrapper.condition+' AND Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT 1';
                    }
                    checkNext = Database.query(checkNextQuery);
                    if(checkNext.size() > 0) {
                        queryWrapper.isEndRecord = false;
                    }
                }

                queryWrapper.resultRecords = resultRecords;
            }
            return queryWrapper;
            
        // } catch (Exception e) {
        //     System.debug('Error:'+e);
        //     // throw new AuraHandledException(' '+e);
        //     String message1 = 'Data not Found';
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    public class teamWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<String> channel;
        @AuraEnabled
        public String teamName;
        @AuraEnabled
        public String displayName;
    }

    public class productTargetTeamWrapper {
        @AuraEnabled
        public List<T_Performance_Target_Product_by_Team__c> productList;
        @AuraEnabled
        public List<teamWrapper> teamList;
        @AuraEnabled
        public String summaryPage;
        @AuraEnabled
        public string teamCondition;
        @AuraEnabled
        public List<T_Performance_Target_Product_by_Team__c> selectedTarget;
    }

    private static T_Performance_Permission__mdt getPerfMetaData(String userRole, String userProfile) {
        List<T_Performance_Permission__mdt> metaDataList = [SELECT Label,Channel__c,SF_Profile__c,SF_Role__c,Summary_Page__c, Group_of_Channel__c, SummaryByTypeFieldMapping__c FROM T_Performance_Permission__mdt WHERE SF_Profile__c =: userProfile];
        for(T_Performance_Permission__mdt p : metaDataList) {
            if(p.SF_Role__c != null && userRole.startsWith(p.SF_Role__c)) {
                return p;
            }
        }
        return null;
    }

    @AuraEnabled
    public static productTargetTeamWrapper getProductTargetTeam2(String selectedYear , String selectedMonth , String period, String summaryGroupType , String summaryGroupValue){
        // try {
            User currUser = [SELECT Id,UserRoleName__c,Profile.Name,Region_Code__c,Zone_Code__c,RTL_Branch_Code__c from User WHERE Id =: UserInfo.getUserId()];
            T_Performance_Permission__mdt metaDataPerf = getPerfMetaData(currUser.UserRoleName__c,currUser.Profile.Name);
            productTargetTeamWrapper productTargetTeamWrapper = new productTargetTeamWrapper();
            if(metaDataPerf != null) {
                productTargetTeamWrapper.summaryPage = metaDataPerf.Summary_Page__c;
            }

            if(summaryGroupType != null) {
                productTargetTeamWrapper.summaryPage = summaryGroupType;
            }

            String dataTimeCondition;
            if (selectedYear != null && selectedMonth != null && period != null ) {
                if (period =='YTD') {
                    dataTimeCondition = ' Year__c = \''+selectedYear+'\' AND Month__c <=\''+selectedMonth+'\' ';
                }else if (period =='MTD') {
                    dataTimeCondition = ' Year__c = \''+selectedYear+'\' AND Month__c =\''+selectedMonth+'\' ';
                }

                if(metaDataPerf != null) {
                    if (productTargetTeamWrapper.summaryPage == 'Retail' ) {
                        
                        string checkGroupOfChannel = metaDataPerf.Group_of_Channel__c;
                        string newData = checkGroupOfChannel.removeEnd(';');
                        List<string> splitData = newData.split(';');
                        Set<String> stringSplitData = new Set<String>(splitData);
                        string queryProduct = 'SELECT Product_Group_Code__c,Product_Group_Name__c,Group_Channel__c, Channel_Name__c,Target_Unit_Year__c,Target_Unit_Month__c,Product_List__c,Rank__c,Indicator_Level1__c,Month__c,Actual_Amount__c,Year__c,Volumn__c FROM T_Performance_Target_Product_by_Team__c WHERE Group_Channel__c IN: stringSplitData AND Channel_Name__c = null AND RecordType.Name = \'level_group_of_channel\' AND '+dataTimeCondition+' ORDER BY Rank__c'  ;
                        productTargetTeamWrapper.productList = Database.query(queryProduct);

                        List<teamWrapper> teamList = new List<teamWrapper>();
                        for(String team : stringSplitData) {
                            teamWrapper teamWrapper = new teamWrapper();
                            teamWrapper.label = team;
                            teamWrapper.teamName = team;
                            teamWrapper.displayName = team;
                            teamList.add(teamWrapper);
                        }

                        productTargetTeamWrapper.teamList = teamList;
                    }else if (productTargetTeamWrapper.summaryPage == 'Group of channel' ) {
                        List<teamWrapper> teamList = new List<teamWrapper>();
                        Set<String> channelName = new Set<String>();
                        
                        Set<String> channelListMeta = new Set<String>();
                        String channelListInMetaStr = metaDataPerf.Channel__c;
                        if(channelListInMetaStr != null) {
                            channelListMeta = new Set<String>(channelListInMetaStr.removeEnd(';').split(';'));
                        }
                        
                        List<T_Performance_Target_Product_by_Team__c> channelList = [SELECT Channel_Name__c FROM T_Performance_Target_Product_by_Team__c WHERE Group_Channel__c  =: summaryGroupValue AND RecordType.Name = 'level_channel'];
                        for (T_Performance_Target_Product_by_Team__c channel : channelList) {
                            String channelStr = String.valueOf(channel.get('Channel_Name__c'));
                            if(channelListMeta.contains(channelStr)) {
                                channelName.add(channelStr);
                            }
                        }

                        String querySelectedTarget = 'SELECT Volumn__c, Product_Group_Name__c, Channel_Name__c FROM T_Performance_Target_Product_by_Team__c WHERE Group_Channel__c  =: summaryGroupValue AND Channel_Name__c = null AND RecordType.Name = \'level_group_of_channel\' AND Year__c =: selectedYear AND Month__c =: selectedMonth';
                        if(metaDataPerf.SummaryByTypeFieldMapping__c == 'Channel') {
                            querySelectedTarget = 'SELECT Volumn__c, Product_Group_Name__c, Channel_Name__c FROM T_Performance_Target_Product_by_Team__c WHERE Channel_Name__c =: channelListInMetaStr AND RecordType.Name = \'level_group_of_channel\' AND Year__c =: selectedYear AND Month__c =: selectedMonth';
                        }
                        productTargetTeamWrapper.selectedTarget = Database.query(querySelectedTarget);

                        for(String team : channelName) {
                            teamWrapper teamWrapper = new teamWrapper();
                            teamWrapper.label = team;
                            teamWrapper.channel = new List<String>();
                            teamWrapper.teamName = team;
                            teamWrapper.displayName = team;
                            teamList.add(teamWrapper);
                        }

                        string queryProduct = 'SELECT Product_Group_Code__c,Product_Group_Name__c,Group_Channel__c, Channel_Name__c,Target_Unit_Year__c,Target_Unit_Month__c,Product_List__c,Rank__c,Indicator_Level1__c,Month__c,Actual_Amount__c,Year__c,Volumn__c FROM T_Performance_Target_Product_by_Team__c WHERE Channel_Name__c IN:channelName AND RecordType.Name = \'level_channel\' AND '+dataTimeCondition+' ORDER BY Rank__c' ;
                        productTargetTeamWrapper.productList = Database.query(queryProduct);

                        productTargetTeamWrapper.teamList = teamList;

                    }else if (productTargetTeamWrapper.summaryPage == 'Channel' ) {
                        String channel ;
                        channel = summaryGroupValue;
                        string queryProduct = 'SELECT Product_Group_Code__c,Channel_Name__c,Product_Group_Name__c,Region_Code__c,Target_Unit_Year__c,Target_Unit_Month__c,Product_List__c,Rank__c,Indicator_Level1__c,Month__c,Actual_Amount__c,Year__c,Volumn__c FROM T_Performance_Target_Product_by_Team__c WHERE Channel_Name__c =: channel AND RecordType.Name = \'level_region\'  AND '+dataTimeCondition+' ORDER BY Rank__c' ;
                        List<T_Performance_Target_Product_by_Team__c> productList = Database.query(queryProduct);
                        productTargetTeamWrapper.productList = productList;
                        List<teamWrapper> teamList = new List<teamWrapper>();

                        List<T_Performance_Target_Product_by_Team__c> regionList = [SELECT Region_Code__c, Region_Name__c, Month__c,Year__c FROM T_Performance_Target_Product_by_Team__c WHERE Channel_Name__c  =: channel AND RecordType.Name = 'level_region' AND Month__c =: selectedMonth AND Year__c =: selectedYear ORDER BY Region_Code__c];
                        Set<String> regionNameList = new Set<String>();
                        Set<String> existingRegionCodes = new Set<String>();
                        for(T_Performance_Target_Product_by_Team__c eachRegion : regionList) {
                            String regionCode = String.valueOf(eachRegion.get('Region_Code__c'));
                            String regionName = String.valueOf(eachRegion.get('Region_Name__c'));
                            String displayName = regionName == null ? regionCode : regionName;
                            if (regionName == null) {
                                regionName = regionCode; 
                            }
                        
                            if (!existingRegionCodes.contains(regionCode)) {
                                teamWrapper teamWrapper = new teamWrapper();
                                teamWrapper.label = regionCode;
                                teamWrapper.teamName = regionName;
                                teamWrapper.displayName = displayName;
                                teamList.add(teamWrapper);
                                existingRegionCodes.add(regionCode);
                            }
                        }

                        productTargetTeamWrapper.teamList = teamList;
                    }else if (productTargetTeamWrapper.summaryPage == 'Region' ) {
                        String region;
                        region = summaryGroupValue;
                        string queryProduct = 'SELECT Product_Group_Code__c,Product_Group_Name__c,Channel_Name__c,Zone_Code__c,Target_Unit_Year__c,Target_Unit_Month__c,Product_List__c,Rank__c,Indicator_Level1__c,Month__c,Actual_Amount__c,Year__c,Volumn__c FROM T_Performance_Target_Product_by_Team__c WHERE Region_Code__c =: region AND RecordType.Name = \'level_zone\' AND '+dataTimeCondition+' ORDER BY Rank__c' ;
                        List<T_Performance_Target_Product_by_Team__c> productList = Database.query(queryProduct);
                        productTargetTeamWrapper.productList = productList;
                        List <teamWrapper> teamList = new List<teamWrapper>();
                        Set<String> zone = new Set<String>();

                        List<T_Performance_Target_Product_by_Team__c> zoneList = [SELECT Zone_Code__c , Zone_Name__c, Month__c, Year__c FROM T_Performance_Target_Product_by_Team__c WHERE Region_Code__c  =: region AND RecordType.Name = 'level_zone' AND Month__c =: selectedMonth AND Year__c =: selectedYear ORDER BY Zone_Code__c];
                        
                        Set<String> existingZoneCodes = new Set<String>();
                        

                        for(T_Performance_Target_Product_by_Team__c eachZone : zoneList) {
                            String zoneCode = String.valueOf(eachZone.get('Zone_Code__c'));
                            String zoneName = String.valueOf(eachZone.get('Zone_Name__c'));
                            String displayName = zoneName == null ? zoneCode : zoneName;
                            if (zoneName == null) {
                                zoneName = zoneCode; 
                            }
                        
                            if (!existingZoneCodes.contains(zoneCode)) {
                                teamWrapper teamWrapper = new teamWrapper();
                                teamWrapper.label = zoneCode;
                                teamWrapper.teamName = zoneName;
                                teamWrapper.displayName = displayName;
                                teamList.add(teamWrapper);
                                existingZoneCodes.add(zoneCode);
                            }
                        }

                        productTargetTeamWrapper.teamList = teamList;

                    }else if (productTargetTeamWrapper.summaryPage == 'Zone' ) {
                        String zone;
                        zone = summaryGroupValue;
                        string queryProduct = 'SELECT Product_Group_Code__c,Product_Group_Name__c,Channel_Name__c,Branch_Team_Code__c,Target_Unit_Year__c,Zone_Code__c,Target_Unit_Month__c,Product_List__c,Rank__c,Indicator_Level1__c,Month__c,Actual_Amount__c,Year__c,Volumn__c FROM T_Performance_Target_Product_by_Team__c WHERE Zone_Code__c =: zone AND RecordType.Name = \'level_branch\' AND '+dataTimeCondition+' ORDER BY Rank__c' ;
                        productTargetTeamWrapper.productList = Database.query(queryProduct);
                        List<teamWrapper> teamList = new List<teamWrapper>();
                        Set<String> branch = new Set<String>();
                        List<T_Performance_Target_Product_by_Team__c> branchList = [SELECT Branch_Team_Code__c, Branch_Team_Name__c, Month__c, Year__c FROM T_Performance_Target_Product_by_Team__c WHERE Zone_Code__c  =: zone AND RecordType.Name = 'level_branch' AND Month__c =: selectedMonth AND Year__c =: selectedYear ORDER BY Branch_Team_Code__c];

                        
                        Set<String> existingBranchTeamCodes = new Set<String>();
                        for(T_Performance_Target_Product_by_Team__c eachBranchTeam : branchList) {
                            String branchCode = String.valueOf(eachBranchTeam.get('Branch_Team_Code__c'));
                            String branchName = String.valueOf(eachBranchTeam.get('Branch_Team_Name__c'));
                            String displayName = branchName == null ? branchCode : branchName;
                            if (branchName == null) {
                                branchName = branchCode; 
                            }
                            if(!existingBranchTeamCodes.contains(branchCode)) {
                                teamWrapper teamWrapper= new teamWrapper();
                                teamWrapper.label = branchCode;
                                teamWrapper.teamName = branchName;
                                teamWrapper.displayName = displayName;
                                teamList.add(teamWrapper);
                                existingBranchTeamCodes.add(branchCode);
                            }
                        }
                        productTargetTeamWrapper.teamList = teamList;
                    }else {
                        throw new AuraHandledException('Invalid Parameter');
                        
                    }
                    return productTargetTeamWrapper;
                }else {
                    throw new AuraHandledException('User is unauthorized');
                }
            }else{
            throw new AuraHandledException('Invalid Parameter');
            }

            // productTargetTeamWrapper productTargetTeamWrapper = new productTargetTeamWrapper();
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        try{
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;

        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}