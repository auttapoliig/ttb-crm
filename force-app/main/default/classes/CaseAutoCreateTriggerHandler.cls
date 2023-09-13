public without sharing class CaseAutoCreateTriggerHandler {
    public static void run() {
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                List<Id> chatSessionIdList = new List<Id>();
                List<Id> socialPostIdList = new List<Id>();
                List<Id> caseIdList = new List<Id>();
                Map<Id, AgentWork> agentWorkMap = new Map<Id, AgentWork>();
                List<AgentWork> agentWorkTriggerList = Trigger.new;
                for (AgentWork agentWork : agentWorkTriggerList) {
                    System.debug('agentWork: ' + agentWork);
                    // acccept datetime
                    Datetime workAcceptDateTime = agentWork.AcceptDateTime;
                    // accecpt status == Opened
                    String workStatus = agentWork.Status;
                    Id OwnerId = agentWork.OwnerId;
                    // workItemType == chatSession__c
                    Schema.SObjectType workItemType = agentWork.WorkItemId.getSObjectType();

                    if (workAcceptDateTime != null && workStatus == 'Opened') {
                        Schema.SObjectType wiObjectType = agentWork.WorkItemId.getSObjectType();
                        
                        if (Schema.iigproduct_2__ChatSession__c.getSObjectType() == wiObjectType) {
                            Id chatSessionId = agentWork.WorkItemId;
                            chatSessionIdList.add(chatSessionId);
                            agentWorkMap.put(chatSessionId, agentWork);
                        } else if (Schema.Social_Post__c.getSObjectType() == wiObjectType) {
                        	Id socialPostId = agentWork.WorkItemId;
                        	socialPostIdList.add(socialPostId);
                        	agentWorkMap.put(socialPostId, agentWork);
                        } else if (Schema.Case.getSObjectType() == wiObjectType) {
                            Id caseId = agentWork.WorkItemId;
                            caseIdList.add(caseId);
                            agentWorkMap.put(caseId, agentWork);
                        }
                    }
                }

                if (chatSessionIdList.size() > 0) {
                    CaseAutoCreateTriggerHandler.afterUpdate(chatSessionIdList, agentWorkMap);
                }

                if (socialPostIdList.size() > 0) {
                	CaseAutoCreateTriggerHandler.afterUpdateForSocialPost(socialPostIdList, agentWorkMap);
                }
                
                if (caseIdList.size() > 0) {
                    CaseAutoCreateTriggerHandler.afterUpdateForCase(caseIdList, agentWorkMap);
                }
            }
        }
    }


    public static void afterUpdate(List<Id> chatSessionIdList, Map<Id, AgentWork> chatworkMap) {
        System.debug('Preparing Data start: ' + System.now() + ' | ' + System.now().getTime());
        List<iigproduct_2__ChatSession__c> chatSessionList = [
            SELECT
                Id,
                iigproduct_2__Subject__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Display_Name__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Phone_Number__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Email__c,
                iigproduct_2__Status__c,
                iigproduct_2__Case__c,
                iigproduct_2__RMID__c,
                Accept_Datetime__c,
                Assign_Datetime__c
            FROM iigproduct_2__ChatSession__c
            // WHERE Id IN :chatSessionIdList AND iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c = 'ttb Website'
            WHERE Id IN :chatSessionIdList AND iigproduct_2__Case__c = NULL
        ];

        // map of chatSessionId to Case
        Map<Id, Case> mapSessioIdToCase = new Map<Id, Case>();

        // skill master
        Map<String, Skill_Master__c> skillMasterMapWeb = new Map<String, Skill_Master__c>();

        List<Skill_Master__c> skillListWeb = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - ttb Web'
        ];

        Map<String, Skill_Master__c> skillMasterMapTouch = new Map<String, Skill_Master__c>();

        List<Skill_Master__c> skillListTouch = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - ttb touch'
        ];

        List<Skill_Master__c> skillListLine = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - Line'
        ];

        List<Skill_Master__c> skillListFacebook = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - Facebook'
        ];

        for (Skill_Master__c s : skillListWeb) {
            skillMasterMapWeb.put(s.Topic__c, s);
        }

        for (Skill_Master__c t : skillListTouch) {
            skillMasterMapTouch.put(t.Topic__c, t);
        }

        List<String> rmidList = new List<String>();
        for (iigproduct_2__ChatSession__c c : chatSessionList) {
            if (c.iigproduct_2__RMID__c != null) {
                rmidList.add(c.iigproduct_2__RMID__c);
            }
        }
        Map<String, Account> accountMap = new Map<String, Account>();
        for (Account a : [SELECT TMB_Customer_ID_PE__c, Id FROM Account WHERE TMB_Customer_ID_PE__c IN :rmidList]) {
            accountMap.put(a.TMB_Customer_ID_PE__c, a);
        }
        System.debug('Preparing Data done: ' + System.now() + ' | ' + System.now().getTime());

        System.debug('CaseCreate put data start: ' + System.now() + ' | ' + System.now().getTime());
        for (iigproduct_2__ChatSession__c chatSession : chatSessionList) {
            Case thisCase = new Case();
            thisCase.Status = 'New';
            thisCase.Subject = chatSession.iigproduct_2__Subject__c;
            thisCase.Contact_Person_Name__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Display_Name__c;
            thisCase.Contact_Person_Phone__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Phone_Number__c;
            thisCase.Contact_Person_Email__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Email__c;
            String socialType = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c;
            if (socialType == 'ttb Website') {
                socialType = 'Chat - ttb Web';
                if (skillMasterMapWeb.containsKey(thisCase.Subject)) {
                    thisCase.PTA_Segment__c = skillMasterMapWeb.get(thisCase.Subject).Segment__c;
                    thisCase.Category__c = skillMasterMapWeb.get(thisCase.Subject).Service_Level1__c;
                    thisCase.Sub_Category__c = skillMasterMapWeb.get(thisCase.Subject).Service_Level2__c;
                    // thisCase.Service_Type_Matrix_Code__c = skillMasterMapWeb.get(thisCase.Subject).Validate_Code__c;
                }
            } else if (socialType == 'Line') {
                socialType = 'Chat - Line';
                thisCase.Subject = skillListLine[0].Topic__c;
                thisCase.PTA_Segment__c = skillListLine[0].Segment__c;
                thisCase.Category__c = skillListLine[0].Service_Level1__c;
                thisCase.Sub_Category__c = skillListLine[0].Service_Level2__c;
                // thisCase.Service_Type_Matrix_Code__c = skillListLine[0].Validate_Code__c;
            } else if (socialType == 'Facebook') {
                socialType = 'Chat - Facebook';
                thisCase.Subject = skillListFacebook[0].Topic__c;
                thisCase.PTA_Segment__c = skillListFacebook[0].Segment__c;
                thisCase.Category__c = skillListFacebook[0].Service_Level1__c;
                thisCase.Sub_Category__c = skillListFacebook[0].Service_Level2__c;
                // thisCase.Service_Type_Matrix_Code__c = skillListFacebook[0].Validate_Code__c;
            } else if (socialType == 'OneApp' || socialType == 'TOUCH') {
                socialType = 'Chat - ttb touch';
                if (skillMasterMapTouch.containsKey(thisCase.Subject)) {
                    thisCase.PTA_Segment__c = skillMasterMapTouch.get(thisCase.Subject).Segment__c;
                    thisCase.Category__c = skillMasterMapTouch.get(thisCase.Subject).Service_Level1__c;
                    thisCase.Sub_Category__c = skillMasterMapTouch.get(thisCase.Subject).Service_Level2__c;
                    // thisCase.Service_Type_Matrix_Code__c = skillMasterMapTouch.get(thisCase.Subject).Validate_Code__c;
                }
                if (accountMap.containsKey(chatSession.iigproduct_2__RMID__c)) {
                    thisCase.AccountId = accountMap.get(chatSession.iigproduct_2__RMID__c).Id;
                }
            }
            thisCase.Origin = socialType;
            // thisCase.Current_Service_Template__c = 'General';
            mapSessioIdToCase.put(chatSession.Id, thisCase);

            if (chatworkMap.containsKey(chatSession.Id) && chatSession.Accept_Datetime__c == null && chatSession.Assign_Datetime__c == null) {
                chatSession.Accept_Datetime__c = chatworkMap.get(chatSession.Id).AcceptDateTime;
                chatSession.Assign_Datetime__c = chatworkMap.get(chatSession.Id).AssignedDateTime;
            }
        }
        System.debug('CaseCreate put data done: ' + System.now() + ' | ' + System.now().getTime());
        
        System.debug('CaseCreate case owner mapping: ' + System.now() + ' | ' + System.now().getTime());
        List<iigproduct_2__ChatSession__c> caseSessionList = [
            SELECT Id, iigproduct_2__Case__c, iigproduct_2__Case__r.OwnerId
            FROM iigproduct_2__ChatSession__c
            WHERE Id IN :chatSessionIdList AND iigproduct_2__Case__c != NULL
        ];

        Id currUserId = UserInfo.getUserId();
        Set<Id> caseToUpdate = new Set<Id>();
        for (iigproduct_2__ChatSession__c chat : caseSessionList) {
            if (currUserId != chat.iigproduct_2__Case__r.OwnerId) {
                caseToUpdate.add(chat.iigproduct_2__Case__c);
            }
        }

        List<Case> changedOwnerCase = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseToUpdate];
        for (Case eachCase : changedOwnerCase) {
            eachCase.OwnerId = currUserId;
        }
        System.debug('CaseCreate case owner done: ' + System.now() + ' | ' + System.now().getTime());
        
        if (!changedOwnerCase.isEmpty()){
            System.debug('change case owner start: ' + System.now() + ' | ' + System.now().getTime());
            update changedOwnerCase;
            System.debug('change case owner done: ' + System.now() + ' | ' + System.now().getTime());
        }

        if (Case.sObjectType.getDescribe().isCreateable() || Case.sObjectType.getDescribe().isUpdateable()) {
            System.debug('CaseCreate start: ' + System.now() + ' | ' + System.now().getTime());
            upsert mapSessioIdToCase.values();
            System.debug('CaseCreate finish: ' + System.now() + ' | ' + System.now().getTime());
        }
        System.debug('CaseCreate finish: ' + System.now() + ' | ' + System.now().getTime());

        for (iigproduct_2__ChatSession__c thisChatSession : chatSessionList) {
            Case mapCase = mapSessioIdToCase.get(thisChatSession.Id);
            thisChatSession.iigproduct_2__Case__c = mapCase.Id;
            if (thisChatSession.iigproduct_2__Status__c == 'Waiting') {
                thisChatSession.iigproduct_2__Status__c = 'Inprogress';
            }
            System.debug('changed session');
        }
        
        update chatSessionList;
    }

    public static void afterUpdateForSocialPost(List<Id> socialPostIdList, Map<Id, AgentWork> postworkMap) {
        if (!socialPostIdList.isEmpty()) {
            Case newCase = null;
            Case mapCase = null;
            Skill_Master__c currentSkillMaster = null;
            Map<Id, Case> mapSocialPostIdWithCase = new Map<Id, Case>();
            List<Social_Post__c> socialPostToUpdateList = new List<Social_Post__c>();

            // Find skill master information
            Map<String, Skill_Master__c> skillMasterMap = new Map<String, Skill_Master__c>();
            for (Skill_Master__c skillMaster : [SELECT id, Topic__c, Source__c, Segment__c, Assign_to_Queue__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Problem_Type__c, Social_Network__c, Topic_Profile_Name__c 
                                                    FROM Skill_Master__c 
                                                    WHERE Assign_to_Queue__c like 'Post%']) {

                skillMasterMap.put(skillMaster.Topic_Profile_Name__c, skillMaster);
            }
            
            List<Social_Post__c> socialPostList = [SELECT id, Topic_Profile_Name__c, Social_Post_Author__r.Post_Author_Name__c
                                                    FROM Social_Post__c 
                                                    WHERE id in :socialPostIdList AND Case__c = NULL];

            for (Social_Post__c socialPost : socialPostList) {
                System.debug('SocialPost :: ' + socialPost.id);

                currentSkillMaster = skillMasterMap.get(socialPost.Topic_Profile_Name__c);
                
                // Create new Case
                newCase = new Case();
                newCase.Status = 'New';
                newCase.Contact_Person_Name__c = socialPost.Social_Post_Author__r.Post_Author_Name__c;
                newCase.Subject = currentSkillMaster.Topic__c;
                newCase.PTA_Segment__c = currentSkillMaster.Segment__c;
                newCase.Category__c = currentSkillMaster.Service_Level1__c;
                newCase.Sub_Category__c = currentSkillMaster.Service_Level2__c;
                newCase.Origin = currentSkillMaster.Social_Network__c;

                mapSocialPostIdWithCase.put(socialPost.Id, newCase);
            }

            List<Social_Post__c> casePostList = [
                SELECT Id, Case__c, Case__r.OwnerId
                FROM Social_Post__c
                WHERE Id IN :socialPostIdList AND Case__c != NULL
            ];

            Id currUserId = UserInfo.getUserId();
            Set<Id> caseToUpdate = new Set<Id>();
            for (Social_Post__c post : casePostList) {
                if (currUserId != post.Case__r.OwnerId) {
                    caseToUpdate.add(post.Case__c);
                }
            }

            List<Case> changedOwnerCase = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseToUpdate];
            for (Case eachCase : changedOwnerCase) {
                eachCase.OwnerId = currUserId;
            }
            
            if (!changedOwnerCase.isEmpty()){
                update changedOwnerCase;
            }

            if (Case.sObjectType.getDescribe().isCreateable() || Case.sObjectType.getDescribe().isUpdateable()) {
                upsert mapSocialPostIdWithCase.values();
            }

            for (Social_Post__c socialPost : socialPostList) {
                mapCase = mapSocialPostIdWithCase.get(socialPost.Id);
                socialPost.Case__c = mapCase.Id;

                // Update datetime field when accept AgentWork
                if (postworkMap.containsKey(socialPost.Id)) {
                    socialPost.Accept_Datetime__c = postworkMap.get(socialPost.Id).AcceptDateTime;
                    socialPost.Assign_Datetime__c = postworkMap.get(socialPost.Id).AssignedDateTime;
                }
            }

            update socialPostList;
        }

    }

    public static void afterUpdateForCase(List<Id> caseIdList, Map<Id, AgentWork> caseworkMap) {
        if (!caseIdList.isEmpty()) {
            List<Case> caseList = [SELECT Id, SourceId, Accept_Datetime__c FROM Case WHERE Id IN :caseIdList];
            List<Case> eList = new List<Case>();
            if (!caseList.isEmpty()) {
                for (Case c : caseList) {
                    Schema.SObjectType sourceObjectType = c.SourceId.getSObjectType();
                    if (Schema.EmailMessage.getSObjectType() == sourceObjectType && caseworkMap.containsKey(c.Id) && c.Accept_Datetime__c == null) {
                        c.Accept_Datetime__c = caseworkMap.get(c.Id).AcceptDateTime;
                        eList.add(c);
                    }
                }
                update eList;
            }
        }
    }
}