({
    doInit : function(component, event, helper) {
        helper.getInitData(component, event, helper);
    },

    replyMessageToWarroom : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var selectedOption = component.get("v.selectedOption")

        helper.closeModel(component, event, helper);
        helper.showSpinner(component, event, helper);
        var action1 = component.get("c.getThreadIdentity");
        action1.setParams({
            "recordId": component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var res = response.getReturnValue();
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "type": "success",
                //     "title": "",
                //     "message": 'thread_identity_id: ' + res.thread_identity_id
                // });
                // toastEvent.fire();
                var action2 = component.get("c.replyMessage");
                var message = component.get("v.message");
                action2.setParams({
                    "recordId": recordId,
                    "threadIdentityId": res.thread_identity_id,
                    "socialId": selectedOption,
                    "messageBody": message
                });
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        // toastEvent.setParams({
                        //     "type": "success",
                        //     "title": "",
                        //     "message": 'สำเร็จ'
                        // });
                        // toastEvent.fire();
                        toastEvent.setParams({
                            mode: "sticky",
                            type: "warning",
                            title: "",
                            message: "สิ้นสุดการสนทนา กรุณากรอกข้อมูลบนเคสให้สมบูรณ์\n\nEnd of conversation, Please complete the information on the case."
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    } else {
                        var errMsg = response.getError();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "",
                            "message": 'Some error has occurred'
                        });
                        toastEvent.fire();
                    }
                    helper.hideSpinner(component, event, helper);
                });
                $A.enqueueAction(action2);
            } else {
                var errMsg = response.getError();
                console.log(JSON.stringify(errMsg));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "",
                    "message": 'Some error has occurred'
                });
                toastEvent.fire();
                helper.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(action1);
    },

    handleChange: function (component, event) {
        var selectedOption = component.get("v.selectedOption");
        
        if (selectedOption != "") {
            var data = component.get("v.options");
            for (var i = 0; i < data.length; i++) {
                if (selectedOption == data[i].id) {
                    component.set("v.selectedOptionName", data[i].name);
                }
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "success",
                "title": "Account Changed!",
                "message": "เปลี่ยนเป็น: '" + component.get("v.selectedOptionName") + "'"
            });
            toastEvent.fire();
        }
    },
    
    handleClick: function (component, event, helper) {
        var message = component.get("v.message");
        // var selectedOptionValue = component.get("v.selectedOption");
        var toastEvent = $A.get("e.force:showToast");
        var isValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.focus();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);

        if (isValid) {
            // toastEvent.setParams({
            //     "type": "success",
            //     "title": "ข้อความ",
            //     "message": selectedOptionValue + ' ตอบกลับว่า ' + message,
            // });
            // toastEvent.fire();
            helper.openModel(component, event, helper);
        } else {
            toastEvent.setParams({
                "type": "error",
                "title": "ข้อความ",
                "message": 'กรุณากรอกข้อมูลให้ครบถ้วน\nPlease complete the information.',
            });
            toastEvent.fire();
        }
    },

    handleReject: function (component, event, helper) {
        helper.openRejectModel(component, event, helper);
    },

    closeModel: function (component, event, helper) {
        helper.closeModel(component, event, helper);
    },

    closeRejectModel: function (component, event, helper) {
        helper.closeRejectModel(component, event, helper);
    },

    handleRejectPost: function (component, event, helper) {
        var selectedRejectOption = component.get("v.selectedRejectOption");
        var rejectComment = component.get("v.rejectComment");

        var reason = component.find("reason");
        var comment = component.find("comment");

        if (selectedRejectOption === "อื่นๆ" && !rejectComment || selectedRejectOption === "") {
            reason.focus();
            reason.checkValidity();
            comment.focus();
            comment.checkValidity();
            reason.focus();
        } else {
            helper.doRejectPost(component, event, helper);
        }
    },
    
    submitDetails: function (component, event, helper) {
        helper.submitDetails(component, event, helper);
    },

    handleSelectChange: function(component, event, helper) {
        var selectedRejectOption = component.get("v.selectedRejectOption");
        if (selectedRejectOption === "อื่นๆ") {
            component.set("v.otherOption", true);
        } else {
            component.set("v.otherOption", false);
        }
    }

})