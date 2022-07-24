@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
  // prep test data
  private static void prepTestData(){
    Account account = new Account(Name='Test Account');
    insert account;

    Opportunity opportunity = new Opportunity();
    opportunity.Name = 'Super Big Deal';
    opportunity.AccountId = account.Id;
    opportunity.StageName = 'Closed Won';
    opportunity.CloseDate = Date.today();
    insert opportunity;
  }

  // Test positive success result
  @IsTest static void testPositiveResult(){
    prepTestData();
    Opportunity opportunity = [SELECT Id FROM Opportunity];

    // call method to test
    String result = ProjectRESTService.postProjectData('Test - Project Ref', 'Super Project', opportunity.Id,
            Date.today(), Date.today().addDays(14), 300000, 'Running');
    // verify results
    System.assertEquals('OK', result);

    // query the delivery installation status to verify
    opportunity = [SELECT DeliveryInstallationStatus__c FROM Opportunity];
    System.assertEquals('In progress', opportunity.DeliveryInstallationStatus__c);

  }

  // Test negative result
  @IsTest static void testNegativeResult(){
    prepTestData();
    Opportunity opportunity = [SELECT Id FROM Opportunity];
    // call method to test
    String result = ProjectRESTService.postProjectData('Test - Project Ref', 'Super Project', '0015h00000tYYSuAAO',
            Date.today(), Date.today().addDays(14), 300000, 'Running');
    // verify results
    //System.debug(result);
    System.assertNotEquals('OK', result);
    //System.assertEquals('OK', result);

    // query the delivery installation status to verify
    opportunity = [SELECT DeliveryInstallationStatus__c FROM Opportunity];
    System.assert(opportunity.DeliveryInstallationStatus__c == null);
    //System.debug(opportunity.DeliveryInstallationStatus__c);
    //System.assertNotEquals('In progress', opportunity.DeliveryInstallationStatus__c);

  }
}