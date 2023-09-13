@isTest
public class AvayaCallistDTOTest {
    @isTest 
    static void testDeclaration(){
        Test.startTest();
            AvayaCallistDTO dto = new AvayaCallistDTO();
            dto.request.setRequestId('001zf34002dxgQAA');
            System.assertEquals('001zf34002dxgQAA', dto.request.getRequestId());

            dto.request.setFirstName('Test First Name');
            System.assertEquals('Test First Name', dto.request.getFirstName());
            dto.request.getTruncateFirstName();

            dto.request.setLastName('Last Name');
            System.assertEquals('Last Name', dto.request.getLastName());
            dto.request.getTruncateLastName();

            dto.request.setProductName('Home Loan');
            System.assertEquals('Home Loan', dto.request.getProductName());
            dto.request.getTruncateProductName();

            dto.request.setSub_ProductName('Home Loan');
            System.assertEquals('Home Loan', dto.request.getSub_ProductName());
            dto.request.getTruncateSub_ProductName();

            dto.request.setMobile('0881122993');
            System.assertEquals('0881122993', dto.request.getMobile());

            dto.request.setCampaign('callmenow_sme');
            System.assertEquals('callmenow_sme', dto.request.getCampaign());

            dto.request.setDial_time('2017:02:02 12:12:00');
            System.assertEquals('2017:02:02 12:12:00', dto.request.getDial_time());

            dto.request.setChannel_name('Web');
            System.assertEquals('Web', dto.request.getChannel_name());

            dto.request.setSf_id('111222333');
            System.assertEquals('111222333', dto.request.getSf_id());

            dto.request.setBusiness1('bus1');
            System.assertEquals('bus1', dto.request.getBusiness1());
            dto.request.getTruncateBusiness1();

            dto.request.setBusiness2('bus2');
            System.assertEquals('bus2', dto.request.getBusiness2());
            dto.request.getTruncateBusiness2();

            dto.request.setBusiness2('bus2');
            System.assertEquals('bus2', dto.request.getBusiness2());
            dto.request.getTruncateBusiness2();

            dto.request.setBusiness3('bus3');
            System.assertEquals('bus3', dto.request.getBusiness3());
            dto.request.getTruncateBusiness3();

            dto.request.setBusiness4('bus4');
            System.assertEquals('bus4', dto.request.getBusiness4());
            dto.request.getTruncateBusiness4();

            dto.request.setBusiness5('bus5');
            System.assertEquals('bus5', dto.request.getBusiness5());
            dto.request.getTruncateBusiness5();

            dto.request.setBusiness6('bus6');
            System.assertEquals('bus6', dto.request.getBusiness6());
            dto.request.getTruncateBusiness6();

            dto.request.setBusiness7('bus7');
            System.assertEquals('bus7', dto.request.getBusiness7());
            dto.request.getTruncateBusiness7();

            dto.request.setBusiness8('bus8');
            System.assertEquals('bus8', dto.request.getBusiness8());
            dto.request.getTruncateBusiness8();

            dto.request.setBusiness9('bus9');
            System.assertEquals('bus9', dto.request.getBusiness9());
            dto.request.getTruncateBusiness9();

            dto.request.setBusiness10('bus10');
            System.assertEquals('bus10', dto.request.getBusiness10());
            dto.request.getTruncateBusiness10();

            dto.request.setRemark('remark');
            System.assertEquals('remark', dto.request.getRemark());
            dto.request.getTruncateRemark();

            dto.request.setURL('http://www.google.co.th');
            System.assertEquals('http://www.google.co.th', dto.request.getURL());
            dto.request.getTruncateURL();


            String systemContactID = dto.response.systemContactID;
            String inserted = dto.response.inserted;
            String errorCode = dto.response.errorCode;
            String failureReason = dto.response.failureReason;
            List<String> emptiedAttributes = dto.response.emptiedAttributes;
            String message = dto.response.message;
            String rawResponse = dto.response.rawResponse;

            dto.generateJSONContent();
        Test.stopTest();
    }
}