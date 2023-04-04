@isTest
public class SentinelFunctionalityUtil{
    static Account acc;
    static Opportunity opp;
    static Contact con;
    static Product2 product;
    static Integer s_num = 1;
    static PricebookEntry pbe;
    static SObject qt;  //changed 9th Jan 2022 (Quote SObject)
    static SObject quoteLine; //changed 9th Jan 2022 (QuoteLineItem SObject)
    public static Order ord;
    static OrderItem ordItm;

    public static void setupTestData(){


        Test.startTest();
        List<Sentinel_Order_Field_Mapping__c> ordFldMapings = new List<Sentinel_Order_Field_Mapping__c>();

        // Test data setup for Order
        Sentinel_Order_Field_Mapping__c ordFldMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Order', 'Order', 'Status', '');
        Sentinel_Order_Field_Mapping__c ordFldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Order', 'Order', 'Name', '');
        Sentinel_Order_Field_Mapping__c ordEnt1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Entitlement', 'Order', 'EID__c', 'EID');
        Sentinel_Order_Field_Mapping__c ordEnt2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Entitlement', 'Order', 'PoNumber', 'refId1');
        Sentinel_Order_Field_Mapping__c ordEnt3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Entitlement', 'Order', 'Account.AccountNumber', 'refId2');
        Sentinel_Order_Field_Mapping__c ordEnt4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Entitlement', 'Order', 'userRegistration__c', 'userRegistration');
        Sentinel_Order_Field_Mapping__c ordEnt5FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('Entitlement', 'Order', 'Account.Name', 'Order Type');

        ordFldMapings.add(ordFldMaping);
        ordFldMapings.add(ordFldNameMaping);
        ordFldMapings.add(ordEnt1FldNameMaping);
        ordFldMapings.add(ordEnt2FldNameMaping);
        ordFldMapings.add(ordEnt3FldNameMaping);
        ordFldMapings.add(ordEnt4FldNameMaping);
        ordFldMapings.add(ordEnt5FldNameMaping);

        Sentinel_Order_Field_Mapping__c ordItmFldMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Product', 'Order', 'Quantity', '');
        ordFldMapings.add(ordItmFldMaping);

        Sentinel_Order_Field_Mapping__c ordC1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Customer', 'Order', 'Account.AccountNumber', 'externalId');
        Sentinel_Order_Field_Mapping__c ordC2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Customer', 'Order', 'Account.Name', 'customerName');
        Sentinel_Order_Field_Mapping__c ordC3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Customer', 'Order', 'Account.BillingCountry', 'customerIdentifier');
        Sentinel_Order_Field_Mapping__c ordC4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Customer', 'Order', 'Account.BillingState', 'refId');
        //Sentinel_Order_Field_Mapping__c ordC5FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('Customer', 'Order', 'Account.BillingCity', 'Customer 1');
        ordFldMapings.add(ordC1FldNameMaping);
        ordFldMapings.add(ordC2FldNameMaping);
        ordFldMapings.add(ordC3FldNameMaping);
        ordFldMapings.add(ordC4FldNameMaping);
        //ordFldMapings.add(ordC5FldNameMaping);

        Sentinel_Order_Field_Mapping__c ordCC1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.ShippingCity', 'shippingAddress.city');
        Sentinel_Order_Field_Mapping__c ordCC2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.ShippingCountry', 'shippingAddress.country');
        Sentinel_Order_Field_Mapping__c ordCC3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.ShippingState', 'shippingAddress.state');
        Sentinel_Order_Field_Mapping__c ordCC4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.ShippingPostalCode', 'shippingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c ordCC5FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.Name', 'contactName');
        Sentinel_Order_Field_Mapping__c ordCC6FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.BillingCity', 'billingAddress.city');
        Sentinel_Order_Field_Mapping__c ordCC7FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.BillingCountry', 'billingAddress.country');
        Sentinel_Order_Field_Mapping__c ordCC8FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.BillingState', 'billingAddress.state');
        Sentinel_Order_Field_Mapping__c ordCC9FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'Account.BillingPostalCode', 'billingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c ordCC10FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContact', 'Order', 'BillToContact.Email', 'contactEmail');
        Sentinel_Order_Field_Mapping__c ordCC11FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('CustomerContact', 'Order', 'Account.ShippingCity', 'Alias Name');
        ordFldMapings.add(ordCC1FldNameMaping);
        ordFldMapings.add(ordCC2FldNameMaping);
        ordFldMapings.add(ordCC3FldNameMaping);
        ordFldMapings.add(ordCC4FldNameMaping);
        ordFldMapings.add(ordCC5FldNameMaping);
        ordFldMapings.add(ordCC6FldNameMaping);
        ordFldMapings.add(ordCC7FldNameMaping);
        ordFldMapings.add(ordCC8FldNameMaping);
        ordFldMapings.add(ordCC9FldNameMaping);
        ordFldMapings.add(ordCC10FldNameMaping);
        ordFldMapings.add(ordCC11FldNameMaping);

