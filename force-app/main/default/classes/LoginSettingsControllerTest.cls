/*----------------------------------------------------
* @name           LoginSettingsController 
* @date           23 May 2020
* @description    This is a test class for LoginSettingsController. 
* ------------------------------------------------------*/
@isTest
public with sharing class LoginSettingsControllerTest {

    @TestSetup
    static void setup(){
        Sentinel_User_Info__c cusSetting = new Sentinel_User_Info__c(
            Name='Primary User');
        insert cusSetting;
    }

    @isTest
    public static void positiveTest() {
        Test.startTest();
            LoginSettingsController con = new LoginSettingsController();
            con.Settings.Username__c = 'user1';
            con.rdSave();
            con.editRedirect();
            con.cancelRedirect();
        Test.stopTest();
        system.assertEquals('user1', [select Username__c from Sentinel_User_Info__c limit 1].Username__c);
    }
}