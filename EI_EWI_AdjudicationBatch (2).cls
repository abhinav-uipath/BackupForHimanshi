global class EI_EWI_AdjudicationBatch implements Database.Batchable<sObject>,database.AllowsCallouts, Database.Stateful, Schedulable {
    
     public void execute(SchedulableContext SC){
        if(!Test.isRunningTest()) {
            Database.executeBatch(new EI_EWI_AdjudicationBatch(), 100);
        }
    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        String query ='Select Id,Status,Respond_date__c,OwnerId,TDSN_Reference_Number__c,Dispute_Reference__c,Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Evidence_Review_Complete_Date__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c,(Select Id,Type__c, Case__c,Account__c, Account__r.Name, Account__r.Email__c, Account__r.PersonEmail, Contact__c, Contact__r.Email, Contact__r.Name, Access_Code__c From Case_Participants__r  ) from Case where Evidence_Review_Complete_Date__c !=null AND  RecordtypeId=:devRecordTypeId ' ; // AND Id =\'5003L000005Vn92QAC\'
        return DataBase.getQueryLocator(query);
        
    }
    
    global void execute(DataBase.BatchableContext BC,List<Case> caseList){
        List<Case> updateCaseList = new List<Case>();
        
        if(!caseList.isEmpty()){
            for(Case eachCase : caseList){
                system.debug('Calculate7days--'+eachCase.Evidence_Review_Complete_Date__c.addDays(7));
                if((eachCase.Status == 'Evidence review complete'||eachCase.Status == 'Adjudication') &&
                   (system.today() == eachCase.Evidence_Review_Complete_Date__c.addDays(7) || system.today() == eachCase.Evidence_Review_Complete_Date__c.addDays(14)|| system.today() == eachCase.Evidence_Review_Complete_Date__c.addDays(21)|| system.today() == eachCase.Evidence_Review_Complete_Date__c.addDays(28))) 
                {
                    EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                    EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(eachCase, 'AdjudicationBatch');
                    helper.sendMailJetEmail(wrapper);
                }
                
            } 
            
        }
        
    }
    
    global void finish(DataBase.BatchableContext BC){
        
    }
    
}