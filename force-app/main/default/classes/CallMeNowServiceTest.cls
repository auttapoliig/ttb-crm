@isTest
private class CallMeNowServiceTest {
	private class CMNAvayaResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"api_token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"9f4082e43710ee3e981c989283a3a837","encrypted_data":"2f96f536740c1fefec528b0254d30e6c0f6fb333d91ad0c09a54eeef6d239178e2d3b65938174a826fe95432a2243391d4b34fb852a04e9433c06c80d6a0f7a6517278fe45407717ed9fcec8a69c522fdc1fe12e97764d528be16320f2a33a24777dc7b1344cf800668d9b424f046c13"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

	private class CMNAvayaResponseAvayaTokenFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"error": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"9f4082e43710ee3e981c989283a3a837","encrypted_data":"2f96f536740c1fefec528b0254d30e6c0f6fb333d91ad0c09a54eeef6d239178e2d3b65938174a826fe95432a2243391d4b34fb852a04e9433c06c80d6a0f7a6517278fe45407717ed9fcec8a69c522fdc1fe12e97764d528be16320f2a33a24777dc7b1344cf800668d9b424f046c13"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

	private class CMNAvayaResponseAvayaFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"api_token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"05c2f15b7ca4551a648f341da5227fcd","encrypted_data":"6998bc9529f679dd21f3456a85714e7b965bbf798d436d736e5398648d3618e6b7b8b291ab8eaab31bcbad7dfb50918f9e6a3aeb89f89abaa5e5ff3fd03dd2b3c963b3d2ff37c37180d60bba855d452568fcbe4d8b48ecd87bdfbedbe2b000d0d13a2a7cbeb61aa7e5b7cf3009b2f64642843f321faf4bd52275bfab2e7aee28"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

