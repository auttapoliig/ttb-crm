({
    cancel : function(cmp, event, helper) {
        var compEvent = cmp.getEvent("closeEvent");
        compEvent.fire();
    },

    confirmDelete : function(cmp, event, helper) {
        cmp.set("v.isDelete", true);
    },

    closeModel: function(cmp, event, helper) {
        cmp.set("v.isDelete", false);
     },

    delete : function(cmp, event, helper) {
        var action = cmp.get("c.deleteCrossSellProduct");
        action.setParams({ 
            productId : cmp.get("v.productId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if(rtnValue.success){
                    var compEvent = cmp.getEvent("saveEvent");
                    compEvent.fire();
                }
                else{
                    cmp.set("v.isError", true);
                    cmp.set("v.error", rtnValue.message);
                }
            }
            else if (state === "ERROR") {
                cmp.set("v.isError", true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        cmp.set("v.error", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    cmp.set("v.error", 'Something went wrong. Please reload page or try again later.');
                }
            }
            cmp.set("v.activeSpinner", false);
        });

        $A.enqueueAction(action);
    },

    saveAndNew : function(cmp, event, helper) {
        if(helper.validateInput(cmp)){
            helper.upsert(cmp, 'save & new');
            // var errorlist = cmp.get("v.errorList");
            // var errmsg = 'Lead must have at least 1 recommended product. (โปรดระบุ Product ที่ลูกค้าสนใจ อย่างน้อย 1 Product)';
            // errorlist = errorlist.filter(e => e !== errmsg);
            // cmp.set("v.errorList", errorlist);
            // cmp.set("v.isAllowedToConvert", true);
        }
    },

    save : function(cmp, event, helper) {
        if(helper.validateInput(cmp)){
            helper.upsert(cmp, 'save');
            // var errorlist = cmp.get("v.errorList");
            // var errmsg = 'Lead must have at least 1 recommended product. (โปรดระบุ Product ที่ลูกค้าสนใจ อย่างน้อย 1 Product)';
            // errorlist = errorlist.filter(e => e !== errmsg);
            // cmp.set("v.errorList", errorlist);
            // cmp.set("v.isAllowedToConvert", true);

        }

    },

    handleToggle: function (cmp, event, helper) {
        cmp.set('v.activeSectionName', ['A', 'B']);
    }
})