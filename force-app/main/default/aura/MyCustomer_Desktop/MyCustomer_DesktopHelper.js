({
    fetchDataTable : function(component, event, helper){
        helper.getDataFilter(component, event, helper);
        let taskForConfirm = component.get('c.getTaskCustomSetting');
        taskForConfirm.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let result = response.getReturnValue();
                component.set('v.Task_Activity_Days',result.RMC_My_Customer_Task_Activity_Days);
                component.set('v.Task_Priority',result.RMC_My_Customer_Task_Priority);
                component.set('v.Task_Subject',result.RMC_My_Customer_Task_Subject);
            }
            else if (state === "ERROR") {
                var errors = getCustomerData.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                        component.set('v.disableButtonSearch',false);
                    }
                }
                helper.hideSpinner(component);
            } else {
                console.error(response);
                helper.hideSpinner(component);
            }
        })
        $A.enqueueAction(taskForConfirm);
    },

    getTaskFieldLabel : function(component, event, helper){

        let action = component.get('c.getFieldLabelTaskMap');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let result = response.getReturnValue();
                component.set('v.taskFieldLabelMap', result);
            }
            else if (state === "ERROR") {
                var errors = getCustomerData.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                        component.set('v.disableButtonSearch',false);
                    }
                }
                helper.hideSpinner(component);
            } else {
                console.error(response);
                helper.hideSpinner(component);
            }
        })
        $A.enqueueAction(action);
    },

    updateDataRow : function(component, event, helper){
        /* update data row between main table and viewmore */
        let data = component.get('v.dataRow');
        let countSelectCust = 0;
        data.forEach((e) => {
            countSelectCust += e.candidate == true ? 1 : 0;
        });
        if(countSelectCust > parseInt($A.get('$Label.c.Max_Select_Customer'))){
            helper.displayToast('warning', $A.get('$Label.c.warnning_for_maxSelectCustomer'));
            component.set('v.countSelectCustWarning',true);
        }
        else{
            component.set('v.countSelectCustWarning',false);
        }
        component.set('v.countSelectCust',countSelectCust);
    },
    getDataFilter : function(component, event, helper){
        /* function filter data */
        helper.resetIcons(component, 'name');
        component.set('v.iconsNameSort','utility:arrowdown');
        component.set('v.disableButtonSearch',true);
        let getCustomerData = component.get('c.getCustomerTableData');
        let filter = component.get("v.valueFilter");
        getCustomerData.setParams({
            "params": filter
        });
        getCustomerData.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let result = response.getReturnValue();
                for (let e of result){
                    e.last_selected_date_value = !e['last_selected_date_value'] ? 0 : Date.parse(e['last_selected_date_value']);
                    e.last_activity_dateTime_value = !e['last_activity_dateTime_value'] ? 0 : Date.parse(e['last_activity_dateTime_value']);
                }
                let sortedList = helper.sortThaiString(component, event, helper, result);
                component.set('v.isNameSort', true);
                component.set('v.dataRow',sortedList);
                component.set('v.disableButtonSearch',false);
                helper.hideSpinner(component);
            }
            else if (state === "ERROR") {
                var errors = getCustomerData.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                        component.set('v.disableButtonSearch',false);
                    }
                }
                helper.hideSpinner(component);
            } else {
                console.error(response);
                helper.hideSpinner(component);
            }
        })
        $A.enqueueAction(getCustomerData);
    },
    createTaskforSelectedAccount : function(component, event, helper){
        /* function createTask */
        let getDataCreateTaskResult = component.get('c.createTaskForSelectedAccount');
        let dataCreateTask = component.get('v.dataSelectCust');
        let dataforGetResult = [];
        let countSuccess = 0;
        for (const e of dataCreateTask){
            dataforGetResult.push(e.Customer_Id);
        }
        getDataCreateTaskResult.setParams({
            "accIdList" : dataforGetResult
        });
        getDataCreateTaskResult.setCallback(this, function (response){
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let result = response.getReturnValue();
                for(const i of result){
                    for (const n of dataCreateTask){
                        if (i.Customer_Id == n.Customer_Id){
                            i.name = n.name;
                            if (i.IsSuccess == 'true'){
                                countSuccess += 1
                            }
                        }
                    }
                }

                component.set('v.countSuccess',countSuccess);
                component.set('v.dataSelectCust',result);
                component.set('v.openSpinner',false);
                component.set('v.openCreateTaskResult',true);
            }
            else if (state === "ERROR") {
                var errors = getCustomerData.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                        component.set('v.disableButtonSearch',false);
                    }
                }
                helper.hideSpinner(component);
            } else {
                console.error(response);
                helper.hideSpinner(component);
            }
        })
        $A.enqueueAction(getDataCreateTaskResult);
    },
    displayToast : function(type,message){
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'dismissible',
                title: type.toUpperCase(),
                message: message,
                type: type,
                duration: 3000,
            });
            toastEvent.fire();
    },
    exportExcelData : function(component, event, helper){
        const d = new Date().toLocaleDateString();
        const t = new Date().toLocaleTimeString();
        let filter = component.get("v.valueFilter");
        const columns = component.get('v.columns');
        let stockData = component.get("v.dataRow");
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        columns.forEach(element => {  
            if(element.label != $A.get('$Label.c.Select_customer')){
                doc += '<th>'+ element.label +'</th>'           
            }          
        });
        doc += '</tr>';
        // Add the data rows
        stockData.forEach(record => {
            doc += '<tr>';
            // doc += '<td>'+record.candidate+'</td>'; 
            doc += '<td>'+`'${record.tmb_cust_id}`+'</td>'; 
            doc += '<td>'+record.name+'</td>'; 
            doc += '<td>'+record.relationship+'</td>';
            doc += '<td>'+record.moment_trigger+'</td>'; 
            doc += '<td>'+record.regulartion_trigger+'</td>'; 
            doc += '<td>'+record.product_trigger+'</td>'; 
            doc += '<td>'+record.portfolio_trigger+'</td>'; 
            doc += '<td>'+record.campaign_trigger+'</td>';
            doc += '<td>'+record.aum_is+'</td>'; 
            doc += '<td>'+record.dp_op+'</td>'; 
            doc += '<td>'+record.mf_os+'</td>'; 
            doc += '<td>'+record.last_selected_date+'</td>'; 
            doc += '<td>'+record.age+'</td>'; 
            doc += '<td>'+record.age_range+'</td>'; 
            doc += '<td>'+record.cust_sub_segment+'</td>'; 
            doc += '<td>'+record.suit_score+'</td>'; 
            doc += '<td>'+record.wealth_flag+'</td>'; 
            doc += '<td>'+record.shareholder_flag+'</td>'; 
            doc += '<td>'+record.mou_payroll_flag+'</td>'; 
            doc += '<td>'+record.debenture_flag+'</td>'; 
            doc += '<td>'+record.last_activity+'</td>'; 
            doc += '<td>'+record.last_activity_dateTime+'</td>';  
            doc += '<td>'+record.aum_range+'</td>'; 
            doc += '<td>'+record.allFree_os+'</td>'; 
            doc += '<td>'+record.nfx_os+'</td>'; 
            doc += '<td>'+record.td_os+'</td>'; 
            doc += '<td>'+record.other_deposit_os+'</td>'; 
            doc += '<td>'+record.mfGainLoss+'</td>'; 
            doc += '<td>'+record.nfx_rate+'</td>'; 
            doc += '<td>'+record.all_matur_this_month+'</td>'; 
            doc += '<td>'+record.deposit_matur_this_month+'</td>';
            doc += '<td>'+record.mf_matur_this_month+'</td>'; 
            doc += '<td>'+record.insurnace_anni_this_month+'</td>'; 
            doc += '<td>'+record.deb_matur_this_month+'</td>'; 
            doc += '<td>'+record.all_matur_next_month+'</td>'; 
            doc += '<td>'+record.deposit_matur_next_month+'</td>'; 
            doc += '<td>'+record.mf_matur_next_month+'</td>'; 
            doc += '<td>'+record.insurnace_anni_next_month+'</td>'; 
            doc += '<td>'+record.deb_matur_next_month+'</td>'; 
            doc += '<td>'+record.cc_reserve_eligible+'</td>'; 
            doc += '<td>'+record.cc_reserve_point+'</td>'; 
            doc += '<td>'+record.cc_reserve_annual_point+'</td>'; 
            doc += '<td>'+record.cc_other_point_balance+'</td>';  
            doc += '</tr>';
        });
        doc += '</table>';
        doc += `<h3> Download by ${component.get('v.userName')} ${d} ${t}</h3>`;
        doc += `<h3> Filter List : </h3>` ;
        doc += '<ul>'
        filter.forEach((e) => {
            doc += `<li> ${e.filterLabel} : ${e.selectedLabel} </li>`;
        });
        doc += '</ul>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = `MyCustomer_${d}_${t}.xls`;
        document.body.appendChild(downloadElement);
        downloadElement.click();
    },
    getCurrentUserName : function(component, event, helper){
        let action = component.get('c.getCurrentUserName');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const result = response.getReturnValue();
                component.set('v.userName', result);
            }
            else if (state === "ERROR") {
                var errors = getCustomerData.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                    }
                }
                helper.hideSpinner(component);
            } else {
                console.error(response);
                helper.hideSpinner(component);
            }
        })
        $A.enqueueAction(action);
    },

    prepForSortingDataRow : function(component, event, helper, accList, selectField){
        return new Promise( $A.getCallback( function( resolve , reject ) {
            try{
                let high = accList.length - 1;
                let low = 0;
                let sortList;
                if(selectField != 'name'){
                    sortList = helper.quickSort(component, event, helper, accList, low, high, selectField);
                }
                else{
                    sortList = helper.sortThaiString(component, event, helper, accList);
                }
                resolve(sortList);
            }catch(e){
                reject(component.get('v.dataRow'));
            }
        }));
    },

    reversData : function(accList){
        return new Promise( $A.getCallback( function( resolve , reject ) {
            try{
                let reversed = accList.reverse();
                resolve(reversed);
            }catch(e){
                reject(accList);
            }
        }));
    },

    quickSort : function(component, event, helper, arr, low, high, selectField){
        if (low < high) {
            let pi = helper.partition(component, event, helper, arr, low, high, selectField);
            arr = helper.quickSort(component, event, helper, arr, low, pi - 1, selectField);
            arr = helper.quickSort(component, event, helper, arr, pi + 1, high, selectField);
        }
        return arr;
    },

    partition : function(component, event, helper, arr, low, high, selectField){
        let currentIndex = arr[high];
        let pivot = currentIndex[selectField];
 
        let i = (low - 1);
 
        for (let j = low; j <= high - 1; j++) {
            let runningJ = arr[j];
            let jOS = runningJ[selectField];
            if (jOS < pivot) {
 
                i++;
                arr = helper.swap(arr, i, j);
            }
        }
        arr =  helper.swap(arr, i + 1, high);
        return (i + 1);
    },

    swap : function(arr, i, j){
        let temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
        return arr;
    },

    sortThaiString : function(component, event, helper, accList){
        const newList = [...accList];
        newList.sort((a, b) => a['name'].localeCompare(b['name'], 'en'));
        return newList
    },

    showSpinner : function(component){
        let openViewMore = component.get('v.openViewMore');
        if (openViewMore == true){
            component.set('v.openSpinnerViewmore',true);
        }else{
            component.set('v.openSpinnerTable', true);
        }
    },
    
    hideSpinner : function(component){
        let openViewMore = component.get('v.openViewMore');
        if (openViewMore == true){
            component.set('v.openSpinnerViewmore',false);
        }else{
            component.set('v.openSpinnerTable', false);
        }
    },

    resetIcons : function(component,selectField){
        const down = 'utility:arrowdown';
        const up = 'utility:arrowup';

        const sortColumnObject = component.get('v.sortColumnObject');
        const focusIcon = sortColumnObject[selectField].icon;
        let allIcon = [];
        for(const key in sortColumnObject){
            allIcon.push(sortColumnObject[key].icon);
        }

        allIcon.forEach((e) => {
            if(e != focusIcon){
                component.set(`v.${e}`, down);
            }
            else{
                component.set(`v.${focusIcon}`, component.get(`v.arrowAt`) == focusIcon && component.get(`v.${focusIcon}`) == down ? up : down);
                component.set(`v.arrowAt`, focusIcon);
            }
        });
    },

    handleError: function(component, event, helper, errorMessage){
        helper.displayToast('error', errorMessage);
    },

    callParentMethod : function(component, event, helper) {
        var parentComponent = component.get("v.parent");                         
		parentComponent.AfterCreateTask(true);
    },

    setSortColumnObject : function(component, event, helper){
        const sortColumnObject = {
            'name' : { icon : 'iconsNameSort', column : 'activeSortName'},
            'aum_is_double' : { icon : 'iconsAUMSort', column : 'activeSortAUM'},
            'dp_op_double' : { icon : 'iconsDPSort', column : 'activeSortDP'},
            'mf_os_double' : { icon : 'iconsMFSort', column : 'activeSortMF'},
            'mfGainLoss_double' : { icon : 'iconsMFGainLossSort', column : 'activeSortMFgainloss'},
            'last_activity_dateTime_value' : { icon : 'iconsLastActivitySort', column : 'activeSortLastActivety'},
            'last_selected_date_value' : { icon : 'iconsLastSelectedSort', column : 'activeSortLastSelect'},
            'cc_ttb_reserve_invitation_value' : { icon : 'iconsReserveInviteSort', column : 'activeSortReserve'},
            'allFree_os_double' : { icon : 'iconsAllFreeSort', column : 'activeSortAllFree'},
            'td_os_double' : { icon : 'iconsTDOSSort', column : 'activeSortTDOS'},
            'nfx_os_double' : { icon : 'iconsNFXOSSort', column : 'activeSortNFXOS'},
            'other_deposit_os_double' : { icon : 'iconsOTHEROSSort', column : 'activeSortOTHEROS'},
        };
        component.set('v.sortColumnObject', sortColumnObject);
    }
})