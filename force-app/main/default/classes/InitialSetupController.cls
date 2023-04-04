global without sharing class InitialSetupController {
    global static Boolean setupCompleted {get; set;}
  	global static Boolean setupAlreadyCompleted {get; set;}
 	global static Boolean isQuoteEnabled {get; set;}
    global static Boolean isMetadataUpdateNeeded {get; set;}
  
  @AuraEnabled(Cacheable = false)
  global static void checkInitialSetup() {
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get( 'Quote' );
      if(targetType != null) {           
          List<Initial_Setup_Setting__mdt> initialSetupList = [Select Id,DeveloperName,Setup_Completed__c from Initial_Setup_Setting__mdt
                                                                       Where DeveloperName = 'Is_SetUp_Complete'];
          if(initialSetupList[0].Setup_Completed__c == true) {
              setupAlreadyCompleted = true; 
          }
      }
      else {
          setupCompleted = true;
          isQuoteEnabled = false;
			          
              /*MetadataService.MetadataPort service = createService();
      		  MetadataService.Profile admin = (MetadataService.Profile) service.readMetadata('Profile', new String[] { 'Admin' }).getRecords()[0];
        	  MetadataService.ProfileTabVisibility tabVis = new MetadataService.ProfileTabVisibility();
              tabVis.tab = 'thalesnoncpqde__Quote_Field_Mapper';
          	  tabVis.visibility = 'Hidden';
              admin.tabVisibilities = new MetadataService.ProfileTabVisibility[] {tabVis};
              List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { admin });
        	  handleSaveResults(results[0]); */
          
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Quote is not enabled in your org, please contact your system administrator'));
     
      }
  }
  
  @AuraEnabled(Cacheable = false)
  global static void createRemoteSiteSettings() {
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get( 'Quote' );
      if(targetType != null) {  
          try {
              String hostURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
              MetadataService.MetadataPort service = createService();
              MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
              remoteSiteSettings.fullName = 'Host_URL';
              remoteSiteSettings.url = hostURL;
              remoteSiteSettings.description = 'Used for rest callouts';
              remoteSiteSettings.isActive = true;
              remoteSiteSettings.disableProtocolSecurity = false;
              List<MetadataService.UpsertResult> results = service.upsertMetadata( new MetadataService.Metadata[] { remoteSiteSettings });
              handleUpsertResults(results[0]);
              InitialSetupController.createFieldsAndTrigger();
              InitialSetupController.createQuoteFields();
              //InitialSetupController.updateTabVisibilityforQuote();
              
              List<Initial_Setup_Setting__mdt> MetadataSetUpList1  = [Select MasterLabel,Id,DeveloperName,Setup_Completed__c from Initial_Setup_Setting__mdt Where DeveloperName = 'Is_SetUp_Complete'];           
              Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
              
              Metadata.CustomMetadata metadataRecord =  new Metadata.CustomMetadata();
              metadataRecord.fullName = 'Initial_Setup_Setting__mdt.'+ MetadataSetUpList1[0].DeveloperName;
              metadataRecord.label = MetadataSetUpList1[0].MasterLabel;
                           
              Metadata.CustomMetadataValue setupdate = new Metadata.CustomMetadataValue();
              setupdate.field = 'Setup_Completed__c';
              setupdate.value = true;
              metadataRecord.values.add(setupdate);
                            
              mdContainer.addMetadata(metadataRecord);
              Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
        	
              ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
              setupCompleted = true;
                           
          }
          catch(MetadataServiceExamplesException e) {
              System.debug('error-----'+e.getMessage());
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' + e.getMessage())); 
          }
      }
  }
    
    global static void updateTabVisibilityforQuote(){
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = (MetadataService.Profile) service.readMetadata('Profile', new String[] { 'Admin' }).getRecords()[0];
        MetadataService.ProfileTabVisibility tabVis = new MetadataService.ProfileTabVisibility();
        tabVis.tab = 'thalesnoncpqde__Quote_Field_Mapper';
        tabVis.visibility = 'DefaultOn';
        admin.tabVisibilities = new MetadataService.ProfileTabVisibility[] {tabVis};
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { admin });
        		handleSaveResults(results[0]); 
        
    }      
  global static void createFieldsAndTrigger() {
      List<ApexTrigger> apexTriggerList = [SELECT Id,Name FROM ApexTrigger Where Name IN ('SentinelQuoteItemTrigger', 'SentinelSFCPQQuoteTrigger')];
      Boolean createQuoteTrigger = false;
      Boolean createQuoteLineTrigger = false;
      if(apexTriggerList.size() == 0) {
          createQuoteTrigger = true;
          createQuoteLineTrigger = true;
      }
      else {
          for(ApexTrigger trigg: apexTriggerList) {
              if(trigg.Name == 'SentinelQuoteItemTrigger') {
                  createQuoteLineTrigger = false;
              }
              else if(trigg.Name == 'SentinelSFCPQQuoteTrigger') {
                  createQuoteTrigger = false;
              }
          }
      }
      InitialSetupController.createQuoteTrigger(createQuoteTrigger);
      InitialSetupController.createQuoteLineTrigger(createQuoteLineTrigger);
  }
  
  global static void createQuoteTrigger(Boolean createQuoteTrigger) {
      if(createQuoteTrigger == true) {
          String content = 'trigger SentinelSFCPQQuoteTrigger on Quote (before insert, before update, after insert, after update, after delete, after undelete) {\n';
          content += 'new thalesnoncpqde.QuoteTriggerHandler().process();\n' + '}';
          Map < String, String > body = new Map < String, String > {
                  'Name' => 'SentinelSFCPQQuoteTrigger', 'TableEnumOrId' => String.valueOf('Quote'), 'Body' => content };
                  String url = '' + Url.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + 'v48.0' + '/sobjects/' + 'ApexTrigger';
          HttpRequest req = new HttpRequest();
          req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
          req.setHeader('Content-Type', 'application/json');
          req.setMethod('POST');
          req.setBody(JSON.serialize(body));
          req.setEndpoint(url);
          HttpResponse res = new Http().send(req);
          Object[] ob = new Object[] { url, res.getStatusCode(), res.getBody().abbreviate(1000)  };
          String str = String.format('Result of {0} POST is statusCode={1} body={2}', ob);
          System.debug('str-----' + str);
      }
  }
  
  global static void createQuoteLineTrigger(Boolean createQuoteLineTrigger) {
      if(createQuoteLineTrigger == true) {
          String content = 'trigger SentinelQuoteItemTrigger on QuoteLineItem (before insert, before update, after insert, after update, after delete, after undelete) {\n';
          content += 'new thalesnoncpqde.QuoteLineItemTriggerHandler().process();\n' + '}';
          Map < String, String > body = new Map < String, String > {
                  'Name' => 'SentinelQuoteItemTrigger','TableEnumOrId' => String.valueOf('QuoteLineItem'),'Body' => content };
                  String url = '' +Url.getSalesforceBaseUrl().toExternalForm() +'/services/data/' +'v48.0' +'/sobjects/' + 'ApexTrigger';           
          HttpRequest req = new HttpRequest();
          req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
          req.setHeader('Content-Type', 'application/json');
          req.setMethod('POST');
          req.setBody(JSON.serialize(body));
          req.setEndpoint(url);
          HttpResponse res = new Http().send(req);
          Object[] ob = new Object[] { url, res.getStatusCode(), res.getBody().abbreviate(1000)  };
          String str = String.format('Result of {0} POST is statusCode={1} body={2}', ob);
          System.debug('str-----' + str);
      }
  }
  
  global static void createQuoteFields() { 
    
      MetadataService.MetadataPort service = createService();
      
      MetadataService.CustomObject customObject = new MetadataService.CustomObject();
      customObject.fullName = 'Quote_JSON__c';
      customObject.label = 'Quote JSON';
      customObject.pluralLabel = 'Quote JSONs';
      customObject.nameField = new MetadataService.CustomField();
      customObject.nameField.type_x = 'AutoNumber';
      customObject.nameField.label = 'Quote JSON Name';
      customObject.nameField.DisplayFormat = 'QJSON-{00000}'; 
      customObject.deploymentStatus = 'Deployed';
      customObject.sharingModel = 'ReadWrite';
      List<MetadataService.UpsertResult> result = service.upsertMetadata(new MetadataService.Metadata[] { customObject });handleUpsertResults(result[0]);
      
      List < MetadataService.Metadata > allMetadataList = new List < MetadataService.Metadata > ();
      MetadataService.CustomField customField1 = new MetadataService.CustomField();
      customField1.fullName = 'Quote.userRegistration__c';
      customField1.label = 'userRegistration';
      customField1.type_x = 'Text';
      customField1.length = 100;
      allMetadataList.add(customField1);
      
      MetadataService.CustomField customField2 = new MetadataService.CustomField();
      customField2.fullName = 'Quote.EID__c';
      customField2.label = 'EID';
      customField2.type_x = 'Text';
      customField2.length = 200;
      allMetadataList.add(customField2);
      
      MetadataService.CustomField customField3 = new MetadataService.CustomField();
      customField3.fullName = 'Quote.Last_Sync__c';
      customField3.label = 'Last Sync';
      customField3.type_x = 'DateTime';
      allMetadataList.add(customField3);
      
      MetadataService.CustomField customField4 = new MetadataService.CustomField();
      customField4.fullName = 'Quote.Sync_Error__c';
      customField4.label = 'Sync Error';
      customField4.type_x = 'LongTextArea';
      customField4.length = 32768;
      customField4.visibleLines = 3;
      allMetadataList.add(customField4);
      
      MetadataService.CustomField customField5 = new MetadataService.CustomField();
      customField5.fullName = 'Quote_JSON__c.Quote__c';
      customField5.externalId = false;
      customField5.label = 'Quote';
      customField5.referenceTo = 'Quote';
      customField5.relationshipLabel = 'Quote JSONS';
      customField5.relationshipName = 'Quote_JSONs3';
      customField5.relationshipOrder = 0;
      customField5.type_x = 'MasterDetail';
      customField5.writeRequiresMasterRead = true;
      allMetadataList.add(customField5);
      
      List<MetadataService.UpsertResult> results = service.upsertMetadata(allMetadataList);handleUpsertResults(results[0]);
  	  InitialSetupController.updateFieldLevelSecurity();
  } 
  global static void updateFieldLevelSecurity() {
        
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = 'Admin';
        admin.custom = false;
    	//MetadataService.Profile admin = (MetadataService.Profile) service.readMetadata('Profile', new String[] { 'Admin' }).getRecords()[0];
		
        List < MetadataService.ProfileFieldLevelSecurity> allMetadatafieldSec = new List < MetadataService.ProfileFieldLevelSecurity> ();
        
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity(); 
        fieldSec.field='Quote.EID__c';
      	fieldSec.editable=true;
        fieldSec.readable=true;
        allMetadatafieldSec.add(fieldSec);
      
        MetadataService.ProfileFieldLevelSecurity fieldSec1 = new MetadataService.ProfileFieldLevelSecurity();
      	fieldSec1.field='Quote.userRegistration__c';
        fieldSec1.editable=true;
        fieldSec1.readable=true;
        allMetadatafieldSec.add(fieldSec1); 
      
      	MetadataService.ProfileFieldLevelSecurity fieldSec2 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec2.field='Quote.Last_Sync__c';
        fieldSec2.editable=true;
        fieldSec2.readable=true;
        allMetadatafieldSec.add(fieldSec2);
      
      	MetadataService.ProfileFieldLevelSecurity fieldSec3 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec3.field='Quote.Sync_Error__c';
        fieldSec3.editable=true;
        fieldSec3.readable=true;
        allMetadatafieldSec.add(fieldSec3);
      
        admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[allMetadatafieldSec];
      
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { admin });
        handleSaveResults(results[0]);
    }
    
  public static MetadataService.MetadataPort createService() {
      MetadataService.MetadataPort service = new MetadataService.MetadataPort();
      service.SessionHeader = new MetadataService.SessionHeader_element();
      service.SessionHeader.sessionId = UserInfo.getSessionId();
      return service;
  }
  
  global class MetadataServiceExamplesException extends Exception { }
  
  public static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
  {
      // Nothing to see?
      if(upsertResult==null || upsertResult.success)
          return;
      // Construct error message and throw an exception
      if(upsertResult.errors!=null)
      {
          List<String> messages = new List<String>();
          messages.add(
              (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                  'occured processing component ' + upsertResult.fullName + '.');
          for(MetadataService.Error error : upsertResult.errors)
              messages.add(
                  error.message + ' (' + error.statusCode + ').' +
                  ( error.fields!=null && error.fields.size()>0 ?
                      ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
          if(messages.size()>0)
              throw new MetadataServiceExamplesException(String.join(messages, ' '));
      }
      if(!upsertResult.success)
          throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
 public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        System.debug('success_______' + saveResult.success);
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
        	System.debug('success_______' + saveResult.success);
    }
}