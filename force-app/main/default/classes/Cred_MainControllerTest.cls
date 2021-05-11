@isTest
private class Cred_MainControllerTest {

    @testSetup 
    public static void setUpData()
    {
    }
    static testMethod void testPositiveNegative_Cred() {
       	//No data
        Cred_DataWrappers.Cred_ResultWrapper result = Cred_MainController.getCredentialData();
        
        //Data
        my_Credential__c my_cred = new my_Credential__c();
        my_cred.Category__c = 'Personal';
        insert my_cred;
                
        Credential_detail__c cdObj = new Credential_detail__c();
        	cdObj.my_Credential__c = my_cred.Id;
        	cdObj.Category__c = 'Personal';
            cdObj.Title__c = 'Facebook';
            cdObj.Redirect_URL__c = 'https://www.facebook.com';
            cdObj.Username__c = 'test@gmail.com';
            cdObj.Password__c = 'Test12304';
            cdObj.Email__c = 'test@gmail.com';
            cdObj.Mobile__c = '9876543210';
            cdObj.Security_question__c = 'Pet Name';
            cdObj.Security_answer__c = 'Maggi';
            cdObj.Comments__c = 'test';
        insert cdObj;
        
        Cred_DataWrappers.Cred_ResultWrapper resultCD = Cred_MainController.getCredentialData();
        system.debug('test:'+ resultCD);
        system.assert(resultCD != null);
        
        Cred_DataWrappers.Options op = new Cred_DataWrappers.Options();
        op.recId = my_cred.Id;
        op.Text = my_cred.Category__c;
        
        Cred_DataWrappers.CDWrapper Cred_DetailObject = new Cred_DataWrappers.CDWrapper();
        Cred_DetailObject.Category = op;
        Cred_DetailObject.Title = 'Gmail';
        Cred_DetailObject.Redirect_URL = 'https://www.gmail.com';
        Cred_DetailObject.Username = 'test-me@gmail.com';
        Cred_DetailObject.Password = 'test1234';
        Cred_DetailObject.Email = 'test@gmail.com';
        Cred_DetailObject.Mobile = '9876543210';
        Cred_DetailObject.Security_question = 'test';
        Cred_DetailObject.Security_answer ='test';
        Cred_DetailObject.Comments ='test';
        String str = JSON.serialize(Cred_DetailObject);
        
        //create new cd
        Cred_DataWrappers.Cred_ResultWrapper resultCreateNew = Cred_MainController.UpsertCredentialDetail(str, 'Create');
        system.assert(resultCreateNew != null);
        
        //create new cd with new category
        op.recId = '';
        op.Text = 'Other';
        resultCreateNew = Cred_MainController.UpsertCredentialDetail(str, 'Create');
        system.assert(resultCreateNew != null);
        
        //update
        Cred_DetailObject.Id = cdObj.Id;
        str = JSON.serialize(Cred_DetailObject);
        resultCreateNew = Cred_MainController.UpsertCredentialDetail(str, 'Update');
        system.assert(resultCreateNew != null);
        
        //delete
        resultCreateNew = Cred_MainController.UpsertCredentialDetail(str, 'Delete');
        system.assert(resultCreateNew != null);
    }
}