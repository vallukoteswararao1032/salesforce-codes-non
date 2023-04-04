/*----------------------------------------------------
* @name           SentinelOrderTrigger 
* @date           10 May 2020
* @description    This is a trigger on order to create/ update entitlement. 
* ------------------------------------------------------*/
trigger SentinelOrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SentinelOrderTriggerHandler handler = new SentinelOrderTriggerHandler();
    
    //Before Insert
    if(Trigger.isInsert && Trigger.isBefore){

    }
     
    //After Insert
    if(Trigger.isInsert && Trigger.isAfter){
        handler.onAfterInsert(Trigger.new);
    }
    //After Update
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
}