        Sentinel_Order_Field_Mapping__c ordCP1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.AccountNumber', 'partnerIdentifier');
        Sentinel_Order_Field_Mapping__c ordCP2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.AccountNumber', 'externalId');
        Sentinel_Order_Field_Mapping__c ordCP3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.AccountNumber', 'refId1');
        Sentinel_Order_Field_Mapping__c ordCP4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.ShippingPostalCode', 'shippingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c ordCP5FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.Name', 'partnerName');
        Sentinel_Order_Field_Mapping__c ordCP6FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.BillingCity', 'billingAddress.city');
        Sentinel_Order_Field_Mapping__c ordCP7FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.BillingCountry', 'billingAddress.country');
        Sentinel_Order_Field_Mapping__c ordCP8FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.BillingState', 'billingAddress.state');
        Sentinel_Order_Field_Mapping__c ordCP9FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartner', 'Order', 'Account.BillingPostalCode', 'billingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c ordCP10FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('ChannelPartner', 'Order', 'Account.Name', 'Alias Name');
        ordFldMapings.add(ordCP1FldNameMaping);
        ordFldMapings.add(ordCP2FldNameMaping);
        ordFldMapings.add(ordCP3FldNameMaping);
        ordFldMapings.add(ordCP4FldNameMaping);
        ordFldMapings.add(ordCP5FldNameMaping);
        ordFldMapings.add(ordCP6FldNameMaping);
        ordFldMapings.add(ordCP7FldNameMaping);
        ordFldMapings.add(ordCP8FldNameMaping);
        ordFldMapings.add(ordCP9FldNameMaping);
        ordFldMapings.add(ordCP10FldNameMaping);

        Sentinel_Order_Field_Mapping__c ordLI1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Product', 'Order', 'Product2.ProductCode', 'activationMethod');
        Sentinel_Order_Field_Mapping__c ordLI2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Product', 'Order', 'Product2.ProductCode', 'externalId');
        Sentinel_Order_Field_Mapping__c ordLI3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Product', 'Order', 'itemState__c', 'itemState');
        ordFldMapings.add(ordLI1FldNameMaping);
        ordFldMapings.add(ordLI2FldNameMaping);
        ordFldMapings.add(ordLI3FldNameMaping);

		Sentinel_Order_Field_Mapping__c ordES1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('EntitlementStatus', 'Order', 'Status', 'Draft');
        ordFldMapings.add(ordES1FldNameMaping);
        
        // Test data setup for Quote
        Sentinel_Order_Field_Mapping__c quoteFldMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('Quote', 'Quote', '', '');
        Sentinel_Order_Field_Mapping__c quoteEnt1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('EntitlementQuote', 'Quote', 'EID__c', 'EID');
        Sentinel_Order_Field_Mapping__c quoteEnt2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('EntitlementQuote', 'Quote', 'Account.AccountNumber', 'refId1');
        Sentinel_Order_Field_Mapping__c quoteEnt3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('EntitlementQuote', 'Quote', 'Account.AccountNumber', 'refId2');
        Sentinel_Order_Field_Mapping__c quoteEnt4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('EntitlementQuote', 'Quote', 'userRegistration__c', 'userRegistration');
        Sentinel_Order_Field_Mapping__c quoteEnt5FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('EntitlementQuote', 'Quote', 'Account.Name', 'Order Type');

