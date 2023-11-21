public class SecurityScan {

    //get set for current user
    public static User currentUser {
        get
        {
            if(currentUser == null){ 
                currentUser = [SELECT Id, Name, RTL_Branch__c, RTL_Branch_Code__c, ProfileId, UserRoleId FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
            }
            return currentUser;
            
        }set;
    }

    public static List<String> leadStatusList {
        get
        {
            if(leadStatusList == null){ 
                Data_Partition_App_Config__mdt dataPartitionLeadStatus = Data_Partition_App_Config__mdt.getInstance('Lead_Status_Permission');
                leadStatusList = dataPartitionLeadStatus.Value__c.split(';');
            }
            return leadStatusList;
            
        }set;
    }

    public static List<String> referralStatusList {
        get
        {
            if(referralStatusList == null){ 
                Data_Partition_App_Config__mdt dataPartitionReferralStatus = Data_Partition_App_Config__mdt.getInstance('Referral_Status_Permission');
                referralStatusList = dataPartitionReferralStatus.Value__c.split(';');
            }
            return referralStatusList;
            
        }set;
    }

    public static List<String> campaignStatusList {
        get
        {
            if(campaignStatusList == null){ 
                Data_Partition_App_Config__mdt dataPartitionCampaignStatus = Data_Partition_App_Config__mdt.getInstance('Campaign_Status_Permission');
                campaignStatusList = dataPartitionCampaignStatus.Value__c.split(';');
            }
            return campaignStatusList;
            
        }set;
    }

    public static Object applySecurityMatrix(Map<String, Object> jsonMap, String recordId, List<String> fields, List<String> fields_translate) {
        Profile p = [SELECT Name FROM Profile WHERE Id =: currentUser.ProfileId];
        String dataHidden = Label.Data_Condition_Hidden_Text;
        String profileName = p.Name;
        Map<String, String> dpMap = new Map<String, String>();
        Set<String> sectionList = new Set<String>();
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        for(Security_Matrix__mdt m : [SELECT Field__c, Section__c FROM Security_Matrix__mdt WHERE Field__c IN: fields]){
            dpMap.put(m.Field__c, m.Section__c);
            sectionList.add(m.Section__c);
        }
        // ใช้ TestByNobNab
        accessMap = getSectionAccessibility(profileName, recordId);
        // เอาไว้หา value ในแต่ละ field 
        Map<String, Object> searchKeyMap = new Map<string, Object>();
        for(String key : jsonMap.keySet()){
            searchKeyMap = (Map<string,Object>) jsonMap.get(key);
            String section = dpMap.get(key);
            if(section != null){
                Boolean sectionvisible = accessMap.get(section);
                if(sectionvisible == true){
                    searchKeyMap.put('isAccessible', true);
                }
                else{
                    searchKeyMap.put('value', dataHidden);
                    searchKeyMap.put('isAccessible', false);
                }
            }
            else{
                searchKeyMap.put('value', dataHidden);
                searchKeyMap.put('isAccessible', false);
            }
            jsonMap.put(key, searchKeyMap);
        }
        return (Object) jsonMap;
    }

    public static Object getVerifyByField(String field, String profileName, String recordId){
        String section =  [SELECT Field__c, Section__c FROM Security_Matrix__mdt WHERE Field__c =: field].Section__c;
        Object isVisible = RetailCSVLightningUtil.verifyFieldSecurity(section, profileName, recordId);
        return isVisible;
    }
    public static Map<String, Boolean> getSectionAccessibility(String profileName, Id recordId) {
        Map<String, Boolean> sectionVis = new Map<String, Boolean>();
        Boolean authVis = false;
        Set<String> authSection = new Set<String>() ;
        for(Data_Security_Matrix__c each : [SELECT Id, Access_Type__c, Profile_Name__c, Section_Name__c, Data_Matrix_Key__c FROM Data_Security_Matrix__c WHERE Profile_Name__c =: profileName]){
            if(each.Access_Type__c == 'All'){
                sectionVis.put(each.Section_Name__c, true);
            }
            else if(each.Access_Type__c == 'Authorize Only'){
                authSection.add(each.Section_Name__c);
            }
            else{
                sectionVis.put(each.Section_Name__c, false);
            }
        }
        if(authSection.size() > 0){
            authVis = verifyForAuth(recordId);
            for(String section : authSection){
                sectionVis.put(section, authVis);
            }
        }
        return sectionVis;
    }
    public static Boolean verifyForAuth(Id objId){
        Boolean isVisible = false;   
        System.debug('UserName:' + currentUser.Name);
        Id UserId = currentUser.Id;
        //User cu = [SELECT Id,name,Employee_ID__c,UserRoleId ,UserRole.name  FROM User WHERE id = :UserId ];
        
        List<Id> accountOwnerList = new List<Id>();
        
        List<Id> teamMemberIdList = new List<Id>();
        List<Id> objShareTeamMemberIdList = new List<Id>();
        
        Id objOwnerId;
        //String empBrCode;
        Id rtlWealthRM;
        Boolean condition3 = false;
        String objectType = objId.getsobjecttype().getDescribe().getName();
        
        if( objectType == 'Account' ){               
            Account acc = [SELECT id, Name, ownerId, RTL_RM_Name__c, RTL_Wealth_RM__c, RTL_Assigned_BRC__c, RTL_Most_Operating_Branch__r.Branch_Code__c  FROM Account WHERE Id =:objId ];
            objOwnerId = acc.ownerId;

            rtlWealthRM = acc.RTL_Wealth_RM__c;
            
            teamMemberIdList = RTL_AccountUtility.getAccountTeamMeammer(objId);

            if(acc.RTL_Assigned_BRC__c != null){
                accountOwnerList.add(acc.RTL_Assigned_BRC__c);
            }

            condition3 = isAccountCampaignMemberVisible(objId) || isAccountLeadVisible(objId) || isAccountBranchVisible(acc) || isAccountReferralVisible(objId)? true : false;
            
        }
        else if ( objectType == 'Contact' ){
            Contact con = [SELECT id,Account.ownerId,Account.RTL_RM_Name__c,Account.RTL_Wealth_RM__c,AccountId FROM Contact WHERE id =:objId ];
            objOwnerId = con.Account.ownerId;
            //empBrCode = con.Account.RTL_RM_Name__c;
            rtlWealthRM = con.Account.RTL_Wealth_RM__c;
            
            Id accountId = (ID)con.get('AccountId'); 
            
            teamMemberIdList = RTL_AccountUtility.getAccountTeamMeammer(accountId);
            objShareTeamMemberIdList = RTL_AccountUtility.getAccountShare(accountId);
            
        }
        // Other custom object dynamically get owner etc. here
        // empBrCode not require for other object other than Account and Contact
        else if( objId.getsobjecttype().getDescribe().isCustom() ){
            sObject obj = Database.query( ' SELECT id,OwnerId FROM ' + objId.getsobjecttype() +' WHERE id = :objId '  );
            
            objOwnerId = (ID)obj.get('OwnerId');
            
            String shareObjName = objectType.replace('__c','__share');
            
            List<sObject> shareObjList = Database.query( ' SELECT id,ParentId,UserOrGroupId,AccessLevel FROM ' + shareObjName +' WHERE ParentId = :objId '  );
            
             
            for( sObject shareObj : shareObjList ){
                objShareTeamMemberIdList.add( (ID)shareObj.get('UserOrGroupId') );
            }
        }
        else{
        //other statndard object
        }
        
        // Add all Account team memmber to account List
        if( teamMemberIdList.size() > 0 ){
            accountOwnerList.addAll(  teamMemberIdList );
        }
        
        // Add all account share to account List
        if( objShareTeamMemberIdList.size() > 0 ){
            accountOwnerList.addAll(  objShareTeamMemberIdList );
        }
        //Get Account owner 
        if( objOwnerId != null ){
            accountOwnerList.add(objOwnerId);
        }
        if(  rtlWealthRM != null ){
            accountOwnerList.add( rtlWealthRM );
        }
        Map<Id,User> mul = new Map<Id,User>( [ SELECT id,name, UserRoleId ,UserRole.name, UserRole.ParentRoleId FROM User WHERE id in :accountOwnerList ] );      
        // Check if current User existing in User list 
        // Owner , EMP Code or team member
       Boolean condition1 = mul.containsKey(UserId) ? true : false;

       Boolean condition2 = getParentRoleVisible(mul);

        // Else then check for Hiughter role hierachy
        isVisible = condition1 || condition2 || condition3;
        
        return isVisible;
    }

    private static Boolean getParentRoleVisible(Map<Id,User> mul){
        Id currentRoleId = currentUser.UserRoleId;
        Set<ID> allParentRoles = new Set<Id>();
        Set<ID> setChildRoles = new Set<Id>();
        for( User acessU : mul.values() ){
            if( acessU.UserRoleId != null )
            {
                setChildRoles.add(acessU.UserRoleId);
            }
        }
        allParentRoles = RTL_AccountUtility.getParentRoleId( setChildRoles );
        return allParentRoles.contains(currentRoleId) ? true : false;
    }

    public static Boolean isAccountCampaignMemberVisible(Id accountId){
        List<Id> accountCampaignMemberIdList = new List<Id>();
        List<CampaignMember> campaignMemberList = [SELECT Id, Name, Customer__c, Campaign.Status, RTL_Assigned_Agent__c,RTL_Assigned_Branch__c FROM CampaignMember WHERE Customer__c =: accountId AND Campaign.Status IN: campaignStatusList AND (RTL_Assigned_Agent__c =:currentUser.Id OR (RTL_Assigned_Agent__c = null AND RTL_Assigned_Branch__c != null AND RTL_Assigned_Branch__r.Branch_Code__c =: currentUser.RTL_Branch_Code__c) )];
        
        
        return campaignMemberList.size() > 0 ? true : false;
    }

    public static Boolean isAccountLeadVisible(Id accountId){
        for(Lead eachLead : [SELECT Id, Name, OwnerId, Status FROM Lead WHERE Customer__c =: accountId AND Status IN: leadStatusList]){

            if(LeadAssignmentUtil.mapIdQueue.containsKey(eachLead.OwnerId)){
                String branchCode = LeadAssignmentUtil.mapIdQueue.get(eachLead.OwnerId).DeveloperName;
                if(branchCode.indexOf('_') != -1) {
                    branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                }

                if(branchCode == currentUser.RTL_Branch_Code__c){
                    return true;
                } 
            }else if(LeadAssignmentUtil.mapIdUser.containsKey(eachLead.OwnerId)){
                if(currentUser.Id == eachLead.OwnerId){
                    return true;
                }
            }
        }

        return false;
    }

    public static Boolean isAccountReferralVisible(Id accountId){

        for(RTL_Referral__c eachRef : [SELECT Id, Name, RTL_Account_Name__c, RTL_Stage__c, OwnerId FROM RTL_Referral__c WHERE RTL_Account_Name__c =: accountId AND RTL_Stage__c IN: referralStatusList]){
            if(LeadAssignmentUtil.mapIdQueue.containsKey(eachRef.OwnerId)){
                String branchCode = LeadAssignmentUtil.mapIdQueue.get(eachRef.OwnerId).DeveloperName;
                if(branchCode.indexOf('_') != -1) {
                    branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                }

                if(branchCode == currentUser.RTL_Branch_Code__c){
                    return true;
                } 
            }else if(LeadAssignmentUtil.mapIdUser.containsKey(eachRef.OwnerId)){
                if(currentUser.Id == eachRef.OwnerId){
                    return true;
                }
            }
        }

        return false;
    }

    public static Boolean isAccountBranchVisible(Account accObj){
        Boolean isVisible = false;
        if(accObj.RTL_Assigned_BRC__c != null){
            isVisible = accObj.RTL_Assigned_BRC__c == currentUser.Id ? true : false;
        }else if(accObj.RTL_Most_Operating_Branch__c != null){
            Boolean cond1 = accObj.RTL_Most_Operating_Branch__r.Branch_Code__c != null;
            Boolean cond2 = currentUser.RTL_Branch_Code__c != null;
            Boolean cond3 = accObj.RTL_Most_Operating_Branch__r.Branch_Code__c == currentUser.RTL_Branch_Code__c;

            isVisible = cond1 && cond2 && cond3 ? true : false;
        }
        return isVisible;
    }

    
}