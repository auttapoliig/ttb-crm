public without sharing class SocialPostTriggerHandler {
    private static final Integer sla {
        get {
            // 120000 ms
            if(sla == null){
                List<SLA_Config__mdt> postSLA = [SELECT Time_Sec__c FROM SLA_Config__mdt WHERE DeveloperName = 'Post'];

                return postSLA != null && postSLA.size() > 0 ? Integer.valueOf(postSLA.get(0).Time_Sec__c) : 0;
            }
            return sla;
        }
        set;
    }

    public static Map<String,PostChannel2Queue__mdt> channelQueueMap {
        get{
            Map<String,PostChannel2Queue__mdt> channelQueueMap = new Map<String,PostChannel2Queue__mdt>();        
                for(PostChannel2Queue__mdt postChannel2Queue : [select id, Topic_Profile_Name__c, Warroom_Channel__c, Social_ID__c  from PostChannel2Queue__mdt] ){
                    channelQueueMap.put(postChannel2Queue.Warroom_Channel__c ,postChannel2Queue);
                }           
            return new Map<String,PostChannel2Queue__mdt>(channelQueueMap);
        }set;
    }

    public static void beforeInsert(List<Social_Post__c> newSocialPostList) {
        /* Find Queue name list */
        List<String> queueNameList = new List<String>();
        Map<String, Id> queueMap = new Map<String, Id>();
        Map<String, Social_Post__c> chkDupMap = new Map<String, Social_Post__c>();

        // Prepare Skill master map
        Map<String, Skill_Master__c> skillMasterMap = new Map<String, Skill_Master__c>();
        for (Skill_Master__c skillMaster : [SELECT id, Topic__c, Source__c, Segment__c, Assign_to_Queue__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Problem_Type__c, Social_Network__c, Topic_Profile_Name__c 
                                                FROM Skill_Master__c 
                                                WHERE Assign_to_Queue__c like 'Post%']) {

            skillMasterMap.put(skillMaster.Topic_Profile_Name__c, skillMaster);
            queueNameList.add(skillMaster.Assign_to_Queue__c);
        }

        // Prepare Queue map
        for (Group queue : [SELECT Id, Name, Type FROM Group WHERE Type='Queue' AND Name in :queueNameList]) {
            queueMap.put(queue.Name, queue.Id);
        }

        for (Social_Post__c socialPost : newSocialPostList) {
            System.debug('socialPost.Message_Type__c -->' + socialPost.Message_Type__c);
            if ( !'Outbound'.equals(socialPost.Message_Type__c) ) {
                /* Assign SLA */
                System.debug('sla -->' + sla);
                socialPost.SLA__c = sla;

                /* Assign to queue */
                PostChannel2Queue__mdt channelQueue = channelQueueMap.get(socialPost.Subject_Name__c);
                System.debug('channelQueue -->' + channelQueue);
                System.debug('Post_Body__c -->' + socialPost.Post_Body__c);
    
                if (queueMap != null) {
                    try {
                        Skill_Master__c skillMaster = skillMasterMap.get(channelQueue.Topic_Profile_Name__c);
                        System.debug('skillMaster -->' + skillMaster);
                        ID channelQueueId = queueMap.get(skillMaster.Assign_to_Queue__c);
                        System.debug('channelQueueId -->' + channelQueueId);
                        socialPost.OwnerId = channelQueueId;
                    } catch (Exception e) {
                        e.setMessage('Invalid subject name :: ' + socialPost.Subject_Name__c);
                        throw e;
                    }
                }

                if (channelQueue != null) {
                    socialPost.Topic_Profile_Name__c = channelQueue.Topic_Profile_Name__c;
                    socialPost.Default_Social_Account__c = channelQueue.Social_ID__c;
                }

                chkDupMap.put(socialPost.Post_Identity_ID__c, socialPost);
            }
        }

        List<Social_Post__c> updateSocialPostList = new List<Social_Post__c>();
        Set<String> socialPostToRemove = new Set<String>();
        for (Social_Post__c existingSocialPost : [SELECT id, Thread_ID__c, Post_ID__c, Post_Identity_ID__c from social_post__c where Post_Identity_ID__c in :chkDupMap.keySet()]) {
            Social_Post__c mapSocialPost = chkDupMap.get(existingSocialPost.Post_Identity_ID__c);
            if (mapSocialPost != null) {
                System.debug('existingSocialPost ID -->' + mapSocialPost.id);
                System.debug('mapSocialPost.Post_ID__c -->' + mapSocialPost.Post_ID__c);
                existingSocialPost.Post_ID__c = mapSocialPost.Post_ID__c;
    
    
                socialPostToRemove.add(existingSocialPost.Post_Identity_ID__c);
                updateSocialPostList.add(existingSocialPost);
            }
        }

        update updateSocialPostList;

        for (Social_Post__c socialPost : newSocialPostList) {
            if (socialPostToRemove.contains(socialPost.Post_Identity_ID__c)) {
                System.debug('Duplicate record -->' + socialPost.Post_Identity_ID__c);
                socialPost.addError('Duplicate record');
            }
        }

        System.debug('End beforeInsert');
    }

    public static void afterUpdate(List<Social_Post__c> newSocialPostList, Map<Id,Social_Post__c> oldMap) {
        
        /* Create negative post record */
        List<Social_Post__c> negativeList = new List<Social_Post__c>();
        for (Social_Post__c socialPost : newSocialPostList) {
            System.debug('Update social post Id -->' + socialPost.id);
            Social_Post__c oldSocialPost = oldMap.get(socialPost.id);
            if (socialPost.Intention__c == 'Defame' && oldSocialPost.Intention__c != 'Defame') {
                negativeList.add(socialPost);
            }
        }
        if (!negativeList.isEmpty()) {
            SocialPostTriggerHandler.negativePost(negativeList);
        }

    }

    private static void negativePost(List<Social_Post__c> newSocialPostList) {
       
        List<Social_Post_Negative__c> negativePostList = new List<Social_Post_Negative__c>();
        Map<String, Social_Persona_Negative__c> personaNegativeMap = new Map<String, Social_Persona_Negative__c>();

        Social_Post_Negative__c negativePost = null;
        Social_Persona_Negative__c personaNegative = null;
        List<String> personaIds = new List<String>(); 

        for (Social_Post__c socialPost : newSocialPostList) {
            personaIds.add(socialPost.Social_Post_Author__c);
        }
 
        for (Social_Post_Author__c socialPersona : [SELECT id, Name, Post_Author_Name__c from Social_Post_Author__c where id in :personaIds ]) {
            personaNegative = new Social_Persona_Negative__c();
            personaNegative.Real_Name__c = socialPersona.Post_Author_Name__c;
            personaNegative.Social_Persona_ID__c = socialPersona.id;
            personaNegative.name = socialPersona.name;
            personaNegativeMap.put(socialPersona.id, personaNegative);
        }

        upsert personaNegativeMap.values() Social_Persona_ID__c;
         
        for (Social_Post__c socialPost : newSocialPostList) {
                  
            negativePost = new Social_Post_Negative__c();
            negativePost.Social_Persona_Negative__c = personaNegativeMap.get(socialPost.Social_Post_Author__c).id;
            negativePost.Posted_Date__c = socialPost.Post_Date__c;
            negativePost.Sentiment__c = socialPost.Sentiment__c;
            negativePost.Post_Channel__c = socialPost.Source_Channel__c;
            negativePost.Intention__c = socialPost.Intention__c;
            negativePost.Message__c = socialPost.Post_Body__c;
            negativePost.Social_Post_ID__c = socialPost.Id;
            System.debug('    negativePost --> ' + negativePost);
            
            negativePostList.add(negativePost);
        }

        insert negativePostList;
        
    }

    private class InvalidSubjectException extends Exception{}
}