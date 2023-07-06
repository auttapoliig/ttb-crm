public without sharing class transferAgentController {
    public virtual class BaseException extends Exception {
    }
    public class OtherException extends BaseException {
    }
    @AuraEnabled
    public static String changeOwner(Id recordId, Id ownerId, String type) {
        Social_Post__c selectedPost = [SELECT Id, Name, OwnerId, Owner.Name, LastTransferUser__c, Status__c FROM Social_Post__c WHERE Id = :recordId LIMIT 1];
        if (selectedPost.OwnerId == ownerId) {
            throw new OtherException('Owner cannot be duplicated.');
        } else {
            // Social_Post_Transfer_log__c changelog = new Social_Post_Transfer_log__c();
            //changelog.Social_Post__c = recordId; comment for change SocialPost to Social_Post__c object
            // changelog.Transfer_Datetime__c = Datetime.now();
            // changelog.Transfer_From__c = selectedPost.Owner.Name;
            // if (type == 'user') {
                // changelog.Transfer_To__c = [SELECT Id, Name FROM User WHERE Id = :ownerId LIMIT 1].Name;
            // } else if (type == 'queue') {
                // changelog.Transfer_To__c = [SELECT Id, Name FROM Group WHERE Id = :ownerId LIMIT 1].Name;
            // }
            // insert changelog;
            // selectedPost.OwnerId = ownerId;
            // update selectedPost;
            ServiceChannel chatServiceChannel = [SELECT Id FROM ServiceChannel WHERE relatedEntity = :'Social_Post__c' WITH SECURITY_ENFORCED LIMIT 1];
            if (type == 'user') {
                PendingServiceRouting psr = new PendingServiceRouting();
                psr.workItemId = recordId;
                psr.RoutingType = 'SkillsBased';
                psr.RoutingPriority = 1;
                psr.CapacityWeight = 0;
                // psr.ServiceChannelId = '0N90l0000008P2SCAU';
                psr.ServiceChannelId = chatServiceChannel.Id;
                psr.RoutingModel = 'MostAvailable';
                psr.IsReadyForRouting = true;
                psr.preferredUserId = ownerId;
                psr.CustomRequestedDateTime = System.now();
                psr.PushTimeout = 120;
                insert psr;
            } else {
                selectedPost.OwnerId = ownerId;
            }
            // selectedPost.LastTransferUser__c = UserInfo.getUserId();
            selectedPost.LastTransferUser__c = null;
            selectedPost.Status__c = 'Transfer';
            update selectedPost;
            return selectedPost.Name;
        }
    }
    @AuraEnabled
    public static List<String> queueCondition(Id recordId) {
        // Social_Post__c selectedPost = [SELECT Id, OwnerId, Provider FROM Social_Post__c WHERE Id =: recordId LIMIT 1];
        Social_Post__c selectedPost = [
            SELECT Id, OwnerId, Source_Channel__c
            FROM Social_Post__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        List<String> returnValue = new List<String>();
        id currentuserId = Userinfo.getUserId();
        if (selectedPost.OwnerId == currentuserId) {
            // String socialNetwork = selectedPost.Provider;
            String socialNetwork = selectedPost.Source_Channel__c;
            List<Skill_Master__c> skillList = [
                SELECT Id, Assign_to_Queue__c
                FROM Skill_Master__c
                WHERE Assign_to_Queue__c LIKE 'Post%'
            ];
            for (Skill_Master__c skill : skillList) {
                returnValue.add('\'' + skill.Assign_to_Queue__c + '\'');
            }
            // if (socialNetwork == 'Facebook') {
            //     returnValue.add('\'Post_TTB_Advisory\'');
            //     returnValue.add('\'Post_TTB_Bank\'');
            //     returnValue.add('\'Post_TTB_Drive\'');
            //     returnValue.add('\'Post_KOL\'');
            //     returnValue.add('\'Post_BOT\'');
            // } else if (socialNetwork == 'Other') {
            //     returnValue.add('\'Post_Pantip\'');
            // } else {
            //     returnValue.add('\'Post_Twitter\'');
            // }
        } else {
            throw new OtherException('You must be owner of this post.');
        }
        return returnValue;
    }
}