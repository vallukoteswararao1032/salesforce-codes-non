/*----------------------------------------------------
 * @name           SentinelOrderTriggerHandler
 * @date           10 May 2020
 * @description    This is a handler class for SentinelOrderTrigger.
 * ------------------------------------------------------*/
public with sharing class SentinelOrderTriggerHandler{
    private Sentinel_User_Info__c configObj;
    private List<Sentinel_Order_Field_Mapping__c> orderMappingFieldList;

    public SentinelOrderTriggerHandler(){
        configObj = Sentinel_User_Info__c.getOrgDefaults();
        orderMappingFieldList = Sentinel_Order_Field_Mapping__c.getall().values();
    }

    public void onAfterInsert(List<Order> newOrders){
        //EXECUTE AFTER INSERT LOGIC
        //SentinelUtil.syncEntitlements(new Set<String>{newOrders[0].id}, 'create');
    }

    public void onAfterUpdate(List<Order> oldOrders, List<Order> updatedOrders, Map<Id, Order> OrderMap){
        //AFTER UPDATE LOGIC
       // Map<String,String> checkodrstatus = checkstatusmapping();
        Map<String, String> sentinelToOrderStatusMap = new Map<String, String>();
        sentinelToOrderStatusMap = getMappedodrstatusvalue();
        System.debug('sentinelToOrderStatusMap-----'+sentinelToOrderStatusMap);

        Set<String> mappedOdrFields = getMappedOrderFields(); 
        Boolean odrSentForProcessing = false;        
        if (!mappedOdrFields.isEmpty() || !sentinelToOrderStatusMap.isEmpty()){
            for (Order odr : oldOrders){
                Order newOdr = OrderMap.get(odr.id);
                System.debug('newOdr-----'+newOdr);
                System.debug('newOdr-----'+newOdr.EID__c);
                System.debug('newOdr-----'+checkStatus(newOdr.Status));
                //newOdr.Status.equalsIgnoreCase('Activated') || newOdr.Status.equalsIgnoreCase('Disable') || newOdr.Status.equalsIgnoreCase('Commit') || newOdr.Status.equalsIgnoreCase('Closed')
                if (odr.Status != newOdr.Status && newOdr.Status != 'Draft' && (sentinelToOrderStatusMap.get('Commit') != null || sentinelToOrderStatusMap.get('Closed') != null || sentinelToOrderStatusMap.get('Disable') != null) && (checkStatus(newOdr.Status)) && newOdr.EID__c == null){
                    System.debug('in loop 1');
                    if (!SentinelConstants.integrationDone){
                        SentinelConstants.integrationDone = true;
                        SentinelUtil.syncEntitlements(new Set<String>{ newOdr.id }, 'create');
                        odrSentForProcessing = true;
                        break;
                    }
                } else if ((sentinelToOrderStatusMap.get('Commit') != null || sentinelToOrderStatusMap.get('Closed') != null || sentinelToOrderStatusMap.get('Disable') != null) && (checkStatus(newOdr.Status)) && newOdr.Status != 'Draft'){
                    //newOdr.Status.equalsIgnoreCase('Activated') || newOdr.Status.equalsIgnoreCase('Disable') || newOdr.Status.equalsIgnoreCase('Commit') || newOdr.Status.equalsIgnoreCase('Closed')
                    if (!System.isFuture()){
                        System.debug('in loop 2');                        
                        for (String field : mappedOdrFields){
                            System.debug('field----'+field);
                            System.debug('field----'+odr.get(field));
                            System.debug('field----'+newOdr.get(field));
                            System.debug('SentinelConstants.integrationDone----'+SentinelConstants.integrationDone);
                            if (odr.get(field) != newOdr.get(field)){
                                if (!SentinelConstants.integrationDone){
                                    SentinelConstants.integrationDone = true;
                                    SentinelUtil.syncEntitlements(new Set<String>{ newOdr.id }, 'update');
                                    odrSentForProcessing = true;
                                    break;
                                }
                            }
                            if (odr.get('Status') != newOdr.get('Status')){
                                System.debug('Status----'+odr.get('Status'));
                                System.debug('Status----'+newOdr.get('Status'));
                                if (!SentinelConstants.integrationDone){
                                    SentinelConstants.integrationDone = true;
                                    SentinelUtil.syncEntitlements(new Set<String>{ newOdr.id }, 'update');
                                    odrSentForProcessing = true;
                                    break;
                                }
                            }
                        }
                    }
                }else {
                    if (newOdr != null && newOdr.Status != null && newOdr.Status == 'Draft' && (sentinelToOrderStatusMap.get(newOdr.Status) != null)){
                        system.debug('OT-Odr No need to call becoz it is in Draft state');
                    } else{
                        system.debug('OT-Odr other case');
                    }
                }
                if (odrSentForProcessing)
                    break;
            }
        }
    }

    public Set<String> getMappedOrderFields(){
        Set<String> ordFields = new Set<String>();
        for (Sentinel_Order_Field_Mapping__c mapObj : orderMappingFieldList){
            if (mapObj.sObjectName__c.equalsIgnoreCase('Order') && !String.isBlank(mapObj.SF_Api_Field__c) && !mapObj.SF_Api_Field__c.contains('.') && !mapObj.Category__c.equalsIgnoreCase('Product')){
                ordFields.add(mapObj.SF_Api_Field__c);
            }
        }
        return ordFields;
    }
    public Map<String, String> getMappedodrstatusvalue(){
        Map<String, String> ordFieldValue = new Map<String, String>();
        for (Sentinel_Order_Field_Mapping__c mapstatus : orderMappingFieldList){
            if (mapstatus.sObjectName__c.equalsIgnoreCase('Order') && !String.isBlank(mapstatus.SF_orderfield_value__c) && !mapstatus.SF_orderfield_value__c.contains('.') && !mapstatus.Category__c.equalsIgnoreCase('Product')){
                ordFieldValue.put(mapstatus.SF_orderfield_value__c, mapstatus.Sentinel_Status_value__c);
                System.debug('ordFieldValue_____' + ordFieldValue);
            }
        }
        return ordFieldValue;
    }

    public Boolean checkStatus(String key){
        Map<String, String> sentinelToOrderStatusMap = new Map<String, String>();
        sentinelToOrderStatusMap = getMappedodrstatusvalue();
        if(sentinelToOrderStatusMap.get(key) != null) {
            System.debug('key0000---'+sentinelToOrderStatusMap.get(key));
            return true;
        }
        return false;
    }         
}