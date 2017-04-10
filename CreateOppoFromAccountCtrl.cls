/***
Class Name :- CreateOppoFromAccountCtrl
Created by :- Sagar Jogi  07th April 2017
Used by :- CreateOppoFromAccount vf page
***/

public class CreateOppoFromAccountCtrl {


    public Account acc;
    public String accountJSON{get;set;}
    public String opportunityListJSON{get;set;}
    public String stageListJSON{get;set;}
    
    //Constructor
    public CreateOppoFromAccountCtrl(ApexPages.StandardController controller) {
       
        acc = (Account)controller.getrecord();
        if(acc != null) {
            acc = [select id,name,phone,Billing_State__c from Account where id =: acc.id];
            system.debug(acc);
            accountJSON = JSON.serialize(acc);
            opportunityListJSON = JSON.serialize(getOpportunities(acc.Id));
            stageListJSON= JSON.serialize(getStagePicklistValue());
        }
    }


    
    
    //Method to retrieve existing opportunity of account.
    public List<opportunity> getOpportunities (id accountid) {
        List<opportunity> opportunitylist = new List<Opportunity> ();
        opportunitylist  = [select id,Name,StageName,Amount,Closedate,accountId from opportunity where accountid=:accountid];
        return opportunitylist;  
      
    }
    
    
    //Method to retrieve picklist value for field Opportunity'stage
    
    public List<SelectOptionWrapper > getStagePicklistValue () {
    
       List<SelectOptionWrapper> options = new List<SelectOptionWrapper >();
        
       Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOptionWrapper(f.getLabel(), f.getValue()));
       }       
       return options;
   
   }
   
   //Wrappe class for picklist. (We can't serialize List<selectOption>. So I have created wrapper class)
   public class SelectOptionWrapper {
       public string key{get; set;}
       public string value{get; set;}
       
       public SelectOptionWrapper (string key, string value) {
           this.key = key;
           this.value = value;
       }
   
   }
    
    //Remoting Method to save opportunity
    @RemoteAction
    public static string saveOpportunity (string opportunityJSON) {
        List<Opportunity> opportunityListToUpsert = (List<Opportunity>)JSON.deserialize(opportunityJSON.unescapeEcmaScript(), List<Opportunity>.class);
        if(opportunityListToUpsert.size() > 0) {
            upsert opportunityListToUpsert;
        }
        return JSON.serialize(opportunityListToUpsert);
    }
}