({
    // init : function(component, event, helper) {
    //     let picklist = [
    //         {label: "H/W/C", option: ['Yes','No']},
    //         {label: "Sub Segment", option: ['Yes','No']},
    //         {label: "Wealth flag", option: ['Yes','No']},
    //         {label: "Age", option: ['Yes','No']},
    //         {label: "AUM Range", option: ['Yes','No']},
    //         {label: "Suitscore", option: ['Yes','No']},
    //         {label: "MF gain/loss", option: ['Yes','No']},
    //         {label: "Bonds flag", option: ['Yes','No']},
    //         {label: "Flag top sharedholder", option: ['Yes','No']},
    //         {label: "payroll flag", option: ['Yes','No']}
    //     ];
    //     component.set("v.itemFilter",picklist);
    // }

    doInit : function(component, event, helper) {
		var filters = component.get("c.getFilters");
        filters.setCallback(this, function(filter) {
            component.set("v.Filters", filter.getReturnValue());
            // console.log(filter.getReturnValue());
        });
        $A.enqueueAction(filters);
        var data = component.get("c.getCustomerTableData");
        data.setCallback(this, function(filter) {
            component.set("v.Data", data.getReturnValue());
        });
        $A.enqueueAction(data);
	},

    /*handleFilterLimit : function(component, event, helper) {
        var numOfFilter = event.target.value;
    },

    limitNumOfFilter : function(component, event, helper) {
        var filters = component.get("c.getFilters");
    },*/
    handleSectionToggle : function(component, event, helper) {
        var openSections = event.getParam('openSections');
        if (openSections.length === 0) {
            component.set('v.openFilter',false);
        }else{
            component.set('v.openFilter',true);
        }
    },
    handleSelectFilter : function(component, event, helper) {
        var selectedIdx = event.target.id.split('_')[2];
        var selectOptionIdx = event.target.value;
        var selectedFilter = component.get("v.Filters")[selectedIdx];

        var selectedOption = selectedFilter.optionList[selectOptionIdx];
        // console.log('selectedOption', selectedOption);
        var selectedFilterList = JSON.parse(JSON.stringify(component.get("v.selectedFilter")));
        
        var selectedFilterIdx = selectedFilterList.findIndex((obj) => obj.filterId == selectedFilter.filterId);
        if (selectedFilterIdx < 0) {
            var newFilterObj = {
                'filterId': selectedFilter.filterId, 
                'fieldApi': selectedFilter.fieldApi,
                'filterLabel': selectedFilter.filterLabel,
                'recordType': selectedOption.RecordType.Name, 
                'value': selectedOption.Filter_Value__c === undefined ? '' : selectedOption.Filter_Value__c,
                'min': selectedOption.Filter_Min__c, 
                'max': selectedOption.Filter_Max__c,
                'selectedLabel': selectedOption.Name
            };
            // console.log("Select", newFilterObj.fieldApi, newFilterObj.selectedLabel, newFilterObj.value);
            selectedFilterList.push(newFilterObj);
        } else if (selectOptionIdx === '$none;') {
            // console.log("Remove", selectedFilterList[selectedFilterIdx].fieldApi, selectedFilterList[selectedFilterIdx].selectedLabel, selectedFilterList[selectedFilterIdx].value);
            selectedFilterList.splice(selectedFilterIdx, 1);
        } else {
            selectedFilterList[selectedFilterIdx].selectedLabel = selectedOption.Name;
            selectedFilterList[selectedFilterIdx].value = selectedOption.Filter_Value__c === undefined ? '' : selectedOption.Filter_Value__c;
            selectedFilterList[selectedFilterIdx].recordType = selectedOption.RecordType.Name;
            selectedFilterList[selectedFilterIdx].min = selectedOption.Filter_Min__c;
            selectedFilterList[selectedFilterIdx].max = selectedOption.Filter_Max__c;
            // console.log("Change", selectedFilterList[selectedFilterIdx].fieldApi, selectedFilterList[selectedFilterIdx].selectedLabel, selectedFilterList[selectedFilterIdx].value);
        }
        console.log(selectedFilterList);
        component.set("v.selectedFilter", selectedFilterList);
        // console.log(selectedFilterList);
	},
    clearFilters: function(component, event, handler) {
        var selectedFilterList = JSON.parse(JSON.stringify(component.get("v.selectedFilter")));
        component.set("v.selectedFilter", []);
        var filters = component.get("v.Filters");
        for(var i=0; i<filters.length; i++) {
            var filter = document.getElementById('filter_idx_' + i);
            filter.value = '$none;';
        }
        // console.log(component.get("v.selectedFilter"));
        // console.log('Cleared Filters');
    },
    doSearch : function(component, event, handler) {
        // console.log("Filter", component.get("v.selectedFilter"));
        var data = component.get("c.getData");
        data.setParams({
            params: component.get("v.selectedFilter")
        });
        data.setCallback(this, function(data) {
           component.set("v.Data", data.getReturnValue()); 
            // console.log(data.getReturnValue());
        });
        $A.enqueueAction(data);
    }
})