        ordFldMapings.add(quoteFldMaping);
        ordFldMapings.add(quoteEnt1FldNameMaping);
        ordFldMapings.add(quoteEnt2FldNameMaping);
        ordFldMapings.add(quoteEnt3FldNameMaping);
        ordFldMapings.add(quoteEnt4FldNameMaping);
        ordFldMapings.add(quoteEnt5FldNameMaping);

        Sentinel_Order_Field_Mapping__c quoteItmFldMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ProductQuote', 'Quote', 'Quantity', 'totalQuantity');
        ordFldMapings.add(quoteItmFldMaping);

        Sentinel_Order_Field_Mapping__c quoteC1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerQuote', 'Quote', 'Account.AccountNumber', 'externalId');
        Sentinel_Order_Field_Mapping__c quoteC2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerQuote', 'Quote', 'Account.Name', 'customerName');
        Sentinel_Order_Field_Mapping__c quoteC3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerQuote', 'Quote', 'Account.AccountNumber    ', 'customerIdentifier');
        Sentinel_Order_Field_Mapping__c quoteC4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerQuote', 'Quote', 'Account.AccountNumber', 'refId');
        Sentinel_Order_Field_Mapping__c quoteC5FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('CustomerQuote', 'Quote', 'Account.Name', 'Customer 1');
        ordFldMapings.add(quoteC1FldNameMaping);
        ordFldMapings.add(quoteC2FldNameMaping);
        ordFldMapings.add(quoteC3FldNameMaping);
        ordFldMapings.add(quoteC4FldNameMaping);
        ordFldMapings.add(quoteC5FldNameMaping);

        Sentinel_Order_Field_Mapping__c quoteCC1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.ShippingStreet', 'shippingAddress.city');
        Sentinel_Order_Field_Mapping__c quoteCC2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.ShippingCountry', 'shippingAddress.country');
        Sentinel_Order_Field_Mapping__c quoteCC3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.ShippingState', 'shippingAddress.state');
        Sentinel_Order_Field_Mapping__c quoteCC4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.ShippingPostalCode', 'shippingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c quoteCC5FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.Name', 'contactName');
        Sentinel_Order_Field_Mapping__c quoteCC6FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.BillingCity', 'billingAddress.city');
        Sentinel_Order_Field_Mapping__c quoteCC7FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.BillingCountry', 'billingAddress.country');
        Sentinel_Order_Field_Mapping__c quoteCC8FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.BillingState', 'billingAddress.state');
        Sentinel_Order_Field_Mapping__c quoteCC9FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Account.BillingPostalCode', 'billingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c quoteCC10FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('CustomerContactQuote', 'Quote', 'Email', 'contactEmail');
        Sentinel_Order_Field_Mapping__c quoteCC11FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('CustomerContactQuote', 'Quote', 'Account.Name', 'Alias Name');
        ordFldMapings.add(quoteCC1FldNameMaping);
        ordFldMapings.add(quoteCC2FldNameMaping);
        ordFldMapings.add(quoteCC3FldNameMaping);
        ordFldMapings.add(quoteCC4FldNameMaping);
        ordFldMapings.add(quoteCC5FldNameMaping);
        ordFldMapings.add(quoteCC6FldNameMaping);
        ordFldMapings.add(quoteCC7FldNameMaping);
        ordFldMapings.add(quoteCC8FldNameMaping);
        ordFldMapings.add(quoteCC9FldNameMaping);
        ordFldMapings.add(quoteCC10FldNameMaping);
        ordFldMapings.add(quoteCC11FldNameMaping);

