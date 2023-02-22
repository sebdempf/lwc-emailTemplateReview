# LWC Email Template Review

This lightning web component let's users of an org view email templates without the need to enter Settings and navigate through the 'Send Test and Verify Merge Fields' dialog.

![Demo](/assets/LWC_preview.jpg)

## Why

In an org where automation takes care of a large chunk of email interactions (e.g. as part of a standardized stakeholder journey), email templates can often remain unchecked for weeks. By default, standard users - i.e. the ones relying on what these emails communicate - may not be able or willing to review templates by navigating to Settings and making use of the 'Send Test and Verify Merge Fields' functionality. Especially where a lot of individual templates are used, this may simply take too much time to be feasible. This LWC aims to address this conundrum by exposing ready-rendered email templates to the Lightning environment.

## How

The 'Send Test and Verify Merge Fields' functionality makes use of the Salesforce templaterenderer service by embedding it through an iframe on the Classic Email Tempaltes Settings page. We can make use of the same approach by constructing a URL to call the service and embed the iframe within our LWC.
The component uses the EmailTemplateReview class to retrieve email folders and templates within your org. Upon selection, it checks whether the requested template is of type 'text', or of type 'html'/'visualforce'. For the former, the templaterenderer service is not available and the template body is simply returned as string (with literal merge field references such as '{!Contact.Name}'). For the latter, the class provides a default contact id to populate merge fields. Where the template is of type 'visualforce', it further checks the RelatedEntityType (e.g. Opportunity) and associates corresponding records to the templaterenderer service too.

## Setup

To set this up for yourself, you will need to specify the default record IDs inside the EmailTemplateReview class. These are set as a return map of getDefaultRecordIDs() and allow you to differentiate between production and sandbox records.
