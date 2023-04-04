/*----------------------------------------------------
* @name           SentinelQuoteItemTriggerHandler 
* @date           8 Nov 2020
* @description    This is a trigger on Salesforce CPQ object Quote to create/ update entitlement. 
* ------------------------------------------------------*/
public with sharing class SentinelQuoteItemTriggerHandler {
	private Sentinel_User_Info__c configObj;
    private List<Sentinel_Order_Field_Mapping__c> QuoteMappingFieldList; 
    
    public SentinelQuoteItemTriggerHandler(){
        configObj = Sentinel_User_Info__c.getOrgDefaults();
        QuoteMappingFieldList = Sentinel_Order_Field_Mapping__c.getall().values();
    }
	
    public void onAfterInsert(List<SObject> newQuoteItems){
        //EXECUTE AFTER INSERT LOGIC
        Set<Id> quoteSet = new Set<Id>();
		
        Boolean odrSentForProcessing = false;
        Set<Id> productIds = new Set<Id>();
		
        for(SObject quoteItm : newQuoteItems) {
            String prod2Id = (String)quoteItm.get('Product2Id');
            productIds.add(prod2Id);
            System.debug('productIds_____' + productIds);

        }

        Map<ID, Product2> mProduct2 = new Map<ID, Product2>([SELECT Id, Name, Thales__c FROM Product2 WHERE Id IN: productIds ]);
		
        for(SObject quoteItm : newQuoteItems) {
            String prod2Id1 = (String)quoteItm.get('Product2Id');
                   System.debug('prod2Id1____' + prod2Id1);
            Product2 prdt = mProduct2.get(prod2Id1);
            String quotid = (String)quoteItm.get('QuoteId');
            System.debug('quotid11____' + quotid);
            if(prdt.Thales__c)
                quoteSet.add(quotid);
             }
        
       String quotequery = 'SELECT id from Quote where'; // where 
       String condition1 = '(Status = \'Activated\' OR Status = \'Approved\' OR Status = \'Disable\' OR Status = \'Commit\' OR Status = \'Completed\')';
       String condition2 = 'and Eid__c != null and';  //and Id IN :quoteSet limit 1
       String finalquotequery = (quotequery + ' ' +  condition1 + '  ' + condition2 + ' ' + 'Id IN :quoteSet limit 1'); 
        System.debug('finalquery_____' + finalquotequery);
        for(SObject quote : Database.query(finalquotequery)) {
            if(!SentinelConstants.integrationDone) {
                SentinelConstants.integrationDone = true;
                system.debug('onAfterInsert syncQuoteEntitlements called');
                SentinelUtil.syncQuoteEntitlements(new Set<String>{quote.id}, 'update');
            }
        }
    }
     
    public void onAfterUpdate(List<SObject> oldQuoteItems, List<SObject> updatedQuoteItems, Map<Id, SObject> QuoteItemMap){
        //AFTER UPDATE LOGIC
        Set<String> mappedOdrItemFields= getMappedQuoteItemFields();
        Set<Id> quoteSet = new Set<Id>();
        system.debug('onAfterUpdate mappedOdrItemFields==' + mappedOdrItemFields);
        if(!mappedOdrItemFields.isEmpty()) {
            Map<Id, SObject> mQuoteLineDBRec = fetchQuoteLine(oldQuoteItems);
            System.debug('mQuoteLineDBRec__________' + mQuoteLineDBRec.keyset()); 
            Set<Id> prodIds = new Set<Id>();
            Map<Id, Id> mapQLineVsProdIds = new Map<Id, Id>();
            for(SObject quoteItm : oldQuoteItems) {
                System.debug('quoteItm_________' + quoteItm);
                
                SObject quoteLineDBRec = mQuoteLineDBRec.get(quoteItm.Id); //no value is coming 
                		System.debug('quoteLineDBRec____' + quoteLineDBRec);
                Id prodId = (Id)quoteLineDBRec.get('Product2Id');
                prodIds.add(prodId);
                mapQLineVsProdIds.put(quoteItm.Id, prodId);
            }
            List<Product2> prods = [SELECT Id, Thales__c FROM Product2 WHERE ID IN:prodIds];

            if(!prods.isEmpty()) {
                Map<ID, Product2> mapIdProds = new Map<ID, Product2>();
                mapIdProds.putAll(prods);
                for(SObject quoteItm : oldQuoteItems) {
                   //SObject prod2 = (SObject)quoteLineDBRec.get('Product2'); //no value is coming 
                    SObject prod2 = mapIdProds.get(mapQLineVsProdIds.get(quoteItm.Id));
                    
                    System.debug('prod2______' + prod2);
                    Boolean prodthales = (Boolean)prod2.get('Thales__c'); //no value is coming 
                    System.debug('prodthales______' + prodthales);
                    if(prodthales){
                        SObject newOdrItem = QuoteItemMap.get(quoteItm.id);
                        System.debug('newOdrItem______' + newOdrItem);
                        for(String field : mappedOdrItemFields) {
                            if(quoteItm.get(field) != newOdrItem.get(field)) {
                                //SObject quot = (SObject)newOdrItem.get('Quote');
                                //List<Id> quotid = quot.get('Id');
                                Id quoteitemid = (Id)newOdrItem.get('QuoteId');
                                quoteSet.add(quoteitemid);
                                System.debug('quoteSet' + quoteSet);
                            }
                        }
                    } 
                }
 
            }
        }        
        system.debug('onAfterUpdate quoteSet ==' + quoteSet );
	    String quotequery = 'SELECT id from Quote where'; // where 
        String condition1 = '(Status = \'Activated\' OR Status = \'Approved\' OR Status = \'Disable\' OR Status = \'Commit\' OR Status = \'Completed\')';
        String condition2 = 'and Eid__c != null and';  //and Id IN :quoteSet limit 1
        String finalquotequery = (quotequery + ' ' +  condition1 + '  ' + condition2 + ' ' + 'Id IN :quoteSet limit 1'); 
        System.debug('finalquery_____' + finalquotequery);  
        for(SObject quote : Database.query(finalquotequery)) {
            system.debug('onAfterUpdate quote ==' + quote );
            if(!SentinelConstants.integrationDone) {
                SentinelConstants.integrationDone = true;
                system.debug('onAfterUpdate syncQuoteEntitlements called');
                SentinelUtil.syncQuoteEntitlements(new Set<String>{quote.id}, 'update');
            }
        }
    }

    public Set<String> getMappedQuoteItemFields() {
        Set<String> ordFields = new Set<String>();
        for(Sentinel_Order_Field_Mapping__c mapObj : QuoteMappingFieldList) {
            if(!String.isBlank(mapObj.SF_Api_Field__c) && 
                !mapObj.SF_Api_Field__c.contains('.') && 
                mapObj.Category__c.equalsIgnoreCase('ProductQuote') && mapObj.sObjectName__c.equalsIgnoreCase('Quote') ) {
                ordFields.add(mapObj.SF_Api_Field__c);
            }
        }
        return ordFields;
    }
	
    //Schema.SObjectType quoteLines = Schema.getGlobalDescribe().get('QuoteLineItem');
	public Map<Id, SObject> fetchQuoteLine (List<SObject> quoteLines) {
		
        System.debug('quoteLines______' + quoteLines);
        
        //List<SObject> qutlineID = Database.query('SELECT Id FROM QuoteLineItem ');   
        //System.debug('qutlineID____' + qutlineID);
        
        set<Id> quoidset = new set<Id>();
        
        for(SObject quoteid: quoteLines){
            
            String quoid = (String)quoteid.Id;
            System.debug('quoid____' + quoid);
            
            quoidset.add(quoid);
            System.debug('quoidset______' + quoidset);
        }
        
        List<SObject> quoteLineDBRecs = Database.query('SELECT Id, Product2.thalesnoncpqde__Thales__c FROM QuoteLineItem WHERE Id IN: quoidset');
		System.debug('quoteLineDBRecs____' + quoteLineDBRecs);
        
        Map<Id, SObject> mQuoteLineDBRec = new Map<Id, SObject>();
        mQuoteLineDBRec.putAll(quoteLineDBRecs);
          System.debug('mQuoteLineDBRec_____' + mQuoteLineDBRec);
        return mQuoteLineDBRec;
      
		
    }
}