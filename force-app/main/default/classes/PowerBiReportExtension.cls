public without sharing class PowerBiReportExtension {
public String embedURL{get;set;} //URL Power Bi from mdt
public String titleReportName{get;set;}
private String reportId{get;set;}//SF_ID by report frim mdt
private String encryptParam{get;set;}//encrypt TMB_cust_id
public  Power_Bi_Report__mdt powerBiMdt {get;set;}
private final String encodeSingleQuotes ='%27'; 

    public PowerBiReportExtension(ApexPages.StandardController controller) {
        encryptParam  = encodeSingleQuotes+ApexPages.currentpage().getparameters().get('param_1') +encodeSingleQuotes;
        reportId  = ApexPages.currentpage().getparameters().get('ReportId'); 
        powerBiMdt = [select  Id, DeveloperName, ReportId__c, ReportName__c, URL_Report__c from Power_Bi_Report__mdt WHERE Id =:reportId limit 1];
        embedURL = powerBiMdt.URL_Report__c + encryptParam; //set url for iframe 
        titleReportName = powerBiMdt.ReportName__c;
        System.debug('reportId>>>>>>>>>>>>> '+reportId);
        System.debug('encryptParam >>>>>>>>>>>>> '+encryptParam);
        System.debug('embedURL >>>>>>>>>>>>> '+embedURL);
    }

}