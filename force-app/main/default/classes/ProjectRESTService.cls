@RestResource(UrlMapping='/project')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String projectRef, String projectName, String oppId, Date startDate,
            Date endDate, Double amount, String status){

        // instantiate project object and assign the params
        Project__c project = new Project__c(ProjectRef__c = projectRef, Name=projectName, Opportunity__c=oppId,
                Start_Date__c=startDate, End_Date__c=endDate, Billable_Amount__c=amount,Status__c=status);
        String result;

        //Update Opportunity Delivery Installation Status
        List<Opportunity> opportunities = new List<Opportunity>([SELECT DeliveryInstallationStatus__c
        FROM Opportunity WHERE Id =: oppId]);
        for (Opportunity opportunity : opportunities) {
            opportunity.DeliveryInstallationStatus__c = 'In progress';
        }
        // Creating savepoint
        Savepoint savepoint = Database.setSavepoint();

        // update opportunities and upsert project
        try {
            update opportunities;
            upsert project;
            // set result as 'OK'
            result = 'OK';
        } catch (Exception e) {
            // Rollback if error happens
            Database.rollback(savepoint);
            result = e.getMessage();
        }
        return result;
    }
}