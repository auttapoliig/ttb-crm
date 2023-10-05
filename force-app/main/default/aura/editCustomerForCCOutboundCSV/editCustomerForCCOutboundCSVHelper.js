({
    startSpinner: function (component) {
        component.set('v.showSpinner', true);
    },
    stopSpinner: function (component) {
        component.set('v.showSpinner', false);
    },
    getDescribeFieldResultAndValue: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            'recordId': component.get('v.recordId'),
            'fields': component.get('v.fields').filter(f => f),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                component.set('v.dataFields', objectInfoField);

                var canSubmit = false;

                Object.keys(objectInfoField).forEach((key) => {
                    if (objectInfoField[key].isAccessible == true) {
                        canSubmit = true;
                        return;
                    }
                });

                component.set('v.isSubmit', canSubmit);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    getInitialData: function (component) {
        var action = component.get('c.getInitialData');
        action.setParams({
            'accId': component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState(response.getReturnValue());
            if (component.isValid && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.account', result.account);
                component.set('v.preferredContactChannelOption', result.preferredContactChannelOption);
                component.set('v.alternativeContactChannelOption', result.alternativeContactChannelOption);

                this.runWorkspaceAPI(component);
            } else {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    this.displayToast('error', 'Error :' + message);
                }
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    runWorkspaceAPI: function (component) {
        this.checkExistingTab(component)

        var tabName = `Edit ${component.get('v.account.Name')}`;
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:account",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    checkExistingTab: function (component) {
        var tabName = `Edit ${component.get('v.account.Name')}`;
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var currentTab = JSON.parse(JSON.stringify(response));
            workspaceAPI.getAllTabInfo().then(function (response) {
                response.forEach(elm => {
                    if (elm.tabId == currentTab.parentTabId) {
                        elm['subtabs'].forEach(subtab => {
                            if (subtab.customTitle == tabName && subtab.tabId != currentTab.tabId) {
                                workspaceAPI.focusTab({ tabId: subtab.tabId });
                                workspaceAPI.closeTab({
                                    tabId: subtab.tabId
                                });
                            }
                        });
                    }
                });
            }).catch(function (error) {
                console.log(error);
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    closeTab: function (component) {
        var device = $A.get('$Browser.formFactor');
        if (device == 'DESKTOP') {
            var workspaceAPI = component.find('workspace');
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.openTab({
                    recordId: component.get('v.recordId'),
                    focus: true
                }).then((res) => {
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(error => {
                    console.log(error);
                });
            }).catch(function (error) {
                console.log(error);
            })
        } else {
            var appEvent = $A.get('e.c:RetailCSV_Event');
            appEvent.setParams({
                isRefresh: true,
                recoridId: component.get('v.recordId'),
                fieldUpdate: []
            });
            appEvent.fire();

            var navEvent = $A.get('e.force:navigateToSObject');
            navEvent.setParams({
                'recordId': component.get('v.recordId')
            });
            navEvent.fire();
        }
    },
    updateAccountData: function (component, fieldValueMap) {
        const accountObj = Object.fromEntries(fieldValueMap);
        var action = component.get('c.updateAccountData');
        action.setParams({
            'acct': accountObj,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.closeTab(component);

                var appEvent = $A.get('e.c:RetailCSV_Event');
                appEvent.setParams({
                    isRefresh: true,
                    recordId: component.get('v.recordId'),
                    fieldUpdate: accountObj
                });
                appEvent.fire();

                this.displayToast('success', 'The data has been updated. Refreshing page.');

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId')
                });
                navEvt.fire();
            } else {
                var errors = response.getError();
                this.stopSpinner(component);
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    this.displayToast('error', 'Error :' + message);
                }
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    }
})