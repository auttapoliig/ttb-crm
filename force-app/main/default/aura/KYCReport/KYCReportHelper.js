({

    sortData : function(component, helper, fieldName,sortDirection, dataList){
        var data;
        if(dataList){
            data = dataList;
        }
        else{
            data = component.get("v.data");
        }
        var key = function(a) { return a[fieldName]; }
        var key2 = function(a) { return a['Name']; }
        var reverse = sortDirection == 'asc' ? 1: -1;

        data.sort(function(a,b){
            if(key(a) < key(b)) {return reverse * 1}
            if(key(a) > key(b)) {return reverse * (-1) }
         
            const nameA = key2(a) || "";
            const nameB = key2(b) || ""; 
            return nameA.localeCompare(nameB, 'en');
        });
        component.set("v.data", helper.arrayShorter(component, helper, data));
    },

    arrayShorter : function(component, helper, data){
        let finalData = [];
        for(let i = 0; i < data.length ; i++){
            if(i == 5){
                break;
            }
            else{
                finalData.push(data[i]);
            }
        }
        return finalData;
    },
})