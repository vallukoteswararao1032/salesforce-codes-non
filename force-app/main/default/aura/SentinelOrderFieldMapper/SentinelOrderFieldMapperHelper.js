({
    doInit: function (component) {
        console.log('doINit order field mapper helper');

        // added 27 Nov
        // var showMsgNoAccessDiv = document.getElementById("showMsgNoAccessDiv");
        // showMsgNoAccessDiv.style.display = "none"; // hide no access msg

        var action = component.get("c.getAllMappingData");
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (result.getReturnValue().length > 0) {
                    console.log('result first', result.getReturnValue());
                    component.set('v.orderFieldMapperList', result.getReturnValue());
                }
            } else if (state == "ERROR") {
                alert("Error in calling server side action");
            }
        });
        $A.enqueueAction(action);

        // for isSync from User setting 24 Nov 2020
        var actionIsCheck = component.get('c.checkEnabled');
        //var mainDivId = document.getElementById("mainDiv");

        console.log('++++1 ' + actionIsCheck);
        actionIsCheck.setCallback(this, function (response) {

            var state = response.getState();
            console.log('++++2 ' + state);

            if (state === 'SUCCESS' && component.isValid()) {
                /* set the value to the attribute of the component */
                var responseValue = response.getReturnValue();
                console.log('++++3 ' + responseValue);

                // console.log('++++31 ' + mainDivId);
                console.log('++++32 '+responseValue.includes('Order')); 
                if (responseValue.includes('Order')) {
                    component.set("v.isSync", true); // added to get value in attribute
                    //mainDivId.style.display = "block"; // show main div
                    //showMsgNoAccessDiv.style.display = "none"; // hide no access msg
                }
                else {
                    component.set("v.isSync", false);
                    //mainDivId.style.display = "none";// main div hide
                    //showMsgNoAccessDiv.style.display = "block"; // show no access msg
                }


            } else {
                var errors = response.getError();
                $A.log(errors);
                if (errors || errors[0].message) {
                    console(errors[0].message);
                }
            }
        });
        $A.enqueueAction(actionIsCheck);
    },
    fetchStatusPicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': component.get("v.Order"),
            'field_apiname': component.get("v.Status"),
            'nullRequired': false
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('state-----', a.getState());
            if (state === "SUCCESS"){
                console.log('a.getReturnValue()----',a.getReturnValue());
                let returnValues = a.getReturnValue();
                let arr = [];
                for(let i=0; i<returnValues.length;i++) {
                    arr.push({ label: returnValues[i], value: returnValues[i] });
                }
                component.set("v.StatusPicklist",arr);
            }
        });
        $A.enqueueAction(action);
    },
    saveOrderMapping: function (component) {
        if(component.find('childlwc') != undefined){
            var statusValues = component.find('childlwc').passStatusData();
            console.log('statusValues---',statusValues);
            var orderMapperList = component.get('v.orderFieldMapperList');
            for( let i=0; i< statusValues.length; i++) {
                let index = orderMapperList.findIndex(o => o.Id === statusValues[i].Id);
                orderMapperList[index] = statusValues[i];
            }
            console.log('orderMapperList---',orderMapperList);
        }
        var action = component.get("c.saveMappingData");
        action.setParams({
            updateList: component.get('v.orderFieldMapperList'),
            deleteList: component.get('v.orderFieldMapperDeleteList')
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                this.showSuccessToast(component);
            } else if (state == "ERROR") {
                this.showErrorToast(component);
            }
        });
        $A.enqueueAction(action);
    },
    showSuccessToast: function (component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "The record has been saved successfully."
        });
        toastEvent.fire();
    },
    showErrorToast: function (component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": "There was error saving record. Please retry."
        });
        toastEvent.fire();
    },
})