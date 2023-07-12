# Pre-Required
1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli_windows)
3. Install [Git Command](https://git-scm.com/)

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

# Production Deployment Step
1. Checkout code from STAGING Branch
```

```
2. 

# Release Track
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

## Ref Link
[Source Control](https://bitbucket.tmbbank.local:7990/projects/CRMSAL/repos/ttb-crm/browse)
[SF Command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm)