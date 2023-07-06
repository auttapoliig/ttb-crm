@isTest
public class T_Performance_Onedown_Controller_Test {
    static String recordTypeIdBranch = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_branch').getRecordTypeId();
    static String recordTypeIdZone = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_zone').getRecordTypeId();
    static String recordTypeIdRegion = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_region').getRecordTypeId();
    static String recordTypeIdChannel = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_channel').getRecordTypeId();
    static String recordTypeIdGOC = Schema.SObjectType.T_Performance_Target_Product_by_Team__c.getRecordTypeInfosByName().get('level_group_of_channel').getRecordTypeId();

    

    static User createMockUser(Id profileId ,Id Roleid) {
        User u;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            u = new User(alias = 'TestUser', email='test@test.com',
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', localesidkey='en_US', profileid = profileId,UserRoleId=Roleid,
            timezonesidkey='America/New_York', username= String.valueOf(Roleid) + System.now().millisecond() + 'test@test.com');
            insert u;
            
        }
        return  u;
    }

    static User createMockUserForProfileAndRole(String profileName,String RoleName) {
        Profile p = [SELECT Id FROM profile WHERE name like :profileName limit 1];
        UserRole ur =[SELECT Name, DeveloperName from UserRole WHERE Name=:RoleName LIMIT 1];

        return createMockUser(p.id,ur.id);
    } 

    static User RetailUser{
        get
        {
            if(RetailUser == null){
                RetailUser = createMockUserForProfileAndRole('TMB Retail CRM Specialist','CRBO');
            }
            return RetailUser;
        }
        set;
    }
    static User notPermissionUser{
        get
        {
            if(notPermissionUser == null){
                notPermissionUser = createMockUserForProfileAndRole('TMB BDM Profile','SE RM SME5 Phitsanulok');
            }
            return notPermissionUser;
        }
        set;
    }

    @isTest static void testwatermark(){
        try {
            T_Performance_Onedown_Controller.getWatermarkHTML();
        } catch (Exception e) {
            
        }
        
    }

    @isTest static void testgetProductTargetTeamV1(){
        List<T_Performance_Target_Product_by_Team__c> channelList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c channel = new T_Performance_Target_Product_by_Team__c();
        channel.Group_Channel__c = 'BBD';
        channel.Channel_Name__c = 'Branch';
        channel.Unique_External_Key__c='202208001SUM5001';
        channel.Year__c ='2022';
        channel.Month__c ='08';
        channel.Product_Group_Code__c ='SUM5001';
        channel.Product_List__c ='BR5001;';
        channel.Rank__c ='5.1';
        channel.Indicator_Level1__c ='Special Assignment';
        channel.RecordTypeId = recordTypeIdZone;
        channelList.add(channel);
        T_Performance_Target_Product_by_Team__c channel2 = new T_Performance_Target_Product_by_Team__c();
        channel2.Group_Channel__c = 'BBD';
        channel2.Channel_Name__c = 'Telemarketing';
        channel2.Unique_External_Key__c='202208001SUM5002';
        channel2.Year__c ='2022';
        channel2.Month__c ='08';
        channel2.Product_Group_Code__c ='SUM5001';
        channel2.Product_List__c ='BR5001;';
        channel2.Rank__c ='5.1';
        channel2.Indicator_Level1__c ='Special Assignment';
        channel.RecordTypeId = recordTypeIdZone;
        channelList.add(channel2);
        insert channelList;
        String selectedYear = '2022';
        String selectedMonth = '11';        
        String period = 'YTD';
        String summaryGroupType = 'Retail';
        String summaryGroupValue = '';
        List<T_Performance_Target_Product_by_Team__c> teamList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c label = new T_Performance_Target_Product_by_Team__c();
        label.Unique_External_Key__c= '202208001SUM0002';
        label.Year__c = '2022';
        label.Month__c = '11';
        label.Product_Group_Code__c = 'SUM0002';
        label.Product_List__c = 'BR1001;BR1004;';
        label.Rank__c = '1.1';
        label.Indicator_Level1__c = 'Deposit & Investment';
        label.Channel_Name__c = 'Branch';
        teamList.add(label);
        insert teamList;

        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
        }
    }
    @isTest static void testgetProductTargetTeamV2(){
        List<T_Performance_Target_Product_by_Team__c> channelList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c channel = new T_Performance_Target_Product_by_Team__c();
        channel.Group_Channel__c = 'BBD';
        channel.Channel_Name__c = 'Branch';
        channel.Unique_External_Key__c='Unique_External_Key__c';
        channel.Year__c ='2022';
        channel.Month__c ='08';
        channel.Product_Group_Code__c ='SUM5001';
        channel.Product_List__c ='BR5001;';
        channel.Rank__c ='5.1';
        channel.Indicator_Level1__c ='Special Assignment';
        channel.RecordTypeId = recordTypeIdChannel;
        channelList.add(channel);
        insert channelList;
    
        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'MTD';
        String summaryGroupType = 'Group of channel';
        String summaryGroupValue = 'BBD';
        //  channelList = [SELECT Group_Channel__c, Channel_Name__c FROM T_Performance_Target_Product_by_Team__c WHERE Group_Channel__c IN('BBD','RASC')];
        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());            
            T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
        }
    }
    @isTest static void testgetProductTargetTeamV3(){
        List<T_Performance_Target_Product_by_Team__c> productList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c product = new T_Performance_Target_Product_by_Team__c();
        product.Product_Group_Code__c ='SUM1001';
        product.Channel_Name__c = 'Branch';
        product.Product_Group_Name__c ='MF Type B';
        product.Region_Code__c = '1800';
        product.Product_List__c ='BR1001;';
        product.Rank__c ='1.1';
        product.Indicator_Level1__c ='Deposit & Investment';
        product.Year__c ='2022';
        product.Month__c ='11';
        product.Group_Channel__c = 'BBD';
        product.Unique_External_Key__c='202208001SUM1001';
        product.RecordTypeId = recordTypeIdRegion;
        productList.add(product);
        insert productList;
        List<T_Performance_Team_List__c> regionNameList = new List<T_Performance_Team_List__c>();
        T_Performance_Team_List__c regionName = new T_Performance_Team_List__c();
        regionName.Region_Code__c ='1800';
        regionName.Region_Name__c = 'RH1';
        regionNameList.add(regionName);
        insert regionName;
        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'MTD';
        String summaryGroupType = 'Channel';
        String summaryGroupValue = 'Branch';
        

        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
        }
    }
    @isTest static void testgetProductTargetTeamV4(){
        List<T_Performance_Target_Product_by_Team__c> productList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c product = new T_Performance_Target_Product_by_Team__c();
        product.Product_Group_Code__c ='SUM1001';
        product.Channel_Name__c = 'Branch';
        product.Product_Group_Name__c ='MF Type B';
        product.Region_Code__c = '1800';
        product.Zone_Code__c = '1820';
        product.Product_List__c ='BR1001;';
        product.Rank__c ='1.1';
        product.Indicator_Level1__c ='Deposit & Investment';
        product.Year__c ='2022';
        product.Month__c ='11';
        product.Group_Channel__c = 'BBD';
        product.Unique_External_Key__c='202208001SUM1001';
        product.RecordTypeId = recordTypeIdZone;
        productList.add(product);
        insert productList;

        List<T_Performance_Team_List__c> zoneList = new List<T_Performance_Team_List__c>();
        T_Performance_Team_List__c zoneName = new T_Performance_Team_List__c();
        zoneName.Zone_Code__c ='1820';
        zoneName.Region_Code__c = '1800';
        zoneName.Zone_Name__c = 'PATHUMWAN';
        zoneList.add(zoneName);
        insert zoneList;


        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'MTD';
        String summaryGroupType = 'Region';
        String summaryGroupValue = '1800';

        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
        }
    }
    @isTest static void testgetProductTargetTeamV5(){
        List<T_Performance_Target_Product_by_Team__c> productList = new List<T_Performance_Target_Product_by_Team__c>();
        T_Performance_Target_Product_by_Team__c product = new T_Performance_Target_Product_by_Team__c();
        product.Product_Group_Code__c ='SUM1001';
        product.Channel_Name__c = 'Branch';
        product.Product_Group_Name__c ='MF Type B';
        product.Region_Code__c = '1800';
        product.Zone_Code__c = '1820';
        product.Branch_Team_Code__c = '001';
        product.Product_List__c ='BR1001;';
        product.Rank__c ='1.1';
        product.Indicator_Level1__c ='Deposit & Investment';
        product.Year__c ='2022';
        product.Month__c ='11';
        product.Group_Channel__c = 'BBD';
        product.Unique_External_Key__c='202208001SUM1001';
        product.RecordTypeId = recordTypeIdBranch;
        productList.add(product);
        insert productList;

        List<T_Performance_Team_List__c> branchList = new List<T_Performance_Team_List__c>();
        T_Performance_Team_List__c branchName = new T_Performance_Team_List__c();
        branchName.Branch_Team_Code__c ='001';
        branchName.Branch_Team_Name__c = 'สาขาสำนักพหลโยธิน';
        branchList.add(branchName);
        insert branchList;

        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'MTD';
        String summaryGroupType = 'Zone';
        String summaryGroupValue = '1820';
        Test.startTest();
        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current RetailUser: ' + RetailUser);
        T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
        }
        Test.stopTest();
    }

    @isTest static void testgetProductTargetTeamErrorV1(){
        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'YTD';
        String summaryGroupType = 'mock001';
        String summaryGroupValue = 'mock1';
        Test.startTest();
        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            try {
                T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
            } catch (AuraHandledException e) {
                
            }
        }
        Test.stopTest();
    }
    @isTest static void testgetProductTargetTeamErrorV2(){
        String selectedYear = '2022';
        String selectedMonth = '11';
        String period = 'YTD';
        String summaryGroupType = 'Retail';
        String summaryGroupValue = '';
        Test.startTest();
        System.runAs(notPermissionUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            try {
                T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
            } catch (AuraHandledException e) {
                
            }
        }
        Test.stopTest();
    }
    @isTest static void testgetProductTargetTeamErrorV3(){
        String selectedYear = null;
        String selectedMonth = null;
        String period = null;
        String summaryGroupType = 'Retail';
        String summaryGroupValue = '';
        Test.startTest();
        System.runAs(RetailUser){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            try {
                T_Performance_Onedown_Controller.getProductTargetTeam2(selectedYear, selectedMonth, period, summaryGroupType, summaryGroupValue);
            } catch (AuraHandledException e) {
                
            }
        }
        Test.stopTest();
    }

    @isTest static void testchunkQueryV1(){
        List<Summary_Team_and_Product__c> stList = new List<Summary_Team_and_Product__c>();
        for(Integer i=0; i<2 ;i++){
            Summary_Team_and_Product__c st = new Summary_Team_and_Product__c();
        st.Actual_Amount__c = 1000;
        st.Month__c = '11';
        st.Year__c  = '2022';
        st.Unique_External_Key__c = 'szxcwlqwezxyyulqwdwzz' + i;
        st.Indicator_Code__c = 'BR1001';
        st.Channel_Name__c = 'Branch';
        st.Region_Code__c = '1800';
        st.Zone_Code__c = '1820';
        st.Branch_Team_Code__c = '001'+i;
        stList.add(st);
        }
        insert stList;
        // ObjectMock Object1 = new ObjectMock();
        T_Performance_Onedown_Controller.chunkQueryWrapper Object1 = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
        Object1.chunkSize = 35000;
        Object1.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
        Object1.queryObject = 'Summary_Team_and_Product__c';
        Object1.condition = ' WHERE Year__c = \'2022\' AND Month__c = \'11\'  AND Indicator_Code__c IN  (\'BR1001\') AND Channel_Name__c IN( \'Branch\') ';
        Object1.isEndRecord = false;
        Object1.lastRecordId = null;
        Object1.resultRecords = null;

        T_Performance_Onedown_Controller.chunkQueryWrapper chunkQuery2 = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
        chunkQuery2.chunkSize = 35000;
        chunkQuery2.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
        chunkQuery2.queryObject = 'Summary_Team_and_Product__c';
        chunkQuery2.condition = null;
        chunkQuery2.isEndRecord = false;
        chunkQuery2.lastRecordId = null;
        chunkQuery2.resultRecords = null;

        T_Performance_Onedown_Controller.chunkQueryWrapper chunkQueryLastRecordId = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
        chunkQueryLastRecordId.chunkSize = 1;
        chunkQueryLastRecordId.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
        chunkQueryLastRecordId.queryObject = 'Summary_Team_and_Product__c';
        chunkQueryLastRecordId.condition = null;
        chunkQueryLastRecordId.isEndRecord = false;
        chunkQueryLastRecordId.lastRecordId = stList[0].id;
        chunkQueryLastRecordId.resultRecords = null;

        T_Performance_Onedown_Controller.chunkQueryWrapper chunkQueryLastRecordId2 = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
        chunkQueryLastRecordId2.chunkSize = 1;
        chunkQueryLastRecordId2.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
        chunkQueryLastRecordId2.queryObject = 'Summary_Team_and_Product__c';
        chunkQueryLastRecordId2.condition =  ' WHERE Year__c = \'2022\' AND Month__c = \'11\'  AND Indicator_Code__c IN  (\'BR1001\') AND Channel_Name__c IN( \'Branch\') ';
        chunkQueryLastRecordId2.isEndRecord = false;
        chunkQueryLastRecordId2.lastRecordId = stList[0].id;
        chunkQueryLastRecordId2.resultRecords = null;
        Test.startTest();
        System.runAs(RetailUser){
            try {
                T_Performance_Onedown_Controller.chunkQuery(Object1);
                T_Performance_Onedown_Controller.chunkQuery(chunkQuery2);
                T_Performance_Onedown_Controller.chunkQuery(chunkQueryLastRecordId);
                T_Performance_Onedown_Controller.chunkQuery(chunkQueryLastRecordId2);
            } catch (DmlException  e) {
                
            }

        }
        Test.stopTest();
    }
    @isTest static void testchunkQueryError(){
        List<Summary_Team_and_Product__c> stList = new List<Summary_Team_and_Product__c>();
        for(Integer i=0; i<2 ;i++){
            Summary_Team_and_Product__c st = new Summary_Team_and_Product__c();
        st.Actual_Amount__c = 1000;
        st.Month__c = '11';
        st.Year__c  = '2022';
        st.Unique_External_Key__c = 'szxcwlqwezxyyulqwdwzz' + i;
        st.Indicator_Code__c = 'BR1001';
        st.Channel_Name__c = 'Branch';
        st.Region_Code__c = '1800';
        st.Zone_Code__c = '1820';
        st.Branch_Team_Code__c = '001'+i;
        stList.add(st);
        }
        insert stList;
        // ObjectMock Object1 = new ObjectMock();
        T_Performance_Onedown_Controller.chunkQueryWrapper Object1 = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
        Object1.chunkSize = 35000;
        Object1.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
        Object1.queryObject = 'Summary_Team_and_Product__c';
        Object1.condition = ' WHERE Year__c = \'2022\' AND Month__c = \'11\'  AND Indicator_Code__c IN  (\'BR1001\') AND Channel_Name__c IN( \'Branch\') ';
        Object1.isEndRecord = false;
        Object1.lastRecordId = null;
        Object1.resultRecords = null;

        Test.startTest();
        System.runAs(RetailUser){
            try {
                T_Performance_Onedown_Controller.chunkQuery(Object1);
            } catch (AuraHandledException  e) {
                
            }

        }
        Test.stopTest();
    }
    // @isTest static void testchunkQueryV2(){
    //     // ObjectMock Object1 = new ObjectMock();
    //     T_Performance_Onedown_Controller.chunkQueryWrapper Object1 = new  T_Performance_Onedown_Controller.chunkQueryWrapper();
    //     Object1.chunkSize = 35000;
    //     Object1.fieldList = 'Id,Actual_Amount__c, Indicator_Code__c,Indicator_Level1__c, Channel_Name__c, Region_Code__c, Zone_Code__c, Branch_Team_Code__c, Year__c, Month__c ';
    //     Object1.queryObject = 'Summary_Team_and_Product__c';
    //     Object1.condition = null;
    //     Object1.isEndRecord = null;
    //     Object1.lastRecordId = null;
    //     Object1.resultRecords = null;
    //     System.runAs(RetailUser){
    //     T_Performance_Onedown_Controller.chunkQuery(Object1);
    //     }
    // }
    
    
}