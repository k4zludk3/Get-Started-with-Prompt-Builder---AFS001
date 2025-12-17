import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import getExperienceSessions from "@salesforce/apex/ExperienceController.getExperienceSessions";
import NAME_FIELD from "@salesforce/schema/Experience__c.Name";
import DESCRIPTION_FIELD from "@salesforce/schema/Experience__c.Description__c";
import PICTURE_FIELD from "@salesforce/schema/Experience__c.Picture_URL__c";

const fields = [NAME_FIELD, DESCRIPTION_FIELD, PICTURE_FIELD];

export default class ExperienceSchedule extends NavigationMixin(LightningElement) {

  // Data
  @api recordId;
  @track experienceSessions = [];
  @track date = new Date();
  dateIncriment = 0;

  // State
  loading = true;
  noInstancesAvailable = false;


  @wire(getRecord, { recordId: "$recordId", fields })
  experience;

  @wire(getExperienceSessions, { experienceId: "$recordId" })
  wiredPictures(experienceSessions) {
    if (experienceSessions.data) {
      this.experienceSessions = experienceSessions.data;
      this.loading = false;
    } else {
      this.noInstancesAvailable = true;
      this.loading = false;
    }
  }

  increaseDate() {
    this.dateIncriment++;
    this.date = this.updateDateIncriment();
  }

  decreaseDate() {
    this.dateIncriment--;
    this.date = this.updateDateIncriment();
  }

  updateDateIncriment() {
    let today = new Date();
    let updatedDate = new Date();
    updatedDate.setDate(today.getDate() + this.dateIncriment);
    return updatedDate;
  }

  get name() {
    return getFieldValue(this.experience.data, NAME_FIELD);
  }

  get description() {
    return getFieldValue(this.experience.data, DESCRIPTION_FIELD);
  }

  get pictureURL() {
    return getFieldValue(this.experience.data, PICTURE_FIELD);
  }

  get selectedExperiences() {
    let selectedExperiences = this.experienceSessions.filter((exp) => exp.Date__c === this.date.toISOString().substring(0, 10));
    console.log("selected Experiences: ", JSON.stringify(selectedExperiences));
    return selectedExperiences;
  }

  viewInstance(event){
  let experienceId = event.currentTarget.dataset.id;
  this[NavigationMixin.Navigate]({
    type: "standard__recordPage",
    attributes: {
      recordId: experienceId,
      actionName: "view"
    }
  });
  }
}