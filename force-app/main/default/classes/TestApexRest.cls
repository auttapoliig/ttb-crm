@RestResource(urlMapping='/TestApexRest/*')
global with sharing class TestApexRest {
	@HttpPost
    global static String doPost() {
        return 'Success';
    }
}