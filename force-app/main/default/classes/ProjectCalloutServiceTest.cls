@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here

  // Prep the Test Data
  private static void setupTestData() {
    Account account = new Account(Name = 'Test Account');
    insert account;

    Opportunity opportunity = new Opportunity();
    opportunity.Name = 'Awesome Deal';
    opportunity.Type = 'New Project';
    opportunity.AccountId = account.Id;
    opportunity.Amount = 150000;
    opportunity.CloseDate = Date.today();
    opportunity.StageName = 'Prospecting';
    insert opportunity;

    ServiceTokens__c serviceTokens = new ServiceTokens__c();
    serviceTokens.Name = 'ProjectServiceToken';
    serviceTokens.Token__c = 'myTestToken';
    insert serviceTokens;
  }

  // Test positive
  @IsTest
  private static void testOppSuccessPost(){
    setupTestData();
    List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity]);
    List<Id> oppIds = new List<Id>();
    for (Opportunity opportunity : opportunities) {
      opportunity.StageName = 'Closed Won';
      oppIds.add(opportunity.Id);
    }
    update opportunities;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
    ProjectCalloutService.postOpportunityToPMS(oppIds);
    Test.stopTest();

    List<Opportunity> submittedOpps = new List<Opportunity>([SELECT Id, StageName FROM Opportunity WHERE StageName='Submitted Project']);
    //System.debug(submittedOpps[0].StageName);
    System.assertEquals(1, submittedOpps.size());

  }


  // Test negative
  @IsTest
  private static void testOppFailurePost(){
    setupTestData();
    List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity]);
    List<Id> oppIds = new List<Id>();
    for (Opportunity opportunity : opportunities) {
      opportunity.StageName = 'Closed Won';
      oppIds.add(opportunity.Id);
    }
    update opportunities;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
    ProjectCalloutService.postOpportunityToPMS(oppIds);
    Test.stopTest();

    List<Opportunity> failOpp = new List<Opportunity>([SELECT Id FROM Opportunity WHERE StageName='Resubmit Project']);
    System.assertEquals(1, failOpp.size());

  }
}