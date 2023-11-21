//query มาแค่ tmbId แล้วค่อยไป query name ที่หลังบ้าน
import { LightningElement, track, wire, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getCustomer from '@salesforce/apex/RetailCSVCustomerChartController.fetchAccount';
import NoAuthorizeMSG from '@salesforce/label/c.Data_Condition_NotAuthorizedMsg';
import ERR001 from '@salesforce/label/c.ERR001';
import ERR002 from '@salesforce/label/c.ERR002';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUsagePercentageData  from '@salesforce/apex/RetailCSVCustomerChartController.getUsagePercentageData';
import getUsagePercentageRes  from '@salesforce/apex/RetailCSVCustomerChartController.getUsagePercentageRes';
//เพิ่มมาลอง
import getDescribeFieldResultAndValue from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';



//data partition 
import userId from '@salesforce/user/Id';
import getProfileverifyFieldSecurityName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity'; 
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';

import NUMBER_OF_RETRY_TIME from '@salesforce/label/c.Number_Of_Retry_Times';
import RETRY_SETTIMEOUT from '@salesforce/label/c.Retry_SetTimeOut';

import { getRecord } from 'lightning/uiRecordApi';
import { parseObj } from 'c/methodUtils';

const FIELDS = ['TMB_Customer_ID_PE__c', 'Name'];

export default class RetailCSVChartUsageLastMonth extends LightningElement {
    @track isChartJsInitialized = false;
    @api recordId;
    @track customer;
    customerData;
    accountQM_A;
    acc;
    @track res;
    chart;
    rmId;
    @track cData = [];
    @track displayData = [];
    dataChart;
    totalData;
    chartXSize;
    valueText = [];
    titleLabel = 'Loading...';
    @track isServiceError = false;
    @track isInternalError = false;

    profileName;
    @track isVisible = true;
    @track isAccessible = false;
    section = 'RtlCust:Sales Support Information';
    @track isEndService = false;
    @track isHaveTMB_ID = true;

    label = {
      noPermission: NoAuthorizeMSG,
      getError: ERR001,
      internalError: ERR002
    }

    connectedCallback() {
      // this.initialize();
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
      if(data){
        const returnObject = parseObj(data);
        if(returnObject.TMB_Customer_ID_PE__c == null){
          this.isHaveTMB_ID = false;
        }

        //ใช้แค่ TMB_Customer_ID_PE__c กับ Name
        const accObject = {
          Name : returnObject.Name.value,
          TMB_Customer_ID_PE__c : returnObject.TMB_Customer_ID_PE__c.value,
        }
        this.acc = accObject;
        this.initialize();
      }
      else{
        console.error(error);
      }
    }

    initialize = async () => {
      this.profileName = await getProfileName({
        userId: userId
      });
      getProfileverifyFieldSecurityName({
          section: this.section,
          userProfile: this.profileName,
          accountId: this.recordId
      })
      .then(result => {
          this.isAccessible = result;
          if (result == false) {
            this.isVisible = false;
          } 
          else{
            if(this.acc && this.isHaveTMB_ID) {
              this.callServices(0);
            }
          }
      })
      .catch(error => {
          console.error('Get data partition error: ', error)
      })
    }

    callServices(round) {
      getUsagePercentageRes({
        recordId: this.recordId, 
        account: this.acc
      }).then(result => {
        this.res = JSON.parse(result);
        if (this.res.Status && this.res.Status.StatusCode == '200') {
          if (this.res.GetCVSAnalyticsDataResponse) {
            let UsagePercent;
            let DatasInt = [];
            try {
              UsagePercent = this.res.GetCVSAnalyticsDataResponse.Result.UsagePercentage;
              let dataString = UsagePercent.split(':', 6);
              dataString.forEach(element => {
                DatasInt.push(parseInt(element, 10));
              });
              this.cData.push(DatasInt[0]);
              this.cData.push(DatasInt[1]);
              this.cData.push(DatasInt[2]);
              this.cData.push(DatasInt[3]);
              this.cData.push(DatasInt[4]);
              this.cData.push(DatasInt[5]);
              this.isChartJsInitialized = false;
              this.totalData = this.cData[0] + this.cData[1] + this.cData[2] + this.cData[3] + this.cData[4] + this.cData[5];
              this.chartXSize = this.totalData + 10;
              this.isEndService = true;
              
              this.displayData = this.cData;
            } catch (error) {
              this.isVisible = false;
              this.isServiceError = true;
            }
          }
        }else if(this.res.Status.StatusCode == '401' && round < NUMBER_OF_RETRY_TIME ){
          round += 1;
          setTimeout(() => {
              this.callServices(round);
          }, RETRY_SETTIMEOUT);
        }else {
          this.isServiceError = true;
          this.isVisible = false;
        }
        
      }).catch(error => {
        this.isInternalError = true;
        this.isVisible = false;
      })
    }

    renderedCallback() {
        if (this.isChartJsInitialized  && this.chart) {
          this.chart.data.datasets[0].data = this.displayData;
          this.chart.update();
            return;
        }
        if(!this.isChartJsInitialized && this.isVisible && this.isEndService) {
            this.displayData = this.cData;
            this.titleLabel = '% Branch/Digital  ' + this.cData[0] +'/'+ (this.totalData-this.cData[0]);
          Promise.all([
            loadScript(this, chartjs)
          ]).then(() => {
              const ctx = this.template.querySelector('canvas.horizontalBar').getContext('2d');
              this.chart = new window.Chart(ctx, {
                type: 'horizontalBar',
                data: {
                    labels: ["Branch", "ATM", "ADM", "IB", "Touch", "Others"],
                    datasets: [{
                      label: '%Usage Last Month',
                      data: this.displayData,
                      backgroundColor: [
                        'rgba(0, 176, 80, 0.7)',
                        'rgba(0, 112, 192, 0.7)',
                        'rgba(75, 192, 192, 0.7)',
                        'rgba(189, 215, 238, 0.7)',
                        'rgba(0, 176, 240, 0.7)',
                        'rgba(255, 99, 132, 0.7)'
                      ],
                      borderColor: [
                        'rgba(0, 176, 80,1)',
                        'rgba(0, 112, 192, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(189, 215, 238, 1)',
                        'rgba(0, 176, 240, 1)',
                        'rgba(255,99,132,1)'
                      ],
                      borderWidth: 1
                    }]
                  },
                  options: {
                    "hover": {
                      "animationDuration": 0
                    },
                    "events": [],
                    "tooltips": {
                      enabled: false
                    },
                    "animation": {
                      "duration": 1,
                      "onComplete": function() {
                        var chartInstance = this.chart,
                        ctx = chartInstance.ctx;
        
                        // ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
        
                        this.data.datasets.forEach(function(dataset, i) {
                          var total = dataset.data[0] + dataset.data[1] + dataset.data[2] + dataset.data[3] + dataset.data[4] + dataset.data[5];
                          var meta = chartInstance.controller.getDatasetMeta(i);
                          let dataZeroCount = 0;
                          meta.data.forEach(function(bar, index) {
                            var data = dataset.data[index];
                            if(data == 0){
                              var percent = ' ';
                              dataZeroCount += 1;
                            }else{
                              var percent = data + '%';
                            }
                            ctx.fillText(percent, bar._model.x + 20, bar._model.y + 7);
                          });
                          if (dataZeroCount == 6) {
                          }
                        });
                      }
                    },
                    responsive: true,
                    legend: {
                      // position: 'top',
                      display: false,
                      // align: 'start'
                    },
                    title: {
                      display: true,
                      text: this.titleLabel,
                      align: 'start',
                      position: 'top'
                    },
                    scales: {
                      xAxes: [{
                        ticks: {
                          beginAtZero: true,
                          max: this.chartXSize,
                          display: false
                        },
                        gridLines: { display: false },
                        scaleLabel: {
                          display: true,
                          labelString: 'Transaction'
                        }
                      }],
                      yAxes: [{
                        ticks: {
                          beginAtZero: true
                        },
                        gridLines: { display: false }
                      }]
                    }
                  }
              });
              this.chart.canvas.parentNode.style.height = '100%';
              this.chart.canvas.parentNode.style.width = '100%';
          }).catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error loading ChartJS',
                      message: error.message,
                      variant: 'error',
                  }),
              );
          });

          this.isChartJsInitialized = true;
        
        }
        
    }
}