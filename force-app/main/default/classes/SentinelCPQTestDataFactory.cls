@isTest
public class SentinelCPQTestDataFactory{
    public static final Set<String> adminAliases = new Set<String>{ 'SPath', 'SKandar' };
    public static Account createAccount(String name, Id parentId, Id podId){

        Account acc = createAccount(name, 'US', 'CPQ Test', podId);
        if (parentId != null){
            acc.ParentId = parentId;
        }
        insert acc;
        return acc;
    }

    public static Account createAccount(String acName, String billingCountry, String BusEntity, id pod){
        return new Account(Name = acName, BillingCountry = billingCountry, AccountNumber = generateRandomString(8), BillingCity = generateRandomString(8), BillingState = generateRandomString(8), BillingPostalCode = generateRandomString(8), ShippingCity = generateRandomString(8), ShippingCountry = generateRandomString(8), ShippingPostalCode = generateRandomString(8)// BusEntity__c=BusEntity,
        // Pod__c =pod
        );
    }

    public static Contact createContact(Id accountId){

        Contact con = new Contact();
        con.AccountId = accountId;
        con.FirstName = 'Test';
        con.LastName = 'Test LastName';
        con.Email = 'test@test.com';
        con.MailingCity = 'City';
        insert con;
        return con;
    }

    public static Contract createContract(Id accountId){
        Contract contract = new Contract(AccountId = accountId, ContractTerm = 12, StartDate = Date.today());
        insert contract;
        return contract;
    }

    /*
     * Code commeneted due to Subscription is not implemented properly
     public static SBQQ__Subscription__c createSubscription(
     Id accountId, Id contractId, Id productId,
     Decimal quantity, Decimal netPrice) {
     return createSubscription(accountId, contractId, productId, quantity, netPrice, TRUE);
     }

     public static SBQQ__Subscription__c createSubscription(
     Id accountId, Id contractId, Id productId,
     Decimal quantity, Decimal netPrice, Boolean isInsert) {

     Date endDate = Date.today().addYears(1);
     SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
     SBQQ__Contract__c = contractId,
     Product2Id = productId,
     Quantity = quantity,
     AccountId = accountId,
     SBQQ__NetPrice__c = netPrice * quantity,
     SBQQ__SubscriptionEndDate__c = endDate);
     if (isInsert) {

     insert subs;
     }
     return subs;


     }
     */
    public static SObject createQuote(Id accountId, Id opportunityId){
        return createQuote(accountId, opportunityId, null);
    }

    public static SObject createQuote(Id accountId, Id opportunityId, Id contactId){
        return createQuote(accountId, opportunityId, contactId, true);
    }

    public static SObject createQuote(Id accountId, Id opportunityId, Id contactId, Boolean isInsert){
        Schema.SObjectType quoteobj = Schema.getGlobalDescribe().get('Quote');
            sObject quote = quoteobj.newSObject();
        	quote.put('OpportunityId' , opportunityId);  
            quote.put('Name' ,'Quote3');     
            quote.put('Status' , 'Presented');
        	quote.put('ContactId' , contactId);
        if (isInsert){

            insert quote;
        }
        return quote;
    }

    public static SObject createQuoteLine(Id quoteId, Id productId, PricebookEntry priceEntry){
           Schema.SObjectType quotelineobj = Schema.getGlobalDescribe().get('QuoteLineItem');
            sObject line = quotelineobj.newSObject();
        	line.put('Product2Id' , productId); 
            line.put('QuoteId' , quoteId); 
            line.put('PricebookEntryId' , priceEntry.Id); 
            line.put('Quantity' , 1); 
            line.put('UnitPrice' , 15);
        //QuoteLineItem line = new QuoteLineItem(Product2Id = productId, QuoteId = quoteId, PricebookEntryId = priceEntry.Id, Quantity = 1, UnitPrice = 15 // Send_to_Thales__c = true);

        insert line;
        return line;
    }

    public static Opportunity createOpportunity(Id accountId, String type, String stage){
        Opportunity opportunity = new Opportunity(AccountId = accountId, Name = type, CloseDate = System.today().addMonths(12), StageName = stage, Pricebook2Id = Test.getStandardPricebookId());
        insert opportunity;
        return opportunity;
    }

