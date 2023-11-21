@isTest
public class CXMClearLogBatchTest {
    Static testmethod void CXMClearLogBatch_Test(){

        AsyncRequest__c asyncReq = new AsyncRequest__c();
        asyncReq.IsSuccess__c = false;
        asyncReq.Aborted__c = true;
        insert asyncReq;   

        CalloutRequest__c calloutReq = new CalloutRequest__c();
        calloutReq.RequestId__c = String.valueOf(datetime.now());
        calloutReq.Response_Description__c = 'MuleSoft unexpected error: Timeout exceeded';
        calloutReq.Status__c = 'Failed';
        calloutReq.Sent__c = datetime.now();
        calloutReq.Response_Code__c = '1001';
        calloutReq.CalloutHandlerName__c = 'CXMCalloutHandler';
        calloutReq.AsyncRequest__c =  asyncReq.Id;
        insert calloutReq;  

        Date lastNDay = Date.today().addDays(1) ;
        String errorLogCalloutRequestQuery = 'SELECT Id,CreatedDate  FROM CalloutRequest__c WHERE Status__c =\'Failed\' AND CreatedDate < :lastNDay ';
        database.executebatch(new CXMClearLogBatch(errorLogCalloutRequestQuery, lastNDay), 2000);

        
    }
}