@istest
public with sharing class acceptPostControllerTest {
    
    //public static final Id System_Administrator = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    @TestSetup
    static void makeData(){
        Id System_Administrator = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
 
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            List<Group> g = [SELECT Id FROM Group WHERE DeveloperName = 'test_queue' AND Type = 'Queue' LIMIT 1];
            if (g.isEmpty()) {
                Group q = new Group(Name = 'Post - TTB Advisory', DeveloperName = 'test_queue', type = 'Queue');
                insert q;
                g.add(q);
        	}
        QueueSobject supportObj = new QueueSobject(QueueId = g.get(0).Id, SobjectType = 'Social_Post__c');
        insert supportObj;
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
        }
        
        //create User
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
        
        User newUser2 = new User(
            FirstName = 'FName2',
            LastName = 'LName2',
            UserName = 'test2@tmb.com',
            Email = 'test2@tmbbank.com',
            Alias = 'Testtmb',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            CommunityNickname = 'TMBTesttmb2',
            ProfileId = System_Administrator,
            TimeZoneSidKey = 'America/New_York',
            isActive = true,
            Employee_ID__c = 'MM013'
        );
        insert newUser2;

        System.runAs(newUser2) {
            AppConfig__c runtrigger = new AppConfig__c();
            runtrigger.Name = 'runtrigger';
            runtrigger.Value__c = 'false';
            insert runtrigger;
            AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
            insert ac;
        }

        //create Social_Post__c
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
            Group queue = [SELECT Id FROM Group WHERE Name = 'Post - TTB Advisory' and Type = 'queue' LIMIT 1];
            GroupMember g1 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser1.Id);
            insert g1;
            GroupMember g2 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser2.Id);
            insert g2;
        }
        
        
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
        socialPost2.Social_Post_Author__c=socialPostAuthor.id;

        insert socialPost2;

    }

    @IsTest
    static void acceptPostTest() {
        /*
        Id sp = [SELECT id FROM Social_Post__c WHERE Thread_Type__c = 'Facebook' LIMIT 1].Id;
        User newUser1 = [SELECT Id FROM User WHERE Firstname = 'FName1' LIMIT 1];
        User newUser2 = [SELECT Id FROM User WHERE Firstname = 'FName2' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Post - TTB Advisory' and Type = 'queue' LIMIT 1];

        GroupMember g1 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser1.Id);
        insert g1;
        GroupMember g2 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser2.Id);
        insert g2;
*/
        // Id queueowner = [SELECT id FROM Social_Post__c WHERE Name = 'Test queue' LIMIT 1].Id;
        
        // test transfer to queue
        Group queue = [SELECT Id FROM Group WHERE Name = 'Post - TTB Advisory' and Type = 'queue' LIMIT 1];
        Id queueowner = queue.Id;
        User newUser1 = [select id from User where FirstName = 'FName1'];
        User newUser2 = [SELECT Id FROM User WHERE Firstname = 'FName2' LIMIT 1];
        Social_Post__c sp = [select Id from Social_Post__c where Post_ID__c='3050282zzz'];
       	// test transfer to queue
        System.runAs(newUser1) {
            try {
                Social_Post__c s = [select Id from Social_Post__c where Post_ID__c='3050282zzz'];
                s.OwnerId = newUser1.Id;
                update s;
                acceptPostButtonController.acceptPost(s.Id, newUser1.Id);
            } catch (Exception e) {
                System.assertEquals('You are already owner.', e.getMessage());
            }
        }

        System.runAs(newUser2) {
            try {
                acceptPostButtonController.acceptPost(sp.Id, newUser2.Id);
            } catch (Exception e) {
                System.assertEquals('You don\'t have authorization to accept case.', e.getMessage());
            }
        }
    }
}