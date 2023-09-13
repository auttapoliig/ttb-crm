public without sharing class CustomLookupVFController {
    public class lookupWrapper {
        public String Name{get;set;}
        public String Id{get;set;}
        public Map<String, String> extraValue{get;set;}
        public String extraValueStr{get;set;}
    }

    public String searchField {get; set;}
    public String query {get; set;}
    public List<lookupWrapper> sObj {get; set;}
    public Integer sObjSize {get; set;}
    public Boolean doneLookup {get; set;}    
    public String ObjectName {get; set;}   
    public String nameField {get; set;}   
    public String condition {get; set;}   
    public String extraField {get; set;}  
    public List<String> extraFields {get; set;}  
    public Map<String, String> showFields {get; set;}   
    public String objectLabel {get; set;} 
    public String index {get; set;} 

    public String errorMsg {get; set;}

    // constructor
    public CustomLookupVFController() {
        doneLookup = false;
        sObjSize = 0;
        showFields = new Map<String,String>();
        ObjectName = Apexpages.currentPage().getParameters().get('ObjectName');
        condition = Apexpages.currentPage().getParameters().get('condition') != null ? EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('condition'), 'UTF-8') : '';
        index = Apexpages.currentPage().getParameters().get('index');
        searchField = 'NAME FIELDS';
        nameField = '';
		System.debug('ObjectName:'+ObjectName);
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{ObjectName}); 
        objectLabel = describeSobjectsResult[0].getLabelPlural();

        System.debug('condition:'+condition);
        List<Custom_Lookup_VF_Setting__mdt> lookupSetting = [SELECT label,ObjectName__c,FieldName__c,Condition__c FROM Custom_Lookup_VF_Setting__mdt WHERE ObjectName__c =: ObjectName LIMIT 1];
        System.debug('condition:'+lookupSetting);
        if(lookupSetting.size() > 0)
        {
            nameField = lookupSetting[0].FieldName__c != null ? lookupSetting[0].FieldName__c : '';
            extraField = lookupSetting[0].FieldName__c != null ? lookupSetting[0].FieldName__c : '';
            if(condition == null && condition == '' )
            {
                condition = lookupSetting[0].Condition__c;
            }          
        }
        if(Apexpages.currentPage().getParameters().get('searchValue') != null)
        {
            query = Apexpages.currentPage().getParameters().get('searchValue');          
        }
        if(query != null && query != '')
        {
            runQuery();
        }
        else {
            doneLookup = true;
        }
    }
    // executes the search
    public PageReference runQuery() {
 
        try {
            if(query.length() >= 2)
            {
                errorMsg = null;
                System.debug('condition:'+condition);
                String searchQuery = 'FIND \'' + query + '\' IN '+ searchField +' RETURNING ' + ObjectName + '(' + nameField + ' ' + condition + ')' + ' Limit 100';
                System.debug('query => '+searchQuery);
                List<List<sObject>> searchList = search.query(searchQuery);
                System.debug('searchList => '+searchList);

                extraFields = extraField != null ? extraField.split(',') : null;
                List < lookupWrapper > returnList = new List < lookupWrapper > ();
                for (List<sObject> sObjList : searchList) {
                    for (sObject obj : sObjList) {
                        System.debug('obj => '+obj);
                        lookupWrapper res = new lookupWrapper();
                        res.Id = obj.Id;
                        res.Name = String.valueOf(obj.get('Name'));
                        res.extraValue = null;
                        if(extraFields != null) {
                            res.extraValue = new Map<String, String>();
                            for(String fname : extraFields) {
                                res.extraValue.put(fname, String.valueOf(obj.get(fname)));
                               
                            }
                        }
                        res.extraValueStr = JSON.serialize(res.extraValue);
                        returnList.add(res);
                    }
                }
                sObj = returnList;
                sObjSize = returnList.size();
                doneLookup = true;
                System.debug('sObjSize => '+sObjSize);
                System.debug('returnList => '+returnList);
                // System.debug('extraValue### => '+JSON.serialize(returnList[0].extraValue));

                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjSchema = schemaMap.get(ObjectName);
                Map<String, Schema.SObjectField> fieldMap = sObjSchema.getDescribe().fields.getMap();
                
                for (String fieldName: extraFields) 
                {      
                    System.debug('##Field API Name='+fieldName);
                    //It provides to get the object fields label.
                    if(fieldMap.containsKey(fieldName))
                    {
                        System.debug('##fieldMap='+fieldMap.get(fieldName).getDescribe().getLabel());
                        showFields.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                    }
                }
                System.debug('##showFields='+showFields);
                extraFields.remove(0);
                System.debug('##extraFields='+extraFields);
            }
            else {
                sObj = null;
                doneLookup = true;
                sObjSize = 0;
                errorMsg = 'Error: Please enter a search string at least 2 characters long.';
            }
            return null;
        } catch (Exception e) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Please enter a search string at least 2 characters long.'));
            errorMsg = e.getMessage();
            return null;
        }
        
    }
    public void selectRadio()
    {
        searchField = System.currentPagereference().getParameters().get('searchField');
        System.debug('searchField:'+searchField);
    }   

    
}