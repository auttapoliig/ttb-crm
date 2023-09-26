({
    displayToast : function(component ,helper, title, type, message) {
	    var toastEvent = $A.get('e.force:showToast');
	    toastEvent.setParams({
            title: title,
	        type: type,
	        message: message,
            duration: 5000
	    });
	    toastEvent.fire();
    },

    getTask : function(component, event, helper) {
        component.set('v.loaded',true);
        var currentUser = component.get('v.currentUser');
        console.log('User',currentUser);
        var action = component.get('c.searchExistingCallback');
            action.setParams({
                recordId: component.get('v.recordId')
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    if(response.getReturnValue().Call_Log_ID__c ){
                        var task = response.getReturnValue();                  
                        var user_language;
                        // console.log('currentUser:',currentUser);
                        console.log('task:',task);
                        if(currentUser != null)
                        {
                            user_language = currentUser.LanguageLocaleKey;
                            // console.log('user_language:',user_language);
                            component.set('v.original_task', task);
                            component.set('v.task', task);

                            component.set('v.reschedule', true);
                            component.set('v.isExpanded',true);       
                            // console.log('task:',task);
                            
                            helper.setDateTime(component, event, helper, task , user_language);

                            component.set('v.callback_number',task.Call_Number__c);
                            component.set('v.callback_description',task.Description);
                            if(task.Call_Back_Mode__c)
                            {
                                component.set('v.callback_mode',task.Call_Back_Mode__c);
                            }
                            else
                            {
                                component.set('v.callback_mode','Strict Agent');
                            }

                            // console.log('callback_time_label:',component.get('v.callback_time_label'));
                            // console.log('callback_date_label:',component.get('v.callback_date_label'));

                            component.set('v.loaded',false);
                        }  
                    
                    }
                    else{
                        helper.checkExistingLogCall(component, event, helper)
                        component.set('v.reschedule', false);
                        component.set('v.loaded',false);
                    }
                    helper.setTaskLogId(component, event, helper);
                    var task = component.get('v.task');
                    console.log('ExistingCallBackTask',task);
                    if(task == null){
                        component.set('v.isNull',true);
                    }
                }
            
            })
            $A.enqueueAction(action);
            
    },

    setDateTime : function(component, event, helper, task, user_language) {
        var datetime = new Date(task.Call_Start_Datetime__c);

        var optionsDate = {
            year: 'numeric', month: 'short', day: 'numeric'
        };
        var optionsTime = { hour: '2-digit', minute: '2-digit' };

        if(user_language == 'th')
        {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));               
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));     

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH',optionsTime)+' น.');                                     
            component.set('v.callback_date_label', datetime.toLocaleString('th-TH', optionsDate));
        }
        else if(user_language == 'en_US')
        {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));               
            // component.set('v.callback_time', datetime.toLocaleTimeString('en-US'));     

            // component.set('v.callback_time_label', datetime.toLocaleTimeString('en-US',optionsTime));                                     
            // component.set('v.callback_date_label', datetime.toLocaleString('en-US', optionsDate));
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));     

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH',optionsTime));                                     
            component.set('v.callback_date_label', datetime.toLocaleString('en-US', optionsDate));
        }
        else if(user_language == 'en_GB')
        {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));               
            // component.set('v.callback_time', datetime.toLocaleTimeString('en-GB'));     

            // component.set('v.callback_time_label', datetime.toLocaleTimeString('en-GB',optionsTime));                                     
            // component.set('v.callback_date_label', datetime.toLocaleString('en-GB', optionsDate));
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));     

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH',optionsTime));                                     
            component.set('v.callback_date_label', datetime.toLocaleString('en-GB', optionsDate));
        }
    },
    
    scheduleCallback : function(component, event, helper) {
        var onQuickAction = component.get('v.onQuickAction');
        var allValid;
        if(onQuickAction)
        {
            allValid = component.find('callbackForm').reduce(function(validSoFar, inputCmp){
                inputCmp.reportValidity();
                //component.set('v.loaded',false);
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(allValid)
            {
                allValid = helper.validateDateTime(component, event, helper);
            }
        }
        else
        {
            allValid = true;
        }
      
        // console.log('Sc allValid:',allValid);
        if(allValid){
            let callback_datetime = helper.transformDatetimeUnix(
                component.get('v.callback_date'),
                component.get('v.callback_time')
            );
            let action = component.get('c.insertTask');
            action.setParams({
                "recordId": component.get('v.recordId'),
                "values":{
                    "datetime": callback_datetime,
                    "date" : component.get('v.callback_date'),
                    "number": component.get('v.callback_number'),
                    "note": component.get('v.callback_description'),
                    "mode": component.get('v.callback_mode'),
                    "callLogID":component.get('v.callLogID'),
                    "agentId": component.get('v.agentId'),
                    "contactListName":component.get('v.contactListName'),
                    "campaignName":component.get('v.campaignName'),
                    "sfId":component.get('v.salesForceId')
                },
                "marketingCode" :  component.get('v.marketingCode'),
                "businessName": 'Commercial SME RMC'
            });
            action.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    let returnValue = response.getReturnValue();
                    //console.log('insertTask',task_id);
                    if(returnValue.errorMsg != null && returnValue.errorMsg != '')
                    {
                        helper.displayToast(component ,helper, 'Error', 'error', returnValue.errorMsg);
                        helper.closeQuickActionWindow(component, event, helper);
                    }
                    else
                    {
                        helper.displayToast(component ,helper, 'Success', 'success', 'Save Call Back Success');
                        //helper.calloutCallback(component, event, helper, callback_datetime, task_id);
                        $A.get('e.force:refreshView').fire();
                        helper.closeQuickActionWindow(component, event, helper);
                    }
                }
                else {
                    let error = response.getError();
                    helper.handleErrors(error);
                    component.set('v.loaded',false);
                }
            });

            $A.enqueueAction(action);
        }else{
            component.set('v.loaded',false);
        }
    },
    transformDatetimeUnix : function (date, time){
        return Date.parse(date + ' ' + time);
    },
    transformDateToInput: function(date){
        var date_comp = date.split('/');
        date_comp = date_comp.reverse();
        return date_comp.join('/');
    },

    transformDateToInput2: function(date){
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    },
    // calloutCallback : function(component, event, helper, dt, task_id){
    //     // component.set('v.agentId', res.AVY_Agent_id__c);
    //     // component.set('v.contactListName', res.AVY_Contact_List_Name__c);
    //     // component.set('v.campaignName', res.AVY_Campaign_Name__c);
    //     let action = component.get('c.scheduleCallback');
    //     action.setParams({
    //         "values":{
    //             "datetime": dt,
    //             "number": component.get('v.callback_number'),
    //             "note": component.get('v.callback_description'),
    //             "mode": component.get('v.callback_mode'),
    //             "task_id": task_id,
    //             "agentId": component.get('v.agentId'),
    //             "contactListName":component.get('v.contactListName'),
    //             "campaignName":component.get('v.campaignName'),
    //             "sfId":component.get('v.salesForceId'),

    //         }
    //     })
    //     action.setCallback(this, function(response){
    //         let state = response.getState();
    //         if(state === 'SUCCESS'){
    //             console.log('schedule success');
    //             //helper.displayToast(component ,helper, 'Success', 'success', 'Schedule Callback Success');
    //         }
    //         else{
    //             console.log('schedule failed');
    //             // let error = response.getError();
    //             helper.handleErrors(error);
    //         }

    //     })

    //     $A.enqueueAction(action);
    // },
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toastดrescheduleCallback
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    rescheduleCallback : function(component, event, helper){
        var onQuickAction = component.get('v.onQuickAction');
        var allValid;
        if(onQuickAction)
        {
            allValid = component.find('callbackForm').reduce(function(validSoFar, inputCmp){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(allValid)
            {
                allValid = helper.validateDateTime(component, event, helper);
            }
        }
        else
        {
            allValid = true;
        }
        if(allValid){
            let callback_datetime = helper.transformDatetimeUnix(
                helper.transformDateToInput(component.get('v.callback_date')),
                component.get('v.callback_time')
            );
            // console.log('original_task:',component.get('v.original_task'));
            var action = component.get('c.rescheduleCallback');
            action.setParams({
                "values":{
                    "sfId" : component.get('v.recordId'),
                    "task_id": component.get('v.original_task').Id,
                    "callback_id": component.get('v.original_task').Call_Log_ID__c,
                    // "recordId": component.get('v.recordId'),
                    "datetime": callback_datetime,
                    "number": component.get('v.callback_number'),
                    "note": component.get('v.callback_description'),
                    "mode": component.get('v.callback_mode'),
                    "contactListName" : component.get('v.contactListName'),
                    "campaignName" : component.get('v.campaignName'),
                    "agentId"  :component.get('v.agentId')
                },
                "businessName": 'Commercial SME RMC'
            })
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    //let task_id = component.get('v.original_task').Id;
                    //console.log('ExistingCallBackID',task_id);
                    helper.displayToast(component ,helper, 'Success', 'success', 'Save Call Back Success');
                    //helper.calloutCallback(component, event, helper, callback_datetime, task_id);
                    $A.get('e.force:refreshView').fire();
                    helper.closeQuickActionWindow(component, event, helper);
                }
                else {
                    let error = response.getError();
                    helper.handleErrors(error);
                    component.set('v.loaded',false);
                }

            })

            
            $A.enqueueAction(action)
            
        }else{
            component.set('v.loaded',false);
        }

    },
    closeQuickActionWindow : function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    validateDateTime: function(component, event, helper)
    {
        var onQuickAction = component.get('v.onQuickAction');
        var allValid = true;
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }

        // console.log('Date:',component.find('callbackForm')[0].get('v.label'));
        // console.log('Date:',component.find('callbackForm')[1].get('v.label'));
        // console.log('Time:',component.find('callbackForm')[2].get('v.label'));
        // console.log('Date:',component.find('callbackForm')[3].get('v.label'));
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        var nowTime = today.getHours()*60+today.getMinutes();

        var selectedYear;
        var selectedMonth;
        var selectedDay;
        var selectedHour;
        var selectedMinute;
        var selectedDateTime;
        var selectedTime;

        if(onQuickAction)
        {
            selectedYear = component.find('callbackForm')[0].get('v.value').split('-')[0];
            selectedMonth = component.find('callbackForm')[0].get('v.value').split('-')[1];
            selectedDay = component.find('callbackForm')[0].get('v.value').split('-')[2];
            selectedHour = component.find('callbackForm')[1].get('v.value').split(':')[0];
            selectedMinute = component.find('callbackForm')[1].get('v.value').split(':')[1];
            selectedDateTime = new Date(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
            selectedTime = selectedDateTime.getHours()*60+selectedDateTime.getMinutes();

            if(component.find('callbackForm')[0].get('v.value') != '')
            {
                if(component.find('callbackForm')[0].get('v.value') < todayFormattedDate)
                {
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    helper.displayToast(component ,helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                }

                if(component.find('callbackForm')[0].get('v.value') <= todayFormattedDate && component.find('callbackForm')[1].get('v.value') != ''
                    && selectedTime <= nowTime)
                {
                    helper.displayToast(component ,helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    $A.util.addClass(component.find('callbackForm')[1], "slds-has-error");
                }
                
            }  
        }
        else
        {
            selectedYear = component.find('callbackForm')[0].get('v.value').split('-')[0];
            selectedMonth = component.find('callbackForm')[0].get('v.value').split('-')[1];
            selectedDay = component.find('callbackForm')[0].get('v.value').split('-')[2];
            selectedHour = component.find('callbackForm')[2].get('v.value').split(':')[0];
            selectedMinute = component.find('callbackForm')[2].get('v.value').split(':')[1];
            selectedDateTime = new Date(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
            selectedTime = selectedDateTime.getHours()*60+selectedDateTime.getMinutes();            
            // console.log('currentDate:',todayFormattedDate);
            // console.log('currentTime:',nowTime);
            // console.log('selectedDateTime:',selectedDateTime.getHours()*60+selectedDateTime.getMinutes());
            // console.log('Date:',component.find('callbackForm')[0].get('v.value'));
            // console.log('Time:',component.find('callbackForm')[2].get('v.value'));

            if(component.find('callbackForm')[0].get('v.value') != '')
            {
                if(component.find('callbackForm')[0].get('v.value') < todayFormattedDate)
                {
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    helper.displayToast(component ,helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                }

                if(component.find('callbackForm')[0].get('v.value') <= todayFormattedDate && component.find('callbackForm')[2].get('v.value') != ''
                    && selectedTime <= nowTime)
                {
                    helper.displayToast(component ,helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    $A.util.addClass(component.find('callbackForm')[2], "slds-has-error");
                }
                
            }  
        }  
        return allValid;  
    },

    getCurrentUser: function(component,event,helper){
        var action = component.get('c.getCurrentUser');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                // console.log('currentUser:',result); 
                component.set('v.currentUser',result);  
                helper.getTask(component, event, helper);             
            }         
        });
        
        $A.enqueueAction(action);
    },
    
   //check start call and end call
   checkExistingLogCall : function(component, event, helper) {
        var action = component.get('c.searchExistingLogCall');
            action.setParams({
                recordId: component.get('v.recordId')
            });

            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var result = response.getReturnValue();
                    console.log('ExistingLogCall',result);
                    if(result.Call_Start_Datetime__c != null && result.Call_Start_Datetime__c != ''){
                        if(result.Call_End_Time__c != null && result.Call_End_Time__c != '' ){
                            // this.displayToast(component ,helper,'Error','error', 'Cannot create callback');
                            // this.closeQuickActionWindow(component, event, helper);
                        }
                        component.set('v.callLogID',result.Call_Log_ID__c)
                    }else{
                        this.displayToast(component ,helper,'Error','error', 'Cannot create callback');
                        this.closeQuickActionWindow(component, event, helper);
                        
                    }
                }else {
                    let error = response.getError();
                    this.handleErrors(error);
                }
            
            })
            $A.enqueueAction(action);
    },

    setTaskLogId : function(component, event, helper) {
        //component.set('v.loaded',true);
        var action = component.get('c.searchExistingLogCall');
            action.setParams({
                recordId: component.get('v.recordId')
            });

            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var result = response.getReturnValue();
                    console.log('setTaskLogId',result);
                    component.set('v.taskLogId',result.Id);         
                    helper.setTaskExtension(component, event, helper);
                    helper.setSalesforceId(component, event, helper);
                }else {
                    let error = response.getError();
                    this.handleErrors(error);
                }
            
            })
            $A.enqueueAction(action);
    },
    setTaskExtension : function(component, event, helper) {     
        console.log('taskLogId',component.get('v.taskLogId'));
        var action = component.get('c.getTaskExtension');
            action.setParams({
                taskId: component.get('v.taskLogId')    
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var res =response.getReturnValue();
                    console.log('TaskExtensionLogCall',res);
                    component.set('v.agentId', res.AVY_Agent_id__c);
                    component.set('v.contactListName', res.AVY_Contact_List_Name__c);
                    component.set('v.campaignName', res.AVY_Campaign_Name__c);
                    component.set('v.loaded',false);

                }else {
                    let error = response.getError();
                    this.handleErrors(error);
                    component.set('v.loaded',false);
                }
            
            })
            $A.enqueueAction(action);
            
    },

    setSalesforceId : function(component, event, helper) {
        // component.set('v.loaded',true);
        var action = component.get('c.getSalesforceId');
            action.setParams({
                recordId: component.get('v.recordId')   
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var res =response.getReturnValue();
                    console.log('userContactID',res);
                    component.set('v.salesForceId', res);
                }else {
                    let error = response.getError();
                    this.handleErrors(error);
                    component.set('v.loaded',false);
                }
            
            })
            $A.enqueueAction(action);
            
    },
})