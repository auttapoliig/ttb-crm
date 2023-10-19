({
	onInit: function (component, event, helper) {
		// console.log(JSON.stringify(component.get("v.LeadScoringList")))

	},
	onchangeObject: function (component, event, helper){
		component.set("v.loaded2",true);

		// console.log(component.get("v.rowIndex") + 1);
		// console.log(component.get("v.LeadScoringList").LObject);

		var LeadList = component.get("v.LeadScoringList");
		LeadList.FieldName = '--None--';
		LeadList.APIName = '';
		LeadList.FieldType = '';
		LeadList.Length = '';

		component.set("v.LeadScoringList",LeadList);

		if(component.get("v.LeadScoringList").LObject == 'CampaignMember' || component.get("v.LeadScoringList").LObject == 'Lead'){
			var mapfieldList = component.get("v.mapfieldList");
			var mapWrapperLabel = component.get("v.mapWrapperLabel");

			// console.log('Object : ' + component.get("v.LeadScoringList").LObject);
			var fieldList = mapfieldList[component.get("v.LeadScoringList").LObject];
			var LabelAPIMap = mapWrapperLabel[component.get("v.LeadScoringList").LObject];
			var LabelList = LabelAPIMap["Label"];
			var ApiList = LabelAPIMap["API"];
			// LabelAPIMap = LabelAPIMap.sort();
			// console.log(LabelAPIMap)
			fieldList = fieldList.sort();
			// console.log(fieldList)
			// console.log(typeof fieldList)
			component.set("v.APILabelListWrapper",LabelAPIMap);
			var LeadfieldList = component.get("v.LeadScoringList");
			LeadfieldList.FieldList = fieldList;
			component.set("v.LeadScoringList",LeadfieldList);
			// console.log('test '+ JSON.stringify(fieldList.length));
			component.set("v.readonly",false);
			component.set("v.loaded2",false);

		}else{
			component.set("v.readonly",true);
			var LeadfieldList = component.get("v.LeadScoringList");
			LeadfieldList.FieldList = [];
			component.set("v.LeadScoringList", LeadfieldList);
			component.set("v.")
			component.set("v.loaded2",false);

		}
	},
	onchangeFieldName : function (component, event, helper) {
		// console.log(component.get("v.LeadScoringList").FieldName);
		component.set("v.loaded2",true);
		// console.log('fieldlength' + fieldlength);
		var newMapAPiNameLabel = component.get("v.mapWrapperLabel");
		var mapfieldAPI = component.get("v.mapfieldAPI");
		var FIELDAPINAME = newMapAPiNameLabel[component.get("v.LeadScoringList").LObject];
		// console.log('FIELDAPINAME '+ JSON.stringify(FIELDAPINAME))
		// console.log('hahah' + JSON.stringify(mapfieldAPI[component.get("v.LeadScoringList").LObject]));
		var index = mapfieldAPI[component.get("v.LeadScoringList").LObject][component.get("v.LeadScoringList").FieldName];
		var LeadList = component.get("v.LeadScoringList");
		// console.log('index -- > '+index)
		var LabelList = component.get("v.mapfieldLabel");
		var objectLabel = LabelList[component.get("v.LeadScoringList").LObject];
		var label = objectLabel[index];
		var mapfieldtypelist = component.get("v.mapfieldtype");
		var fieldtypelist = mapfieldtypelist[component.get("v.LeadScoringList").LObject];
		var fieldtype = fieldtypelist[index];
		var mapfieldlengthlist = component.get("v.mapfieldLength");
		var fieldlengthlist = mapfieldlengthlist[component.get("v.LeadScoringList").LObject];
		var fieldlength = fieldlengthlist[index];

		LeadList.Label = label;
		LeadList.FieldType = fieldtype;
		LeadList.Length = fieldlength;
		LeadList.APIName = mapfieldAPI[component.get("v.LeadScoringList").LObject][component.get("v.LeadScoringList").FieldName];
		component.set("v.LeadScoringList",LeadList);
		helper.resetLevel3(component, helper)
	},

	AddNewRow: function (component, event, helper) {
		// fire the AddNewRowEvt Lightning Event 
		// console.log('event : ' + JSON.stringify(component.getEvent("LeadScoringAddNewRowEvt")))
		component.getEvent("LeadScoringAddNewRowEvt").fire();
	},

	removeRow: function (component, event, helper) {
		// fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
		component.getEvent("InquiryDeleteRowEvt").setParams({ "indexVar": component.get("v.rowIndex") }).fire();
	},
    openScoreSettingModal: function (component, event, helper){
        component.set("v.showModal",true);
    },
    closeModal: function (component, event, helper){
        component.set("v.showModal",false);
    },
	openCFDeleteModal: function (component, event, helper){
        component.set("v.showDeleteModal",true);
    },
	closeCFModal: function (component, event, helper){
        component.set("v.showDeleteModal",false);
    },
})