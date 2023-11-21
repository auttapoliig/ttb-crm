({
    doInit: function (component, event, helper) {
        var RecordId = component.get("v.recordId");
        var action = component.get("c.queueCondition");
        action.setParams({
            recordId: RecordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("SUCCESS");
                var returnValue = response.getReturnValue();
                component.set("v.queueCondition", 'AND Name IN (' + returnValue + ')')
                console.log(returnValue)
            }else {
                console.log('FAIL!');
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                helper.showToast(component, event, helper, "error", "Error!", message);
                helper.closeSubtab(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    handleSelect: function (component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == "UserServicePresence") {
            component.set("v.buttonIcon", "standard:avatar");
            component.set("v.extraField", "UserId");
            component.set("v.nameField", "User.Name");
            // component.set("v.condition", 'AND statusenddate = null ')
            component.set("v.condition", "AND StatusEndDate = null AND UserId != '" + userId + "'");
        } else if (selectedMenuItemValue == "Group") {
            component.set("v.buttonIcon", "standard:orders");
            component.set("v.extraField", "");
            component.set("v.nameField", "Name");
            component.set("v.condition", component.get("v.queueCondition"));
        }
        var menuItems = component.find("menuItems");
        menuItems.forEach(function (menuItem) {
            // For each menu item, if it was checked, un-check it. This ensures that only one
            // menu item is checked at a time
            if (menuItem.get("v.checked")) {
                menuItem.set("v.checked", false);
            }
            // Check the selected menu item
            if (menuItem.get("v.value") === selectedMenuItemValue) {
                menuItem.set("v.checked", true);
            }
        });
        component.set("v.selectRecord", "");
        component.set("v.APIName", selectedMenuItemValue);
        console.log("Object : " + selectedMenuItemValue);
    },

    handleCancel: function (component, event, helper) {
        helper.closeSubtab(component, event, helper);
    },

    handleConfirm: function (component, event, helper) {
        var RecordId = component.get("v.recordId");
        var action = component.get("c.changeOwner");
        if (component.get("v.APIName") == "UserServicePresence") {
            var userId = component.get("v.selectRecord").extraValue.UserId;
            action.setParams({
                recordId: RecordId,
                ownerId: userId,
                type: "user"
            });
        } else if (component.get("v.APIName") == "Group") {
            var groupId = component.get("v.selectRecord").Id;
            action.setParams({
                recordId: RecordId,
                ownerId: groupId,
                type: "queue"
            });
        }
        component.set("v.toggleSpinner", true);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("SUCCESS");
                var postName = response.getReturnValue();
                if (component.get("v.APIName") == "Skill" || component.get("v.APIName") == "Group") {
                    component.set("v.toggleSpinner", false);
                    helper.showToast(component, event, helper, "success", "", "โอน \"" + postName + "\" แล้ว\n\"" + postName + "\" have been transferred");
                    helper.closeFocusedTab(component, event, helper);
                } else if (component.get("v.APIName") == "UserServicePresence") {
                    helper.showToast(component, event, helper, "success", "", "อยู่ระหว่างการโอน...\nTransferring...");
                    helper.closeSubtab(component, event, helper);
                }
                // helper.showToast(component, event, helper, "success", "Success!", "Transfer success");
                // helper.closeFocusedTab(component, event, helper);
                // helper.refreshFocusedTab(component, event, helper);
            } else {
                console.log("FAIL!");
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.toggleSpinner", false);
                helper.showToast(component, event, helper, "error", "Error!", message);
            }
        });
        $A.enqueueAction(action);
    }
});