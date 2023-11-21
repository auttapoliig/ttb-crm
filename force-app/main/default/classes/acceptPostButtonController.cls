public with sharing class acceptPostButtonController {
    public virtual class BaseException extends Exception {
    }
    public class OtherException extends BaseException {
    }

    @AuraEnabled
    public static void acceptPost(Id recordId, Id userId) {
        Social_Post__c currentPost = [
            SELECT Id, OwnerId, Owner.Name, Accept_Datetime__c, Assign_Datetime__c, Case__c, Topic_Profile_Name__c, Social_Post_Author__r.Post_Author_Name__c
            FROM Social_Post__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        // Assigned, Opened, Unavailable, Declined, DeclinedOnPushTimeout, Closed, Canceled
        Social_Post__c currentOwner = [SELECT ownerId FROM Social_Post__c WHERE Id = :recordId LIMIT 1];
        List<AgentWork> agentWork = [SELECT Id FROM AgentWork WHERE WorkItemId = :recordId AND Status != 'Unavailable' AND Status != 'Declined' AND Status != 'DeclinedOnPushTimeout' ORDER BY CreatedDate DESC LIMIT 1];

        if (String.valueOf(currentOwner.ownerId).startsWith('00G')) {
            Group selectedQueue = [SELECT Id FROM Group WHERE Id = :currentOwner.ownerId];
            list<Id> userOrGroup = new List<Id>();
            List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :selectedQueue.Id];
            for (GroupMember g : gm) {
                if (String.valueOf(g.UserOrGroupId).startswith('005')) {
                    userOrGroup.add(g.UserOrGroupId);
                }
            }
            Boolean containUser = userOrGroup.contains(userId);
            if (currentPost.OwnerId == userId) {
                throw new OtherException('You are already owner.');
            } else if (!agentWork.isEmpty()) {
                throw new OtherException('You can\'t accept this case');
            } else if (containUser) {
                currentPost.OwnerId = userId;
                Datetime currTime = System.now();
                currentPost.Accept_Datetime__c = currTime;
                currentPost.Assign_Datetime__c = currTime;
                update currentPost;
                createCase(currentPost);
            } else {
                throw new OtherException('You don\'t have authorization to accept case.');
            }
        } else if (String.valueOf(currentOwner.ownerId).startsWith('005')) {
            if (currentPost.OwnerId == userId) {
                throw new OtherException('You are already owner.');
            } else {
                throw new OtherException('You don\'t have authorization to accept case.');
            }
        }
    }

    public static void createCase(Social_Post__c currentPost) {
        Case newCase = null;
        String topicName = currentPost.Topic_Profile_Name__c;
        Skill_Master__c currentSkillMaster = [
            SELECT
                Id,
                Topic__c,
                Source__c,
                Segment__c,
                Assign_to_Queue__c,
                Service_Level1__c,
                Service_Level2__c,
                Service_Level3__c,
                Problem_Type__c,
                Social_Network__c,
                Topic_Profile_Name__c
            FROM Skill_Master__c
            WHERE Assign_to_Queue__c LIKE 'Post%' AND Topic_Profile_Name__c =: topicName
        ];

        // Create new Case
        newCase = new Case();
        newCase.Status = 'New';
        newCase.Contact_Person_Name__c = currentPost.Social_Post_Author__r.Post_Author_Name__c;
        newCase.Subject = currentSkillMaster.Topic__c;
        newCase.PTA_Segment__c = currentSkillMaster.Segment__c;
        newCase.Category__c = currentSkillMaster.Service_Level1__c;
        newCase.Sub_Category__c = currentSkillMaster.Service_Level2__c;
        newCase.Origin = currentSkillMaster.Social_Network__c;
        
        insert newCase;

        currentPost.Case__c = newCase.Id;
        update currentPost;
    }
}