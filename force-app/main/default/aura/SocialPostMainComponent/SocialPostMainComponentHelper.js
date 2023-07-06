({
    getInitData: function (component, event, helper) {
        const empApi = component.find('empApi');
		console.log(JSON.stringify(empApi));
		empApi.setDebugFlag(true);
		empApi.onError($A.getCallback(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        }));

        console.log('getPostInfo...');
        var action1 = component.get("c.getPostInfo");
        action1.setParams({
            "recordId": component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showSpinner(component, event, helper);
                var res = response.getReturnValue();
                var isDisableInput = res.messageType;
                component.set("v.originalMessage", res.message);
                component.set("v.isDisableInput", isDisableInput);
                component.set('v.picklistValues', res.rejectList);
                // console.log("isDisableInput: " + isDisableInput);
                if (!isDisableInput) {
                    helper.subscribeSocialPost(component, event, helper);
                } else {
                    helper.unsubscribeSocialPost(component, event, helper);
                }

                var replyId = res.replyId;
                var replyMessage = res.replyMessage;
                var account = res.default_acc;

                console.log('getAccountList...');
                var action2 = component.get("c.getAccountList");
                action2.setParams({
                    "recordId": component.get("v.recordId")
                });
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        var res = response.getReturnValue();
                        component.set("v.options", res);
                        component.set("v.selectedOption", account);
                        if (replyMessage != null && replyId != null) {
                            component.set("v.isClosed", false);
                            for (var i = 0; i < res.length; i++) {
                                if (replyId == res[i].id) {
                                    component.set("v.replyName", res[i].name);
                                    component.set("v.message", replyMessage);
                                    console.log(res[i].name + ': ' + replyMessage);
                                }
                            }
                        }
                        helper.hideSpinner(component, event, helper);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "",
                            "message": 'get account error'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action2);
            } else {
                var errMsg = response.getError();
                console.log(JSON.stringify(errMsg));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "",
                    "message": 'get info error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action1);
    },

    openModel: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    openRejectModel: function (component, event, helper) {
        component.set("v.isRejectModalOpen", true);
    },

    closeRejectModel: function (component, event, helper) {
        component.set("v.isRejectModalOpen", false);
    },

    submitDetails: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    showSpinner: function (component, event, helper) {
        component.set("v.isLoading", true);
    },

    hideSpinner: function (component, event, helper) {
        component.set("v.isLoading", false);
    },

    subscribeSocialPost: function (component, event, helper) {
		const empApi = component.find('empApi');
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		const channel = '/topic/SocialPostEvent?LastTransferUser__c=' + userId;
		const replayId = -1;
		
		empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
			if(eventReceived.data != undefined){
				// console.log('data: ' + JSON.stringify(eventReceived.data.sobject));
				var recordId = eventReceived.data.sobject.Id;
                var status = eventReceived.data.sobject.Status__c;
                var transferUserId = eventReceived.data.sobject.LastTransferUser__c;
                var lastMod = eventReceived.data.sobject.LastModifiedById;
                var ownerId = eventReceived.data.sobject.OwnerId;
                var postName = eventReceived.data.sobject.Name;
                var thisId = component.get('v.recordId');
                var toastEvent = $A.get("e.force:showToast");
                // transfer
                console.log('thisId: ' + thisId);
                console.log('recordId: ' + recordId);
                console.log('status: ' + status);
                if (thisId == recordId) {
                    console.log('lastMod: ' + lastMod);
                    console.log('transferUserId: ' + transferUserId);
                    if (ownerId != transferUserId && status == "New") {
                        toastEvent.setParams({
                            type: "success",
                            title: "",
                            message: "โอน \"" + postName + "\" แล้ว\n\"" + postName + "\" have been transferred",
                        });
                        toastEvent.fire();
                        helper.closeFocusTab(component, event, helper);
                    } else if (ownerId == userId) {
                        toastEvent.setParams({
                            mode: "sticky",
                            type: "error",
                            title: "",
                            message: "ปฎิเสธคำขอโอนแล้ว\nRejected transfer request",
                        });
                        toastEvent.fire();
                        var action = component.get("c.clearTransfer");
                        action.setParams({
                            "recordId": recordId
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if(state === "SUCCESS") {
                                console.log('clear transfer...');
                            } else {
                                console.log('clear transfer error...');
                            }
                        });
                        $A.enqueueAction(action);
                    }
                }

			}

        })).then($A.getCallback(function (subscription) {
			console.dir(JSON.stringify(subscription));
			component.set('v.postSubscription', subscription);
		}));
	},

	unsubscribeSocialPost: function (component, event, helper) {
		const empApi = component.find('empApi');
        const subscription = component.get('v.postSubscription');

        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.postSubscription', null);
        }));
	},

    closeFocusTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    doRejectPost: function (component, event, helper) {
        helper.closeRejectModel(component, event, helper);
        helper.showSpinner(component, event, helper);

        var action = component.get("c.rejectPost");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "rejectReason": component.get("v.selectedRejectOption"),
            "rejectComment": component.get("v.rejectComment"),
        });
        action.setCallback(this, function(response) {
            console.log('reject');
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "",
                    "message": 'สำเร็จ'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                var errMsg = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "",
                    "message": 'Some error has occurred ' + errMsg
                });
                toastEvent.fire();
            }
            helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    }

});