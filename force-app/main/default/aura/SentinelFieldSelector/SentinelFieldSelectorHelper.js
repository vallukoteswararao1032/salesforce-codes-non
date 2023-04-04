({
    doInit: function (component, event) {
        if (component.get("v.fieldApiName")) {
            this.prePopulateFieldList(component, component.get("v.fieldApiName"), component.get("v.objectApiName"));
        } else if (component.get("v.objectApiName")) {
            this.retrieveFieldList(component, component.get("v.objectApiName"), 1);
        }
    },

    retrieveFieldList: function (component, objectApiName, level) {
        var action = component.get("c.getFieldMap");
        action.setParams({
            objectApiName: objectApiName,
        });
        action.setCallback(this, function (result) {

            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (level == 1) {
                    component.set("v.firstLevelFieldList", result.getReturnValue());
                } else if (level == 2) {
                    component.set("v.secondLevelFieldList", result.getReturnValue());
                } else if (level == 3) {
                    component.set("v.thirdLevelFieldList", result.getReturnValue());
                }
            } else if (state == "ERROR") {
                alert("Error in calling server side action");
            }
        });
        $A.enqueueAction(action);
    },

    setFieldApiName: function (component) {
        var selectedList = component.get("v.selectedFieldList");
        var finalApiName = [];

        if (selectedList.length == 2) {
            finalApiName[0] = this.getFilteredApiName(selectedList[0]);
            finalApiName[1] = selectedList[1];
        } else if (selectedList.length == 3) {
            finalApiName[0] = this.getFilteredApiName(selectedList[0]);
            finalApiName[1] = this.getFilteredApiName(selectedList[1]);
            finalApiName[2] = selectedList[2];
        } else {
            finalApiName[0] = selectedList[0];
        }
        if (finalApiName.length > 0) {

        }
        component.set("v.fieldApiName", finalApiName.join("."));
    },

    getFilteredApiName: function (fieldName) {
        if (fieldName.includes('__c')) {
            fieldName = fieldName.replace('__c', '__r');
        } else if (fieldName.lastIndexOf('Id') + 2 === fieldName.length && fieldName.includes('Id')) {
            fieldName = fieldName.substring(0, fieldName.lastIndexOf('Id'));
        }
        return fieldName;
    },

    getOriginalApiName: function (fieldName) {
        if (fieldName.includes('__r')) {
            fieldName = fieldName.replace('__r', '__c');
        } else {
            fieldName = fieldName + 'Id';
        }
        return fieldName;
    },

    prePopulateFieldList: function (component, fieldName, ObjectName) {
        var selectedFields = [];
        if (ObjectName) {
            //get first list for objectname
            this.retrieveFieldList(component, ObjectName, 1);
            var action = component.get("c.getFieldMap");
            action.setParams({
                objectApiName: ObjectName,
            });
            action.setCallback(this, function (result) {

                var state = result.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.firstLevelFieldList", result.getReturnValue());
                    if (fieldName) {
                        let splittedFieldName = fieldName.split('.');
                        if (splittedFieldName.length == 3) {
                            var field0 = this.getOriginalApiName(splittedFieldName[0]);
                            var field1 = this.getOriginalApiName(splittedFieldName[1]);
                            var field0ReferenceTo, field1ReferenceTo;

                            for (var firstField of result.getReturnValue()) {
                                if (field0 == firstField.fieldApiName) {
                                    field0ReferenceTo = firstField.referenceToObject; break;
                                }
                            };
                            if (field0ReferenceTo) {
                                var action3 = component.get("c.getFieldMap");
                                action3.setParams({
                                    objectApiName: field0ReferenceTo,
                                });
                                action3.setCallback(this, function (result) {
                                    var state = result.getState();
                                    if (component.isValid() && state === "SUCCESS") {
                                        component.set("v.secondLevelFieldList", result.getReturnValue());
                                        for (var secondField of result.getReturnValue()) {
                                            if (field1 == secondField.fieldApiName) {
                                                field1ReferenceTo = secondField.referenceToObject; break;
                                            }
                                        };
                                        selectedFields[0] = field0;
                                        selectedFields[1] = field1;
                                        selectedFields[2] = splittedFieldName[2];
                                        component.set("v.selectedFieldList", selectedFields);
                                        this.retrieveFieldList(component, field1ReferenceTo, 3);
                                    } else if (state == "ERROR") {
                                    }
                                });
                                $A.enqueueAction(action3);
                            }
                        } else if (splittedFieldName.length == 2) {
                            var field00 = this.getOriginalApiName(splittedFieldName[0]);
                            var fieldReferenceTo;
                            for (var firstField of component.get('v.firstLevelFieldList')) {
                                if (field00 == firstField.fieldApiName) {
                                    fieldReferenceTo = firstField.referenceToObject; break;
                                }
                            };
                            selectedFields[0] = field00;
                            selectedFields[1] = splittedFieldName[1];
                            component.set("v.selectedFieldList", selectedFields);
                            this.retrieveFieldList(component, fieldReferenceTo, 2);
                        } else if (splittedFieldName.length == 1) {
                            selectedFields[0] = splittedFieldName[0];
                            component.set("v.selectedFieldList", selectedFields);
                        }
                    }
                } else if (state == "ERROR") {
                }
            });
            $A.enqueueAction(action);
        }
    },
});