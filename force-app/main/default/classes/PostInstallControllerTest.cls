@isTest
public class PostInstallControllerTest {
   	@isTest(SeeAllData=true)
    static void testInstallScript() {
        Test.startTest();
            PostInstallController postinstall = new PostInstallController();
            Test.testInstall(postinstall,  null);
            Test.testInstall(postinstall,  new Version(1, 0));
        Test.stopTest();
	}
}