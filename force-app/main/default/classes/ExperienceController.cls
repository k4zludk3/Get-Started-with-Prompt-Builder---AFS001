public with sharing class ExperienceController {

    /**
     * Endpoint that retrieves the experience instances associated with a experience
     * @param experienceId Property Id
     * @return List of ContentVersion holding the pictures
     */
    @AuraEnabled(cacheable=true scope='global')
    public static List<Session__c> getExperienceSessions(Id experienceId) {
        List<Session__c> experienceSessions = [ SELECT Id, Available_Slots__c, Booked_Slots__c, Capacity__c, Date__c, End_Time__c, Experience__c, Is_Canceled__c, Name, Percentage_Booked__c, Start_Time__c, Status__c FROM Session__c WHERE Experience__c = :experienceId ORDER BY Date__c DESC];
        return experienceSessions;
    }
}