	private class CMNAvayaResponseAvayaDecryptionFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Telephony_Avaya_Droplead_getToken')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"api_token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjMmN1c2VyIiwiYXV0aCI6IkMyQ19VU0VSIiwiZXhwIjoxNjAwODU5MzM5fQ.xLuzHJFfp0xkIJdCTyu9WsktBMLM4Lu91JV9F1cbpFt0S0FYn8wZGn0pBq-i8YrjXGvpPhhtzNNo8OzyDqpCPg"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:get_avaya_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:WsCallMeNow_Avaya')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"initial_vector":"05c2f5b7ca4551a648f341da5227fcd","encrypted_data":"6998bc9529f679dd21f3456a85714e7b965bbf798d436d736e5398648d3618e6b7b8b291ab8eaab31bcbad7dfb50918f9e6a3aeb89f89abaa5e5ff3fd03dd2b3c963b3d2ff37c37180d60bba855d452568fcbe4d8b48ecd87bdfbedbe2b000d0d13a2a7cbeb61aa7e5b7cf3009b2f64642843f321faf4bd52275bfab2e7aee28"}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
	
	@isTest static void CallMeNowServiceTest() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":"1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.basicAuthCallout(dto,'testreferral');
		Test.stopTest();
	}

	@isTest static void CallMeNowServiceFailTest() {
		//set response in wrong format
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{code":"1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.basicAuthCallout(dto,'testreferral');
		Test.stopTest();
	}

	@isTest static void CallMeNowLeadServiceTest() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":"1","message":"success"}'));

		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.callOutCMNLead(dto,'Cisco');
		Test.stopTest();
	}

	@isTest static void CallMeNowServiceTestFail() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.callOutCMNLead(dto,'Cisco');
		Test.stopTest();
	}

	@isTest 
	static void CallMeNowAvayaServiceSuccess() {
		AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
		callMeNowObj.request.setRequestId('001xUQN');
		callMeNowObj.request.setFirstName('cm.lead.FirstName');
		callMeNowObj.request.setLastName('cm.lead.LastName');
		callMeNowObj.request.setProductName('cm.lead.RTL_Product_Name__c');
		callMeNowObj.request.setSub_ProductName('');
		callMeNowObj.request.setMobile('cm.lead.RTL_Mobile_Number__c');
		callMeNowObj.request.setCampaign('cm.lead.RTL_Lead_Campaign_Outbound__c');
		callMeNowObj.request.setDial_time('strDateTime');
		callMeNowObj.request.setChannel_name('cm.lead.RTL_Lead_Channel_Outbound__c');
		callMeNowObj.request.setSf_id('cm.Id');

		callMeNowObj.request.setBusiness1('cm.lead.web_business01__c');
		callMeNowObj.request.setBusiness2('cm.lead.web_business02__c');
		callMeNowObj.request.setBusiness3('cm.lead.web_business03__c');
		callMeNowObj.request.setBusiness4('cm.lead.web_business04__c');
		callMeNowObj.request.setBusiness5('cm.lead.web_business05__c');
		callMeNowObj.request.setBusiness6('cm.lead.web_business06__c');
		callMeNowObj.request.setBusiness7('cm.lead.web_business07__c');
		callMeNowObj.request.setBusiness8('cm.lead.web_business08__c');
		callMeNowObj.request.setBusiness9('cm.lead.web_business09__c');
		callMeNowObj.request.setBusiness10('cm.lead.web_business10__c');

		callMeNowObj.request.setRemark('cm.lead.RTL_Remark__c');
		callMeNowObj.request.setURL('CMNURL');
		
		Test.setMock(HttpCalloutMock.class, new CMNAvayaResponse());
		
		Test.startTest();
			CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');
		Test.stopTest();
	}

	@isTest 
	static void CallMeNowAvayaServiceTokenfail() {
		AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
		callMeNowObj.request.setRequestId('001xUQN');
		callMeNowObj.request.setFirstName('cm.lead.FirstName');
		callMeNowObj.request.setLastName('cm.lead.LastName');
		callMeNowObj.request.setProductName('cm.lead.RTL_Product_Name__c');
		callMeNowObj.request.setSub_ProductName('');
		callMeNowObj.request.setMobile('cm.lead.RTL_Mobile_Number__c');
		callMeNowObj.request.setCampaign('cm.lead.RTL_Lead_Campaign_Outbound__c');
		callMeNowObj.request.setDial_time('strDateTime');
		callMeNowObj.request.setChannel_name('cm.lead.RTL_Lead_Channel_Outbound__c');
		callMeNowObj.request.setSf_id('cm.Id');

		callMeNowObj.request.setBusiness1('cm.lead.web_business01__c');
		callMeNowObj.request.setBusiness2('cm.lead.web_business02__c');
		callMeNowObj.request.setBusiness3('cm.lead.web_business03__c');
		callMeNowObj.request.setBusiness4('cm.lead.web_business04__c');
		callMeNowObj.request.setBusiness5('cm.lead.web_business05__c');
		callMeNowObj.request.setBusiness6('cm.lead.web_business06__c');
		callMeNowObj.request.setBusiness7('cm.lead.web_business07__c');
		callMeNowObj.request.setBusiness8('cm.lead.web_business08__c');
		callMeNowObj.request.setBusiness9('cm.lead.web_business09__c');
		callMeNowObj.request.setBusiness10('cm.lead.web_business10__c');

		callMeNowObj.request.setRemark('cm.lead.RTL_Remark__c');
		callMeNowObj.request.setURL('CMNURL');
		
		Test.setMock(HttpCalloutMock.class, new CMNAvayaResponseAvayaTokenFail());

		Test.startTest();
			CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');
		Test.stopTest();
	}

	@isTest 
	static void CallMeNowAvayaServiceError() {
		AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
		callMeNowObj.request.setRequestId('001xUQN');
		callMeNowObj.request.setFirstName('cm.lead.FirstName');
		callMeNowObj.request.setLastName('cm.lead.LastName');
		callMeNowObj.request.setProductName('cm.lead.RTL_Product_Name__c');
		callMeNowObj.request.setSub_ProductName('');
		callMeNowObj.request.setMobile('cm.lead.RTL_Mobile_Number__c');
		callMeNowObj.request.setCampaign('cm.lead.RTL_Lead_Campaign_Outbound__c');
		callMeNowObj.request.setDial_time('strDateTime');
		callMeNowObj.request.setChannel_name('cm.lead.RTL_Lead_Channel_Outbound__c');
		callMeNowObj.request.setSf_id('cm.Id');

		callMeNowObj.request.setBusiness1('cm.lead.web_business01__c');
		callMeNowObj.request.setBusiness2('cm.lead.web_business02__c');
		callMeNowObj.request.setBusiness3('cm.lead.web_business03__c');
		callMeNowObj.request.setBusiness4('cm.lead.web_business04__c');
		callMeNowObj.request.setBusiness5('cm.lead.web_business05__c');
		callMeNowObj.request.setBusiness6('cm.lead.web_business06__c');
		callMeNowObj.request.setBusiness7('cm.lead.web_business07__c');
		callMeNowObj.request.setBusiness8('cm.lead.web_business08__c');
		callMeNowObj.request.setBusiness9('cm.lead.web_business09__c');
		callMeNowObj.request.setBusiness10('cm.lead.web_business10__c');

		callMeNowObj.request.setRemark('cm.lead.RTL_Remark__c');
		callMeNowObj.request.setURL('CMNURL');
		
		Test.setMock(HttpCalloutMock.class, new CMNAvayaResponseAvayaFail());

		Test.startTest();
			CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');
		Test.stopTest();
	}

	@isTest 
	static void CallMeNowAvayaServiceDecryptError() {
		AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
		callMeNowObj.request.setRequestId('001xUQN');
		callMeNowObj.request.setFirstName('cm.lead.FirstName');
		callMeNowObj.request.setLastName('cm.lead.LastName');
		callMeNowObj.request.setProductName('cm.lead.RTL_Product_Name__c');
		callMeNowObj.request.setSub_ProductName('');
		callMeNowObj.request.setMobile('cm.lead.RTL_Mobile_Number__c');
		callMeNowObj.request.setCampaign('cm.lead.RTL_Lead_Campaign_Outbound__c');
		callMeNowObj.request.setDial_time('strDateTime');
		callMeNowObj.request.setChannel_name('cm.lead.RTL_Lead_Channel_Outbound__c');
		callMeNowObj.request.setSf_id('cm.Id');

		callMeNowObj.request.setBusiness1('cm.lead.web_business01__c');
		callMeNowObj.request.setBusiness2('cm.lead.web_business02__c');
		callMeNowObj.request.setBusiness3('cm.lead.web_business03__c');
		callMeNowObj.request.setBusiness4('cm.lead.web_business04__c');
		callMeNowObj.request.setBusiness5('cm.lead.web_business05__c');
		callMeNowObj.request.setBusiness6('cm.lead.web_business06__c');
		callMeNowObj.request.setBusiness7('cm.lead.web_business07__c');
		callMeNowObj.request.setBusiness8('cm.lead.web_business08__c');
		callMeNowObj.request.setBusiness9('cm.lead.web_business09__c');
		callMeNowObj.request.setBusiness10('cm.lead.web_business10__c');

		callMeNowObj.request.setRemark('cm.lead.RTL_Remark__c');
		callMeNowObj.request.setURL('CMNURL');
		
		Test.setMock(HttpCalloutMock.class, new CMNAvayaResponseAvayaDecryptionFail());

		Test.startTest();
			CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');
		Test.stopTest();
	}

	@isTest 
	static void CallMeNowAvayaServiceTokenfail500() {
		AvayaCallistDTO callMeNowObj = new AvayaCallistDTO();
		callMeNowObj.request.setRequestId('001xUQN');
		callMeNowObj.request.setFirstName('cm.lead.FirstName');
		callMeNowObj.request.setLastName('cm.lead.LastName');
		callMeNowObj.request.setProductName('cm.lead.RTL_Product_Name__c');
		callMeNowObj.request.setSub_ProductName('');
		callMeNowObj.request.setMobile('cm.lead.RTL_Mobile_Number__c');
		callMeNowObj.request.setCampaign('cm.lead.RTL_Lead_Campaign_Outbound__c');
		callMeNowObj.request.setDial_time('strDateTime');
		callMeNowObj.request.setChannel_name('cm.lead.RTL_Lead_Channel_Outbound__c');
		callMeNowObj.request.setSf_id('cm.Id');

		callMeNowObj.request.setBusiness1('cm.lead.web_business01__c');
		callMeNowObj.request.setBusiness2('cm.lead.web_business02__c');
		callMeNowObj.request.setBusiness3('cm.lead.web_business03__c');
		callMeNowObj.request.setBusiness4('cm.lead.web_business04__c');
		callMeNowObj.request.setBusiness5('cm.lead.web_business05__c');
		callMeNowObj.request.setBusiness6('cm.lead.web_business06__c');
		callMeNowObj.request.setBusiness7('cm.lead.web_business07__c');
		callMeNowObj.request.setBusiness8('cm.lead.web_business08__c');
		callMeNowObj.request.setBusiness9('cm.lead.web_business09__c');
		callMeNowObj.request.setBusiness10('cm.lead.web_business10__c');

		callMeNowObj.request.setRemark('cm.lead.RTL_Remark__c');
		callMeNowObj.request.setURL('CMNURL');
		
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(500,''));

		Test.startTest();
			CallMeNowService.addToAvayaCallist(callMeNowObj, 'Avaya');
		Test.stopTest();
	}
}