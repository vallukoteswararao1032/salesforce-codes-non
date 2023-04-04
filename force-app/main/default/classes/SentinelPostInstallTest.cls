/*----------------------------------------------------
* @name           SentinelPostInstall 
* @date           10 May 2020
* @description    This is test class for SentinelPostInstall class. 
* ------------------------------------------------------*/
@isTest
public with sharing class SentinelPostInstallTest {

    @isTest
    public static void setup(){
        SentinelPostInstall postinstall = new SentinelPostInstall();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        List<Sentinel_Order_Field_Mapping__c> settingList = [Select id from Sentinel_Order_Field_Mapping__c];
        System.debug('settingList____' + settingList);
        System.assertNotEquals(settingList.size(), 0, 'Settings not inserted');
    }
}