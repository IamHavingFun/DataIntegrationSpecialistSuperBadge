public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    // This method should be invocable from FLow
    @InvocableMethod(Label='Post Opportunity To PMS')
	public static void postOpportunityToPMS(List<Id> ids){
        // Get the opportunities List
        List<Opportunity> opportunities = new List<Opportunity>([SELECT Id, Name,
        Account.Name, CloseDate, Amount FROM Opportunity WHERE Id IN : ids]);

       // System.debug(opportunities.size());

        if (opportunities.size() > 0) {
            // queue the job
            //System.debug('Start Queueing the Job');
            System.enqueueJob(new QueueablePMSCall(opportunities));
        }
    }

    // Call Queueable Inner Class
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts{
        List<Opportunity> oppsToPost = new List<Opportunity>();

        // Constructor with parameter List
        public QueueablePMSCall(List<Opportunity> oppsToProcess){
            this.oppsToPost = oppsToProcess;
        }

        // implement execute method
        public void execute(QueueableContext context){
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            //System.debug('Inside the execution');
            //System.debug(oppsToPost.size());
            for (Opportunity opportunity : oppsToPost) {
                // check the callout status and update opp stage
                try {
                    if (callout(opportunity).getStatusCode() == 201) {
                        //System.debug('Inside the success callout');
                        opportunity.StageName = 'Submitted Project';
                        oppsToUpdate.add(opportunity);
                    }
                    else {
                        opportunity.StageName = 'Resubmit Project';
                        oppsToUpdate.add(opportunity);
                    }
                } catch (System.CalloutException e) {
                    System.debug(e.getMessage());
                }
            }
            //System.debug('Opportunity To Update: ' + oppsToUpdate.size());
            if (oppsToUpdate.size() > 0 ) {
                update oppsToUpdate;
            }

        }
    }


    // Call Out Method
    public static HttpResponse callout(Opportunity opp){
        // Get Service Token from custom settings
        ServiceTokens__c serviceTokens = ServiceTokens__c.getValues('ProjectServiceToken');
        //System.debug('ServiceToken' + serviceTokens);
        Opportunity oppToPost = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity
        WHERE Id =: opp.Id];
        //System.debug('Opportunity Inside the callout: ' + oppToPost.Name);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Token', serviceTokens.Token__c);
        request.setBody(JSON.serialize(new oppWrapper(oppToPost.Id, oppToPost.Name, oppToPost.Account.Name,
                String.valueOf(oppToPost.CloseDate), oppToPost.Amount)));
        HttpResponse response = http.send(request);
        //System.debug(response);
        return  response;

    }

    // Opportunity Wrapper Class
    public class oppWrapper{
        public String opportunityId;
        public String opportunityName;
        public String accountName;
        public String closeDate;
        public Decimal amount;

        public oppWrapper(String oppId, String oppName, String accName, String closeDate, Decimal amount){
            this.opportunityId = oppId;
            this.opportunityName = oppName;
            this.accountName = accName;
            this.closeDate = closeDate;
            this.amount = amount;
        }
    }
}