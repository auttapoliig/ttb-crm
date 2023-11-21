@isTest
public class ManualRunActualAmountController_Test {

    Static testmethod void TestExecuteActualAmountBatch(){
        Test.startTest();
            // ManualRunActualAmountController manualRun = new ManualRunActualAmountController();
            ManualRunActualAmountController.executeActualAmountBatch(String.valueOf(Date.Today().year()),String.valueOf(Date.today().month()).leftPad(2, '0'));
        Test.stopTest();
    }
}