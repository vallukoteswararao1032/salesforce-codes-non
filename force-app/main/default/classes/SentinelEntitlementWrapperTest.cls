/*----------------------------------------------------
* @name           SentinelEntitlementWrapperTest 
* @date           25 May 2020
* @description    This is a test class for SentinelEntitlementWrapper. 
* ------------------------------------------------------*/
@isTest
public with sharing class SentinelEntitlementWrapperTest {

    @isTest
    public static void positiveTest() {
        Test.startTest();
        SentinelEntitlementWrapper obj = new SentinelEntitlementWrapper();
        obj.refId1 = 'r1';
        obj.externalId = 'r2';
        obj.refId2 = 'r3';
        obj.EID = 'r4';
        obj.startDate = 'r5';
        obj.endDate = 'r6';


        obj.customer = new SentinelEntitlementWrapper.Customer();
        obj.customer.customerName = 'test1';
        obj.customer.externalId = 'test12';

        obj.customerContact = new SentinelEntitlementWrapper.CustomerContact();
        obj.customerContact.contactName = 'test3';
        obj.customerContact.contactEmail = 'test4';

        SentinelEntitlementWrapper.ChannelPartner cp = new SentinelEntitlementWrapper.ChannelPartner();
        cp.partnerIdentifier = 'test33';
        cp.partnerName = 'test44';
        obj.channelPartner = new List<SentinelEntitlementWrapper.ChannelPartner>{cp};

        SentinelEntitlementWrapper.Product pro= new SentinelEntitlementWrapper.Product();
        pro.startDate = 'test3';
        pro.endDate = 'test4';
        pro.totalQuantity = 'test3';
        pro.externalId = 'test4';
        pro.refId1 = 'test3';
        //pro.activationMethod = 'test4';
        obj.product = new List<SentinelEntitlementWrapper.Product>{pro};
        Test.stopTest();
        system.assertNotEquals(obj , null);
    }

}