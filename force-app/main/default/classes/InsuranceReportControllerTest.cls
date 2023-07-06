@Istest
public class InsuranceReportControllerTest {
	@isTest
    static void test(){
        InsuranceReportController.getAnniversaryInsurance(5);
        InsuranceReportController.getMatureInsurance(5);
        InsuranceReportController.getPaidUpInsurance(5);
    }
}