public with sharing class Cred_MainController {
       
    @RemoteAction
    public static Cred_DataWrappers.Cred_ResultWrapper UpsertCredentialDetail(String Cred_DetailJSON,String Operation) { 
        Cred_DataWrappers.Cred_ResultWrapper resultwrapper = new Cred_DataWrappers.Cred_ResultWrapper();
        Savepoint CDSavePoint;  
        try{
            boolean isCreate = true;
            CDSavePoint = Database.setSavepoint();
            Cred_DataWrappers.CDWrapper Cred_DetailObject = (Cred_DataWrappers.CDWrapper) JSON.deserialize(Cred_DetailJSON , Cred_DataWrappers.CDWrapper.class); 
            if(Operation.equalsIgnoreCase('Delete')){
                Credential_detail__c obj = new Credential_detail__c(Id=Cred_DetailObject.Id);
                delete obj;      

                resultwrapper.status = 'success';
                resultwrapper.data = obj;
                resultwrapper.statusCode = 410;
                resultwrapper.message = 'Record Deleted Sussessfully.';
                return resultwrapper;
            }
            
            Credential_detail__c objCredDetail = new Credential_detail__c(); 

                    if(!String.isEmpty(Cred_DetailObject.Id)){ //Edit or Create
                           objCredDetail.id = Cred_DetailObject.Id;
                           isCreate = false;
                        }
                    
                    if(String.isEmpty(Cred_DetailObject.Category.recId))//Create new category
                    {
                        my_Credential__c my_cred = new my_Credential__c();
                        my_cred.Category__c = Cred_DetailObject.Category.Text;
                        insert my_cred;
                        objCredDetail.my_Credential__c = my_cred.Id;
                    }
                    else{
                        objCredDetail.my_Credential__c = Cred_DetailObject.Category.recId;
                    }
                    
                    objCredDetail.Category__c = Cred_DetailObject.Category.Text;
                    objCredDetail.Title__c = Cred_DetailObject.Title;
                    //objCredDetail.Redirect_URL__c = Cred_DetailObject.Redirect_URL;
                    
                    String strURL = Cred_DetailObject.Redirect_URL;
            system.debug('Test1:'+ strURL);
                    if(strURL.containsIgnoreCase('.salesforce.com')){
                        strURL = strURL.substringBefore('.salesforce.com');
                        strURL = strURL + '.salesforce.com/login.jsp?un='+Cred_DetailObject.Username+'&pw='+Cred_DetailObject.Password;
                    }
            system.debug('Test2:'+ strURL);
                    objCredDetail.Redirect_URL__c = strURL;
                    objCredDetail.Username__c = Cred_DetailObject.Username;
                    objCredDetail.Password__c = Cred_DetailObject.Password;
                    objCredDetail.Email__c = Cred_DetailObject.Email;
                    objCredDetail.Mobile__c = Cred_DetailObject.Mobile;
                    objCredDetail.Security_question__c = Cred_DetailObject.Security_question;
                    objCredDetail.Security_answer__c = Cred_DetailObject.Security_answer;
                    objCredDetail.Comments__c = Cred_DetailObject.Comments;
                    upsert objCredDetail;
                    
            Cred_DataWrappers.Options objOP = new Cred_DataWrappers.Options();
            objOP.Text = objCredDetail.Category__c;
            objOP.recId = objCredDetail.my_Credential__c;
            Cred_DataWrappers.CDWrapper CDdata = new Cred_DataWrappers.CDWrapper();
            CDdata.Id= objCredDetail.Id;
            CDdata.Category= objOP;
            CDdata.Title =objCredDetail.Title__c;
            CDdata.Redirect_URL=objCredDetail.Redirect_URL__c;
            CDdata.Username= objCredDetail.Username__c;
            CDdata.Password=objCredDetail.Password__c;
            CDdata.Email= objCredDetail.Email__c;
            CDdata.Mobile= objCredDetail.Mobile__c;
            CDdata.Security_question= objCredDetail.Security_question__c;
            CDdata.Security_answer=objCredDetail.Security_answer__c;
            CDdata.Comments=objCredDetail.Comments__c;

            resultwrapper.status = 'success';
            resultwrapper.data = CDdata;
            resultwrapper.statusCode = 200;
            resultwrapper.message = (isCreate) ? 'Record Created Sussessfully.' : 'Record Updated Sussessfully.';
            
        }
        Catch(Exception ex){
            Database.rollback(CDSavePoint);
            resultwrapper.status = 'error'; 
            resultwrapper.statusCode = 400;
            resultwrapper.message = ex.getMessage() + ' at ' + ex.getLineNumber() + '/n' + ex.getStackTraceString();
        }
        return resultwrapper;
    }

    
    @RemoteAction
    public static Cred_DataWrappers.Cred_ResultWrapper getCredentialData() { 
        Cred_DataWrappers.Cred_ResultWrapper resultwrapper = new Cred_DataWrappers.Cred_ResultWrapper();
         try{           
            
            List<Cred_DataWrappers.CDWrapper> listData = new List<Cred_DataWrappers.CDWrapper>();        
            List<Cred_DataWrappers.Options> categoryOptions = new List<Cred_DataWrappers.Options>();
            Cred_DataWrappers.DataWrapper DataWrap = new Cred_DataWrappers.DataWrapper(); 
            List<my_Credential__c> listMy_Credential = [Select Id, Category__c, (SELECT Id, Category__c,Title__c,Redirect_URL__c, Username__c, Password__c,
                                                                                    Email__c, Mobile__c, Security_question__c, Security_answer__c, Comments__c
                                                    
                                                                                    FROM Credential_details__r)
                                                         From my_Credential__c 
                                                         LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())];
             if(listMy_Credential.size()>0){
                 
                 for(my_Credential__c m_cd : listMy_Credential){
                    Cred_DataWrappers.Options objOP = new Cred_DataWrappers.Options();
                    objOP.Text = m_cd.Category__c;
                    objOP.recId = m_cd.Id;
                      for(Credential_detail__c cd : m_cd.Credential_details__r){
                        Cred_DataWrappers.CDWrapper data = new Cred_DataWrappers.CDWrapper();
                             data.Id= cd.Id;
                             data.Category= objOP;
                             data.Title =cd.Title__c;
                             data.Redirect_URL=cd.Redirect_URL__c;
                             data.Username= cd.Username__c;
                             data.Password=cd.Password__c;
                             data.Email= cd.Email__c;
                             data.Mobile= cd.Mobile__c;
                             data.Security_question= cd.Security_question__c;
                             data.Security_answer=cd.Security_answer__c;
                             data.Comments=cd.Comments__c;
                              
                             listData.add(data);
                             
                         }
                         categoryOptions.add(objOP);
                     }
                 
                // Redirection Url datalist Temp
                /*
                String objectName = 'Credential_detail__c';
                String fieldName ='Redirect_URL__c';
                set<string> Redirect_URLDataList = new set<string>();
                Schema.DescribeFieldResult fieldResult = Credential_detail__c.Redirect_URL__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    Redirect_URLDataList.add(pickListVal.getValue());
                }   

                 DataWrap.URL_DataList.addAll(Redirect_URLDataList); */
                 DataWrap.CategoryList = categoryOptions;
                 DataWrap.Credential_DetailList = listData;
                 resultwrapper.status = 'success';
                 resultwrapper.data =DataWrap;
                 resultwrapper.statusCode = 200;
             }
             else{
                 resultwrapper.status = 'success';
                 resultwrapper.data =listData;
                 resultwrapper.statusCode = 200;
                 resultwrapper.message='No Data Available !!';
             }
            
         }
         catch (Exception ex)
         {
            resultwrapper.status = 'error'; 
            resultwrapper.statusCode = 400;
            resultwrapper.message = ex.getMessage() + ' at ' + ex.getLineNumber() + '/n' + ex.getStackTraceString();
            
         }
        return resultwrapper;
    } 
    
    

}