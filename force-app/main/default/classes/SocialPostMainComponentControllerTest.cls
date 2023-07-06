@isTest
public with sharing class SocialPostMainComponentControllerTest {
    @isTest
    static void SocialPostMainComponentControllerTestSuccess() {
        Test.startTest();
        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';
        
        Group testGroup = new Group(Name='Post - TTB Advisory', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Social_Post__c');
            insert testQueue;
		}

        insert runtrigger;

        Skill_Master__c skillMaster = SocialPostTriggerHandler_Test.createSkillMaster();
        insert skillMaster;

        Social_Post_Author__c socialPostAuthor = SocialPostTriggerHandler_Test.createSocialPostAuthor();
        upsert socialPostAuthor;

        Social_Post__c socialPost = SocialPostTriggerHandler_Test.createSocialPost(socialPostAuthor.id);
        insert socialPost;
        try {
            SocialPostMainComponentController.getAccountList(socialPost.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            SocialPostMainComponentController.getPostInfo(socialPost.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            SocialPostMainComponentController.getThreadIdentity(socialPost.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}