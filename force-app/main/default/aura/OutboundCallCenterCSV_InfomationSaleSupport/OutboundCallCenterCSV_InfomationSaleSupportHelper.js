({
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    getDescribeFieldResults: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields'),
            "fields_translate": []
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                helper.generateField(component,objectInfoField);
                helper.getCVSAnalyticsData(component, event, helper,objectInfoField,0);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    generateField : function(component,objectInfoField) {
        let result = objectInfoField;
        for (const i of component.get('v.fields')){
            result[i].isAccessible = result[i].isAccessible ? result[i].isAccessible : false;
            result[i].type = result[i].type;
            result[i].label = result[i].label;
            result[i].value = result[i].value != null ? result[i].value : '';
            result[i].inlineHelpText = result[i].inlineHelpText ? result[i].inlineHelpText : '';
        };
        /* RTL_Occupation_Details__c (change value) */
        if (result['RTL_Occupation_Details__c'].isAccessible == true){
            result['RTL_Occupation_Details__c'].value = result['RTL_Occupation_Details__r.RTL_Occupation_Desc__c'].value;
            result['RTL_Occupation_Details__c'].inlineHelpText = result['RTL_Occupation_Details__c'].inlineHelpText ? result['RTL_Occupation_Details__c'].inlineHelpText : '';
        };
        /* RTL_Primary_Banking_All_Free_Benefit__c (mainbank + description) */
        if (result['RTL_Primary_Banking_All_Free_Benefit__c'].isAccessible == true){
            result['RTL_Primary_Banking_All_Free_Benefit__c'].value = result['RTL_Primary_Banking_All_Free_Benefit__c'].value ? 'Yes':'No';
            result['RTL_Primary_Banking_All_Free_Benefit__c'].value += result['RTL_Main_Bank_Desc__c'].value ? (' [' +result['RTL_Main_Bank_Desc__c'].value + ']' ):''; 
        };
        /* RTL_Risk_Level_Details__c (change color)  */
        if (result['RTL_Risk_Level_Details__c'].isAccessible == true){
            if(result['RTL_Risk_Level_Details__c'].value == 'AC – ลูกค้าปกติ' || result['RTL_Risk_Level_Details__c'].value == 'A2 – ลูกค้าเสี่ยงระดับ 2'){
                result['RTL_Risk_Level_Details__c'].class = 'greenColor';
            }else{
                result['RTL_Risk_Level_Details__c'].class = 'redColor';
            }
        };
        /* RTL_4THANA_Info__c */
        if (result['RTL_4THANA_Info__c'].isAccessible == true){
            result['RTL_4THANA_Info__c'].value = '- ' + result['RTL_4THANA_Fund_AMT__c'].label + ' ' + (result['RTL_4THANA_Fund_AMT__c'].value ? result['RTL_4THANA_Fund_AMT__c'].value : '0.00' ) + ' บาท'
            + '<br/>- ' + result['RTL_4THANA_Aggregate_Bond_AMT__c'].label + ' ' + (result['RTL_4THANA_Aggregate_Bond_AMT__c'].value ? result['RTL_4THANA_Aggregate_Bond_AMT__c'].value : '0.00' ) + ' บาท'
            + '<br/>- ' + result['RTL_4THANA_Bond_AMT__c'].label + ' ' + (result['RTL_4THANA_Bond_AMT__c'].value ? result['RTL_4THANA_Bond_AMT__c'].value : '0.00' ) + ' บาท'
            + '<br/>- ' + result['RTL_4THANA_Short_Bond_AMT__c'].label + ' ' + (result['RTL_4THANA_Short_Bond_AMT__c'].value ? result['RTL_4THANA_Short_Bond_AMT__c'].value : '0.00' ) + ' บาท'
            + '<br/>- ' + result['RTL_4THANA_Total_AMT__c'].label + ' ' + (result['RTL_4THANA_Total_AMT__c'].value ? result['RTL_4THANA_Total_AMT__c'].value : '0.00' ) + ' บาท';
        }else{
            result['RTL_4THANA_Info__c'].value = result['RTL_4THANA_Info__c'].value;
        }
        /* RTL_OnSite_Service__c */
        if (result['RTL_OnSite_Service__c'].isAccessible == true){
            result['RTL_OnSite_Service__c'].value += result['RTL_OnSite_Service_Update_Date__c'].value ? (' ['+ $A.localizationService.formatDateTime((result['RTL_OnSite_Service_Update_Date__c'].value),'dd/MM/yyyy') + ']' ): '';
            result['RTL_OnSite_Service__c'].value += result['RTL_OnSite_Service_User_Update__c'].value ? (' ['+ result['RTL_OnSite_Service_User_Update__c'].value + ']' ): '';
        }

        component.set('v.fields',result);
        /* E Statement */
        component.set('v.eStatement.data',[{
            'Consolidate': result['Consolidate_Status__c'].isAccessible ? (result['Consolidate_Status__c'].value == 'Y'? true : false) : false,
            'CreditCard': result['RTL_CC_STMT_status__c'].isAccessible ? (result['RTL_CC_STMT_status__c'].value == 'Y'? true : false) : false,
            'RDC': result['RTL_RDC_STMT_status__c'].isAccessible ? (result['RTL_RDC_STMT_status__c'].value == 'Y'? true : false) : false,
            'C2G': result['RTL_C2G_STMT_status__c'].isAccessible ? (result['RTL_C2G_STMT_status__c'].value == 'Y' ? true : false) : false
        }]);
    },
    getCVSAnalyticsData: function (component, event, helper, objectInfoField,round) {
        var numberOfRetry = component.get('v.numberOfRetry');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        var action = component.get('c.getCVSAnalyticsDataByAccID');
        action.setParams({
            'accId': component.get('v.recordId')
            // 'rmId': objectInfoField['TMB_Customer_ID_PE__c'].value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result && result.Status == 'SUCCESS') {
                    helper.generateCVSAnalyticsData(component, result);
                    component.set('v.is07Success',true);
                    helper.checkIsRender(component,helper);
                }else if(result.StatusCode == '401' && round < numberOfRetry ){ 
                    round += 1;
                    console.log(round);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.getCVSAnalyticsData(component, event, helper, objectInfoField, round);
                        }), retrySetTimeOut
                    );
                }else{
                    component.set('v.is07Success',true);
                    helper.checkIsRender(component,helper);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        if (objectInfoField['TMB_Customer_ID_PE__c'].value){
            $A.enqueueAction(action);
        }else{
            component.set('v.is07Success',true);
            helper.checkIsRender(component,helper);
        } 
    },
    generateCVSAnalyticsData : function(component,result){
        if (result) {
            var fieldsResult = component.get('v.fields');
            /* RTL_Most_Visited_Branch__c */
            if (fieldsResult['RTL_Most_Visited_Branch__c'].isAccessible == true){
                fieldsResult['RTL_Most_Visited_Branch__c'].value = result.csProfFreqBr ? result.csProfFreqBr : '';
            }else if (fieldsResult['RTL_Most_Visited_Branch__c'].isAccessible == false){
                fieldsResult['RTL_Most_Visited_Branch__c'].value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            };
            /* RTL_Suitability__c */
            if (fieldsResult['RTL_Suitability__c'].isAccessible == true){
                fieldsResult['RTL_Suitability__c'].value = result.suitability ? result.suitability : '';
            }else if (fieldsResult['RTL_Suitability__c'].isAccessible == false){
                fieldsResult['RTL_Suitability__c'].value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            };
            /* RTL_Entitled_Privilege2__c */
            if (fieldsResult['RTL_Entitled_Privilege2__c'].isAccessible == true){
                fieldsResult['RTL_Entitled_Privilege2__c'].value = result.entitledPrivilege2Desc ? result.entitledPrivilege2Desc.split('|').filter(f => f).join('<br />') : '';
            }else if (fieldsResult['RTL_Entitled_Privilege2__c'].isAccessible == false){
                fieldsResult['RTL_Entitled_Privilege2__c'].value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            };
            /* RTL_Privilege2__c */
            if (fieldsResult['RTL_Privilege2__c'].isAccessible == true){
                fieldsResult['RTL_Privilege2__c'].value = result.currentPrivilege2Desc ? result.currentPrivilege2Desc : '';
            }else if (fieldsResult['RTL_Privilege2__c'].isAccessible == false){
                fieldsResult['RTL_Privilege2__c'].value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            };

            component.set('v.fields',fieldsResult);

            if ( fieldsResult['Fna_Avatar_Name__c'].isAccessible == true){
                component.set('v.payStatus.data', [{
                    'TMBTouch': result.touchStatus ? (result.touchStatus == 'YES'? true:false) : false,
                    'InternetBanking': result.ibStatus ? (result.ibStatus == 'YES'? true:false): false,
                    'PromptPay': result.promptPay ? (result.promptPay == 'YES'? true:false) : false,
                }]);
            }else{
                component.set('v.payStatus.data', [{
                    'TMBTouch': false,
                    'InternetBanking': false,
                    'PromptPay': false,
                }]);
            };
        }
    },
    getInstantLendingDetail: function (component, event, helper) {
        var action = component.get('c.getInstantLendingDetail');
        action.setParams({
            "accId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var lendingDetail = response.getReturnValue();
                component.set('v.instantLendingDetail',lendingDetail);
            }
            else if(state === 'ERROR') {
                console.log('getInstantLendingDetail ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
        });
        $A.enqueueAction(action);
    },
    getProfileName: function (component, event, helper) {
        return new Promise((resolve, reject) => {
            var action = component.get('c.getProfileName');
            action.setParams({
                "userId": component.get('v.userId'),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.profileName', result); 
                    resolve(result);
                }
                else if(state === 'ERROR') {
                    console.error('error: getProfileName');
                    reject('error');
                } else {
                    console.error('Unknown problem, state.');
                    reject('error');
                }
            });
            $A.enqueueAction(action);
        })
    },
    onVerifyFieldSecurity: function (component, event, helper, profileName, sectionName) {
        return new Promise((resolve, reject) => {
            var action = component.get('c.verifyFieldSecurity');
            action.setParams({
                "section": sectionName,
                "userProfile": profileName,
                "accountId": component.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (sectionName == 'RtlCust:Sales Support Information'){
                        component.set('v.isSalseSupportSectionVisible',result);
                    }else if (sectionName == 'RtlCust:MI Benefits'){
                        component.set('v.isMIBenefitSectionVisible',result);
                    }
                    resolve(result)
                } else if(state === 'ERROR') {
                    reject('error')
                } else {
                    console.log('Unknown problem, state.');
                    reject('error')
                }
            });
            $A.enqueueAction(action);
        })
    },
    onMessengerCoverArea : function(component, event, helper){
        var action = component.get('c.getMessengerCoverArea');
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                let MessengerCoverArea = {value : (result ? result : ''), class : (result == 'Cover' ? 'greenColor':'redColor')};
                component.set('v.messengerCoverArea',MessengerCoverArea);
            } else if(state === 'ERROR') {
                console.log('MessengerCoverArea ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
        });
        $A.enqueueAction(action);
    },
    CYCPrepareDataCustomer : function(component, event, helper){
        // Set Loading Status for display
        var response_status = JSON.parse('{"code":"LOAD","description":"Loading","cyc_status":"LOAD"}');
        component.set("v.CYCCampaignMappingInqStatus",response_status);

        var fields = ["TMB_Customer_ID_PE__c","Name","Core_Banking_Suggested_Segment__c"];
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": fields
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var ObjectField = response.getReturnValue();
                helper.CallCYCCampaignMapingInq(component,event,helper,ObjectField,0);
            } else {
                response_status.code = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                component.set("v.CYCCampaignMappingInqStatus",response_status);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    CallCYCCampaignMapingInq : function(component,event,helper,ObjectField,round){
        var numOfRetryTime = component.get('v.numberOfRetry');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        // ObjectField for Test 
        //ObjectField.TMB_Customer_ID_PE__c.value = "001100000000000000000007189785";
        var recordId = component.get('v.recordId');
        var tmbCustomer_id = ObjectField.TMB_Customer_ID_PE__c.value;
        var accountSegment = ObjectField.Core_Banking_Suggested_Segment__c.value;
        var action = component.get('c.CallCYCCampaignMappingInqAPI');
        //var bodyParam = '{"rmid":"'+ObjectField+'"}';
        var bodyParam = '{"rmid":"'+tmbCustomer_id+'"}';
        var servieLogObject = '{"customerName":"'+ObjectField.Name.value+'","rmId":"'+tmbCustomer_id+'","accId":"'+recordId+'","accSegment":"'+accountSegment+'"}';
        var response_status = JSON.parse('{"code":"XXXX","description":"-","cyc_status":"XXXX"}');
        var response_value = JSON.parse('{"customer_id":"'+tmbCustomer_id+'","promotion_condition":""}');
        
        action.setParams({
            "NameCredentail" : "CYC_CAMPAIGN_MAPPING_INQ",
            "headerParam" : "",
            "bodyParam" :  bodyParam,
            "OnlineServiceLog" : servieLogObject
        });
        action.setCallback(this, function(response){
            var statusCodeSuccess = ["0000","4001"];
            var state = response.getState();
            var returnValue = response.getReturnValue();
            var max_committee_price = 0.00;
            var tmp_committee_price = 0.00;
            var campaign_date_str = "";
            var current_date = new Date();
            var campaign_date;
            var date_ofmaxcomittee_price = new Date(9999,11,31); // set Max date
            var strInitialDate = "01011970";
            var checkNewLine = /\^/g;

            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DCCAQ0999F1245319023","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042022","contract_period":"72","car_product_group":"NEW CAR","car_register_no":"","car_year":"2017","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"Navara","car_type":"นั่งสองตอนท้ายบรรทุก","committee_price":"580000.00","normal_price":"580000.00","installment_amount":"10700.00","remaining_installment_month":"46","offer_installment_amount":"15000.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"LINE1 580000.00^LINE2 580000.00^LINE3^^LINE4^LINE5^LINE6^LINE7^LINE8^LINE9^LINE10^LINE11^LINE12^LINE13^","remark":"","promotion_condition":"LINE1 580000.00^LINE2 580000.00^LINE3^^LINE4^LINE5^LINE6^LINE7^LINE8^LINE9^LINE10^LINE11^LINE12^LINE13^","lead_owner":"272","owner_type":"BRANCH"}]}');
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}');
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1^TestLINE^Line^Line^","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}');

            response_status = (returnValue!=undefined && returnValue.status!=undefined)? returnValue.status :  response_status;
            if( component.isValid() && state == "SUCCESS"){
                if(returnValue.description == 'Unauthorized' && round < numOfRetryTime){   
                    round += 1;
                    response_value.promotion_condition = 'Error getting data, retrying... ('+round+')';
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.CallCYCCampaignMapingInq(component,event,helper,ObjectField,round);
                        }), retrySetTimeOut
                    );
                }else if( returnValue != undefined && returnValue.status != undefined && returnValue.status.code != undefined && statusCodeSuccess.indexOf(returnValue.status.code) >=0 ){
                    response_status.cyc_status = "SUCCESS";
                    if( returnValue.cyc_campaign_mapping_list != undefined){
                        returnValue.cyc_campaign_mapping_list.forEach((element,index,array)=>{
                            tmp_committee_price = element.committee_price == undefined && isNaN( element.committee_price )? 0 : parseFloat(element.committee_price);
                            campaign_date_str = element.campaign_expiry_date == undefined && element.campaign_date.length != 8 ? strInitialDate : element.campaign_expiry_date;
                            campaign_date = new Date(parseInt(campaign_date_str.substr(4,4)),parseInt(campaign_date_str.substr(2,2))-1,parseInt(campaign_date_str.substr(0,2)));
                            current_date.setHours(0,0,0,0);   // Set time equal for same type comparison
                            campaign_date.setHours(0,0,0,0);  // Set time equal for same type comparison
                            //console.log(campaign_date + " :  price : "+tmp_committee_price+" : current max : "+max_committee_price);
                            if( element.customer_id == tmbCustomer_id ){  // Check TMB Customer Id
                                if( max_committee_price <= tmp_committee_price  && current_date <= campaign_date ){   // Check Commitee Price and Campaign Date 
                                    
                                    if( max_committee_price < tmp_committee_price){
                                        max_committee_price = tmp_committee_price;
                                        date_ofmaxcomittee_price = campaign_date;
                                        // Change Character ^ to newline
                                        element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):""; 
                                        response_value = element;    
                                    }else if( max_committee_price == tmp_committee_price){
                                        if( date_ofmaxcomittee_price >= campaign_date){
                                            max_committee_price = tmp_committee_price;
                                            date_ofmaxcomittee_price = campaign_date;
                                            // Change Character ^ to newline
                                            element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                 
                                            response_value = element;                                                    
                                        }// else campaign_date > current max not update

                                    } // else max_commitee_price > tmp_committee_price ( using old data )

                                }
                            }
                        });
                    }
                    component.set('v.isCYCSuccess',true);
                    helper.checkIsRender(component,helper);
                }else{ // Error from API
                    response_status.cyc_status == "API_EXECPTION";
                    component.set("v.isCYCSuccess",true);
                    helper.checkIsRender(component,helper);
                    // else there are other status code return response_status will send originally to component
                }
            }else{
                response_status.code = "ERROR";
                response_status.cyc_status = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                component.set("v.isCYCSuccess",true);
                helper.checkIsRender(component,helper);
            }
            component.set("v.CYCCampaignMappingInqStatus",response_status);
            component.set("v.CYCCampaignMappingInq",response_value);
        });
        $A.enqueueAction(action);
    },
    checkIsRender: function(component,helper){
        var is07Success = component.get('v.is07Success');
        var isCYCSuccess = component.get('v.isCYCSuccess');
        if(is07Success && isCYCSuccess){
            helper.stopSpinner(component);
        }
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
})