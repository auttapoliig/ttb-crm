({
    onInit : function(component, event, helper) {
        window.onclick = function(event) {
            if (event.target && !event.target.id.includes('select_team')) {
                component.set('v.isShowSelectTeam',false)
            }
          }
          
        var myPageRef = component.get('v.pageReference');
        var summaryGroupType = myPageRef.state.c__summaryGroupType;
        var summaryGroupValue = myPageRef.state.c__summaryGroupValue;
        var selectedYear = myPageRef.state.c__selectedYear;
        var selectedMonthInt = myPageRef.state.c__selectedMonthInt;
        var channelName = myPageRef.state.c__channelName;

        component.set("v.summaryGroupType", summaryGroupType); //เปิดต่อนส่งค่ามาแล้ว
        component.set("v.summaryGroupValue", summaryGroupValue); 
        component.set("v.selectedYear", selectedYear); 
        component.set("v.selectedMonthInt", selectedMonthInt); 
        component.set("v.channelName", channelName); 

        helper.setDefaultDate(component, event, helper);
        helper.getWatermarkHTML(component,helper);;

        component.set("v.loading", true);
        helper.makeData(component,event,helper);

    },

    handleClickShow: function(component, event, helper) {
        component.set("v.loading", true);
        component.set('v.teamLabelList', []);
        component.set('v.selectedTeam', []);
        helper.makeData(component,event,helper);
    },

    filterTeamHandle: function(component, event, helper) {
        var clickId = event.target.id;
        var keyId = clickId.split('_');
        if(keyId.length == 3) {
            var selectedValue = keyId[2];
            if(selectedValue) {
                var selectedTeamList = component.get('v.selectedTeam');
                var idxValue = selectedTeamList.indexOf(selectedValue);

                if(idxValue >= 0) {
                    // deselect
                    selectedTeamList.splice(idxValue, 1);
                } else {
                    // select
                    selectedTeamList.push(selectedValue);
                }
                component.set('v.selectedTeam',selectedTeamList);
            }
        }
    },

    toggleSelectTeam: function(component, event, helper) {
        var currState = component.get('v.isShowSelectTeam');
        component.set('v.isShowSelectTeam',!currState);
    },

    selectAllHandle: function(component, event, helper) {
        var selectedTeamList = component.get('v.selectedTeam');
        var allTeamList = component.get('v.teamLabelList');
        var defaultSelectedTeam = [];
        allTeamList.forEach(team => {
            defaultSelectedTeam.push(team.label);
        });
        if(selectedTeamList.length == defaultSelectedTeam.length && defaultSelectedTeam.length > 0) {
            // deselect all
            component.set('v.selectedTeam',[]);
        } else {
            // select all
            component.set('v.selectedTeam',defaultSelectedTeam);
        }
     },
     navigateToSummary: function (component, event, helper) {
        var clickId = event.target.id;
        var keyId = clickId.split('_');
        var selectedValue = keyId[0]; 
        var selectedMonth = component.get("v.selectedMonth");
        var monthList = component.get("v.monthList");
        var channelName = component.get("v.channelName");
        var summaryGroupType = component.get("v.summaryGroupType");
        if (summaryGroupType == 'Group of channel' && channelName == null) {
            channelName = selectedValue;
        }

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
          componentDef: "c:T_Performance_SummaryPage",
          componentAttributes: {
            "summaryPage": component.get("v.useField"),
            "onedownValue": selectedValue,
            "selectYear" :component.get("v.selectedYear"),
            "selectMonth" :(monthList.indexOf(selectedMonth) + 1).toString().padStart(2, '0'),
            "channelName" :channelName,
          }
        });
        evt.fire();
      },
      handleMouseOver:function (component,event,helper) {
        var index = event.target.id;

        if(index) {
            var splitIdx = index.split('_');
            if(splitIdx.length > 0) {

                component.set('v.hoveringId',splitIdx[0]);
            }
        }
      },
      handleMouseOut : function(component, event, helper) {
        component.set('v.hoveringId',null);
      }
})