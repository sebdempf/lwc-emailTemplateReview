public with sharing class Utils {
  @AuraEnabled(cacheable=true)
  public static String getOrgMyDomain() {
    Domain domain = [SELECT Domain FROM Domain LIMIT 1];
    ORganization thisOrg = [SELECT IsSandbox FROM Organization];
    String domainBase = String.valueOf(domain.domain).substringBefore('.');

    if (thisOrg.IsSandbox) {
      domainBase += '.sandbox';
    }

    return domainBase;
  }

}