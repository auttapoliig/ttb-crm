import { api, LightningElement, wire } from 'lwc'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

// Constant
// import formFactor from '@salesforce/client/formFactor'
import userId from '@salesforce/user/Id';
// import label from './customLabel';

// Method
import { uuid } from 'c/methodUtils';
import { getRecord } from 'lightning/uiRecordApi';
import getMetaPowerbi from '@salesforce/apex/PowerBiUtils.getMetaPowerbi';
import encryptCustomerId from '@salesforce/apex/PowerBiUtils.encryptCustomerId';
import getFieldVisibilityByPage from '@salesforce/apex/PowerBiUtils.getFieldVisibilityByPage';

export default class PowerBiReportProductHolding extends NavigationMixin(
  LightningElement
) {
  @api
  recordId //Account Id
  reportId

  URL_Report //URL Power Bi Report 
  _title = 'MF Dashboard' //Button label

  _account
  @wire(getRecord, {
    recordId: '$recordId', fields: [
      'Account.TMB_Customer_ID_PE__c', 'Account.Id'
    ]
  })
  callbackGetRecord({ data }) {
    if (data) {
      this._account = Object.keys(data.fields).reduce((l, i) => {
        l[i] = data.fields[i].value
        return l
      }, {})

      this._tmb_cust_id = this._account.TMB_Customer_ID_PE__c;
      console.log('accountId >>>> ' + this._account.Id);
      this.getAccessPermission();
    }
  }
  reportId //report Id  from Metadata 
  @wire(getMetaPowerbi, {})
  callbackGetReportMetadata({ data }) {
    // console.log("callbackGetReportMetadata 111 >>>>>");
    if (data) {
      this.reportId = data.Id
      // console.log("callbackGetReportMetadata 222 " + data.Id);
      this.getEncryptParam(this._tmb_cust_id);
    }
  }

  handlerOpenPowerBi() {
    // await this.calloutInit();
    try {
      this.getEncryptParam(this._tmb_cust_id);
      this.URL_Report = "/apex/PowerBiReportPage?ReportId=" + this.reportId + "&param_1=" + this.encryptedString
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: this.URL_Report
        },
      });
    } catch {
      console.error(e);
      this.dispatchEvent(new ShowToastEvent({
        variant: 'error',
        title: e.body?.exceptionType,
        message: e.body?.message,
      }));
    }

  }

  _isRetailProfile = false
  @wire(getRecord, {
    recordId: userId,
    fields: [
      'User.Profile.Name'
    ]
  })
  callbackGetProfileName({ data }) {
    if (data) {
      this._isRetailProfile =
        `${data.fields.Profile.displayValue}`.includes('Admin') ||
        `${data.fields.Profile.displayValue}`.includes('Retail')
    }
  }

  connectedCallback() {
    this._class = `${this._formFactor === 'Large' ? 'slds-m-horizontal_small' : 'd-flex slds-m-vertical_small'}`
    this.dispatchEvent(new CustomEvent('init'))
  }

  getEncryptParam(param) {
    // console.log("getEncryptParam >>>>>" + param);
    encryptCustomerId({
      strParam: param
    }).then((result) => {
      this.encryptedString = result;
      // console.log("encryptedString >>>>>" + this.encryptedString);
    }).catch((error) => {
      console.error(error);
    })
  }

  _isAccess = false;
  getAccessPermission() {
    getFieldVisibilityByPage({
      pageName: 'PowerBiOnProductHolding',
      recordId: this._account.Id
    }).then((result) => {
      // console.log("getFieldVisibilityByPage 111 >>>>>" + JSON.stringify(result));
      if (result) {
        this._isAccess = result.Authorize;
        // console.log("getFieldVisibilityByPage 222 " + result.Authorize);
      }
    }).catch((error) => {
      console.error(error);
    })
  }

}