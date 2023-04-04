global with sharing class QuoteLineItemTriggerHandler extends TriggerHelper {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get('QuoteLineItem');
	SentinelQuoteItemTriggerHandler handler = new SentinelQuoteItemTriggerHandler();
    
    global override void processAfterInsert() {
        handler.onAfterInsert(Trigger.new);  
    }
    global override void processAfterUpdate() {
       handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);  
    }
}