        Sentinel_Order_Field_Mapping__c quoteCP1FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.AccountNumber', 'partnerIdentifier');
        Sentinel_Order_Field_Mapping__c quoteCP2FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.AccountNumber', 'externalId');
        Sentinel_Order_Field_Mapping__c quoteCP3FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.AccountNumber', 'refId1');
        Sentinel_Order_Field_Mapping__c quoteCP4FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.ShippingPostalCode', 'shippingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c quoteCP5FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.Name', 'partnerName');
        Sentinel_Order_Field_Mapping__c quoteCP6FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.BillingCity', 'billingAddress.city');
        Sentinel_Order_Field_Mapping__c quoteCP7FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.BillingCountry', 'billingAddress.country');
        Sentinel_Order_Field_Mapping__c quoteCP8FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.BillingState', 'billingAddress.state');
        Sentinel_Order_Field_Mapping__c quoteCP9FldNameMaping = SentinelCPQTestDataFactory.populateOrdFldMapng('ChannelPartnerQuote', 'Quote', 'Account.BillingPostalCode', 'billingAddress.postalCode');
        Sentinel_Order_Field_Mapping__c quoteCP10FldNameMaping = SentinelCPQTestDataFactory.populateOrdCustomFldMapng('ChannelPartnerQuote', 'Quote', 'Account.Name', 'Alias Name');
        ordFldMapings.add(quoteCP1FldNameMaping);
        ordFldMapings.add(quoteCP2FldNameMaping);
        ordFldMapings.add(quoteCP3FldNameMaping);
        ordFldMapings.add(quoteCP4FldNameMaping);
        ordFldMapings.add(quoteCP5FldNameMaping);
        ordFldMapings.add(quoteCP6FldNameMaping);
        ordFldMapings.add(quoteCP7FldNameMaping);
        ordFldMapings.add(quoteCP8FldNameMaping);
        ordFldMapings.add(quoteCP9FldNameMaping);
        ordFldMapings.add(quoteCP10FldNameMaping);

        insert ordFldMapings;

        // Pod__c pod = SentinelCPQTestDataFactory.createTestPod('CPQ Test',true);

        SentinelCPQTestDataFactory.createUserInfo();
        //List<sObject> ls = Test.loadData(Sentinel_Order_Field_Mapping__c.sObjectType, 'Sentinel_Order_Field_Mapping');
        List<Sentinel_Order_Field_Mapping__c> ls = SentinelUtil.getListOrderMapFields(SentinelConstants.categoryVsSentinelFieldMap, false);
        acc = SentinelCPQTestDataFactory.createAccount('Test Account', null, null);


        opp = SentinelCPQTestDataFactory.createOpportunity(acc.Id, 'Multiple', 'Prospecting');
        con = SentinelCPQTestDataFactory.createContact(acc.Id);
        product = SentinelCPQTestDataFactory.createProduct('Product X', 100);
        System.debug('$$$ product ' + product);
        pbe = SentinelCPQTestDataFactory.createPricebookEntry(product.Id, 100);

