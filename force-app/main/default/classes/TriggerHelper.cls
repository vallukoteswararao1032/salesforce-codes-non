global virtual with sharing class TriggerHelper {
    global static Boolean skipTrigger = false;
    public static Boolean skipValidation = false; 
    public static Boolean firstRun = true;
    global void process() {
        System.debug('tigger-Started---------');
        if (!skipTrigger) {
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    processBeforeInsert();
                }
                else if(Trigger.isUpdate){
                    processBeforeUpdate();
                }
                else if(Trigger.isDelete){
                    processBeforeDelete();
                }
                else if(Trigger.isUndelete){
                    processBeforeUndelete();
                }
            }
            else if(Trigger.isAfter){
                if(Trigger.isInsert){
                    processAfterInsert();
                }
                else if(Trigger.isUpdate){
                    processAfterUpdate();
                }
                else if(Trigger.isDelete){
                    processAfterDelete();
                }
                else if(Trigger.isUndelete){
                    processAfterUndelete();
                }
            }
        }
    }

    /* The following methods can be overridden in the sub classes as per the need */

    global virtual void processBeforeInsert() {}
    global virtual void processBeforeUpdate() {}
    global virtual void processBeforeDelete() {}
    global virtual void processBeforeUndelete() {}
    global virtual void processAfterInsert() {}
    global virtual void processAfterUpdate() {}
    global virtual void processAfterDelete() {}
    global virtual void processAfterUndelete() {}

}