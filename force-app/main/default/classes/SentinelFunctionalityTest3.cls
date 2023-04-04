@isTest
private class SentinelFunctionalityTest3{
    @testSetup
    static void setupTestData(){

        SentinelFunctionalityUtil.setupTestData();
    }

    @isTest
    static void testGetAuthenticationToken(){
        List<Sentinel_User_Info__c> rdList = SentinelUtil.rd;
        Sentinel_User_Info__c rd = rdList.get(0);
        rd.Selected_Org__c = 'dev';
        SentinelUtil.getAuthenticationToken(rd);
        rd.Selected_Org__c = 'prod';
        SentinelUtil.getAuthenticationToken(rd);
        SentinelUtil.getAuthenticationToken(null);
    }

    @isTest
    static void testAttachement(){
        Account acc = [SELECT Id
                       FROM Account
                       LIMIT 01];
        Blob b = Blob.valueOf('Test Data');

        Attachment attachment = new Attachment();
        attachment.ParentId = acc.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;

        insert attachment;

        // SentinelUtil.updateAttachment(attachment.Id, 'Test');
        //SentinelUtil.fetchErrorBody(null);
        //SentinelUtil.fetchErrorBody(new HttpResponse());
    }

    @isTest
    static void TestUpdateOrdRecWihtExp(){

        Test.startTest();
        SentinelFunctionalityUtil.populateData();
        try{
            Integer i = 120 / 0;
        } catch (Exception e){
            System.debug('$$$ exception ');
            try{
                //SentinelUtil.updateOrdRecWihtExp(SentinelFunctionalityUtil.ord.Id, e);

            } catch (Exception e2){

            }


        }

        Test.stopTest();
    }

    @isTest
    static void updateOrders(){
        SentinelFunctionalityUtil.updateOrders();
    }

    @isTest
    static void updateOrderItems(){
        SentinelFunctionalityUtil.updateOrderItems();
    }

    @isTest
    static void updateQuotes(){
        SentinelFunctionalityUtil.updateQuote2();
    }

    @isTest
    static void updateQuoteItems(){
        SentinelFunctionalityUtil.updateQuoteItems();
    }


    @isTest
    static void updateQuoteWithDiffStatus(){
        SentinelFunctionalityUtil.updateQuoteWithDiffStatus();
    }

    @isTest
    static void syncQuoteEntitlements(){
        Test.startTest();
        SentinelFunctionalityUtil.syncQuoteEntitlements();
        Test.stopTest();
    }

    @isTest
    static void syncEntitlements(){
        Test.startTest();
        SentinelFunctionalityUtil.syncEntitlements();
        Test.stopTest();
    }
}