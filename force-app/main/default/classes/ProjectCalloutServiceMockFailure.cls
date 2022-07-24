public class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here
   public HttpResponse respond(HttpRequest httpRequest) {
      // Create a fake response
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatus('Error');
      response.setBody('Fail');
      response.setStatusCode(500);
      return response;
   }

}