({
    helperMethod : function() {

    },

    handleActive: function (component, event) {
        var tab = event.getSource();
        let cTab = tab.get('v.id');
        if(cTab == 'Product'){
            component.set('v.CurrentTab', 'Product');
        }
        else if( cTab == 'Sales'){
            component.set('v.CurrentTab', 'Sales');
        }
        else if( cTab == 'Tips'){
            component.set('v.CurrentTab', 'Tips');
        }
    },
})