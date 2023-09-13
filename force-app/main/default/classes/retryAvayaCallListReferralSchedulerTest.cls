@isTest
public class retryAvayaCallListReferralSchedulerTest {

    static{

    }

    @isTest
    public static void testSetupScheduler(){
        System.schedule('Retry_AvayaCallList_Test', '0 0 * * * ?', new retryAvayaCallListReferralScheduler());
    }
}