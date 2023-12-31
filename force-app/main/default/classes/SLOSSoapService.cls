//Generated by wsdl2apex

public class SLOSSoapService {
    public class OpportunityResponse {
        public String Status;
        public String Message;
        public String Code;
        public String AppRefNumber;
        private String[] Status_type_info = new String[] {'Status', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Message_type_info = new String[] {'Message', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Code_type_info = new String[] {'Code', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AppRefNumber_type_info = new String[] {'AppRefNumber', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] apex_schema_type_info = new String[] {'http://www.tmbbank.com/slsservices/', 'false', 'false'};
        private String[] field_order_type_info = new String[] {'Status', 'Message', 'Code', 'AppRefNumber'};
    }

    public class CreateOpportunityResponse_element {
        public SLOSSoapService.OpportunityResponse Result;
        private String[] Result_type_info = new String[] {'Result', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] apex_schema_type_info = new String[] {'http://www.tmbbank.com/slsservices/', 'false', 'false'};
        private String[] field_order_type_info = new String[] {'Result'};
    }
    
    public class FacilityInfos_element {
        public SLOSSoapService.FacilityInfoRequest[] FacilityInfo;
        private String[] FacilityInfo_type_info = new String[]{'FacilityInfo','http://www.tmbbank.com/slsservices/',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.tmbbank.com/slsservices/','false','false'};
        private String[] field_order_type_info = new String[]{'FacilityInfo'};
    }

    //Wrapper Class
    public class CreateOpportunityRequest {
        public String JobName {get; set;}
        public String CaNumber {get; set;}
        public String OldCaNumber {get; set;}
        public String AccountNo1 {get; set;}
        public String CustomerId {get; set;}
        public String CustomerName {get; set;}
        public String CitizenId {get; set;}
        public Integer RequestType {get; set;}
        public Integer CustomerType {get; set;}
        public String BdmId {get; set;}
        public String HubCode {get; set;}
        public String RegionCode {get; set;}
        public String UwId {get; set;}
        public String AppInDateBDM {get; set;}
        public String FinalApproved_x {get; set;}
        public String Parallel_x {get; set;}
        public String Pending {get; set;}
        public String CaExist {get; set;}
        public String CaEnd {get; set;}
        public String AccountNo2 {get; set;}
        public String AccountNo3 {get; set;}
        public String AccountNo4 {get; set;}
        public String AccountNo5 {get; set;}
        public String AccountNo6 {get; set;}
        public String AccountNo7 {get; set;}
        public String AccountNo8 {get; set;}
        public String AccountNo9 {get; set;}
        public String AccountNo10 {get; set;}
        public String AppInDateUW {get; set;}
        public String RefAppNumber {get; set;}
        public String Reason {get; set;}
        public String CheckNCB {get; set;}
        public String Ssoid {get; set;}
        public String MobileNo {get; set;}
        public String Province {get; set;}
        public String District {get; set;}
        public String SubDistrict {get; set;}
        public String ZipCode {get; set;}
        public String Country {get; set;}
        public Decimal SaleAmount {get; set;}
        public Integer YearInBusiness {get; set;}
        public Integer ProductGroupId {get; set;}
        public FacilityInfos_element FacilityInfos {get; set;}
    }

    public class CreateOpportunityRequest_element {
        // Custom code
        public CreateOpportunityRequest_element(SLOSSoapService.CreateOpportunityRequest createOpportunityRequest) {
            JobName       =   createOpportunityRequest.JobName          ;
            CaNumber      =   createOpportunityRequest.CaNumber         ;
            OldCaNumber   =   createOpportunityRequest.OldCaNumber      ;
            AccountNo1    =   createOpportunityRequest.AccountNo1       ;
            CustomerId    =   createOpportunityRequest.CustomerId       ;
            CustomerName  =   createOpportunityRequest.CustomerName     ;
            CitizenId     =   createOpportunityRequest.CitizenId        ;
            RequestType   =   createOpportunityRequest.RequestType      ;
            CustomerType  =   createOpportunityRequest.CustomerType     ;
            BdmId         =   createOpportunityRequest.BdmId            ;
            HubCode       =   createOpportunityRequest.HubCode          ;
            RegionCode    =   createOpportunityRequest.RegionCode       ;
            UwId          =   createOpportunityRequest.UwId             ;
            AppInDateBDM  =   createOpportunityRequest.AppInDateBDM     ;
            FinalApproved =   createOpportunityRequest.FinalApproved_x  ;
            Parallel_x    =   createOpportunityRequest.Parallel_x       ;
            Pending       =   createOpportunityRequest.Pending          ;
            CaExist       =   createOpportunityRequest.CaExist          ;
            CaEnd         =   createOpportunityRequest.CaEnd            ;
            AccountNo2    =   createOpportunityRequest.AccountNo2       ;
            AccountNo3    =   createOpportunityRequest.AccountNo3       ;
            AccountNo4    =   createOpportunityRequest.AccountNo4       ;
            AccountNo5    =   createOpportunityRequest.AccountNo5       ;
            AccountNo6    =   createOpportunityRequest.AccountNo6       ;
            AccountNo7    =   createOpportunityRequest.AccountNo7       ;
            AccountNo8    =   createOpportunityRequest.AccountNo8       ;
            AccountNo9    =   createOpportunityRequest.AccountNo9       ;
            AccountNo10   =   createOpportunityRequest.AccountNo10      ;
            AppInDateUW   =   createOpportunityRequest.AppInDateUW      ;
            RefAppNumber  =   createOpportunityRequest.RefAppNumber     ;
            Reason        =   createOpportunityRequest.Reason           ;
            CheckNCB      =   createOpportunityRequest.CheckNCB         ;
            Ssoid         =   createOpportunityRequest.Ssoid            ;            
            MobileNo      =   createOpportunityRequest.MobileNo         ;
            Province      =   createOpportunityRequest.Province         ;
            District      =   createOpportunityRequest.District         ;
            SubDistrict   =   createOpportunityRequest.SubDistrict      ;
            ZipCode       =   createOpportunityRequest.ZipCode          ;
            Country       =   createOpportunityRequest.Country          ;
            SaleAmount    =   createOpportunityRequest.SaleAmount       ;
            YearInBusiness=   createOpportunityRequest.YearInBusiness   ;
            ProductGroupId=   createOpportunityRequest.ProductGroupId   ;
            FacilityInfos =   createOpportunityRequest.FacilityInfos    ;
        }
        public String JobName;
        public String CaNumber;
        public String OldCaNumber;
        public String AccountNo1;
        public String CustomerId;
        public String CustomerName;
        public String CitizenId;
        public Integer RequestType;
        public Integer CustomerType;
        public String BdmId;
        public String HubCode;
        public String RegionCode;
        public String UwId;
        public String AppInDateBDM;
        public String FinalApproved;
        public String Parallel_x;
        public String Pending;
        public String CaExist;
        public String CaEnd;
        public String AccountNo2;
        public String AccountNo3;
        public String AccountNo4;
        public String AccountNo5;
        public String AccountNo6;
        public String AccountNo7;
        public String AccountNo8;
        public String AccountNo9;
        public String AccountNo10;
        public String AppInDateUW;
        public String RefAppNumber;
        public String Reason;
        public String CheckNCB;
        public String Ssoid;
        public String MobileNo;
        public String Province;
        public String District;
        public String SubDistrict;
        public String ZipCode;
        public String Country;
        public Decimal SaleAmount;
        public Integer YearInBusiness;
        public Integer ProductGroupId;
        public facilityInfos_element FacilityInfos;
        private String[] JobName_type_info = new String[] {'JobName', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CaNumber_type_info = new String[] {'CaNumber', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] OldCaNumber_type_info = new String[] {'OldCaNumber', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo1_type_info = new String[] {'AccountNo1', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CustomerId_type_info = new String[] {'CustomerId', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CustomerName_type_info = new String[] {'CustomerName', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CitizenId_type_info = new String[] {'CitizenId', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] RequestType_type_info = new String[] {'RequestType', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CustomerType_type_info = new String[] {'CustomerType', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] BdmId_type_info = new String[] {'BdmId', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] HubCode_type_info = new String[] {'HubCode', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] RegionCode_type_info = new String[] {'RegionCode', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] UwId_type_info = new String[] {'UwId', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AppInDateBDM_type_info = new String[] {'AppInDateBDM', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] FinalApproved_type_info = new String[] {'FinalApproved', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Parallel_x_type_info = new String[] {'Parallel', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Pending_type_info = new String[] {'Pending', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CaExist_type_info = new String[] {'CaExist', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CaEnd_type_info = new String[] {'CaEnd', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo2_type_info = new String[] {'AccountNo2', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo3_type_info = new String[] {'AccountNo3', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo4_type_info = new String[] {'AccountNo4', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo5_type_info = new String[] {'AccountNo5', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo6_type_info = new String[] {'AccountNo6', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo7_type_info = new String[] {'AccountNo7', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo8_type_info = new String[] {'AccountNo8', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo9_type_info = new String[] {'AccountNo9', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AccountNo10_type_info = new String[] {'AccountNo10', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] AppInDateUW_type_info = new String[] {'AppInDateUW', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] RefAppNumber_type_info = new String[] {'RefAppNumber', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Reason_type_info = new String[] {'Reason', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] CheckNCB_type_info = new String[] {'CheckNCB', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] Ssoid_type_info = new String[] {'Ssoid', 'http://www.tmbbank.com/slsservices/', null, '1', '1', 'false'};
        private String[] MobileNo_type_info = new String[]{'MobileNo','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] Province_type_info = new String[]{'Province','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] District_type_info = new String[]{'District','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] SubDistrict_type_info = new String[]{'SubDistrict','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] ZipCode_type_info = new String[]{'ZipCode','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] SaleAmount_type_info = new String[]{'SaleAmount','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] YearInBusiness_type_info = new String[]{'YearInBusiness','http://www.tmbbank.com/slsservices/',null,'1','1','false'};
        private String[] ProductGroupId_type_info = new String[]{'ProductGroupId','http://www.tmbbank.com/slsservices/',null,'1','1','false'};
        private String[] FacilityInfos_type_info = new String[]{'FacilityInfos','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[] {'http://www.tmbbank.com/slsservices/', 'false', 'false'};
        /*private String[] field_order_type_info = new String[] {'JobName', 'CaNumber', 'OldCaNumber', 'AccountNo1', 'CustomerId', 'CustomerName', 'CitizenId', 'RequestType', 'CustomerType', 'BdmId', 'HubCode', 'RegionCode', 'UwId', 'AppInDateBDM', 'FinalApproved', 'Parallel_x', 'Pending', 'CaExist', 'CaEnd', 'AccountNo2', 'AccountNo3', 'AccountNo4', 'AccountNo5', 'AccountNo6', 'AccountNo7', 'AccountNo8', 'AccountNo9', 'AccountNo10', 'AppInDateUW', 'RefAppNumber', 'Reason', 'CheckNCB', 'Ssoid'};*/
        /*private String[] field_order_type_info = new String[] {'JobName', 'CaNumber', 'OldCaNumber', 'AccountNo1', 'CustomerId', 'CustomerName', 'CitizenId', 'RequestType', 'CustomerType', 'BdmId', 'HubCode', 'RegionCode', 'UwId', 'AppInDateBDM', 'FinalApproved', 'Parallel_x', 'Pending', 'CaExist', 'CaEnd', 'AccountNo2', 'AccountNo3', 'AccountNo4', 'AccountNo5', 'AccountNo6', 'AccountNo7', 'AccountNo8', 'AccountNo9', 'AccountNo10', 'AppInDateUW', 'RefAppNumber', 'Reason', 'CheckNCB', 'Ssoid','MobileNo','Province','District','SubDistrict','ZipCode','Country','SaleAmount','YearInBusiness','ProductGroupId'};*/
        private String[] field_order_type_info = new String[] {'JobName', 'CaNumber', 'OldCaNumber', 'AccountNo1', 'CustomerId', 'CustomerName', 'CitizenId', 'RequestType', 'CustomerType', 'BdmId', 'HubCode', 'RegionCode', 'UwId', 'AppInDateBDM', 'FinalApproved', 'Parallel_x', 'Pending', 'CaExist', 'CaEnd', 'AccountNo2', 'AccountNo3', 'AccountNo4', 'AccountNo5', 'AccountNo6', 'AccountNo7', 'AccountNo8', 'AccountNo9', 'AccountNo10', 'AppInDateUW', 'RefAppNumber', 'Reason', 'CheckNCB', 'Ssoid','MobileNo','Province','District','SubDistrict','ZipCode','Country','SaleAmount','YearInBusiness','ProductGroupId','FacilityInfos'};
    }
    
    public class FacilityInfoRequest {
        public Integer ProductProgramId;
        public Integer CreditTypeId;
        public Decimal RequestAmount;
        private String[] ProductProgramId_type_info = new String[]{'ProductProgramId','http://www.tmbbank.com/slsservices/',null,'1','1','false'};
        private String[] CreditTypeId_type_info = new String[]{'CreditTypeId','http://www.tmbbank.com/slsservices/',null,'1','1','false'};
        private String[] RequestAmount_type_info = new String[]{'RequestAmount','http://www.tmbbank.com/slsservices/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.tmbbank.com/slsservices/','false','false'};
        private String[] field_order_type_info = new String[]{'ProductProgramId','CreditTypeId','RequestAmount'};
    }

    public class SlsServicesPort {
        /*-------------------------------------------
        * Configurable End point via custom settings
        *--------------------------------------------*/
        AppConfig__c mc = AppConfig__c.getValues('slsservices');
        string tmpEndpoing = mc == null ? 'https://sfmashupservices.tmbbank.com/commercial/SLS/VIT/slsservices' : mc.Value__c;
        public String endpoint_x = tmpEndpoing;
        public Map<String, String> inputHttpHeaders_x;
        public Map<String, String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[] {'http://www.tmbbank.com/slsservices/', 'SLOSSoapService'};
        
        public SLOSSoapService.OpportunityResponse CreateOpportunity(SLOSSoapService.CreateOpportunityRequest createOpportunityRequest) {
        
        //public void CreateOpportunity(SLOSSoapService.CreateOpportunityRequest createOpportunityRequest) {
            SLOSSoapService.CreateOpportunityRequest_element request_x = new SLOSSoapService.CreateOpportunityRequest_element(createOpportunityRequest);
            /******************************************
            * Unuse code we change to use wrapper class
            *******************************************
            request_x.JobName = JobName;
            request_x.CaNumber = CaNumber;
            request_x.OldCaNumber = OldCaNumber;
            request_x.AccountNo1 = AccountNo1;
            request_x.CustomerId = CustomerId;
            request_x.CustomerName = CustomerName;
            request_x.CitizenId = CitizenId;
            request_x.RequestType = RequestType;
            request_x.CustomerType = CustomerType;
            request_x.BdmId = BdmId;
            request_x.HubCode = HubCode;
            request_x.RegionCode = RegionCode;
            request_x.UwId = UwId;
            request_x.AppInDateBDM = AppInDateBDM;
            request_x.FinalApproved = FinalApproved;
            request_x.Parallel_x = Parallel_x;
            request_x.Pending = Pending;
            request_x.CaExist = CaExist;
            request_x.CaEnd = CaEnd;
            request_x.AccountNo2 = AccountNo2;
            request_x.AccountNo3 = AccountNo3;
            request_x.AccountNo4 = AccountNo4;
            request_x.AccountNo5 = AccountNo5;
            request_x.AccountNo6 = AccountNo6;
            request_x.AccountNo7 = AccountNo7;
            request_x.AccountNo8 = AccountNo8;
            request_x.AccountNo9 = AccountNo9;
            request_x.AccountNo10 = AccountNo10;
            request_x.AppInDateUW = AppInDateUW;
            request_x.RefAppNumber = RefAppNumber;
            request_x.Reason = Reason;
            request_x.CheckNCB = CheckNCB;
            request_x.Ssoid = Ssoid;
            **************************************************************/

            SLOSSoapService.CreateOpportunityResponse_element response_x;
            Map<String, SLOSSoapService.CreateOpportunityResponse_element> response_map_x = new Map<String, SLOSSoapService.CreateOpportunityResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[] {endpoint_x,
                              'http://www.tmbbank.com/slsservices/CreateOpportunity',
                              'http://www.tmbbank.com/slsservices/',
                              'CreateOpportunityRequest',
                              'http://www.tmbbank.com/slsservices/',
                              'CreateOpportunityResponse',
                              'SLOSSoapService.CreateOpportunityResponse_element'
                             }
            );
            response_x = response_map_x.get('response_x');
            return response_x.Result;

        }
    }

}