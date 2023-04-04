public with sharing class SentinelOrderItemTriggerHandler{
    private Sentinel_User_Info__c configObj;
    private List<Sentinel_Order_Field_Mapping__c> orderMappingFieldList;

    public SentinelOrderItemTriggerHandler(){
        configObj = Sentinel_User_Info__c.getOrgDefaults();
        orderMappingFieldList = Sentinel_Order_Field_Mapping__c.getall().values();
    }

    public void onAfterInsert(List<OrderItem> newOrderItems){
        //EXECUTE AFTER INSERT LOGIC
        Set<Id> odrSet = new Set<Id>();

        Boolean odrSentForProcessing = false;
        for (OrderItem odrItm : newOrderItems){
            if (odrItm.Product2.Thales__c){
                system.debug('++thale=' + odrItm.Product2.Thales__c);
                odrSet.add(odrItm.OrderId);
            }
        }

        for (order odr : [select id
                          from Order
                          where (status = 'Activated' OR status = 'Disable' OR status = 'Commit' OR status = 'Closed') and Eid__c != null and Id IN :odrSet
                          limit 1]){
            if (!SentinelConstants.integrationDone){
                SentinelConstants.integrationDone = true;
                SentinelUtil.syncEntitlements(new Set<String>{ odr.id }, 'update');
            }
        }
    }

    public void onAfterUpdate(List<OrderItem> oldOrderItems, List<OrderItem> updatedOrderItems, Map<Id, OrderItem> OrderItemMap){
        //AFTER UPDATE LOGIC
        Set<String> mappedOdrItemFields = getMappedOrderItemFields();
        Set<Id> odrSet = new Set<Id>();
        system.debug('onAfterUpdate mappedOdrItemFields==' + mappedOdrItemFields);
        Map<Id, OrderItem> ordItmDBRecMap = new Map<Id, OrderItem>();
        List<OrderItem> ordItmDBRecs = [SELECT Id, Product2.Thales__c
                                        FROM OrderItem
                                        WHERE Id IN :OrderItemMap.keySet()];
        ordItmDBRecMap.putAll(ordItmDBRecs);
        if (!mappedOdrItemFields.isEmpty()){
            for (OrderItem odrItm : oldOrderItems){
                OrderItem odrItmDbRec = ordItmDBRecMap.get(odrItm.Id);
                if (odrItmDbRec.Product2.Thales__c){
                    system.debug('++thale=' + odrItmDbRec.Product2.Thales__c);
                    OrderItem newOdrItem = OrderItemMap.get(odrItm.id);
                    for (String field : mappedOdrItemFields){
                        if (odrItm.get(field) != newOdrItem.get(field)){
                            odrSet.add(newOdrItem.OrderId);
                        }
                    }
                }
            }
        }
        system.debug('onAfterUpdate odrSet ==' + odrSet);

        for (order odr : [select id
                          from Order
                          where (status = 'Activated' OR status = 'Disable' OR status = 'Commit' OR status = 'Closed') and Eid__c != null and Id IN :odrSet
                          limit 1]){
            system.debug('onAfterUpdate odr ==' + odr);
            if (!SentinelConstants.integrationDone){
                SentinelConstants.integrationDone = true;
                SentinelUtil.syncEntitlements(new Set<String>{ odr.id }, 'update');
            }
        }
    }

    public Set<String> getMappedOrderItemFields(){
        Set<String> ordFields = new Set<String>();
        for (Sentinel_Order_Field_Mapping__c mapObj : orderMappingFieldList){
            if (!String.isBlank(mapObj.SF_Api_Field__c) && !mapObj.SF_Api_Field__c.contains('.') && mapObj.Category__c.equalsIgnoreCase('Product') && mapObj.sObjectName__c.equalsIgnoreCase('Order')){
                ordFields.add(mapObj.SF_Api_Field__c);
            }
        }
        return ordFields;
    }
}