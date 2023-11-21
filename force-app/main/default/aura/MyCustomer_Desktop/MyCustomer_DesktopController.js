({
    init : function(component, event, helper) {
        component.set('v.openSpinnerTable',true);
        let columns = [
            {label: $A.get('$Label.c.Select_customer'), fieldName: 'candidate',type: 'text'},
            {label: $A.get('$Label.c.tmb_cust_id'), fieldName: 'tmb_cust_id',type: 'text'},
            {label: $A.get('$Label.c.Name_My_Customer'), fieldName: 'name',type: 'text', sortBy: 'name'},
            {label: $A.get('$Label.c.Relationship_Level'), fieldName: 'relationship',type: 'text'},
            {label: $A.get('$Label.c.Moment_Trigger'), fieldName: 'moment_trigger',type: 'text'},
            {label: $A.get('$Label.c.Regulation_Trigger'), fieldName: 'regulartion_trigger',type: 'text'},
            {label: $A.get('$Label.c.Product_Trigger'), fieldName: 'product_trigger',type: 'text'},
            {label: $A.get('$Label.c.Portfolio_Trigger'), fieldName: 'portfolio_trigger',type: 'text'},
            {label: $A.get('$Label.c.Campaign_Trigger'), fieldName: 'campaign_trigger',type: 'text'},
            {label: $A.get('$Label.c.AUM_OS'), fieldName: 'aum_is',type: 'text', sortBy: 'aum_is_double'},
            {label: $A.get('$Label.c.DP_OS'), fieldName: 'dp_op',type: 'text', sortBy: 'dp_op_double'},
            {label: $A.get('$Label.c.MF_OS'), fieldName: 'mf_os',type: 'text', sortBy: 'mf_os_double'},
            {label: $A.get('$Label.c.Select_Date_Time'), fieldName: 'last_selected_date',type: 'text', sortBy: 'last_selected_date_value'},
            {label: $A.get('$Label.c.AGE'), fieldName: 'age',type: 'text'},
            {label: $A.get('$Label.c.AGE_Range'), fieldName: 'age_range',type: 'text'},
            {label: $A.get('$Label.c.Cust_Sub_Segment'), fieldName: 'cust_sub_segment',type: 'text'},
            {label: $A.get('$Label.c.SUIT_SCORE_FIN'), fieldName: 'suit_score',type: 'text'},
            {label: $A.get('$Label.c.WEALTH_FLAG'), fieldName: 'wealth_flag',type: 'text'},
            {label: $A.get('$Label.c.Employer_Flag'), fieldName: 'shareholder_flag',type: 'text'},
            {label: $A.get('$Label.c.MOU_payroll_flag'), fieldName: 'mou_payroll_flag',type: 'text'},
            {label: $A.get('$Label.c.Debenture'), fieldName: 'debenture_flag',type: 'text'},
            {label: $A.get('$Label.c.Last_Activity'), fieldName: 'last_activity',type: 'text'},
            {label: $A.get('$Label.c.Last_Activity_Date'), fieldName: 'last_activity_dateTime',type: 'text', sortBy: 'last_activity_dateTime_value'},
            {label: $A.get('$Label.c.AUM_Range'), fieldName: 'aum_range',type: 'text'},
            {label: $A.get('$Label.c.AllFree_OS'), fieldName: 'allFree_os',type: 'text', sortBy: 'allFree_os_double'},
            {label: $A.get('$Label.c.NFX_OS'), fieldName: 'nfx_os',type: 'text', sortBy: 'nfx_os_double'},
            {label: $A.get('$Label.c.TD_OS'), fieldName: 'td_os',type: 'text', sortBy: 'td_os_double'},
            {label: $A.get('$Label.c.other_dp_os'), fieldName: 'other_deposit_os',type: 'text', sortBy: 'other_deposit_os_double'},
            {label: $A.get('$Label.c.mf_gain_loss'), fieldName: 'mfGainLoss',type: 'text', sortBy: 'mfGainLoss_double'},
            {label: $A.get('$Label.c.nfx_rate'), fieldName: 'nfx_rate',type: 'text'},
            {label: $A.get('$Label.c.total_maturity_this_month'), fieldName: 'all_matur_this_month',type: 'text'},
            {label: $A.get('$Label.c.td_maturity_this_month'), fieldName: 'deposit_matur_this_month',type: 'text'},
            {label: $A.get('$Label.c.term_fund_maturity_this_month'), fieldName: 'mf_matur_this_month',type: 'text'},
            {label: $A.get('$Label.c.ba_ape_this_month'), fieldName: 'insurnace_anni_this_month',type: 'text'},
            {label: $A.get('$Label.c.Debenture_this_month'), fieldName: 'deb_matur_this_month',type: 'text'},
            {label: $A.get('$Label.c.total_maturity_next_month'), fieldName: 'all_matur_next_month',type: 'text'},
            {label: $A.get('$Label.c.TD_next_month'), fieldName: 'deposit_matur_next_month',type: 'text'},
            {label: $A.get('$Label.c.Mutual_FUND_next_month'), fieldName: 'mf_matur_next_month',type: 'text'},
            {label: $A.get('$Label.c.ba_ape_next_month'), fieldName: 'insurnace_anni_next_month',type: 'text'},
            {label: $A.get('$Label.c.Debentured_next_month'), fieldName: 'deb_matur_next_month',type: 'text'},
            {label: $A.get('$Label.c.CC_Reserve_Eligible'), fieldName: 'cc_reserve_eligible',type: 'text', sortBy: 'cc_ttb_reserve_invitation_value'},
            {label: $A.get('$Label.c.CC_RESERVE_POINT'), fieldName: 'cc_reserve_point',type: 'text'},
            {label: $A.get('$Label.c.CC_RESERVE_ANUAL_POINT'), fieldName: 'cc_reserve_annual_point',type: 'text'},
            {label: $A.get('$Label.c.CC_Other_POINT_BALANCE'), fieldName: 'cc_other_point_balance',type: 'text'},
        ];

        component.set('v.columns',columns);
        helper.setSortColumnObject(component, event, helper);
        helper.getCurrentUserName(component, event, helper);
        helper.getTaskFieldLabel(component, event, helper);
        helper.fetchDataTable(component, event, helper);
    },
    onOpenCSV : function(component, event, helper) {
        let currentTarget = event.currentTarget.dataset.id ;
        var workspaceAPI = component.find("workspace");
                
        workspaceAPI.openTab({
            url: '#/sObject/'+ currentTarget +'/view'
        });
    },
    navigateTab : function(component, event, helper) {
        let currentTarget = event.currentTarget.dataset.id ;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": currentTarget,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    onSearchData : function(component, event, helper) {
        component.set('v.openSpinnerTable',true);
        helper.getDataFilter(component, event, helper);
        component.set('v.countSelectCust',0)
    },

    sortingData : function(component, event, helper) {
        helper.showSpinner(component);
        let accList = component.get('v.dataRow');
        let selectField = event.currentTarget.dataset.sort;
        const columnMap = component.get('v.sortColumnObject');
        setTimeout(() => {
            if(columnMap[selectField].icon == component.get('v.arrowAt')){
                helper.reversData(accList)
                .then(function(data){
                    component.set('v.dataRow', data);
                    helper.resetIcons(component, selectField);
                    helper.hideSpinner(component);
                });
            }
            else{
                helper.prepForSortingDataRow(component, event, helper, accList, selectField)
                .then(function(data){
                    component.set('v.dataRow', data);
                    helper.resetIcons(component, selectField);
                    helper.hideSpinner(component);
                });
            }
        }, 200);
    },

    onUpdateDataFromViewMore : function(component, event, helper) {
        helper.updateDataRow(component, event, helper);
    },
    onOpenModalViewMore : function(component, event, helper) {
        component.set('v.openViewMore',true);
    },
    onOpenCreateTask : function(component, event, helper) {
        let countSelectCust = component.get('v.countSelectCust');
        if (countSelectCust > parseInt($A.get('$Label.c.Max_Select_Customer'))){
            helper.displayToast('error', $A.get('$Label.c.warnning_for_maxSelectCustomer'));
        }
        else if (countSelectCust == 0){
            helper.displayToast('error',$A.get('$Label.c.warnning_for_noneSelectCustomer'));
        }
        else if (countSelectCust <= parseInt($A.get('$Label.c.Max_Select_Customer')) && countSelectCust != 0){
            let data = component.get('v.dataRow');
            let dataSelectCust = [];
            for(const e of data){
                if (e.candidate == true){
                    let duedate = new Date(Date.now() + (parseInt(component.get('v.Task_Activity_Days'))*(3600 * 1000 * 24)));
                    let monthThai = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.']
                    let dataCreateTask = {
                                            name: e.name, 
                                            Customer_Id: e.id, 
                                            priority: component.get('v.Task_Priority'), 
                                            subject: component.get('v.Task_Subject'), 
                                            duedate: (duedate.getDate())+' '+monthThai[duedate.getMonth()] + ' ' + (duedate.getFullYear()+543)
                                        };
                    dataSelectCust.push(dataCreateTask);
                }
            }
            component.set('v.dataSelectCust',dataSelectCust);
            component.set('v.openViewMore',false);
            component.set('v.openCreateTask',true);
        }
    },
    onConfirmCreateTask : function(component, event, helper) {
        component.set('v.openCreateTask',false);
        component.set('v.openSpinner',true);
        helper.createTaskforSelectedAccount(component, event, helper);
    },
    onCloseModal : function(component, event, helper) {
        component.set('v.dataRow',component.get('v.dataRow'));
        component.set('v.openViewMore',false);
        component.set('v.openCreateTask',false);
    },
    onCloseResultCreateTask : function(component, event, helper) {
        helper.showSpinner(component);
        helper.callParentMethod(component, event, helper);
        component.set('v.openCreateTaskResult',false);
        component.set('v.dataSelectCust',{});
        component.set('v.countSelectCust',0);
        helper.fetchDataTable(component, event, helper);
        // $A.get('e.force:refreshView').fire();
    },
    onExportExcelData : function(component, event, helper) {
        helper.exportExcelData(component, event, helper);
    },

})