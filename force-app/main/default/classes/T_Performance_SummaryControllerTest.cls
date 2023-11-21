@isTest
public class T_Performance_SummaryControllerTest{
    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        AppConfig__c appConfig = AppConfig__c.getValues('runUserTrigger');
        appConfig.Value__c = 'false';
        update appConfig;

        RecordType levelGOC = [SELECT Id FROM RecordType WHERE Name = 'level_group_of_channel' LIMIT 1];

        T_Performance_Target_Product_by_Team__c channel = new T_Performance_Target_Product_by_Team__c();
        channel.Group_Channel__c = 'BBD';
        channel.Channel_Name__c = 'Branch';
        channel.Unique_External_Key__c = '202208001SUM5001';
        channel.Year__c = '2022';
        channel.Month__c = '08';
        channel.Product_Group_Code__c = 'SUM5001';
        channel.Product_List__c = 'BR5001;';
        channel.Rank__c = '5.1';
        channel.Indicator_Level1__c = 'Special Assignment';
        channel.RecordTypeId = levelGOC.Id;
        insert channel;

        T_Performance_Target_Product_by_Team__c getGOC = new T_Performance_Target_Product_by_Team__c();
        getGOC.Group_Channel__c = 'BBD';
        getGOC.Channel_Name__c = null;
        getGOC.Unique_External_Key__c = '202208001SUM5002';
        getGOC.Year__c = '2022';
        getGOC.Month__c = '08';
        getGOC.Product_Group_Code__c = 'SUM5002';
        getGOC.Product_List__c = 'BR5001;';
        getGOC.Rank__c = '5.1';
        getGOC.Indicator_Level1__c = 'Special Assignment';
        getGOC.RecordTypeId = levelGOC.Id;
        insert getGOC;

        T_Performance_Target_Product_by_Team__c getGOC2 = new T_Performance_Target_Product_by_Team__c();
        getGOC2.Group_Channel__c = 'BBD';
        getGOC2.Channel_Name__c = null;
        getGOC2.Unique_External_Key__c = '202208001SUM5002V2';
        getGOC2.Year__c = '2022';
        getGOC2.Month__c = '11';
        getGOC2.Product_Group_Code__c = 'SUM5002';
        getGOC2.Product_List__c = 'BR5001;';
        getGOC2.Rank__c = '5.1';
        getGOC2.Indicator_Level1__c = 'Special Assignment';
        getGOC2.RecordTypeId = levelGOC.Id;
        insert getGOC2;

        T_Performance_Target_Product_by_Team__c getGOC3 = new T_Performance_Target_Product_by_Team__c();
        getGOC3.Group_Channel__c = 'BBD';
        getGOC3.Channel_Name__c = null;
        getGOC3.Unique_External_Key__c = '202208001SUM5002V3';
        getGOC3.Year__c = '2022';
        getGOC3.Month__c = '11';
        getGOC3.Product_Group_Code__c = 'SUM5002';
        getGOC3.Product_List__c = 'BR5001;';
        getGOC3.Rank__c = '5.1';
        getGOC3.Indicator_Level1__c = 'Special Assignment';
        getGOC3.RecordTypeId = levelGOC.Id;
        insert getGOC3;


        List<T_Performance_Target_Product_by_Team__c> teamList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c label = new T_Performance_Target_Product_by_Team__c();
        label.Unique_External_Key__c = '202208001SUM0002';
        label.Year__c = '2022';
        label.Month__c = '11';
        label.Product_Group_Code__c = 'SUM0002';
        label.Product_List__c = 'BR1001;BR1004;';
        label.Rank__c = '1.1';
        label.Indicator_Level1__c = 'Deposit & Investment';
        label.Channel_Name__c = 'Branch';
        teamList.add(label);
        insert teamList;

