@isTest
public with sharing class WarroomPageControllerTest {
    
	@TestSetup
    static void makeData() {
        Group testGroup = new Group(Name='Post - TTB Advisory', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Social_Post__c');
            insert testQueue;
		}
    }
    
    @isTest static void testSocialPostController() {
        Test.startTest();
        Skill_Master__c skillMaster = SocialPostTriggerHandler_Test.createSkillMaster();
        insert skillMaster;

        Social_Post_Author__c socialPostAuthor = SocialPostTriggerHandler_Test.createSocialPostAuthor();
        
        upsert socialPostAuthor;

        Social_Post__c socialPost = SocialPostTriggerHandler_Test.createSocialPost(socialPostAuthor.id);

        insert socialPost;
        
        
        WarroomPageController.getURLforIframe(socialPost.Id);

        Test.StopTest();
    }
  
}