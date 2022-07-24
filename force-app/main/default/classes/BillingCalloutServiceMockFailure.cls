@IsTest
global class BillingCalloutServiceMockFailure implements WebServiceMock{
   //Implement http mock callout failure here
   global void doInvoke(Object stub, Object request, Map<String, Object> response,
           String endpoint, String soapAction, String requestName, String responseNS,
           String responseName, String responseType){
      BillingServiceProxy.billProjectResponse_element responseElement = new BillingServiceProxy.billProjectResponse_element();
      responseElement.status = 'Error';
      response.put('response_x', responseElement);

   }
}