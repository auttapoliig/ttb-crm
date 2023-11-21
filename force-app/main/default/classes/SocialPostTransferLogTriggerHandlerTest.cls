@isTest
public with sharing class SocialPostTransferLogTriggerHandlerTest {
    public static final Id System_Administrator = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

    @TestSetup
    static void makeData(){
        //Group queue = new Group(Name = 'test queue', DeveloperName = 'test_queue', type = 'Queue');
        Group queue = new Group(Name='Post - TTB Advisory', Type='Queue');
        insert queue;
        QueueSobject supportObj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Social_Post__c');
        insert supportObj;

        User newUser1 = new User(
            FirstName = 'FName1',
            LastName = 'LName1',
            UserName = 'test1@tmb.com',
            Email = 'test1@tmbbank.com',
            Alias = 'Testtmb',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            CommunityNickname = 'TMBTesttmb1',
            ProfileId = System_Administrator,
            TimeZoneSidKey = 'America/New_York',
            isActive = true,
            Employee_ID__c = 'MM012'
        );
        insert newUser1;
    }

    @isTest
    public static void SocialPostTransferLogTriggerHandlerTestSuccess() {
        Skill_Master__c skillMaster = SocialPostTriggerHandler_Test.createSkillMaster();
        insert skillMaster;
        
        Social_Post_Author__c socialPostAuthor = SocialPostTriggerHandler_Test.createSocialPostAuthor();
        upsert socialPostAuthor;
        
        Social_Post__c post = SocialPostTriggerHandler_Test.createSocialPost(socialPostAuthor.id);
        insert post;

        User newUser1 = [SELECT Id FROM User WHERE Firstname = 'FName1' LIMIT 1];

        Group queue = [SELECT Id FROM Group WHERE Type = 'queue' LIMIT 1];
        GroupMember g1 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser1.Id);
        
        Set<Id> postId = new Set<Id>();
        postId.add(post.Id);
        
        try {
            ServiceChannel sc = [SELECT Id, relatedEntity FROM ServiceChannel WHERE relatedEntity = :'Social_Post__c'];
            System.debug('ServiceChannel -->' + sc);
            for (ServiceChannel scIn : [select Id from ServiceChannel]){
                System.debug('ServiceChannel loop  -->' + scIn);
            }
            
            AgentWork awork = new AgentWork();
            awork.WorkItemId = post.Id;
            awork.UserId = UserInfo.getUserId();
            awork.ServiceChannelId = sc.Id;
            User admin = [select id from User where id = :UserInfo.getUserId()];
            try {
                System.runAs(admin) {
                    insert awork;
                }
            } catch (Exception e) {
                System.debug('Error Message :: ' + e.getMessage());
            }
            // insert awork;
            Group g = [SELECT Id FROM Group WHERE Name = 'Post - TTB Drive' AND Type = 'Queue' LIMIT 1];
            Test.startTest();
            post.OwnerId = g.Id;
            update post;
            Set<Id> psrId = new Set<Id>();
            psrId.add(post.Id);
            // update awork;
            List<PendingServiceRouting> psr = [SELECT Id, CreatedBy.Name, CreatedById FROM PendingServiceRouting];
            List<AgentWork> agentw = [SELECT Id, AcceptDateTime, OwnerId, PendingServiceRoutingId, WorkItemId, RequestDateTime FROM AgentWork];
            SocialPostTransferLogTriggerHandler.SocialPostTransferLogTriggerHandlerBeforeUpdate(postId, psrId, agentw);
            try{
                PendingServiceRoutingTriggerHandler.afterUpdateForSocialPost(psr, postId);    
            } catch(Exception e) {
                System.debug('Error Message2 :: ' + e.getMessage());
            }
            
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error Message3 :: ' + e.getMessage());
        }
    }
}