    public static PricebookEntry createPricebookEntry(Id productId, Decimal amount){
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productId, UnitPrice = amount, IsActive = true);
        insert pbEntry;
        return pbEntry;
    }

    public static OpportunityLineItem createOpportunityLine(Id opportunityId, Id productId, PricebookEntry priceEntry, Id lineItemId){
        OpportunityLineItem line = new OpportunityLineItem(Product2Id = productId, OpportunityId = opportunityId, PricebookEntryId = priceEntry.Id, TotalPrice = priceEntry.UnitPrice, Quantity = 1);

        insert line;
        return line;
    }

    public static Product2 createProduct(String name, Decimal amount){
        Product2 product = new Product2(Name = name, IsActive = true, Thales__c = true);

        insert product;
        return product;
    }

    public static Order_JSON__c createOrderJson(Id orderId){

        Order_JSON__c orderJson = new Order_JSON__c();
        orderJson.Order__c = orderId;
        insert orderJson;
        createAttachment(orderJson.Id);
        return orderJson;
    }

    public static SObject createQuoteJson(Id quoteId){

        Schema.SObjectType quotjson = Schema.getGlobalDescribe().get('Quote_JSON__c');
            sObject quoteJson = quotjson.newSObject();
        //Quote_JSON__c quoteJson = new Quote_JSON__c();
        quoteJson.put('Quote__c' , quoteId);
        insert quoteJson;
        createAttachment(quoteJson.Id);
        return quoteJson;
    }

    public static void createAttachment(Id parentId){
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = parentId;
        insert attach;
    }

    public static Sentinel_User_Info__c createUserInfo(){
        //   SELECT Order_Sync__c,Quote_Sync__c, Subscription_Sync__c FROM Sentinel_User_Info__c
        Sentinel_User_Info__c userInfo = new Sentinel_User_Info__c();
        userInfo.Order_Sync__c = TRUE;
        userInfo.Quote_Sync__c = TRUE;
        userInfo.Subscription_Sync__c = TRUE;
        userInfo.Username__c = 'testuser';
        userInfo.PAssword__c = 'asdf';
        userInfo.StageUsername__c = 'testuser';
        userInfo.StagePassword__c = 'asdf';
        userInfo.ProdUsername__c = 'testuser';
        userInfo.ProdPassword__c = 'asdf';
        userInfo.Org_URL__c = 'https://test.salesforce.com/abc';
        userInfo.DML_Url__c = 'https://test.dmllesforce.com/xyz';
        userInfo.StageOrg_URL__c = 'https://test.salesforce.com/abc';
        userInfo.StageDML_Url__c = 'https://test.dmllesforce.com/xyz';
        userInfo.ProdOrg_URL__c = 'https://test.salesforce.com/abc';
        userInfo.ProdDML_Url__c = 'https://test.dmllesforce.com/xyz';

        userInfo.Name = 'Primary User';
        userInfo.Selected_Org__c = 'stage';
        insert userInfo;
        return userInfo;
    }

    public static Order createOrder(Account acc, Id pricebookId){
        return createOrder(acc, pricebookId, null);
    }

    public static Order createOrder(Account acc, Id pricebookId, Id contactId){

        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = acc.id;
        o.Pricebook2Id = Test.getStandardPricebookId();
        o.BillToContactId = contactId;
        o.ShipToContactId = contactId;
        insert o;
        return o;
    }

    public static OrderItem createOrderItem(Order ord, Product2 p, Id pricebookId){
        return createOrderItem(ord, p, pricebookId, true);
    }

    public static OrderItem createOrderItem(Order ord, Product2 p, Id pricebookId, Boolean isInsert){
        // Insert Order Item

        OrderItem i = new OrderItem();
        i.OrderId = ord.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId = pricebookId;
        if (isInsert){

            insert i;
        }

        return i;
    }

    public static Sentinel_Order_Field_Mapping__c populateOrdFldMapng(String category, String objName, String fldApiName, String fldSentinelApiName){

        Sentinel_Order_Field_Mapping__c ordFldMaping = new Sentinel_Order_Field_Mapping__c();
        ordFldMaping.Category__c = category;
        ordFldMaping.Field_Description__c = 'Test';
        ordFldMaping.Field_Type__c = 'Text';
        ordFldMaping.SF_Api_Field__c = fldApiName;
        ordFldMaping.Sentinel_Api_Field__c = fldSentinelApiName;
        ordFldMaping.sObjectName__c = objName;
        ordFldMaping.Name = generateRandomString(30);
        return ordFldMaping;
    }

    public static Sentinel_Order_Field_Mapping__c populateOrdCustomFldMapng(String category, String objName, String fldApiName, String fldSentinelApiName){

        Sentinel_Order_Field_Mapping__c ordFldMaping = populateOrdFldMapng(category, objName, fldApiName, fldSentinelApiName);
        ordFldMaping.IsCustomAttribute__c = true;
        return ordFldMaping;
    }

    public static String generateRandomString(Integer len){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
}