@isTest
public with sharing class UtilsTest {
  static testMethod void getOrgMyDomainTest() {
    Test.startTest();
    String returnString = Utils.getOrgMyDomain();
    System.assertNotEquals(null, returnString);
    Test.stopTest();
  }
  static testMethod void getOrgSalesforceSiteBaseTest() {
    Test.startTest();
    String returnString = Utils.getOrgSalesforceSiteBase();
    System.assertNotEquals(null, returnString);
    Test.stopTest();
  }
}