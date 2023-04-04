global with sharing class QuoteTriggerHandler extends TriggerHelper {
   	SentinelQuoteTriggerHandler1 handler = new SentinelQuoteTriggerHandler1();
    Schema.SObjectType quote1 = Schema.getGlobalDescribe().get('Quote');
    sObject sObj = quote1.newSObject();
   
   
    global override void processBeforeInsert() {
        if (Trigger.new[0].get('EID__c') != null)
            SentinelConstants.isEidEntered = true;
        for (SObject qoutes: (List<sObject>)Trigger.New) {
            qoutes.put('Status', 'Draft');
        }
        system.debug('++eidchecked' + SentinelConstants.isEidEntered);
    }
    global override void processAfterInsert() {
        if (Trigger.new[0].get('EID__c') != null)
            SentinelConstants.isEidEntered = true;

        system.debug('++eidchecked' + SentinelConstants.isEidEntered);

        handler.onAfterInsert(Trigger.new);
    }
    global override void processAfterUpdate() {
        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        
        system.debug('++eidchecked' + SentinelConstants.isEidEntered);
    }
}