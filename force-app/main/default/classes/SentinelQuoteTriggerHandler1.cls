public with sharing class SentinelQuoteTriggerHandler1{
    private Sentinel_User_Info__c configObj;
    private List<Sentinel_Order_Field_Mapping__c> quoteMappingFieldList;
    Schema.SObjectType quote1 = Schema.getGlobalDescribe().get('Quote');
         sObject sObj = quote1.newSObject();
	
    public SentinelQuoteTriggerHandler1(){
        configObj = Sentinel_User_Info__c.getOrgDefaults();
        quoteMappingFieldList = Sentinel_Order_Field_Mapping__c.getall().values();
    }

    public void onAfterInsert(List<sObject> newQuotes){
        //EXECUTE AFTER INSERT LOGIC
        //SentinelUtil.syncEntitlements(new Set<String>{newQuotes[0].id}, 'create');
    }

    public void onAfterUpdate(List<sObject> oldQuotes, List<sObject> updatedQuotes, Map<Id, sObject> QuoteMap){
        //AFTER UPDATE LOGIC
        Set<String> mappedQuoteFields = getMappedQuoteFields();
        Boolean quoteSentForProcessing = false;

        system.debug('++eidchecked1' + SentinelConstants.isEidEntered);

        if (!mappedQuoteFields.isEmpty()){
            for (sObject quote : oldQuotes){
                sObject newQuote = QuoteMap.get(quote.id);
                System.debug('quote Status : ' + quote.get('Status'));
                System.debug('quote EID : ' + quote.get('EID__c'));
                System.debug('quote Last Sync: ' + newQuote.get('Last_Sync__c'));
                System.debug('newQuote Status: ' + newQuote.get('Status'));
                System.debug('newQuote EID: ' + newQuote.get('EID__c'));
                if (updatedQuotes.size() > 0){
                    System.debug('updateQuote Status: ' + updatedQuotes.get(0).get('Status'));
                    System.debug('updateQuote EID: ' + updatedQuotes.get(0).get('EID__c'));
                }
                system.debug('Checking Logic started');
                
                String statusvalue =(String)newQuote.get('Status');
                if (quote.get('Status') != newQuote.get('Status') && (statusvalue.equalsIgnoreCase('Activated') || statusvalue.equalsIgnoreCase('Approved') || statusvalue.equalsIgnoreCase('Disable') || statusvalue.equalsIgnoreCase('Commit') 
                || statusvalue.equalsIgnoreCase('Completed'))){
                    if (!SentinelConstants.integrationDone){
                        SentinelConstants.integrationDone = true;

                        System.debug('Case-1 executed ' + newQuote.get('Status'));
                        system.debug('++A1' + quote.get('Status'));
                        system.debug('++A1' + quote.get('EID__c'));
                        system.debug('++A1' + newQuote.get('Status'));
                        system.debug('++A1' + newQuote.get('EID__c'));

                        if (quote.get('Status') == 'Draft' && quote.get('EID__c') != null){
                            if (quote.get('Last_Sync__c') == null){
                                SentinelUtil.syncQuoteEntitlements(new Set<String>{newQuote.id}, 'createWithEid');
                            } else{
                                system.debug('QT-update-1');
                                SentinelUtil.syncQuoteEntitlements(new Set<String>{newQuote.id}, 'update');
                            }
                        } else if (quote.get('EID__c') == null && newQuote.get('EID__c') == null)
                            SentinelUtil.syncQuoteEntitlements(new Set<String>{newQuote.id}, 'create');
                        else if (quote.get('EID__c') != null && quote.get('Last_Sync__c') != null){
                            system.debug('QT-update-2');
                            SentinelUtil.syncQuoteEntitlements(new Set<String>{newQuote.id}, 'update');
                        }
                        quoteSentForProcessing = true;
                        break;
                    }
                } else if (statusvalue.equalsIgnoreCase('Activated') || statusvalue.equalsIgnoreCase('Approved') || statusvalue.equalsIgnoreCase('Disable') || statusvalue.equalsIgnoreCase('Commit')
                || statusvalue.equalsIgnoreCase('Completed')){
                    if (!System.isFuture()){
						
                        system.debug('++A1' + quote);

                        for (String field : mappedQuoteFields){
                            system.debug('++A1' + quote.get(field));
                            system.debug('++A2' + newQuote.get(field));
                            system.debug('field___' + field);
                            if (quote.get(field) != newQuote.get(field)){
                                if (!SentinelConstants.integrationDone){
                                    SentinelConstants.integrationDone = true;
                                    system.debug('++A1' + quote);
                                    System.debug('Case-2 executed ' + newQuote.get('Status'));
                                    SentinelUtil.syncQuoteEntitlements(new Set<String>{newQuote.id}, 'update');
                                    quoteSentForProcessing = true;
                                    break;
                                }
                            }
                        }
                    } else{
                        system.debug('Case-2 else case executed');
                    }
                } else{
                    system.debug('Case-3 executed ' + newQuote.get('Status'));
                }
                system.debug('Checking Logic completed');
                if (quoteSentForProcessing)
                    break;
            }
        }
    }

    public Set<String> getMappedQuoteFields(){
        Set<String> quoteFields = new Set<String>();
        System.debug('quoteFields____'  + quoteFields);
        for (Sentinel_Order_Field_Mapping__c mapObj : quoteMappingFieldList){
            system.debug('Mapping Field Id:' + mapObj.Id);
            System.debug('mapObj____' + mapObj.SF_Api_Field__c);
            // system.debug(mapObj);
            if (!String.isBlank(mapObj.SF_Api_Field__c) && !mapObj.SF_Api_Field__c.contains('.') && !mapObj.Category__c.equalsIgnoreCase('ProductQuote') && mapObj.sObjectName__c.equalsIgnoreCase('Quote')){
                quoteFields.add(mapObj.SF_Api_Field__c);
            }
        }
        System.debug('quoteFields____' + quoteFields);
        return quoteFields;
    	}
	}