        T_Performance_Summary_by_Type__c SbT = new T_Performance_Summary_by_Type__c();
        SbT.Group_Channel__c = 'BBD';
        SbT.Channel_Name__c = 'Branch';
        SbT.Region_Code__c = '1800';
        SbT.Zone_Code__c = '1820';
        SbT.Branch_Team_Code__c = '1';
        SbT.Year__c = '2022';
        SbT.Month__c = '11';
        SbT.Unique_External_Key__c = '202208001TEST';
        insert SbT;
    }

    static User notPermissionUser{
        get{
            if (notPermissionUser == null){
                notPermissionUser = [SELECT Id, Name, UserRole.Name, Profile.name
                                     FROM User
                                     WHERE UserRole.Name = 'SE RM SME5 Phitsanulok' AND Profile.Name = 'TMB BDM Profile' AND IsActive = true
                                     limit 1];
            }
            return notPermissionUser;
        }

        set;
    }

    @isTest
    static void testwatermark(){
        try{
            T_Performance_SummaryController.getWatermarkHTML();
        } catch (Exception e){

        }
    }

    @isTest
    static void testgetTargetAndSummary(){
        // List<T_Performance_Target_Product_by_Team__c> channelList = new List<T_Performance_Target_Product_by_Team__c>();
        // T_Performance_Target_Product_by_Team__c channel = new T_Performance_Target_Product_by_Team__c();
        // channel.Group_Channel__c = 'BBD';
        // channel.Channel_Name__c = 'Branch';
        // channel.Unique_External_Key__c = '202208001SUM5001';
        // channel.Year__c = '2022';
        // channel.Month__c = '08';
        // channel.Product_Group_Code__c = 'SUM5001';
        // channel.Product_List__c = 'BR5001;';
        // channel.Rank__c = '5.1';
        // channel.Indicator_Level1__c = 'Special Assignment';
        // channelList.add(channel);
        // insert channelList;
        String selectedYear = '2022';
        String selectedMonth = '11';
        String levelRetail = 'Retail';
        String levelGroupofchannel = 'Group of channel';
        String levelChannel = 'Channel';
        String levelRegion = 'Region';
        String levelZone = 'Zone';
        String levelBranch = 'Branch';
        String level = 'level_group_of_channel';
        String queryGOF = 'Group_channel__c';
        String queryCha = 'Channel_Name__c';
        List<String> prodList = new List<String>{ '\'BR5001\'' };
        List<String> emptyProdList = new List<String>();
        String nullValue = null;

        List<String> summaryGroupValue = new List<String>();
        summaryGroupValue.add('\'' + 'Branch' + '\'');
        List<String> summaryGroupofChannelValue = new List<String>();
        summaryGroupofChannelValue.add('\'' + 'BBD' + '\'');
        List<String> summaryChannelValue = new List<String>();
        summaryChannelValue.add('\'' + 'Branch' + '\'');
        List<String> summaryGroupValue2 = new List<String>();
        summaryGroupValue2.add('Branch');
        List<String> summaryGroupValue3 = new List<String>();
        summaryGroupValue3.add('BBD');
        List<String> summaryGroupValue4 = new List<String>();
        summaryGroupValue4.add('1800');
        List<String> summaryGroupValue5 = new List<String>();
        summaryGroupValue5.add('1820');
        List<String> summaryGroupValue6 = new List<String>();
        summaryGroupValue6.add('1');
        
        String ExceptionValue = 'Exception';

        
        User RetailUser = TestUtils.createUsers(1,'Retail','User','ryu@dummy.com', false).get(0);
        RetailUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail CRM Specialist' LIMIT 1].Id;
        RetailUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CRBO' LIMIT 1].Id;
    
        insert RetailUser;

        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            T_Performance_SummaryController.getTargetProductByTeam(levelRetail, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
            T_Performance_SummaryController.getTargetProductByTeam(levelGroupofchannel, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
            T_Performance_SummaryController.getTargetProductByTeam(levelchannel, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryCha);
            T_Performance_SummaryController.getTargetProductByTeam(levelRegion, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
            T_Performance_SummaryController.getTargetProductByTeam(levelZone, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
            T_Performance_SummaryController.getTargetProductByTeam(levelBranch, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelRetail, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelGroupofchannel, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelchannel, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelRegion, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelZone, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            // T_Performance_SummaryController.getSummaryTeamandProduct(prodList, levelBranch, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelRetail, summaryGroupValue2, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelGroupofchannel, summaryGroupValue2, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelchannel, summaryGroupValue3, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelRegion, summaryGroupValue4, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelZone, summaryGroupValue5, selectedYear, selectedMonth, nullValue);
            T_Performance_SummaryController.getSummarybyType(levelBranch, summaryGroupValue6, selectedYear, selectedMonth, nullValue);

            T_Performance_SummaryController.getSummaryPagebyType(nullValue, nullValue);

            T_Performance_SummaryController.getTarget(levelGroupofchannel, summaryGroupofChannelValue, selectedYear, selectedMonth);
            T_Performance_SummaryController.getTarget(levelChannel, summaryChannelValue, selectedYear, selectedMonth);

            // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, levelBranch, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            try{
                // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, ExceptionValue, summaryGroupValue, selectedYear, selectedMonth, nullValue);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }

            try{
                // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, ExceptionValue, summaryGroupValue, nullValue, nullValue, nullValue);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }

            try{
                T_Performance_SummaryController.getSummarybyType(ExceptionValue, summaryGroupValue6, selectedYear, selectedMonth, nullValue);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }

            try{
                T_Performance_SummaryController.getSummarybyType(ExceptionValue, summaryGroupValue6, nullValue, nullValue, nullValue);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }
        }
    }

    @isTest
    static void testValueFromOnedown(){
        String summaryGC = 'Group_Channel__c';
        String summaryvalueGC = 'BBD';
        String summaryCH = 'Channel_Name__c';
        String summaryvalueCH = 'Branch';
        String summaryRE = 'Region_Code__c';
        String summaryvalueRE = '1800';
        String summaryZO = 'Zone_Code__c';
        String summaryvalueZO = '1820';
        String summaryBR = 'Branch_Team_Code__c';
        String summaryvalueBR = '1820';
        
        List<String> emptyProdList = new List<String>();
        String lastRecord = null;
        String levelRetail = 'Retail';
        String nullValue = null;

        List<String> summaryGroupValue = new List<String>();
        summaryGroupValue.add('\'' + 'Exception' + '\'');
        String selectedYear = '2022';
        String selectedMonth = '11';
        String ExceptionValue = 'Exception';
        String selectedYearNull = null;
        String selectedMonthNull = null;
        String level = 'level_group_of_channel';
        String queryGOF = 'Group_channel__c';
        
        User RetailUser = TestUtils.createUsers(1,'Retail','User','ryu@dummy.com', false).get(0);
        RetailUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail CRM Specialist' LIMIT 1].Id;
        RetailUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CRBO' LIMIT 1].Id;
            
        insert RetailUser;
        System.runAs(RetailUser){
            //get summary value and summary page from onedown page
            T_Performance_SummaryController.isNextButton(summaryvalueCH, summaryZO, summaryvalueZO, selectedYear, selectedMonth);
            T_Performance_SummaryController.getSummaryPage(summaryGC, summaryvalueGC, nullValue);
            T_Performance_SummaryController.getSummaryPage(summaryCH, summaryvalueCH, summaryCH);
            T_Performance_SummaryController.getSummaryPage(summaryRE, summaryvalueRE, nullValue);
            T_Performance_SummaryController.getSummaryPage(summaryZO, summaryvalueZO, nullValue);
            T_Performance_SummaryController.getSummaryPage(summaryBR, summaryvalueBR, nullValue);
            //Get summary label from onedown page
            T_Performance_SummaryController.getSummaryLabel(summaryGC, summaryvalueGC);

            T_Performance_SummaryController.getSummaryPagebyType(ExceptionValue, ExceptionValue);
            try{
                T_Performance_SummaryController.getTargetProductByTeam(ExceptionValue, summaryGroupValue, selectedYear, selectedMonth, nullValue, level, queryGOF);
                // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, ExceptionValue, summaryGroupValue, selectedYear, selectedMonth, lastRecord);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }

            try{
                T_Performance_SummaryController.getTargetProductByTeam(levelRetail, summaryGroupValue, selectedYearNull, selectedMonthNull, nullValue, level, queryGOF);
                // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, ExceptionValue, summaryGroupValue, selectedYearNull, selectedMonthNull, lastRecord);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }

            try{
                T_Performance_SummaryController.getTargetProductByTeam(nullValue, emptyProdList, selectedYear, selectedMonth, nullValue, level, queryGOF);
                // T_Performance_SummaryController.getSummaryTeamandProduct(emptyProdList, ExceptionValue, summaryGroupValue, selectedYearNull, selectedMonthNull, lastRecord);
            } catch (Exception ex){
                System.assertEquals(ex.getMessage(), 'Script-thrown exception');
            }
        }
    }

    @isTest
    static void testRetailUser(){
        String summaryNull = null;
        String summaryvalueNull = null;
        String nullValue = null;
        User RetailUser = TestUtils.createUsers(1,'Retail','User','ryu@dummy.com', false).get(0);
        RetailUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail CRM Specialist' LIMIT 1].Id;
        RetailUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CRBO' LIMIT 1].Id;
            
        insert RetailUser;
        System.runAs(RetailUser){
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testGroupofchannelUser(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;
        User GroupofchannelUser = TestUtils.createUsers(1,'Groupofchannel','User','gu@dummy.com', false).get(0);
        GroupofchannelUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB SB Group Head Profile' LIMIT 1].Id;
        GroupofchannelUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Head of Small Business Sales1' LIMIT 1].Id;

        insert GroupofchannelUser;
        System.runAs(GroupofchannelUser){
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testChannelUser(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueCH = 'Branch';
        String summaryvalue = 'Value';
        String summaryvalueNull = null;
        String summaryZO = 'Zone';
        String summaryvalueZO = '1820';
        String selectedYear = '2022';
        String selectedMonth = '11';
        User ChannelUser = TestUtils.createUsers(1,'Channel','User','cu@dummy.com', false).get(0);
        ChannelUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Operations Profile' LIMIT 1].Id;
        ChannelUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Mortgage Loan Sales TL' LIMIT 1].Id;

        insert ChannelUser;

        System.runAs(ChannelUser){
            
            T_Performance_SummaryController.isNextButton(summaryvalueCH, summaryZO, summaryvalueZO, selectedYear, selectedMonth);
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalue);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testZoneUser(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;
        String summaryvalueCH = 'Branch';
        String summaryZO = 'Zone_Code__c';
        String summaryvalueZO = '1820';
        String selectedYear = '2022';
        String selectedMonth = '11';
        User ZoneUser = TestUtils.createUsers(1,'Zone','User','zu@dummy.com', false).get(0);
        ZoneUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Contact Center Outbound' LIMIT 1].Id;
        ZoneUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Telemarketing-2-TL' LIMIT 1].Id;
        ZoneUser.Zone_Code__c = '7793';
        insert ZoneUser;
        System.runAs(ZoneUser){
            T_Performance_SummaryController.isNextButton(summaryvalueCH, summaryZO, summaryvalueZO, selectedYear, selectedMonth);
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testRegionUser(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;
        User RegionUser = TestUtils.createUsers(1,'Region','User','ru@dummy.com', false).get(0);
        RegionUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Contact Center Outbound' LIMIT 1].Id;
        RegionUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE 'Director of Telemarketing' LIMIT 1].Id;
        RegionUser.Region_Code__c = '7700';  
        insert RegionUser;
        System.runAs(RegionUser){
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testBranchUser(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;
        String roleName = 'BR-MGR-Zone-7130';
        String profileName = 'TMB Retail Channel Sales';
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = roleName);
        insert r;

        Profile p = [SELECT Id
                     FROM Profile
                     WHERE Name = :profileName
                     LIMIT 1];

        User myUser = TestUtils.createUsers(1, 'mockuser1', 'mockuser1', 'mockuser1@test.com', true).get(0);
        // User myUser = new User(FirstName='mockuser1',LastName='mockuser1',Region_Code__c='1800',Zone_Code__c='1820',IsActive=true, Username='mockuser1@test.com', Email='mockuser1@test.com', Alias='mockusr', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        myUser.ProfileId = p.Id;
        myUser.UserRoleId = r.Id;
        myUser.Region_Code__c = '1800';
        myUser.Zone_Code__c = '1820';
        myUser.RTL_Branch_Code__c = '1820';
        myUser.IsActive = true;
        update myUser;
        System.runAs(myUser){
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }

    @isTest
    static void testException(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;

        String summaryEX = 'Exception';
        String summaryvalueEX = 'Exception';
        System.runAs(notPermissionUser){
            try{
                T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
                T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);

                T_Performance_SummaryController.getSummaryPage(summaryEX, summaryvalueEX, nullValue);
            } catch (Exception ex){
                //
            }
        }
        try{
            T_Performance_SummaryController.getSummaryPage(summaryEX, summaryvalueEX, nullValue);
        } catch (Exception ex){
            //
        }
    }

    // @isTest
    // static void testData(){
    //     T_Performance_SummaryController.tperf_Permission() = [SELECT Summary_Page__c, Group_of_Channel__c, Channel__c, SF_Role__c, SummaryByTypeFieldMapping__c
    //     FROM T_Performance_Permission__mdt LIMIT 1];
    // }

    @isTest
    static void testGOC(){
        String nullValue = null;
        String summaryNull = null;
        String summaryvalueNull = null;
        String roleName = 'ttb consumer (MD)';
        String profileName = 'TMB Retail Contact Center Outbound';
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = roleName);
        insert r;

        Profile p = [SELECT Id
                     FROM Profile
                     WHERE Name = :profileName
                     LIMIT 1];

        User myUser = TestUtils.createUsers(1, 'mockuser1', 'mockuser1', 'mockuser1@test.com', true).get(0);
        // User myUser = new User(FirstName='mockuser1',LastName='mockuser1',Region_Code__c='1800',Zone_Code__c='1820',IsActive=true, Username='mockuser1@test.com', Email='mockuser1@test.com', Alias='mockusr', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        myUser.ProfileId = p.Id;
        myUser.UserRoleId = r.Id;
        myUser.Region_Code__c = '1800';
        myUser.Zone_Code__c = '1820';
        myUser.RTL_Branch_Code__c = '1820';
        myUser.IsActive = true;
        update myUser;
        System.runAs(myUser){
            T_Performance_SummaryController.getSummaryPage(summaryNull, summaryvalueNull, nullValue);
            T_Performance_SummaryController.getSummaryLabel(summaryNull, summaryvalueNull);
            T_Performance_SummaryController.getSummaryPagebyType(summaryNull, summaryvalueNull);
        }
    }
}