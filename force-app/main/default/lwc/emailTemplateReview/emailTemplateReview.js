import { LightningElement, track } from "lwc";

import getEmailFolders from "@salesforce/apex/EmailTemplateReview.getEmailFolders";
import getEmailTemplates from "@salesforce/apex/EmailTemplateReview.getEmailTemplates";
import getSelectedEmailTemplate from "@salesforce/apex/EmailTemplateReview.getSelectedEmailTemplate";

export default class EmailTemplateReview extends LightningElement {
  availableFolders;
  foldersReady = false;
  templatesReady = false;
  selectedFolderId;
  availableTemplates;
  selectedTemplateId;
  selectedTemplateIndex;
  noTextTemplateReady = false;
  textTemplateReady = false;
  navigationReady = false;

  @track selectedTemplateRenderURL;
  @track selectedTemplatePlainText;
  @track displayValue;

  //////////////////
  //INITIALIZATION//
  //////////////////

  connectedCallback() {
    this.intializeFolderOptions();
    this.foldersReady = true;

    let params = new URL(document.location).searchParams;
    if (params.get("c__folder")) {
      this.selectedFolderId = params.get("c__folder");

      if (params.get("c__template")) {
        this.selectedTemplateId = params.get("c__template");
        this.initializeTemplates(this.selectedTemplateId);
      }
    }
  }

  //////////////////
  //RETRIEVE DATA //
  //////////////////

  //Retrieve folder data
  intializeFolderOptions() {
    getEmailFolders()
      .then((result) => {
        if (result != null) {
          this.availableFolders = this.buildFolderOptions(result);
        }
      })
      .catch((error) => {
        console.error(error);
      });
  }

  //Reconfigure into useable format
  buildFolderOptions(records) {
    let folders = [];
    Object.values(records).forEach((folder) => {
      folders.push({
        label: folder.Name,
        value: folder.Id
      });
    });
    return folders;
  }

  handleFolderSelection(event) {
    this.selectedFolderId = event.target.value;
    this.initializeTemplates();
    this.updateFolderParam();
  }

  //Retrieve template data
  initializeTemplates(IDfromParam) {
    getEmailTemplates({ folderId: this.selectedFolderId })
      .then((result) => {
        if (result != null) {
          this.availableTemplates = this.buildTemplateOptions(result);

          if (IDfromParam) {
            this.selectedTemplateIndex = this.availableTemplates
              .map((template) => template.value)
              .indexOf(this.selectedTemplateId);

            this.prepareTemplateView();
          }
        }
      })
      .catch((error) => {
        console.error(error);
      });
    this.templatesReady = true;
  }

  //Reconfigure into useable format
  buildTemplateOptions(records) {
    let templates = [];
    Object.values(records).forEach((template) => {
      templates.push({
        label: template.Name,
        value: template.Id
      });
    });
    return templates;
  }

  handleTemplatesSelection(event) {
    this.selectedTemplateId = event.target.value;

    this.selectedTemplateIndex = this.availableTemplates
      .map((template) => template.value)
      .indexOf(this.selectedTemplateId);

    this.prepareTemplateView();
    this.updateTemplateParam();
  }

  //Retrieve selected template content
  prepareTemplateView() {
    console.log("preparing template: " + this.selectedTemplateId);
    this.noTextTemplateReady = false;
    this.textTemplateReady = false;
    getSelectedEmailTemplate({
      templateId: this.selectedTemplateId
    })
      .then((result) => {
        if (result != null) {
          console.log(result);
          if (result.URL != null) {
            this.selectedTemplateRenderURL = result.URL;
            this.noTextTemplateReady = true;
          } else {
            this.selectedTemplatePlainText = result.plainText;
            this.textTemplateReady = true;
          }
          this.navigationReady = true;
        }
      })
      .catch((error) => {
        console.error(error);
      });
  }

  //////////////////
  //NAVIGATION    //
  //////////////////

  handleNextButton() {
    if (this.selectedTemplateIndex < this.availableTemplates.length - 1) {
      this.selectedTemplateIndex++;
    } else {
      this.selectedTemplateIndex = 0;
    }
    this.selectedTemplateId =
      this.availableTemplates[this.selectedTemplateIndex].value;
    this.selectedTemplateOption =
      this.availableTemplates[this.selectedTemplateIndex].value;
    this.templateReady = false;
    this.prepareTemplateView();
    this.updateTemplateParam();
  }

  handleBackButton() {
    if (this.selectedTemplateIndex > 0) {
      this.selectedTemplateIndex--;
    } else {
      this.selectedTemplateIndex = this.availableTemplates.length - 1;
    }
    this.selectedTemplateId =
      this.availableTemplates[this.selectedTemplateIndex].value;
    this.selectedTemplateOption =
      this.availableTemplates[this.selectedTemplateIndex].value;
    this.prepareTemplateView();
    this.updateTemplateParam();
  }

  handleSettingsButton() {
    let redirectUTL = `https://indigovolunteers.lightning.force.com/lightning/setup/CommunicationTemplatesEmail/home`;
    window.open(redirectUTL, "_blank").focus();
  }

  handleEditButton() {
    let redirectUTL = `https://indigovolunteers.lightning.force.com/lightning/setup/CommunicationTemplatesEmail/page?address=%2F${this.selectedTemplateId}%3Fsetupid%3DCommunicationTemplatesEmail`;
    window.open(redirectUTL, "_blank").focus();
  }

  ///////////////////
  //PAGE REFERENCES//
  ///////////////////

  updateFolderParam() {
    let params = new URL(document.location).searchParams;
    params.set("c__folder", this.selectedFolderId);
    params.delete("c__template");
    window.history.replaceState(null, null, "?" + params.toString());
  }
  updateTemplateParam() {
    let params = new URL(document.location).searchParams;
    params.set("c__template", this.selectedTemplateId);
    window.history.replaceState(null, null, "?" + params.toString());
  }
}
