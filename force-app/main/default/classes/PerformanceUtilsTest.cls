@isTest
public class PerformanceUtilsTest {
    @isTest
    static void testCheckMyPerformance() {
        Test.startTest();
        PerformanceUtils.checkMyPerformance();
        Test.stopTest();
    }
}