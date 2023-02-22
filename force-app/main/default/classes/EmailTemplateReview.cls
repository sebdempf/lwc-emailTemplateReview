public with sharing class EmailTemplateReview {
  @AuraEnabled(cacheable=true)
  public static List<Folder> getEmailFolders() {
    List<Folder> emailFolderRecords = [
      SELECT Type, Name, Id
      FROM Folder
      WHERE Type = 'Email'
      ORDER BY Name
    ];
    return emailFolderRecords;
  }

  @AuraEnabled(cacheable=true)
  public static List<EmailTemplate> getEmailTemplates(String folderId) {
    List<EmailTemplate> templates = [
      SELECT Id, Name, FolderId
      FROM EmailTemplate
      WHERE FolderID = :folderId
      ORDER BY Name
    ];
    return templates;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getSelectedEmailTemplate(
    String templateId
  ) {
    Map<String, String> result = new Map<String, String>();

    Organization thisOrg = [SELECT IsSandbox FROM Organization];

    //Get email template record
    EmailTemplate template = [
      SELECT
        ID,
        Body,
        Name,
        Markup,
        isActive,
        Subject,
        TemplateType,
        LastUsedDate,
        TemplateStyle,
        Description
      FROM EmailTemplate
      WHERE ID = :templateId
    ];

    //get related records for different template types
    String relatedRecordId = '';
    Map<String, String> relatedRecords;

    relatedRecords = getDefaultRecordIDs(thisOrg);

    if (template.TemplateType == 'visualforce') {
      String relatedToType = getRelatedToType(template.Markup);

      relatedRecordId = relatedRecords.get(relatedToType);

      //...
      //...read in additional default records based on your org's needs
    }

    /**
     * If visualforce or html template, create preview URL
     * For Syntax, see page markup after running 'Send Test and Verify Merge Fields' and check for iframe
     *
     * https://{{ORGDOMAIN}}.sandbox.file.force.com/email/templaterenderer?
     * id={{template.Id}}
     * &recipient_type_id={{defaultContact.Id}}
     * &related_to_id={{relatedRecord.Id}}
     * &base_href=https%3A%2F%2F{{ORGDOMAIN}}.my.salesforce.com
     * &preview_frame=previewFrame
     * &render_type=REPLACED_HTML_BODY
     * &setupid=CommunicationTemplatesEmail
     *
     */

    if (template.TemplateType != 'text') {
      Domain domain = [SELECT Domain FROM Domain LIMIT 1];
      String domainBase = String.valueOf(domain.domain).substringBefore('.');

      if (thisOrg.IsSandbox) {
        domainBase += '.sandbox';
      }

      PageReference renderUrl = new PageReference(
        'https://' +
        domainBase +
        '.file.force.com/email/templaterenderer'
      );

      renderUrl.getParameters().put('id', template.Id);

      renderUrl.getParameters()
        .put('recipient_type_id', relatedRecords.get('Contact'));

      if (template.TemplateType == 'visualforce') {
        renderUrl.getParameters().put('related_to_id', relatedRecordId);
      }

      renderUrl.getParameters()
        .put('base_href', 'https://' + domainBase + '.my.salesforce.com');
      renderUrl.getParameters().put('preview_frame', 'previewFrame');
      renderUrl.getParameters().put('render_type', 'REPLACED_HTML_BODY');
      renderUrl.getParameters().put('setupid', 'CommunicationTemplatesEmail');

      result.put('URL', renderUrl.getUrl());
      System.debug(result.get('URL'));
    } else {
      //As the templaterenderer service can't be used for text templates, the body is retruned directly.
      result.put('plainText', template.body);
    }
    System.debug(result);
    return result;
  }

  //////////
  //HELPER//
  //////////

  //Although the EmailTemplate object provides a RelatedEntityType field, this could not be read for some reason.
  //Hence, we extract the type from a string of the template itself
  public static String getRelatedToType(String inputString) {
    Pattern MyPattern = Pattern.compile('relatedToType=\".+?\"');

    Matcher MyMatcher = MyPattern.matcher(inputString);

    String result;

    while (MyMatcher.find()) {
      result = MyMatcher.group(0);
    }

    String relatedToType = result.substringBetween('"');

    return relatedToType;
  }

  //This method is used to define standard records the email preview will use to populate merge fields.
  //Map keys should be the Object Names in order for getSelectedEmailTemplate() to retrieve them.
  public static Map<String, String> getDefaultRecordIDs(Organization thisOrg) {
    Map<String, String> returnRecords = new Map<String, String>();

    //Production IDs
    if (!thisOrg.IsSandbox) {
      returnRecords.put('Contact', '{{CONTACT.ID}}');

      //...
      //...add default records based on your org's needs

      //Sandbox IDs
    } else {
      returnRecords.put('Contact', '{{CONTACT.ID}}');

      //...
      //...add additional default records based on your org's needs
    }

    return returnRecords;
  }
}
