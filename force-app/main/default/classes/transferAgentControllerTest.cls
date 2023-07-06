@istest
public class transferAgentControllerTest {
    public static final Id System_Administrator = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    static {
        Group queue = new Group(Name = 'Post - TTB Advisory', DeveloperName = 'test_queue', type = 'Queue');
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

        System.runAs(newUser1) {
            AppConfig__c runtrigger = new AppConfig__c();
            runtrigger.Name = 'runtrigger';
            runtrigger.Value__c = 'false';
            insert runtrigger;
            
            AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
            insert ac;

            Skill_Master__c skillMaster = SocialPostTriggerHandler_Test.createSkillMaster();
            insert skillMaster;

            Social_Post_Author__c socialPostAuthor = SocialPostTriggerHandler_Test.createSocialPostAuthor();

            upsert socialPostAuthor;

            Social_Post__c socialPost = SocialPostTriggerHandler_Test.createSocialPost(socialPostAuthor.id);

            insert socialPost;
            
            List<PostChannel2Queue__mdt> postChannel2QueueList = [select id, Topic_Profile_Name__c, Warroom_Channel__c, Social_ID__c from PostChannel2Queue__mdt  where Topic_Profile_Name__c = 'ttb advisory'];
            String subjectName = postChannel2QueueList[0].Warroom_Channel__c;
            
            Social_Post__c socialPost2 = new Social_Post__c();
            socialPost2.Source_Channel__c='Twitter';
            socialPost2.Post_Author_Type__c='Customer';
            socialPost2.Conversation_Id_List__c='[\"3050282502\", \"3050283061\", \"3050283101\"]';
            socialPost2.External_Link__c='https://www.facebook.com/542164707373338';
            socialPost2.Internal_Link__c='https://warroom.wisesight.com/thread/47525025/3050283061';
            socialPost2.Post_ID__c='3050282x';
            socialPost2.Post_Title__c='';
            socialPost2.Post_Body__c='สวัสดีตอนยามเย็น ttb advisory (Page)';
            socialPost2.Post_Type__c='Post';
            socialPost2.Post_Date__c=Datetime.now();
            socialPost2.Post_Identity_ID__c='4450005976268xx_5421647073733x';
            socialPost2.Sentiment__c='positive';
            socialPost2.Comment_No__c='1.00000';
            socialPost2.Subject_ID__c='118xx';
            socialPost2.Subject_Name__c=subjectName;
            socialPost2.Thread_ID__c='47525026x';
            socialPost2.Post_Tags__c='[\"Chatbot\", \"Success\"]';
            socialPost2.Thread_Identity_ID__c='503815916439094_2233297906824x';
            socialPost2.Thread_Type__c='Twitter';
            socialPost2.Social_Post_Author__c=socialPostAuthor.id;
            socialPost2.OwnerId = newUser1.Id;

            insert socialPost2;
        }
    }

    @IsTest
    static void changeOwnerTest() {
        Id spfb = [SELECT id FROM Social_Post__c WHERE Thread_Type__c = 'Facebook' LIMIT 1].Id;
        Id spot = [SELECT id FROM Social_Post__c WHERE Thread_Type__c = 'Twitter' LIMIT 1].Id;
        // Id queueowner = [SELECT id, Post_ID__c FROM Social_Post__c WHERE Post_ID__c = '3050282zzz' LIMIT 1].Id;
        User newUser1 = [SELECT Id FROM User WHERE Firstname = 'FName1' LIMIT 1];
        User newUser2 = [SELECT Id FROM User WHERE Firstname = 'FName2' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Post - TTB Advisory' and Type = 'queue' LIMIT 1];

        GroupMember g1 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser1.Id);
        insert g1;
        GroupMember g2 = new GroupMember(GroupId = queue.Id, UserOrGroupId = newUser2.Id);
        insert g2;

        System.runAs(newUser1) {
            try {
                transferAgentController.changeOwner(spfb, queue.Id, 'queue');
            } catch (Exception e) {
                System.assertEquals('Owner cannot be duplicated.', e.getMessage());
            }
        }
        
        System.runAs(newUser2) {
            try {
                transferAgentController.changeOwner(spot, newUser1.Id, 'user');
            } catch (Exception e) {
                
            }
        }

        System.runAs(newUser1) {
            Social_Post__c s = [SELECT id, ownerid FROM Social_Post__c WHERE Thread_Type__c = 'Twitter' LIMIT 1];
			s.OwnerId = newUser1.Id;
        	update s;
            transferAgentController.queueCondition(s.Id);
        }
        
        System.runAs(newUser2) {
            try {
                transferAgentController.queueCondition(spot);
            } catch (Exception e) {
                System.assertEquals('You must be owner of this post.', e.getMessage());
            }
        }
    }
}