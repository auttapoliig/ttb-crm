({
  onInit : function(component, event, helper) {
    helper.setEditData(component, helper, true);
  },
	removeRow: function (component, event, helper) {
	  var p = component.get("v.parent");
	  p.parentRemoveRowMethod(component.get("v.index"));
	},
	EditName: function (component, event, helper) {
    var allowEdit = true;
		var FieldName = event.target.getAttribute('data-value');
		var attr = 'v.' + FieldName + 'EditMode';
		if (!component.get(attr) && FieldName != 'null') {
      if (FieldName == 'recurringType') {
        var incomeType = component.get('v.mydata.incomeType');
        if (incomeType != null && (incomeType.includes('Fee') || incomeType.includes('Supply Chain'))) {
          allowEdit = true; 
        } else {
          allowEdit = false;
        }
      } else if (FieldName == 'frequency') {
        var recurringType = component.get('v.mydata.recurringType');
        if (recurringType != 'Recurring') {
          allowEdit = false;
        }
      } 
      
      if (allowEdit) {
        component.set(attr, true);
        var FieldAuraId = FieldName + 'id';
        setTimeout(function () {
          component.find(FieldAuraId).focus();
        }, 100);
      }
    }
	},
	closeNameBox: function (component, event, helper) {
    var limitVolume = component.get("v.mydata.limitVolume");
    var startingVolumeEdit = component.get("v.InputNumber.startingVolumeEdited");
    var utilizationEdited = component.get("v.InputNumber.utilizationEdited");
    var NIMfeeRateEdited = component.get("v.InputNumber.NIMfeeRateEdited");

    var eventToast = $A.get("e.force:showToast");
    if(startingVolumeEdit > limitVolume) {
      eventToast.setParams({
        "type":'error',
        "message": $A.get('$Label.c.Starting_volume_cannot_be_greater')
        });
    } else if (startingVolumeEdit > 0 && utilizationEdited == null) {
      eventToast.setParams({
        "type":'error',
        "message": $A.get('$Label.c.No_Utilization')
      });
    } else if (utilizationEdited < 0) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.Utilization_must_be_greater_than_zero')
			});
		} else if (NIMfeeRateEdited < 0) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.NIM_Fee_rate_must_be_greater_than_zero')
			});
		} else if (utilizationEdited > 100) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.Utilization_cannot_be_greater')
			});
		} else if (NIMfeeRateEdited > 100) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.NIM_Fee_rate_cannot_be_greater')
			});
		} else {
      component.set("v.propEditMode",false);
      component.set("v.limitVolumeEditMode",false);
      component.set("v.incomeTypeEditMode",false);
      component.set("v.recurringTypeEditMode",false);
      component.set("v.frequencyEditMode",false);
      component.set("v.expectedStartYearEditMode",false);
      component.set("v.expectedStartMonthEditMode",false);
      component.set("v.utilizationEditMode",false);
      component.set("v.NIMfeeRateEditMode",false);
      component.set("v.startingVolumeEditMode",false);
      component.set("v.remarkEditMode",false);
      
      helper.setDataAfterChange(component, helper);
      helper.setEditData(component, helper, false);
    }
    eventToast.fire();
    
	},     
  saveEditedTalent:function(component, event, helper){
    var limitVolume = component.get("v.mydata.limitVolume");
    var startingVolumeEdit = component.get("v.InputNumber.startingVolumeEdited");
    var utilizationEdited = component.get("v.InputNumber.utilizationEdited");
    utilizationEdited = (utilizationEdited == '') ? null : utilizationEdited
    var NIMfeeRateEdited = component.get("v.InputNumber.NIMfeeRateEdited");

    var eventToast = $A.get("e.force:showToast");
    if(startingVolumeEdit > limitVolume) {
      eventToast.setParams({
        "type":'error',
        "message": $A.get('$Label.c.Starting_volume_cannot_be_greater')
        });
    } else if (startingVolumeEdit > 0 && utilizationEdited == null) {
      eventToast.setParams({
        "type":'error',
        "message": $A.get('$Label.c.No_Utilization')
      });
    } else if (utilizationEdited < 0) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.Utilization_must_be_greater_than_zero')
			});
		} else if (NIMfeeRateEdited < 0) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.NIM_Fee_rate_must_be_greater_than_zero')
			});
		} else if (utilizationEdited > 100) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.Utilization_cannot_be_greater')
			});
		} else if (NIMfeeRateEdited > 100) {
			eventToast.setParams({
        "type":'error',
				"message": $A.get('$Label.c.NIM_Fee_rate_cannot_be_greater')
			});
		} else {
      var DealForecastData = helper.setDealForecastData(component);
      var action = component.get("c.saveDealForecastRecord");
  
      action.setParams({
          DFI: DealForecastData
      });
  
      action.setCallback(this, function (response) {
        var eventToast = $A.get("e.force:showToast");
          if (response.getState() === "SUCCESS" && component.isValid()) {
            component.set( "v.editMode", false ); 
            eventToast.setParams({
                "title":'Success',
                "type":'success',
                "message":'Record updated successfully.'
                });
            eventToast.fire(); 
            
            var target = component.find('isDaft');
            component.set('v.showSaveChildeBtn', false);
            component.set('v.isDaft', false);
            $A.util.removeClass(target, 'slds-is-edited');
  
            var dealForecast = response.getReturnValue();
            helper.setDataAfterSave(component,helper , dealForecast);
          }else if (response.getState() === "ERROR") {
            var errors = action.getError();
            if (errors) {
              if (errors[0] && errors[0].message) {
                console.error(errors[0].message);
                helper.displayToast('error', errors[0].message);
              }
            }
          }else {
            console.error(response);
          }
      });
  
      $A.enqueueAction(action);
    } 
    eventToast.fire();
    
  },

  cancelEditedTalent:function(component, event, helper){
    helper.setDataAfterCancel(component);
    helper.setEditData(component, helper, false);
    var target = component.find('isDaft');
    component.set('v.showSaveChildeBtn', false);
    component.set('v.isDaft', false);
    $A.util.removeClass(target, 'slds-is-edited');

    component.set("v.propEditMode",false);
    component.set("v.limitVolumeEditMode",false);
    component.set("v.incomeTypeEditMode",false);
    component.set("v.recurringTypeEditMode",false);
    component.set("v.frequencyEditMode",false);
    component.set("v.expectedStartYearEditMode",false);
    component.set("v.expectedStartMonthEditMode",false);
    component.set("v.utilizationEditMode",false);
    component.set("v.NIMfeeRateEditMode",false);
    component.set("v.startingVolumeEditMode",false);
    component.set("v.remarkEditMode",false);
  },
  
  openDetailTab : function(component, event, helper) {
    var workspaceAPI = component.find('workspace');
    workspaceAPI.getAllTabInfo().then(function (response) {
    var primaryTabInfo = response.find(f => f.pageReference.attributes.componentName == 'c__ForecastNewDealDetail');
    if(!primaryTabInfo){
      workspaceAPI.openTab({
          pageReference: {
              "type": "standard__component",
              "attributes": {
                  "componentName": 'c__ForecastNewDealDetail',
              },
              "state": {
              "c__id": component.get("v.mydata.customerId"),
              'c__dealForecastId': component.get('v.mydata.Id')
              }
          },
              focus: true
          }).then((response) => {
              workspaceAPI.setTabLabel({
                  tabId: response,
                  // label: component.get("v.mydata.name")
                  label: 'Deal Forecast Detail'
              });
              workspaceAPI.setTabIcon({
              tabId: response,
              icon: "standard:product",
              iconAlt: component.get("v.mydata.name")
              });
          }).catch(function(error) {
              console.log(error);
          });
    }else{
      var tabId = primaryTabInfo.tabId;
      var subtabTabInfo = primaryTabInfo.subtabs.find(f => f.pageReference.state.c__id == component.get('v.mydata.customerId') && f.pageReference.state.c__dealForecastId == component.get('v.mydata.Id'));
      if(!subtabTabInfo){
        //opennew
        if(primaryTabInfo.pageReference.state.c__id == component.get('v.groupData.Customer__c') && primaryTabInfo.pageReference.state.c__dealForecastId == component.get('v.mydata.Id')){
            workspaceAPI.closeTab({tabId: tabId}).then(function(response) {
                setTimeout(() => {
                    workspaceAPI.openTab({
                        pageReference: {
                            "type": "standard__component",
                            "attributes": {
                                "componentName": 'c__ForecastNewDealDetail',
                            },
                            "state": {
                            "c__id": component.get("v.mydata.customerId"),
                            'c__dealForecastId': component.get('v.mydata.Id')
                            }
                        },
                            focus: true
                        }).then((response) => {
                            workspaceAPI.setTabLabel({
                                tabId: response,
                                label: component.get("v.mydata.name")
                            });
                            workspaceAPI.setTabIcon({
                            tabId: response,
                            icon: "standard:product",
                            iconAlt: component.get("v.mydata.name")
                            });
                        }).catch(function(error) {
                            console.log(error);
                        });
                }, 500);
            }).catch(function(error) {
                console.log(error);
            });
        }else{
            workspaceAPI.openSubtab({
                parentTabId: tabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": 'c__ForecastNewDealDetail',
                    },
                    "state": {
                    "c__id": component.get("v.mydata.customerId"),
                    'c__dealForecastId': component.get('v.mydata.Id')
                    }
                },
                    focus: true
                }).then((response) => {
                    workspaceAPI.setTabLabel({
                        tabId: response,
                        label: component.get("v.mydata.name")
                    });
                    workspaceAPI.setTabIcon({
                    tabId: response,
                    icon: "standard:product",
                    iconAlt: component.get("v.mydata.name")
                    });
                }).catch(function(error) {
                    console.log(error);
                });
        }
      }else{
        //focus GOD.
        workspaceAPI.closeTab({tabId: subtabTabInfo.tabId}).then(function(response) {
            setTimeout(() => {
                workspaceAPI.openSubtab({
                    parentTabId: tabId,
                    pageReference: {
                        "type": "standard__component",
                        "attributes": {
                            "componentName": 'c__ForecastNewDealDetail',
                        },
                        "state": {
                        "c__id": component.get("v.mydata.customerId"),
                        'c__dealForecastId': component.get('v.mydata.Id')
                        }
                    },
                        focus: true
                    }).then((response) => {
                        workspaceAPI.setTabLabel({
                            tabId: response,
                            label: component.get("v.mydata.name")
                        });
                        workspaceAPI.setTabIcon({
                        tabId: response,
                        icon: "standard:product",
                        iconAlt: component.get("v.mydata.name")
                        });
                    }).catch(function(error) {
                        console.log(error);
                    });
            }, 500);
        }).catch(function(error) {
            console.log(error);
        });
      }
    }
    });
  },
  addRow: function (component, event, helper) {
    var noOfNewRow = component.get("v.noOfSubChild");
    var childList = component.get("v.ChildList") == null ? [] : component.get("v.ChildList");
    noOfNewRow++;
    var res = component.get( "v.mydata" );
    var data = {
      name: res.name,
      groupName: res.groupName,
      team: res.team,
      opportunity: res.opportunity,
      stage: res.stage,
      oppApplicationStatus: res.oppApplicationStatus,
      expectedCompleteDate: res.expectedCompleteDate,
      product: res.product,
      limitVolume: res.limitVolume,
      prop: res.prop,
      mainDealForecast: res.Id,
      customerId: res.customerId,
      opportunityId: res.opportunityId,
      productId: res.productId,
      opportunityProductId: res.opportunityProductId,
      opportunityRecordType: res.opportunityRecordType
    }
    
    childList.push(data);
    component.set("v.noOfSubChild",noOfNewRow);
    component.set("v.ChildList",childList);
    component.set("v.showSubChild",true);
  },
  expandRow: function (component, event, helper) {
      var showSubChild = component.get("v.showSubChild");
      showSubChild = !showSubChild;
      var showSubChild = component.set("v.showSubChild",showSubChild);
  },
  removeSubChildRow : function (component, event, helper) {
      var params = event.getParam('arguments');
      var noOfNewRow = component.get("v.noOfSubChild");
      if (params) {
          var param1 = params.param1;
          var ChildList = component.get("v.ChildList");
          noOfNewRow--;
          ChildList.splice(param1, 1);
          component.set("v.noOfSubChild",noOfNewRow);
          component.set("v.ChildList", ChildList);
      }
  },
  onChange: function (component, event, helper) {
		var isDaft = component.get('v.isDaft');
		if (!isDaft) {
			var target = component.find('isDaft');
			component.set('v.showSaveChildeBtn', true);
			component.set('v.isDaft', true);
      $A.util.addClass(target, 'slds-is-edited');
    }
	},

	showEdit: function (component, event, helper) {
    var allowEdit = true;
    var name = event.target.getAttribute('data-value');
    
    if (name == 'recurringType') {
      var incomeType = component.get('v.mydata.incomeType');
      if (incomeType != null && (incomeType.includes('Fee') || incomeType.includes('Supply Chain'))) {
        allowEdit = true;
      } else {
        allowEdit = false;
      }
    } else if (name == 'frequency') {
      var recurringType = component.get('v.mydata.recurringType');
      if (recurringType != 'Recurring') {
        allowEdit = false;
      }
    }

    if(allowEdit) {
      var buttonName = name + 'EditButton';
      var target = component.find(buttonName);
      $A.util.removeClass(target, 'slds-hidden');
    }
	},

	hideEdit: function (component, event, helper) {
		var name = event.target.getAttribute('data-value');
		var buttonName = name + 'EditButton';
		var target = component.find(buttonName);
		$A.util.addClass(target, 'slds-hidden');
  },
  
  refreshData: function (component, event, helper) {
    var p = component.get("v.parent");
    p.refreshData();
  },
  openModel: function(component, event, helper) {
    // Set isModalOpen attribute to true
    var childData = component.get('v.mydata');
    component.set("v.isModalOpen", true);
    component.set("v.deleteData", childData);
  },

});