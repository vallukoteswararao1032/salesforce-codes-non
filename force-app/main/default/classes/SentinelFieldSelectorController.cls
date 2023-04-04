/*----------------------------------------------------
* @name           SentinelFieldSelectorController 
* @date           15 May 2020
* @description    This is a controller class for SentinelFieldSelector and SentinelOrderFieldMapper components. 
* ------------------------------------------------------*/
public with sharing class SentinelFieldSelectorController {
    @AuraEnabled
    public static List<FieldDisplayWrapper> getFieldMap(String objectApiName) {
        try {
            if(!String.isBlank(objectApiName) && Schema.getGlobalDescribe().get(objectApiName) != NULL) {
                List<FieldDisplayWrapper> fieldList = new List<FieldDisplayWrapper>();
                SObjectType objToken = Schema.getGlobalDescribe().get(objectApiName);
                DescribeSObjectResult objDef = objToken.getDescribe();
                Map<String, SObjectField> fields = objDef.fields.getMap();
                for(String s : fields.keySet())
                {   
                    SObjectField fieldToken = fields.get(s);
                    DescribeFieldResult selectedField = fieldToken.getDescribe();
                    if(selectedField.getName() == 'OwnerId') continue;
                    //if(selectedField.isUpdateable() || selectedField.isAutoNumber()){
                    FieldDisplayWrapper fieldWrapper = new FieldDisplayWrapper();
                    if(selectedField.getLabel().contains(' ID')) {
                        fieldWrapper.fieldLabel = selectedField.getLabel().substring(0, selectedField.getLabel().indexOf(' ID'));
                    } else {
                        fieldWrapper.fieldLabel = selectedField.getLabel();
                    }
                    if(String.valueOf(selectedField.getType()).equalsIgnoreCase('REFERENCE')) {
                        fieldWrapper.fieldLabel += ' >> ';
                    }
                    fieldWrapper.fieldApiName = selectedField.getName();
                    
                    fieldWrapper.fieldType = String.valueOf(selectedField.getType());
                    String refrenceToString = String.valueOf(selectedField.getReferenceTo());
                    refrenceToString = refrenceToString.remove('(');
                    fieldWrapper.referenceToObject = refrenceToString.remove(')');
                    fieldList.add(fieldWrapper);
                    //}
                }
                system.debug('fieldList size=' + fieldList.size());
                if(!fieldList.isEmpty()) {
                    return fieldList;
                }
            }
        } catch (Exception e) {
            system.debug('Error :' + e.getMessage());
        }
        
        return null;
    }
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>(); 
        Schema.SObjectType quoteobj = Schema.getGlobalDescribe().get( 'Quote' );
        if(objectName == 'Order'){           
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();
            List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
            if(nullRequired == true){
                optionlist.add('--None--');
            }       
            for (Schema.PicklistEntry pv : picklistValues) {
                optionlist.add(pv.getValue());
                System.debug('optionlist____' + optionlist);
            }
        }	else if (quoteobj == null){
            throw new AuraHandledException('Quote not Present');
        }
        return optionlist;
    }
    
    @AuraEnabled
    public static List<Sentinel_Order_Field_Mapping__c> getAllMappingData() {
        system.debug('getAllMappingData');
        return Sentinel_Order_Field_Mapping__c.getall().values();
    }
    
    @AuraEnabled
    public static String saveMappingData(List<Sentinel_Order_Field_Mapping__c> updateList, 
         List<Sentinel_Order_Field_Mapping__c> deleteList) {
             try {
                 
                 if(updateList != null && !updateList.isEmpty()) {
                     upsert updateList;
                 }
                 if(deleteList != null && !deleteList.isEmpty()) {
                     delete deleteList;
                 }
             } catch (Exception e){
                 system.debug('Error:' + e.getMessage());
                 return e.getMessage();
             }
             return 'success';
         }
    /**  @AuraEnabled
	public static string updateMappingData(Sentinel_Order_Field_Mapping__c mappingRecord) {
		try {

			if(mappingRecord != null) {
			update mappingRecord;
			}

			} catch (Exception e){
			system.debug('Error:' + e.getMessage());
			return e.getMessage();
			}
			return 'success';
			}**/
    
    @AuraEnabled
    public static string getOrderJson(string orderId) {
        string orderJson;
        try {
            
            if(orderId != null) {
                list<Order_JSON__c> orderJsonList=[Select id, (select id from attachments) from Order_JSON__c where Order__c=:orderId ];
                if(orderJsonList!=null && orderJsonList.size()>0){
                    List<attachment> attList=[Select id, body from attachment where id =: orderJsonList[0].attachments[0].id];
                    orderJson=(attList[0].body).tostring();
                }   
            }
            system.debug('orderJson-------- '+orderJson);
        } catch (Exception e){
            system.debug('Error:' + e.getMessage());
            return e.getMessage();
        }
        return orderJson;
    }
    @AuraEnabled
    public static string updateFeatures(object jsonEntilementObj, string orderId){
        try{
            Order odr=[select id, Eid__c ,Last_Sync__c from Order where Id =: orderId];
            SentinelUtil.createEntitleMent(String.valueOf(jsonEntilementObj), odr,'update');
            system.debug('udate features');
        } catch(Exception e){
            
        }
        return 'Success';
    }
    
    // added , to check on user setting level which is checked , Quote/Subscription/Order, hide field mapper option, 24 Nov 2020
    @AuraEnabled
    public static string checkEnabled(){
        string strIsChecked='';
        List<Sentinel_User_Info__c> usrInfo = [SELECT Order_Sync__c,Quote_Sync__c, Subscription_Sync__c FROM Sentinel_User_Info__c limit 1];
        if(usrInfo.size() > 0){
            if(usrInfo[0].Order_Sync__c)
                strIsChecked = 'Order~';
            if(usrInfo[0].Quote_Sync__c)
                strIsChecked = strIsChecked +'Quote~';
            if(usrInfo[0].Subscription_Sync__c)
                strIsChecked = strIsChecked +'Subscription'; 
            //Order~Quote~Subscription
            
        }
        system.debug('QQQQQ  '+strIsChecked);
        
        return strIsChecked;
    }
    
    @testVisible
    public class FieldDisplayWrapper{
        @AuraEnabled 
        public String fieldLabel{get;set;}
        @AuraEnabled 
        public String fieldApiName{get;set;}
        @AuraEnabled 
        public String fieldType{get;set;}
        @AuraEnabled 
        public String referenceToObject{get;set;}
    }
}