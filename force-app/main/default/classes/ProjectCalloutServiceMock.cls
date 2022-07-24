@IsTest
public class ProjectCalloutServiceMock implements HttpCalloutMock {
   //Implement http mock callout here
   public HttpResponse respond(HttpRequest httpRequest) {
       // Create a fake response
       HttpResponse response = new HttpResponse();
       response.setHeader('Content-Type', 'application/json');
       response.setStatus('OK');
       response.setBody('{\n' +
               '  "opportunityId": "00641000004EKmFAAW",\n' +
               '  "opportunityName": "Super-Duper Big Deal",\n' +
               '  "accountName": "ACME Corp, Inc.",\n' +
               '  "closeDate": "2016-10-30",\n' +
               '  "amount": 150000\n' +
               '}');
       response.setStatusCode(201);
      return response;
   }
}