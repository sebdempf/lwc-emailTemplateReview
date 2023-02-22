@isTest(SeeAllData=true)
public with sharing class EmailTemplateReviewTest {
  static testMethod void test() {
    Test.startTest();

    //Set default recipient
    //You may also create a mock contact, however, keep in mind that all relevant related fields that may be used inside a template will have to be set manually.

    String contactID = '{{CONTACT.ID}}'; //replace with production contact
    Organization thisOrg = [SELECT IsSandbox FROM Organization];

    if (thisOrg.IsSandbox) {
      contactID = '{{CONTACT.ID}}'; //replace with sandbox contact
    }

    //Test if folders are being read
    List<Folder> returnFolders = EmailTemplateReview.getEmailFolders();
    System.assertNotEquals(null, returnFolders);

    //Test if templates within a folder are read
    List<EmailTemplate> returnTemplates = EmailTemplateReview.getEmailTemplates(
      returnFolders[0].Id
    );
    System.assertNotEquals(null, returnTemplates);

    //Test selected email template, type text.
    EmailTemplate text = [
      SELECT Id, TemplateType
      FROM EmailTemplate
      WHERE TemplateType = 'text'
      LIMIT 1
    ];

    Map<String, String> returnTemplateText = EmailTemplateReview.getSelectedEmailTemplate(
      text.Id
    );
    System.assertNotEquals(null, returnTemplateText);

    //Test selected email template, type html.
    EmailTemplate html = [
      SELECT Id, TemplateType
      FROM EmailTemplate
      WHERE TemplateType = 'html'
      LIMIT 1
    ];

    Map<String, String> returnTemplateHtml = EmailTemplateReview.getSelectedEmailTemplate(
      html.Id
    );
    System.assertNotEquals(null, returnTemplateHtml);

    //Test selected email template, type visualforce.
    EmailTemplate visualforce = [
      SELECT Id, TemplateType
      FROM EmailTemplate
      WHERE TemplateType = 'visualforce'
      LIMIT 1
    ];

    Map<String, String> returnTemplateVisualforce = EmailTemplateReview.getSelectedEmailTemplate(
      visualforce.Id
    );
    System.assertNotEquals(null, returnTemplateVisualforce);

    Test.stopTest();
  }
}