        Test.stopTest();
    }

    public static void populateData(){
        acc = [SELECT Id
               FROM Account
               LIMIT 01];
        opp = [SELECT Id
               FROM Opportunity
               LIMIT 01];
        con = [SELECT Id
               FROM Contact
               Limit 01];
        pbe = [SELECT Id
               FROM PriceBookEntry
               Limit 01];
        product = [SELECT Id, Name, Thales__c
                   FROM Product2
                   Limit 01];
        /*
         qt = [SELECT Id FROM Quote];
         quoteLine = [SELECT Id FROM QuoteLineItem];
         ord = [SELECT Id FROM Order];
         ordItm = [SELECT Id FROM OrderItem];
         */
        createData();
    }

    
    static void createData(){
		
        qt = SentinelCPQTestDataFactory.createQuote(acc.Id, opp.Id, con.Id, false);
        qt.put('Status' , 'Activated');
        qt.put('EID__c' , qt.Id);
        insert qt;
        quoteLine = SentinelCPQTestDataFactory.createQuoteLine(qt.Id, product.Id, pbe);

        ord = SentinelCPQTestDataFactory.createOrder(acc, pbe.Id, con.Id);
        ord.put('QuoteId' , qt.Id);
        ordItm = SentinelCPQTestDataFactory.createOrderItem(ord, product, pbe.Id, FALSE);
        // ordItm.QuoteLineItemId = quoteLine.Id;

        insert ordItm;
    }

    public static void updateQuote(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        acc = [SELECT Id
               FROM Account
               LIMIT 01];
        opp = [SELECT Id
               FROM Opportunity
               LIMIT 01];
        con = [SELECT Id
               FROM Contact
               Limit 01];
        pbe = [SELECT Id
               FROM PriceBookEntry
               Limit 01];
        product = [SELECT Id
                   FROM Product2
                   Limit 01];
        Test.startTest();
        qt = SentinelCPQTestDataFactory.createQuote(acc.Id, opp.Id, con.Id, false);
        qt.put('Status', 'Draft');

        insert qt;
        qt.put('Status' , 'Activated');
        update qt;
        Test.stopTest();

    }

    public static void updateOrders(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());

        populateData();
        String recId = getFakeId(Order.SObjectType);
        // Order oldOrd = SentinelCPQTestDataFactory.createOrder(acc, pbe.Id, con.Id);
        Order oldOrd = ord;
        oldOrd.Status = 'Activated';
        oldOrd.Id = recId;

        Order newOrd = oldOrd.clone();
        newOrd.Status = 'Activated';
        newOrd.Id = recId;
        newOrd.Name = newOrd.Id + ' Test';
        List<Order> newOrds = new List<Order>{ newOrd };
        List<Order> oldOrds = new List<Order>{ oldOrd };
        Map<Id, Order> newOrdMap = new Map<Id, Order>();
        newOrdMap.putAll(newOrds);
        SentinelOrderTriggerHandler hndlr = new SentinelOrderTriggerHandler();
        hndlr.onAfterUpdate(oldOrds, newOrds, newOrdMap);

        Test.stopTest();

    }


    public static void updateOrderItems(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        populateData();

        SentinelOrderItemTriggerHandler hndlr = new SentinelOrderItemTriggerHandler();
        List<OrderItem> newOrdItms = new List<OrderItem>{ ordItm };
        Map<Id, OrderItem> newOrdItmMap = new Map<Id, OrderItem>();
        newOrdItmMap.putAll(newOrdItms);

        OrderItem oldOrdItm = ordItm.clone();
        oldOrdItm.Id = ordItm.Id;
        oldOrdItm.Quantity *= 2;
        List<OrderItem> oldOrdItms = new List<OrderItem>{ oldOrdItm };

        hndlr.onAfterUpdate(newOrdItms, oldOrdItms, newOrdItmMap);
        Test.stopTest();

    }

    public static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }

    public static void updateQuote2(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());

    	Schema.SObjectType quoteobj = Schema.getGlobalDescribe().get('Quote');
        String recId = getFakeId(quoteobj);
    
        sObject oldQte = quoteobj.newSObject();
        //Quote oldQte = new Quote();
        oldQte.put('Status' , 'Activated');
        oldQte.Id = recId;

        sObject qte = quoteobj.newSObject();
        qte.put('Status' , 'Activated');
        qte.Id = recId;
        List<SObject> newQts = new List<SObject>{ qte };
        List<SObject> oldQts = new List<SObject>{ oldQte };
        Map<Id, SObject> newQtMap = new Map<Id, SObject>();
        newQtMap.putAll(newQts);
        SentinelQuoteTriggerHandler1 hndlr = new SentinelQuoteTriggerHandler1();
        hndlr.onAfterInsert(newQts);
        hndlr.onAfterUpdate(oldQts, newQts, newQtMap);

        Test.stopTest();

    }

    public static void updateQuoteItems(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        populateData();

        SentinelQuoteItemTriggerHandler hndlr = new SentinelQuoteItemTriggerHandler();
        Schema.SObjectType quotelineobj = Schema.getGlobalDescribe().get('QuoteLineItem');
        sObject quoteLin = quoteLine;
        /*String recId = getFakeId(quotelineobj);
        quoteLin.Id = recId;
        Product2 prod = SentinelCPQTestDataFactory.createProduct('TestProduct', 2);
        
        quoteLin.put('Product2Id', prod.Id);*/
        
        List<SObject> newQuoteItms = new List<SObject>{ quoteLin };
        Map<Id, SObject> newQuoteItmMap = new Map<Id, SObject>();
        newQuoteItmMap.putAll(newQuoteItms);

        SObject oldQuoteItm = quoteLin.clone();
        oldQuoteItm.Id = quoteLin.Id;
        Decimal quoteitemQuantity = (Decimal)oldQuoteItm.get('Quantity');
        if(quoteitemQuantity != null){
        		quoteitemQuantity *= 2;
          }  
        System.debug('quoteitemQuantity__' + quoteitemQuantity);
        List<SObject> oldQuoteItms = new List<SObject>{ oldQuoteItm };

        hndlr.onAfterUpdate(newQuoteItms, oldQuoteItms, newQuoteItmMap);
        Test.stopTest();

    }

    public static void updateQuoteWithDiffStatus(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
		Schema.SObjectType quoteobj = Schema.getGlobalDescribe().get('Quote');
        
        String recId = getFakeId(quoteobj);
        sObject oldQte = quoteobj.newSObject();
        oldQte.put('Status' , 'Approved');
        oldQte.Id = recId;

        sObject qte = quoteobj.newSObject();
        qte.put('Status' , 'Activated');
        qte.Id = recId;
        List<SObject> newQts = new List<SObject>{ qte };
        List<SObject> oldQts = new List<SObject>{ oldQte };
        Map<Id, SObject> newQtMap = new Map<Id, SObject>();
        newQtMap.putAll(newQts);
        SentinelQuoteTriggerHandler1 hndlr = new SentinelQuoteTriggerHandler1();
        hndlr.onAfterUpdate(oldQts, newQts, newQtMap);

        Test.stopTest();

    }

    public static void syncQuoteEntitlements(){
        try{
            Test.setMock(HttpCalloutMock.class, new Mock());
            populateData();
            SentinelUtil.syncQuoteEntitlements(new Set<String>{ qt.Id }, 'op');
        } catch (Exception e){

        }

    }

    public static void syncEntitlements(){
        try{
            Test.setMock(HttpCalloutMock.class, new Mock());
            populateData();
            SentinelUtil.syncEntitlements(new Set<String>{ ord.Id }, 'op');
        } catch (Exception e){

        }

    }

    /*
     public static void updateOrderItmsTest2 () {

     Test.startTest();
     Test.setMock(HttpCalloutMock.class, new Mock());
     populateData();

     SentinelOrderItemTriggerHandler hndlr = new SentinelOrderItemTriggerHandler();
     List<OrderItem> newOrdItms = new List<OrderItem>{ordItm};
     Map<Id, OrderItem> newOrdItmMap = new Map<Id, OrderItem>();
     newOrdItmMap.putAll(newOrdItms);

     OrderItem oldOrdItm = ordItm.clone();
     oldOrdItm.Id = ordItm.Id;
     oldOrdItm.Quantity *= 2;
     List<OrderItem> oldOrdItms = new List<OrderItem>{ordItm};

     hndlr.onAfterUpdate(newOrdItms, oldOrdItms, newOrdItmMap);
     Test.stopTest();

     }
     */

    private class Mock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            if (req.getEndpoint().endsWith('abc')){
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token": "eyJraWQiOiJkc"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('xyz')){
                HTTPResponse res = new HTTPResponse();
                Schema.SObjectType quotelineobj = Schema.getGlobalDescribe().get('QuoteLineItem');
            	sObject quoteLine = quotelineobj.newSObject();
                String quotelineid = (String)quoteLine.get('QuoteId');
                //res.setBody('{"status": "Success","entitlements": [{"status": "Success","entitlement":{"eId": "67672a46-e95b-4c8f-81a9-c79d2a54f5ad"}}]}');
                res.setBody('{"status":"Success","entitlements":[{"status":"Success","entitlement":{"creationDate":"2021-01-26 06:58","entitlementAsWhole":false,"eId":"b7537b00-9144-4c7c-858d-c1503043139f","id":"6cfa8290-03cc-481b-867a-5d947611425e","startDate":"2020-12-23","expiry":{"neverExpires":true},"customer":{"id":"b870dd64-d762-42c9-a963-d1aa89a0c821","name":"Rivercrest Engineering","identifier":"ca350ce2-4cdd-4fa2-82fe-0c8a610d7615","externalId":"IN0000041397"},"userRegistration":"OPTIONAL","refId1":"Q-71858","activationAllowed":true,"revocationAllowed":true,"state":"DRAFT","sendNotification":false,"isTest":false,"productKeys":{"productKey":[{"startDate":"2020-12-23","expiry":{"neverExpires":true},"id":"439862fa-5bb8-4b60-a28e-557ca09329d3","enforcement":{"id":"d467f0dc-2e4a-11eb-9468-06bf6ecdff30","name":"Sentinel RMS","version":"9.7"},"totalQuantity":1,"availableQuantity":1,"splittedQuantity":0,"activationMethod":"FIXED","fixedQuantity":1,"state":"DRAFT","item":{"itemProduct":{"product":{"externalId":"IWIC-ONESE-500-0-T1-FX-NEW-SUB","id":"e9dbc80e-b7ac-48a7-9af3-aa4e77823ba2","identifier":"764","nameVersion":{"name":"ICMOne 1D - Tier 1  (500 nodes) Subscription","version":"1.0"}}}},"commonLicenseAttributes":{"commonLicenseAttribute":[{"name":"LICENSE_VERSION","value":"21","displayText":"21 - RMS  9.7"},{"name":"ALLOW_VM_DETECTION","value":"1","displayText":"Enabled"},{"name":"CLIENT_1_CRITERIA","value":"2010","displayText":"Ethernet Address + UUID "}]},"activationAttributes":{"activationAttribute":[{"groupName":"LOCKING","name":"CLIENT_1_CRITERIA","value":"2010","readOnly":true,"mandatory":false,"associatedAttribute":{"name":"CLIENT_1_INFO","readOnly":false,"mandatory":true}}]},"customAttributes":{"customAttribute":[{"name":"License Type","value":"Subscription"}, ' + 
                            ' {"name":"Line Item Number","value":" ' + ((null != quoteLine && String.isNotBlank(quotelineid)) ? quoteLine.get('QuoteId') : 'QL-0177365') + ' "},{"name":"Vendor Data"}]}}]},"entitlementAttributes":{"entitlementAttribute":[{"name":"DURATION","value":"720","isSANL":false,"groupName":"CLOUD_SERVED"},{"name":"RENEW_FREQUENCY","value":"24","isSANL":false,"groupName":"CLOUD_SERVED"},{"name":"USAGE_SYNC_FREQUENCY","value":"24","isSANL":false,"groupName":"CLOUD_SERVED"},{"name":"FINGERPRINT_REGISTRATION","value":"true","isSANL":false,"groupName":"CLOUD_SERVED"},{"name":"REDUNDANCY_MAJORITY_RULE","value":"TRUE","isSANL":false,"groupName":"POLICY"},{"name":"REDUNDANT_SERVERS","value":"3","isSANL":false,"groupName":"LOCKING"}]}}}]}');
                res.setStatusCode(201);
                return res;
            } else{
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}