@isTest
global class MockHttpResponseCampaignMemberExtension implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        //test only this endpoint and method
        System.assertEquals('https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}