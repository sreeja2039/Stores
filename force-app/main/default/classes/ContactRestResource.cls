@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRestResource {

@HttpDelete
global static void doDelete() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
delete contact;
}

@HttpGet
global static Contact doGet() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
Contact result = [SELECT Id, Name, Phone FROM Contact WHERE Id = :contactId];
return result;
}

@HttpPost
global static String doPost(String firstName,String lastName,String email,String phone) {
Contact contact = new Contact();
contact.FirstName = firstName;
contact.LastName = lastName;
contact.Email = email;
contact.Phone = phone;
insert contact;
return contact.Id;
}

 @HttpPatch
    global static String updateContactName() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Retrieve the account Id from the URL
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        // Parse the request body to get the new name
        String newContactLastName;
        String newContactPhone;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            newContactLastName = (String) params.get('LastName');
            newContactPhone = (String) params.get('Phone');
        } catch (Exception e) {
            res.statusCode = 400;
            return 'Invalid JSON format.';
        }
        
        // Perform the update
        try {
            Contact con = [SELECT Id, LastName ,Phone FROM Contact WHERE Id = :contactId LIMIT 1];
            con.LastName = newContactLastName;
            con.Phone = newContactPhone;
            update con;
            res.statusCode = 200;
            return 'Contact LastName and Phone updated successfully.';
        } catch (QueryException qe) {
            res.statusCode = 404;
            return 'Contact not found.';
        } catch (Exception e) {
            res.statusCode = 500;
            return 'An error occurred while updating the Contact LastName and Phone.';
        }
  }
}

    
