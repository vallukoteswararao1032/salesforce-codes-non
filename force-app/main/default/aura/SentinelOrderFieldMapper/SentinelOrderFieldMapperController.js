({
    toggleSection: function (component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
    },
    deleteHandler: function (component, event, helper) {
        $(event.target).closest('li').css('display', 'none');
        var nameAttr = event.target.getAttribute("data-index");
        var customSettingList = component.get("v.orderFieldMapperList");
        var tobeDeletedElement = customSettingList[nameAttr];
        customSettingList.splice(nameAttr, 1);
        component.set('v.orderFieldMapperList', customSettingList);
        var deleteList = component.get('v.orderFieldMapperDeleteList');
        if (deleteList && deleteList.length > 0) {
            deleteList.push(tobeDeletedElement);
        } else {
            deleteList = [];
            deleteList.push(tobeDeletedElement);
        }
        component.set('v.orderFieldMapperDeleteList', deleteList);
    },
    doInit: function (component, event, helper) {
        helper.doInit(component);
    },
    
    init: function(component, event, helper) {
        helper.fetchStatusPicklist(component, event);
    },
    saveAction: function (component, event, helper) {
        helper.saveOrderMapping(component);
    },
    addRow: function (component, event, helper) {
        var category = event.target.getAttribute("data-category");
        var customlist = component.get('v.orderFieldMapperList');
        var cusObj = {};
        cusObj['Name'] = 'C-' + Math.random();
        cusObj['Category__c'] = category;
        cusObj['IsCustomAttribute__c'] = true;
        cusObj['SF_Api_Field__c'] = '';
        cusObj['Sentinel_Api_Field__c'] = '';
        cusObj['Field_Description__c'] = 'Name of the user-defined custom attributes.';
        cusObj['sObjectName__c'] = 'Order';
        customlist.push(cusObj);
        component.set('v.orderFieldMapperList', customlist);
    },
    callCheckboxMethod : function(component, event, helper) {
        helper.updateEntitlementMapping(component, event);
    }
})