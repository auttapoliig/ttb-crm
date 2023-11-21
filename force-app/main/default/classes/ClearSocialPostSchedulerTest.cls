@isTest
public class ClearSocialPostSchedulerTest {

    @TestSetup
    static void makeData(){
        Group testGroup = new Group(Name='Post - TTB Advisory', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Social_Post__c');
            insert testQueue;
		}
        
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
        socialPost2.status__c = 'Reject';
        socialPost2.Social_Post_Author__c=socialPostAuthor.id;

        insert socialPost2;
    }

    public static testMethod void testClearSocialNegativeSchedule() {

        Test.StartTest();

        ClearSocialNegativeScheduler sh1 = new ClearSocialNegativeScheduler();

        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ClearSocialNegativeScheduler', sch, sh1); 

        Test.stopTest(); 

    }

    public static testMethod void testClearSocialPostRejectedCaseSchedule() {

        Test.StartTest();

        ClearSocialPostRejectedCaseScheduler sh1 = new ClearSocialPostRejectedCaseScheduler();

        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ClearSocialPostRejectedCaseScheduler', sch, sh1); 

        Test.stopTest(); 

    }
/*
    public static testMethod void testClearSocialPostRejectedCaseBatch() {
        Test.startTest();
        ClearSocialPostRejectedCaseBatch snInstance = new ClearSocialPostRejectedCaseBatch();
        ID batchprocessid = Database.executeBatch(snInstance, 2000);
        Test.stopTest();
    }
*/
}