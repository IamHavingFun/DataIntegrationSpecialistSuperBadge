public class BillingCalloutService {
    //Implement business and callout logic methods here
    // main method to callout
    public static void callBillingService(List<Project__c> projects){
        // Handle Bulk records
        Set<Id> ids = new Set<Id>();
        for (Project__c project : [SELECT Status__c, ProjectRef__c, Billable_Amount__c FROM Project__c
        WHERE Id IN : projects]) {
            if (project.Status__c == 'Billable' && project.ProjectRef__c != null && project.Billable_Amount__c != null) {
                ids.add(project.Id);
            }
            else {
                return ;
            }
        }
        // callout
        callout(ids);

    }

    // implement callout method
    @Future(callout=true)
    public static void callout(Set<Id> projectIds){
        // get the credentials from custom settings
        ServiceCredentials__c credentials = ServiceCredentials__c.getValues('BillingServiceCredential');

        // create a map to hold the data
        Map<Id, String> projectStatusMap = new Map<Id, String>();

        // iterate project list and process data
        for (Project__c project : [SELECT Id, ProjectRef__c, Billable_Amount__c FROM Project__c WHERE Id IN : projectIds]) {
            // instantiate project and pass in necessary param
            BillingServiceProxy.project soapProject = new BillingServiceProxy.project();
            soapProject.username = credentials.Username__c;
            soapProject.password = credentials.Password__c;
            soapProject.projectid = project.ProjectRef__c;
            soapProject.billAmount = project.Billable_Amount__c;

            // send project and get response
            BillingServiceProxy.InvoicesPortSoap11 portSoap11 = new BillingServiceProxy.InvoicesPortSoap11();
            String response = portSoap11.billProject(soapProject);
            projectStatusMap.put(project.Id, response);
        }

        Set<Id> projectIdToProcess = new Set<Id>();
        // Loop the project status map to update projects' status
        for (Id projectId : projectStatusMap.keySet()) {
            if (projectStatusMap.get(projectId) == 'OK') {
                projectIdToProcess.add(projectId);
            }
        }

        // update project status
        if (!projectIdToProcess.isEmpty()) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            for (Project__c project : [SELECT Id, Status__c FROM Project__c WHERE Id IN : projectIdToProcess]) {
                project.Status__c = 'Billed';
                projectsToUpdate.add(project);
            }
            update projectsToUpdate;
        }
    }
}