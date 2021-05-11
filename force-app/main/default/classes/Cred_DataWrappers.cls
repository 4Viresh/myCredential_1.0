global with sharing class Cred_DataWrappers {
    public Cred_DataWrappers() {}

    public class Options{
        public String recId;
        public string Text;
        public Options(){}
    }
    
    public class DataWrapper{
        //set<string> URL_DataList;
        public List<Options> CategoryList;
        public List<CDWrapper> Credential_DetailList;
        public DataWrapper(){
            //URL_DataList = new set<string>();
            CategoryList = new List<Options>();
            Credential_DetailList = new List<CDWrapper>();
        }
    }
    public class CDWrapper{
        public Id Id;
        public Options Category;
        public string Title;
        public string Redirect_URL;
        public string Username;
        public string Password;
        public string Email;
        public string Mobile;
        public string Security_question;
        public string Security_answer;
        public string Comments;
       
        public CDWrapper(){}
    }
    
    
    public class Cred_ResultWrapper { 
	    public string status;               
	    public string message;              
	    public integer statusCode;          
	    public object data;                 
	    
	    public Cred_ResultWrapper(){}
	}    
}