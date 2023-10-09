({
    resetLevel3 : function(component, helper) {
        var recordId = component.get("v.level1Id")
        var result = component.get("v.LeadScoringList")
           
        var newObject = Object.assign({}, result);
        delete newObject.FieldList;
        delete newObject.readonly;
        if(result.Length == "-"){
            result.Length = null;
        }
		
		// result = result.filter(x => x.APIName !== '');
        // console.log('level 2 --> '+JSON.stringify(newObject))
		var action = component.get("c.resetScoringCon");
        action.setParams({
			recordId : recordId,
			LeadList : newObject
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {	
                component.set("v.loaded2",false);
				// var result = response.getReturnValue();
                // console.log('state ' + state);
            }else{
                console.log('err ' + JSON.stringify(response.getError()));
                component.set("v.loaded2",false);
                // component.set("v.loaded",false);
            }
            
        });
        $A.enqueueAction(action);
        
    }
})