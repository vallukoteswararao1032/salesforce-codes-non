/*----------------------------------------------------
* @name           SentinelOrderItemTrigger 
* @date           10 May 2020
* @description    This is a trigger on order to create/ update entitlement. 
* ------------------------------------------------------*/
trigger SentinelOrderItemTrigger on OrderItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SentinelOrderItemTriggerHandler handler = new SentinelOrderItemTriggerHandler();
     
    //After Insert
    if(Trigger.isInsert && Trigger.isAfter){
        handler.onAfterInsert(Trigger.new);
    }
    //After Update
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
}