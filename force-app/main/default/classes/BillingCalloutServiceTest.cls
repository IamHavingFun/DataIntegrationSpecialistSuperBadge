@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
  // prep test data
  private static void prepTestData(){
    Opportunity opportunity = new Opportunity();
    opportunity.Name = 'Test Opportunity';
    opportunity.CloseDate = Date.today();
    opportunity.StageName = 'Prospecting';
    insert opportunity;

    Project__c project = new Project__c();
    project.Name = 'Test Project';
    project.Billable_Amount__c = 300000;
    project.ProjectRef__c = 'TestRef1';
    project.Status__c = 'Billable';
    project.Opportunity__c = opportunity.Id;
    insert project;

    ServiceCredentials__c serviceCredentials = new ServiceCredentials__c();
    serviceCredentials.Name = 'BillingServiceCredential';
    serviceCredentials.Username__c = 'user1';
    serviceCredentials.Password__c = 'pwd1';
    insert serviceCredentials;
  }

  // positive test
  @IsTest static void testPositive(){
    prepTestData();

    Test.startTest();
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    BillingCalloutService.callBillingService([SELECT Id FROM Project__c]);
    Test.stopTest();

    List<Project__c> projects = new List<Project__c>([SELECT Id, Status__c FROM Project__c WHERE Status__c = 'Billed']);
    System.assertEquals(1, projects.size());
    System.assertEquals('Billed', projects[0].Status__c);
  }

  // negative test
  @IsTest static void testNegative(){
    prepTestData();

    Test.startTest();
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
    Test.stopTest();

    System.assertNotEquals(
            'Billed',
            [SELECT Status__c FROM Project__c][0].Status__c
    );
  }
}