/*----------------------------------------------------
* @name           SentinelFieldSelectorController 
* @date           25 May 2020
* @description    This is a test class for SentinelFieldSelectorController 
* ------------------------------------------------------*/
@isTest
public with sharing class SentinelFieldSelectorControllerTest {

    @TestSetup
    public static void setup(){
                Account acc = new Account(Name = SentinelCPQTestDataFactory.generateRandomString(6), 
                AccountNumber = SentinelCPQTestDataFactory.generateRandomString(8), 
                BillingCity = SentinelCPQTestDataFactory.generateRandomString(8), 
                BillingState = SentinelCPQTestDataFactory.generateRandomString(8), 
                BillingPostalCode = SentinelCPQTestDataFactory.generateRandomString(8), 
                ShippingCity = SentinelCPQTestDataFactory.generateRandomString(8), 
                ShippingCountry = SentinelCPQTestDataFactory.generateRandomString(8), 
                ShippingPostalCode = SentinelCPQTestDataFactory.generateRandomString(8));
        insert acc;
        
        Contract contr = new Contract(
            AccountID = acc.id,
            StartDate = system.today(),
            Status = 'Draft',
            ContractTerm = 6
            );
        insert contr;

        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Thales__c = true;
        insert p;
    
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
    
        Order odr = new Order(
            AccountID = acc.id, 
            EffectiveDate = system.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            ContractId = contr.id);
        insert odr;
    
        OrderItem i = new OrderItem();
        i.OrderId = odr.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        insert i;
        List<Sentinel_Order_Field_Mapping__c> settingList = SentinelUtil.getListOrderMapFields(SentinelConstants.categoryVsSentinelFieldMap, false);
        settingList.addAll(SentinelUtil.getListOrderMapFields(SentinelConstants.categoryVsCustomAttributeMap, true));
        for(Sentinel_Order_Field_Mapping__c settObj : settingList) {
            if(settObj.Category__c == 'Product') {
                settObj.SF_Api_Field__c = 'Quantity';
            } else {
                settObj.SF_Api_Field__c = 'Status';
            }
        }
        insert settingList;
    }

    @isTest
    public static void positiveTestGetFieldMap() {
        Test.startTest();
            List<SentinelFieldSelectorController.FieldDisplayWrapper> wrapperList = SentinelFieldSelectorController.getFieldMap('Order');
        Test.stopTest();
        system.assertEquals(wrapperList.size() > 0, true);
    }

    @isTest
    public static void positiveTestMappingData() {
        Test.startTest();
            List<Sentinel_Order_Field_Mapping__c> settingList = SentinelFieldSelectorController.getAllMappingData();
            Sentinel_Order_Field_Mapping__c updateCusSetObj = settingList[0];
            updateCusSetObj.SF_Api_Field__c = 'updated';
            Sentinel_Order_Field_Mapping__c deleteCusSetObj = settingList[1];
            SentinelFieldSelectorController.saveMappingData(new List<Sentinel_Order_Field_Mapping__c>{updateCusSetObj}, 
                new List<Sentinel_Order_Field_Mapping__c>{deleteCusSetObj});
        Test.stopTest();
        system.assertEquals(settingList.size() > 0, true);
        system.assertEquals('updated', [select SF_Api_Field__c from Sentinel_Order_Field_Mapping__c where Name = :updateCusSetObj.Name].SF_Api_Field__c);
        system.assertEquals(0, [select count() from Sentinel_Order_Field_Mapping__c where Name = :deleteCusSetObj.Name]);
    }
    @isTest
    public static void positiveupdateFeatures() {
        List<Sentinel_Order_Field_Mapping__c> settingList = SentinelUtil.getListOrderMapFields(SentinelConstants.categoryVsSentinelFieldMap, false);
        settingList.addAll(SentinelUtil.getListOrderMapFields(SentinelConstants.categoryVsCustomAttributeMap, true));
        for(Sentinel_Order_Field_Mapping__c settObj : settingList) {
            if(settObj.Category__c == 'Product') {
                settObj.SF_Api_Field__c = 'Quantity';
            } else {
                settObj.SF_Api_Field__c = 'Status';
            }
        }
        insert settingList;

        Sentinel_User_Info__c cusSetting = new Sentinel_User_Info__c(
            Username__c = 'testuser',
            PAssword__c = 'asdf',
            Org_URL__c = 'https://test.salesforce.com/abc',
            DML_Url__c = 'https://test.dmllesforce.com/xyz',
            Name='Primary User',
            Selected_Org__c = 'dev');
        insert cusSetting;


        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock());
            Order odr = [select id from Order limit 1];
            object jsonEntilementObj='{"EID":"67672a46-e95b-4c8f-81a9-c79d2a54f5ad","product":[{"externalId":"GC5020","feature":[{"featureId":"8ee4f99f-b387-4b87-87e4-1884caffd62b","licenseModelId":"fbdaff42-3e82-4bb6-a9eb-f69cf4e0c169","licenseModelName":"FlexiLM_SampleStandalone","itemFeatureState":"INCLUDED","featureName":"SampleKidney"}}]}]}';
            SentinelFieldSelectorController.updateFeatures(jsonEntilementObj, odr.id);
            SentinelFieldSelectorController.getOrderJson(odr.id);
        Test.stopTest();

        system.assertNotEquals('67672a46-e95b-4c8f-81a9-c79d2a54f5ad', [select EID__c from Order where id = :odr.id].EID__c);
    }
     public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('abc')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token": "eyJraWQiOiJkc"}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('xyz')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"status": "Success","entitlements": [{"status": "Success","entitlement":{"eId": "67672a46-e95b-4c8f-81a9-c79d2a54f5ad"}}]}');
                res.setStatusCode(201);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}