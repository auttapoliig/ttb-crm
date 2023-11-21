@isTest
public with sharing class SocialPostTriggerHandler_Test {

    @isTest static void testSocialPostTrigger() {
        Group testGroup = new Group(Name='Post - TTB Advisory', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Social_Post__c');
            insert testQueue;
		}
        
        Social_Post_Author__c socialPostAuthor = [select id,Post_Author_ID__c from Social_Post_Author__c where Post_Author_ID__c = '12345679'];

        Social_Post__c socialPost = createSocialPost(socialPostAuthor.id);
        insert socialPost;

        socialPost.Intention__c = 'Defame';
        update socialPost;
        
        List<PostChannel2Queue__mdt> postChannel2QueueList = [select id, Topic_Profile_Name__c, Warroom_Channel__c, Social_ID__c from PostChannel2Queue__mdt  where Topic_Profile_Name__c = 'ttb advisory'];
        String subjectName = postChannel2QueueList[0].Warroom_Channel__c;

        Social_Post__c socialPost2 = new Social_Post__c();
        socialPost2.Source_Channel__c='Facebook';
        socialPost2.Post_Author_Type__c='Customer';
        socialPost2.Conversation_Id_List__c='[\"3050282502\", \"3050283061\", \"3050283101\"]';
        socialPost2.External_Link__c='https://www.facebook.com/542164707373338';
        socialPost2.Internal_Link__c='https://warroom.wisesight.com/thread/47525025/3050283061';
        socialPost2.Post_ID__c='3050282zzz';
        socialPost2.Post_Title__c='';
        socialPost2.Post_Body__c='สวัสดีตอนยามเย็น ttb advisory (Page)';
        socialPost2.Post_Type__c='Post';
        socialPost2.Post_Date__c=Datetime.now();
        socialPost2.Post_Identity_ID__c='4450005976268xx_5421647073733zz';
        socialPost2.Sentiment__c='positive';
        socialPost2.Comment_No__c='1.00000';
        socialPost2.Subject_ID__c='118xx';
        socialPost2.Subject_Name__c=subjectName;
        socialPost2.Thread_ID__c='47525026';
        socialPost2.Post_Tags__c='[\"Chatbot\", \"Success\"]';
        socialPost2.Thread_Identity_ID__c='503815916439094_2233297906824zzz';
        socialPost2.Thread_Type__c='Facebook';
        socialPost2.Social_Post_Author__c=socialPostAuthor.id;

        insert socialPost2;
    }

    public static Social_Post_Author__c createSocialPostAuthor() {
        Social_Post_Author__c socialPostAuthor = new Social_Post_Author__c();
        socialPostAuthor.Post_Author_ID__c = '12345679';
        socialPostAuthor.Post_Author_Social_ID__c = '65432109876543xx';
        socialPostAuthor.Post_Author_Name__c = 'abcdef';

        return socialPostAuthor;
    }

    public static Social_Post__c createSocialPost(Id socialPostAuthorId) {
        List<PostChannel2Queue__mdt> postChannel2QueueList = [select id, Topic_Profile_Name__c, Warroom_Channel__c, Social_ID__c from PostChannel2Queue__mdt where Topic_Profile_Name__c = 'ttb advisory'];
        String subjectName = postChannel2QueueList[0].Warroom_Channel__c;
        
        Social_Post__c socialPost = new Social_Post__c();
        socialPost.Source_Channel__c='Facebook';
        socialPost.Post_Author_Type__c='Customer';
        socialPost.Conversation_Id_List__c='[\"3050282502\", \"3050283061\", \"3050283101\"]';
        socialPost.External_Link__c='https://www.facebook.com/542164707373338';
        socialPost.Internal_Link__c='https://warroom.wisesight.com/thread/47525025/3050283061';
        socialPost.Post_ID__c='3050282xxx';
        socialPost.Post_Title__c='';
        socialPost.Post_Body__c='สวัสดีตอนยามเย็น ttb advisory (Page)';
        socialPost.Post_Type__c='Post';
        socialPost.Post_Date__c=Datetime.now();
        socialPost.Post_Identity_ID__c='4450005976268xx_5421647073733yy';
        socialPost.Sentiment__c='positive';
        socialPost.Comment_No__c='1.00000';
        socialPost.Subject_ID__c='118xx';
        socialPost.Subject_Name__c=subjectName;
        socialPost.Thread_ID__c='47525025';
        socialPost.Post_Tags__c='[\"Chatbot\", \"Success\"]';
        socialPost.Thread_Identity_ID__c='503815916439094_2233297906824211';
        socialPost.Thread_Type__c='Facebook';
        socialPost.Social_Post_Author__c=socialPostAuthorId;

        return socialPost;
    }

    
    public static Skill_Master__c createSkillMaster() {
        Skill_Master__c skillMaster = new Skill_Master__c();
        skillMaster.Topic__c='สอบถามเรื่องทั่วไปและข้อเสนอแนะ';
        skillMaster.Source__c='Social Media - TTB Advisory';
        skillMaster.Segment__c='RBG';
        skillMaster.Assign_to_Queue__c='Post - TTB Advisory';
        skillMaster.Service_Level1__c='Inquiry';
        skillMaster.Service_Level2__c='Contact Center';
        skillMaster.Service_Level3__c='';
        skillMaster.Problem_Type__c='';
        skillMaster.Social_Network__c='Facebook';
        skillMaster.Topic_Profile_Name__c ='ttb advisory';
        skillMaster.Validate_Code__c ='X0027';

        return skillMaster;
    }
    
    @testSetup static void setup() {
        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;
        
        Skill_Master__c skillMaster = new Skill_Master__c();
        skillMaster.Topic__c='สอบถามเรื่องทั่วไปและข้อเสนอแนะ';
        skillMaster.Source__c='Social Media - TTB Advisory';
        skillMaster.Segment__c='RBG';
        skillMaster.Assign_to_Queue__c='Post - TTB Advisory';
        skillMaster.Service_Level1__c='Inquiry';
        skillMaster.Service_Level2__c='Contact Center';
        skillMaster.Service_Level3__c='';
        skillMaster.Problem_Type__c='';
        skillMaster.Social_Network__c='Facebook';
        skillMaster.Topic_Profile_Name__c ='ttb advisory';
        skillMaster.Validate_Code__c ='X0027';
        insert skillMaster;   
        
        Social_Post_Author__c socialPostAuthor = new Social_Post_Author__c();
        socialPostAuthor.Post_Author_ID__c = '12345679';
        socialPostAuthor.Post_Author_Social_ID__c = '65432109876543xx';
        socialPostAuthor.Post_Author_Name__c = 'abcdef';
         insert socialPostAuthor;
    }
}