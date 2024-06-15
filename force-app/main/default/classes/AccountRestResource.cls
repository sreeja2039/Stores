@RestResource(urlMapping='/Account/*')
global with sharing class AccountRestResource {

    @HttpDelete
    global static void doDelete() {
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;
      //Retrives account Id from URl
      String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      Account account = [SELECT Id FROM Account WHERE Id = :accountId];
      delete account;
    }

    @HttpGet
    global static Account doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account result = [SELECT Id, Name ,Phone FROM Account WHERE Id = :accountId];
        return result;
    }

    @HttpPost
    global static String doPost(String name, String phone ,String email) {
        Account account = new Account();
        account.Name = name;
        account.Phone = phone;
        account.Website = email;
        insert account;
        return account.Id;
    }

    @HttpPatch
    global static String updateAccount() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        // Pass values in JSON body to update
        String newAccountName;
        String newAccountPhone;
        try{
            // Convert JSON to XML format
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            newAccountName = (String) params.get('Name');
            newAccountPhone = (String) params.get('Phone');
        } catch(Exception e) {
            res.statusCode = 400;
            return 'Invalid JSON format.';
        }
        // Perform Update
        try{
            Account acc = [SELECT Id, Name, Phone FROM Account WHERE Id = :accountId LIMIT 1];
            acc.Name = newAccountName;
            acc.Phone = newAccountPhone;
            update acc;
            res.statusCode = 200;
            return 'Account Name and Phone updated successfully.';
        } catch (QueryException qe) {
            res.statusCode = 404;
            return 'Account not found.';
        } catch (Exception e) {
            res.statusCode = 500;
            return 'An error occured while updating the Account Name and Phone.';
        }
    }
}