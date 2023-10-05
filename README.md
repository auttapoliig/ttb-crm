# Pre-Required
1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli_windows)
3. Install [Git Command](https://git-scm.com/)
---
# Salesforce CLI setup
1. Validate Salesforce CLI
```
sf --version
```
2. Login to Salesforce CLI
```
sf org login web --instance-url https://tmbbank.my.salesforce.com --alias ttb-prod
```
3. Verify Login
```
sf org list
```
---
# Production Deployment Step
1. Checkout code from STAGING Branch
```
git checkout STAGING
```
2. Validate Component in Production
```
sf project deploy validate --manifest .\deploy\package.xml --target-org ttb-prod --test-level RunLocalTests --async
```
3. Get Update Deployment Status
```
sf project deploy report --job-id _<<jobid>>_
```
4. Quick Deploy
```
sf project deploy quick --job-id _<<jobid>>_
```
---
# Release Track
#### 05 Oct 2023
| SCR No.     | Description    | Implementor | Release Date |
| --------|---------|-------|-------|
| SCR0578084,SCR0580261 | RM cockpit MVP2 | Taechatiphon | 05 Oct 2023 |
| SCR0592577 | Hot warm cold interim solution | Taechatiphon | 05 Oct 2023 |
| SCR0585931 | T-Performance 1.2 backlog | Taechatiphon | 05 Oct 2023 |
| SCR0599861 | Add new Dropdown List on Referral (Phase 1) | Kiitisak | 05 Oct 2023 |
| SCR0599491 | ALSAL-Cancel email notify from CRM | Attasit | 05 Oct 2023 |
#### 21 Sep 2023
| SCR No.     | Description    | Implementor | Release Date |
| --------|---------|-------|-------|
| SCR0567438 | LGS WS1 | Auttapol, Phongrawee, Monkol, Jedilok | 21 Sep 2023 |
| SCR0599447 | Improve performance power bi หน้า product holding (MFDashboard) | Todsapol | 21 Sep 2023 |
| SCR0595232 | เอา link การดูข้อมูลระบบ life Time ของ ลูกค้า ออก เนื่องจาก ระบบนี้ LCM เรียบร้อยแล้ว | Attasit | 21 Sep 2023 |
| SCR0595886 | NPS Score in case of no score / no survey | Attasit | 21 Sep 2023 |
| SCR0593640 | CRM send Fields "Completed case after sent SMS & Close by Team to CXM" | Sanchai | 21 Sep 2023 |
| SCR0594879 | Enhance report raw data chat to show over SLA as text | Attasit | 21 Sep 2023 |
| SCR0598260 | Manually add Payroll and Welfare Product | Todsapol | 21 Sep 2023 |
| SCR0598460 | Add Role hierarchy and Queue | Todsapol | 21 Sep 2023 |
#### 07 Sep 2023
| SCR No.     | Description    | Implementor | Release Date |
| --------|---------|-------|-------|
| SCR0585931 | T-performance 1.2 : แสดงรายงาน kpi สำหรับสาขา | IIG | 07 Sep 2023 |
| SCR0597267 | แก้ไข การ default ค่า sub service segment ก่อนส่งไปให้ dwh (Refer : INC0244604)| CoE (Kitisak) | 07 Sep 2023 |
| SCR0599186 | แก้ไข program ให้สามารถ update ลูกค้าที่มี owner inactive| CoE (Attasit) | 07 Sep 2023 |
| SCR0598849 | upload issue matrix related for OneApp K.Lalida (Upload manual file)| CoE (Todsapol) | 07 Sep 2023 |
| INC0227328 | merge commercial customer (ต่อเนื่องที่ยังคงเหลือ 100 ราย) | CoE (Todsapol) | 07 Sep 2023 |
#### 24 Aug 2023
| SCR No.     | Description    | Implementor | Release Date |
| --------|---------|-------|-------|
| SCR0596488 | GBH Phase 1 | IIG | 24 Aug 2023 |
| SCR0596488 | AL CR Separate Batch Normal Request | IIG | 24 Aug 2023 |
| SCR0579629 | CRM SalesForce to show Mutual Fund Dashboad on Power BI | CoE (Todsapol) | 24 Aug 2023 |
| SCR0593679 | ขอเพิ่ม/ขอแก้ไขสิทธิ load bulk ปิดเคส | CoE (Kitisak) | 24 Aug 2023 |
| SCR0593190 | ขอสิทธิ์ให้ 3 users สามารถ export report ได้ (Role : TMB Retail Contact Center Report Specialist) | CoE (Attasit) | 24 Aug 2023 |
| SCR0592441 | ขอเพิ่มสิทธิ load bulk ปิดเคส ในระบบ CRM : BU Confirm Bulk File ที่จะปิด Case (Field : Case No, Case ID, Resolve, Resolution) | CoE (Attasit) | 24 Aug 2023 |
| SCR0595356 | ขออนุมัติเพื่อดำเนินการ Create 2 role | CoE (Attasit) | 24 Aug 2023 |
| SCR0595231 | Enable Global Search Campaign Code | CoE (Attasit) | 24 Aug 2023 |
| SCR0595867 | Wealth Support Revolk เพื่อสิทธิ์รับเคส | CoE (Attasit) | 24 Aug 2023 |
| SCR0595725 | Merge Customer from 01-Jan-23 to 31-Jul-23 | CoE (Todsapol) | 24 Aug 2023 |
#### 20 July 2023
| SCR No.     | Description    | Implementor | Release Date |
| --------|---------|-------|-------|
| SCR0592576 | Check Duplicate Lead | IIG | 20 July 2023 |
| SCR0590879 | Add Wealth Support list to receive cases | CoE (Attasit) | 20 July 2023 |
| SCR0587873 | ขอเพิ่มสิทธิ์ ให้กับ คุณ Nalinee  Imsaard สามารถทำการ Approve Campaign ได้เหมือนกับคุณ Panawat Innurak (เฉพาะ Campaign type = Exclusive) | CoE (Attasit) | 20 July 2023 |
| SCR0592580 | change logic NPS Score เพื่อให้ในระบบ CRM show NPS score ตรงกับที่ สื่อความ | CoE (Attasit) | 20 July 2023 |
| SCR0581170 | Clear Close branch | CoE (Krittisak) | 20 July 2023 |
| SCR0586993 | Access right to KYC review template | CoE (Todsapol) | 20 July 2023 |
| SCR0589780 | Update UW name list on case management | CoE (Todsapol) | 20 July 2023 |
| SCR0592422 | Reorg SME : Add new role & profile | CoE (Todsapol) | 20 July 2023 |
| SCR0592423 | KYC review on case management : Add new queue KYC – Customer Data Managment | CoE (Todsapol) | 20 July 2023 |
---
## Ref Link
* [Source Control](https://bitbucket.tmbbank.local:7990/projects/CRMSAL/repos/ttb-crm/browse)
* [SF Command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm)