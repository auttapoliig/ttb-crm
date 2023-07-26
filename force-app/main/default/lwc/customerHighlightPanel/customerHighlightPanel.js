import {
  LightningElement,
  track,
  wire,
  api
} from 'lwc';
import userId from '@salesforce/user/Id';
import getDescribeFieldResultAndValue from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import getProfilverifyFieldSecurityeName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';
import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';
import getLatestNPS from '@salesforce/apex/HighlightPanelController.getLatestNPS';

import {
  refreshApex
} from '@salesforce/apex';
import {
  parseObj
} from 'c/methodUtils';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = ['RTL_AUM__c', 'RTL_Wealth_RM__c', 'Wealth_RM_BM_Name__c', 'Assigned_BRC_User_Name__c',
  'RMC_Regulation_Alert__c', 'RTL_Assigned_BRC__c', 'RMC_TTB_Touch__c',
  'RMC_Number_of_Product_Holdings__c'
];

export default class CockpitCSVCustomerInfo extends NavigationMixin(LightningElement) {

  @api recordId;
  @api userAgent = 'Desktop';

  @track activeSections = ['personalInformation', 'dataValidationStatus', 'consentAndRisk', 'AUMAndMainBank', 'RMInformation', 'OtherPersonalInformation', 'ContactInformation'];
  @track customerDetail = {};
  @track dataPartition = {};
  @track isGetDataPartition = false;
  @track isiPad = false;
  @track isTablet = false;

  @track watermarkImage = "";
  isRerender = false;

  label = {
    Data_Condition_Hidden_Text
  }

  nps = { isSurveyAvailable: false, class: '', icon: '', url: '' };

  isDisplayRMBM = false;
  mainBank = '';

  connectedCallback() {
    FIELDS.forEach(k => {
      this.customerDetail[k] = {
        name: '',
        value: '',
        label: '',
        type: '',
        inlineHelpText: '',
        isAccessible: false,
      }
      this.dataPartition[k] = {
        isVisible: false
      }
    });

    var score = 0;

    getLatestNPS({ accId: this.recordId }).then(
      (result) => {
        score = result.score;
        var nps = {};
        nps.score = score;
        if (score == null) {
          nps.class = 'greyFace';
          nps.icon = 'utility:sentiment_neutral';
          nps.url = '#';
        } else if (score >= 5) {
          nps.class = 'greenFace';
          nps.icon = 'utility:smiley_and_people';
          nps.url = result.recordId;
        } else if (score >= 4) {
          nps.class = 'yellowFace';
          nps.icon = 'utility:sentiment_neutral';
          nps.url = result.recordId;
        } else if (score >= 1){
          nps.class = 'redFace';
          nps.icon = 'utility:sentiment_negative';
          nps.url = result.recordId;
        } else {
          nps.score = null;
          nps.url = result.recordId;
          console.log('nps score',nps.score);
        }
        console.log('nps var',JSON.stringify(nps));
        this.nps = nps;
      }
    ).catch(
      error => {
        console.log('error: ' + error);
      }
    );
  }

  renderedCallback() {
    this.isRerender = true;
  }

  disconnectedCallback() {
    refreshApex(this.customerDetail);
  }

  @wire(getDescribeFieldResultAndValue, {
    recordId: '$recordId',
    fields: FIELDS,
    fields_translate: [],
  })

  async wiredGetDescribeFieldResultAndValue({
    error,
    data
  }) {
    if (data) {
      this.customerDetail = parseObj(data);

      var regulationVis = this.customerDetail['RMC_Regulation_Alert__c'].isAccessible;
      if(regulationVis == true){
        var regulation = this.customerDetail['RMC_Regulation_Alert__c'].value;
        if (regulation) {
          this.customerDetail['RMC_Regulation_Alert__c'].value = 'Yes';
        } else {
          this.customerDetail['RMC_Regulation_Alert__c'].value = 'No';
        }
      }

      var regulationVis = this.customerDetail['RMC_TTB_Touch__c'].isAccessible;
      if(regulationVis == true){
        var regulation = this.customerDetail['RMC_TTB_Touch__c'].value;
        if (regulation) {
          this.customerDetail['RMC_TTB_Touch__c'].value = 'มี';
        } else {
          this.customerDetail['RMC_TTB_Touch__c'].value = 'ไม่มี';
        }
      }

      Object.keys(this.customerDetail).forEach((v, i) => {
        this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
        if( this.customerDetail['RTL_Wealth_RM__c'].value || !this.customerDetail['RTL_Assigned_BRC__c'].value){
          this.isDisplayRMBM = true
        }
      });
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error loading.',
          message: error,
          variant: 'error',
        }),
      );
    }
  }

  @wire(getWatermarkHTML)
  getWatermark({
    error,
    data
  }) {
    if (data) {
      var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
        "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + data + "</text></svg>");
      var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
      this.watermarkImage = 'background-image: ' + bg + ';width:100%;height:100%';
    }
  }

  navigateToRecord(event) {
    this[NavigationMixin.Navigate]({
      "type": "standard__recordPage",
      "attributes": {
        "recordId": event.target.dataset.id,
        "actionName": "view"
      }
    });
  }

  navigate(url) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: url,
        actionName: 'view'
      }
    });
  }

  navigateToNPS() {
    this.navigate(this.nps.url);
  }

  navigateToManager(event) {
    this.navigate(event.target.dataset.url);
  }
}