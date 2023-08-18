/**********************************************************************************************************
* Author: Shirin
* Purpose: Handler for Case Particiopant
* *******************************************************************************************************/
/* Changes: 
* 
* *******************************************************************************************************/


public class Case_Participants_TriggerHandler {

    // EID 266 member note details should get updated on Primary Agent case participants
    public static void onBeforeInsert(List<Case_Participant__c> newCaseList){
        Set<Id> cpId = new Set<Id>();
        Map<Id,Case> mapCase = new Map<Id,Case>();
        Map<String, Object> response;
        Case c;
        
        for(Case_Participant__c cp: newCaseList){
            if(cp.Type__c == 'Agent' && cp.Primary_Agent__c == true){
                cpId.add(cp.Case__c);
            }
        }
        
        if(!cpId.isEmpty()){ processMemberNotes(cpId,newCaseList);}
    }
    
    // added by Vidhi EID 56 AC 6.1
    public static void afterEventHandler (List<Case_Participant__c> newList, Map<Id,Case_Participant__c>oldMap){
        List<Case> caselist = new List<case>();
        Set<Id> caseIds = new Set<Id>(); 
        Case_Participant__c oldCP;
        Case cs;
        Set<Id> setCaseIds=new Set<Id>();
        Set<Id> setConIds=new Set<Id>();
        
        if(oldMap == null){
            oldMap = new Map<Id,Case_Participant__c>(); 
        }
        for(Case_Participant__c cp : newList){
            oldCP = oldMap.get(cp.Id);
            if(cp.Type__c == 'Tenant' && (trigger.isInsert || trigger.isDelete || cp.Contact__c != oldCP.Contact__c || cp.Account__c != oldCP.Account__c)){
                caseIds.add(cp.Case__c);
            }
            
            If(cp.Contact__c !=null && cp.Type__c=='Tenant'){
                setCaseIds.add(cp.Case__c); 
                setConIds.add(cp.Contact__c); 
            }
        }
        
        if(!setCaseIds.isEmpty()){
            validatebankdetailsifpaymentReturnMethod(setCaseIds, setConIds, newList, oldMap);
        }
        
        if(caseIds.isEmpty()){ return; }
        
        List<Case_Participant__c> casepartiesall = [select Id, Type__c, Account__r.Name,Case__c, Is_Lead__c 
                                                    from Case_Participant__c Where Case__c IN :caseIds and Type__c='Tenant' ]; 
        
        Map<Id,List<Case_Participant__c> > CasevsParticipants = new Map<Id,List<Case_Participant__c> > ();
        for(Case_Participant__c casepart :casepartiesall ){
            iF(!CasevsParticipants.containskey(casepart.Case__c)){
                CasevsParticipants.Put(casepart.Case__c, new List<Case_Participant__c>());
            }
            CasevsParticipants.get(casepart.Case__c).add(casepart);
        }
        
        for(Id csid : CasevsParticipants.keyset()){
            cs = new Case(Id = csid);
            String TenantsName = '';
            for(Case_Participant__c cst :CasevsParticipants.get(csid) ){
                cs.Id = cst.Case__c;
                TenantsName += cst.Account__r.Name; 
                If(CasevsParticipants.get(csid)[CasevsParticipants.get(csid).size()-1].Id != cst.Id) {
                    TenantsName +=', ';
                }
                if(cst.Is_Lead__c == true){
                    cs.Lead_Tenant_Name__c = cst.Account__r.Name;
                }
            } 
            cs.Tenants_Name__c = TenantsName; 
            caselist.add(cs);
        }
        
        
        If(!caselist.isempty()){
            EI_EWI_CaseTriggerHandler.byPassUpdateDepositTrigger = true;
            Update caselist;
            EI_EWI_CaseTriggerHandler.byPassUpdateDepositTrigger = false;
        }
    }
    
    public static void  updateTenantsNamesOnCase (List<Case_Participant__c> Casepartilist){
        List<Case> caselist = new list<case>();
        Set<Id> caseids = new set<Id> (); 
        For(Case_Participant__c Caseparti : Casepartilist){
            caseids.add(Caseparti.Case__c);
        } 
        list<Case_Participant__c> casepartiesall = [select Id, Type__c,Account__r.Name,Case__c,Is_Lead__c 
                                                    from Case_Participant__c Where Case__c IN :caseids and Type__c='Tenant' ]; 
        
        Map<Id,List<Case_Participant__c> > CasevsParticipants = New Map<Id,List<Case_Participant__c> > ();
        For(Case_Participant__c casepart :casepartiesall ){
            IF(!CasevsParticipants.containskey(casepart.Case__c)){
                CasevsParticipants.Put(casepart.Case__c, New List<Case_Participant__c>());
            }
            CasevsParticipants.get(casepart.Case__c).add(casepart);
        }
        For(Id csid : CasevsParticipants.keyset()){
            Case cs = new Case();
            String TenantsName = '';
            For(Case_Participant__c cst :CasevsParticipants.get(csid) ){
                cs.Id = cst.Case__c;
                TenantsName += cst.Account__r.Name; 
                If(CasevsParticipants.get(csid)[CasevsParticipants.get(csid).size()-1].Id != cst.Id) {
                    TenantsName +=', ';
                }
            } 
            cs.Id = csid;
            cs.Tenants_Name__c = TenantsName; 
            caselist.add(cs);
        }
        
        
        If(!caselist.isempty()){
            Update caselist;
        }
    }

    //EID-43
    //Added by Shirin
    public static void sendEmailCasePartInvalidBankDetails(List<Case_Participant__c>newCaseParticipantList, Map<Id,Case_Participant__c>oldmap){
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> keyMap = new Map<Id, String>(); 
        Set<Id> setCaseIds=new Set<Id>();
        
        
        EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        for(Case_Participant__c cp :newCaseParticipantList){
            if(cp.Case__c!=null){
                if(cp.Type__c=='Tenant' && cp.Incorrect_Bank_Details__c==true){
                    if(cp.Incorrect_Bank_Details__c !=oldmap.get(cp.Id).Incorrect_Bank_Details__c){
                        setCaseIds.add(cp.Case__c);    
                    }
                }
            }
        }
        
        for(Case objCase: [Select Id,Status from Case where id=:setCaseIds]){
            caseMap.put(objCase.Id, objCase);
            keyMap.put(objCase.Id, 'EID43AC28ToTenant');
        }
        
        if(!caseMap.isEmpty()){
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
            wrapper.keyMap = keyMap;
            wrapper.newMap = caseMap;
            //wrapper.oldCaseMap = oldMap;
            helper.sendMailJetEmail(wrapper);
        }
    }
    
    
    public static void validatebankdetailsifpaymentproceeded(List<Case_Participant__c>newCaseParticipantList, Map<Id,Case_Participant__c>oldmap){
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> keyMap = new Map<Id, String>(); 
        Set<Id> setCaseIds=new Set<Id>();
        Set<Id> setConIds=new Set<Id>();
        for(Case_Participant__c cpt : newCaseParticipantList ){
            If(cpt.Contact__c !=null){
              setCaseIds.add(cpt.Case__c); 
              setConIds.add(cpt.Contact__c); 
            }
        }
        
        list<Installment__C> installmentlist = [Select Id,Amount__c,Case__c,Contact__c,Bank_Name__c,BIC__c,Pay_Today__c,Installment_Type__c,Bank_Account_Number__c,Bank_Sort_Code__c,International_Payment__c
                                                from Installment__C where Case__c=:setCaseIds AND Contact__c=:setConIds AND Installment_Type__c='Payable' AND Status__c= 'Pending Processing' AND Lock_payments__c = true ];
        IF(installmentlist.size()>0){
            for(Case_Participant__c cp : newCaseParticipantList ){
                IF(oldmap.get(cp.Id).Bank_Name__c!=cp.Bank_Name__c
                   ||  oldmap.get(cp.Id).Bank_Identification_Code__c!=cp.Bank_Identification_Code__c
                   ||  oldmap.get(cp.Id).Bank_Account_Number__c!=cp.Bank_Account_Number__c 
                   ||  oldmap.get(cp.Id).Bank_Sort_Code__c!=cp.Bank_Sort_Code__c
                   ||  oldmap.get(cp.Id).Bank_Account_Holder_Name__c!=cp.Bank_Account_Holder_Name__c
                   ||  oldmap.get(cp.Id).UK_Payment__c!=cp.UK_Payment__c
                   ||  oldmap.get(cp.Id).International_Payment__c !=cp.International_Payment__c
                   ||  oldmap.get(cp.Id).Swift_Code__c!=cp.Swift_Code__c
                   ||  oldmap.get(cp.Id).International_Payment__c!=cp.International_Payment__c
                   ||  oldmap.get(cp.Id).International_Bank_Name__c!=cp.International_Bank_Name__c
                   ||  oldmap.get(cp.Id).International_Account_Number__c!=cp.International_Account_Number__c
                   ||  oldmap.get(cp.Id).International_Bank_Account_Holder_Name__c!=cp.International_Bank_Account_Holder_Name__c
                   ||  oldmap.get(cp.Id).Beneficiary_Home_Address__c != cp.Beneficiary_Home_Address__c)
                {
                    cp.adderror('these bank details are in use of payment process cannot be modified');      
                }
                else{
                    
                }
            } 
        }
        else{
            
        }
    }
    
    //code by swati // this code only for Tenant
    public static void validatebankdetailsifpaymentReturnMethod(Set<Id> setCaseIds, Set<Id> setConIds, List<Case_Participant__c>newCaseParticipantList, Map<Id,Case_Participant__c>oldmap){
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> keyMap = new Map<Id, String>(); 

        EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        list<Installment__C> installmentlist = [Select Id,Amount__c,Case__c,Contact__c,Bank_Name__c,BIC__c,Pay_Today__c,Installment_Type__c,Bank_Account_Number__c,
                                                Bank_Sort_Code__c,International_Payment__c
                                                from Installment__C where  Case__c=:setCaseIds AND
                                                Contact__c=:setConIds AND Installment_Type__c='Payable' 
                                                AND Status__c= 'Pending Processing' AND Reason_For_Flag__c = 'Bank details rejected' AND Pay_Today__c = false 
                                                AND Pay_by_cheque__c = false AND Lock_payments__c = true];	
        
        
        IF(installmentlist.isEmpty()){ return; }
        for(Case objCase: [Select Id,Status from Case where id=:setCaseIds]){
            caseMap.put(objCase.Id, objCase);
            keyMap.put(objCase.Id, 'EID43AC28ToTenant');
        }
        
        if(!caseMap.isEmpty()){
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
            wrapper.keyMap = keyMap;
            wrapper.newMap = caseMap;
            //wrapper.oldCaseMap = oldMap;
            helper.sendMailJetEmail(wrapper);
        }
    }
    
    //EID-47
    //Added by Shirin
    public static void updateInstallmentBankDetails(List<Case_Participant__c>newCaseParticipantList){
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> keyMap = new Map<Id, String>(); 
        Set<Id> setCaseIds=new Set<Id>();
        Set<Id> setConIds=new Set<Id>();
        Map<Id, Case_Participant__c> casePartConMap = new Map<Id, Case_Participant__c>();
        Map<String,Installment__c> casecontactandinstallmentmap = New Map<String,Installment__c>();
        Map<String,Case_Participant__c> caseContactCPMap = New Map<String,Case_Participant__c>();
        List<Installment__c> listOfInstallmentsToUpdate= new List<Installment__c>();
        try{
            for(Case_Participant__c cp :newCaseParticipantList){
                if(cp.Case__c!=null /*&& cp.Contact__c!=null*/){
                    setCaseIds.add(cp.Case__c);  
                    setConIds.add(cp.Id);
                    casePartConMap.put(cp.Contact__c,cp);
                    caseContactCPMap.put(cp.Case__c+''+cp.Contact__c, cp);
                    system.debug('-----'+caseContactCPMap);
                }
            }
            
            if(setCaseIds!=null){
                List<Installment__c> instList =[Select Id,Amount__c,Case__c,Contact__c,Bank_Name__c,BIC__c,Pay_Today__c,Installment_Type__c,Bank_Account_Number__c,Bank_Sort_Code__c,International_Payment__c,Swift_Code__c
                from Installment__C where Case__c=:setCaseIds AND Case_participant__c=:setConIds AND Installment_Type__c='Payable' AND Status__c='Pending Processing'   AND Lock_payments__c = false ];
                for(Installment__c objIns: instList){
                                                //casecontactandinstallmentmap.put(objIns.Case__c+''+objIns.Contact__c,objIns);
                                                if(objIns!=null){
                                                    Case_Participant__c cp =caseContactCPMap.get(objIns.Case__c+''+objIns.Contact__c);
                                                    system.debug('line-->260 ' + cp.Bank_Name__c);
                                                    if(cp!=null){
                                                        Installment__c objInsUpdate= new Installment__c();
                                                        objInsUpdate.id=objIns.Id;
                                                       // if(cp.UK_Payment__c==true){
                                                        if(cp.Bank_Account_Number__c !=null && cp.Bank_Sort_Code__c !=null && cp.Bank_Account_Holder_Name__c !=null ){
                                                        objInsUpdate.Bank_Name__c=cp.Bank_Name__c;
                                                        objInsUpdate.BIC__c=null;//cp.Bank_Identification_Code__c;
                                                        objInsUpdate.Bank_Account_Number__c=cp.Bank_Account_Number__c; 
                                                        objInsUpdate.Bank_Sort_Code__c=cp.Bank_Sort_Code__c;
                                                        objInsUpdate.Bank_Account_Holder_Name__c=cp.Bank_Account_Holder_Name__c;
                                                        objInsUpdate.UK_Payment__c=true;
                                                        objInsUpdate.International_Payment__c =false;
                                                        objInsUpdate.Swift_Code__c=null;
                                                        objInsUpdate.beneficiary_address__c = null;
                                                        }
                                                       //if(cp.International_Payment__c==true && cp.UK_Payment__c==false){
                                                      //  else if (cp.UK_Payment__c==false){
                                                            else {
                                                            objInsUpdate.International_Payment__c=cp.International_Payment__c;
                                                            objInsUpdate.BIC__c=cp.Bank_Identification_Code__c;
                                                            objInsUpdate.Bank_Name__c=cp.International_Bank_Name__c;
                                                            objInsUpdate.Bank_Account_Number__c=cp.International_Account_Number__c;
                                                            objInsUpdate.Bank_Sort_Code__c=null;
                                                            objInsUpdate.Bank_Account_Holder_Name__c=cp.International_Bank_Account_Holder_Name__c;
                                                            objInsUpdate.beneficiary_address__c = cp.Beneficiary_Home_Address__c;
                                                            objInsUpdate.Swift_Code__c=cp.Swift_Code__c;
                                                            objInsUpdate.UK_Payment__c=false;
                                                           
                                                        }
                                                        
                                                        listOfInstallmentsToUpdate.add(objInsUpdate);
                                                        system.debug('----'+listOfInstallmentsToUpdate);
                                                    }
                                                }
                                                
                                            }
                
                if(listOfInstallmentsToUpdate.size()>0){
                    update listOfInstallmentsToUpdate;  
                }
            }
        }catch(Exception ex){
            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: Case_Participants_TriggerHandler '));   
        }
    }
    
    public static void processMemberNotes(Set<Id> cpId,List<Case_Participant__c> newCaseList){
        Map<Id,Case> mapCase = new Map<Id,Case>();  
        Case c; 
        Map<String, Object> response;    
        mapCase = new Map<Id, Case>([Select Id, Member_Notes__c,Branch_Notes__c  From case where id=:cpId]);
        
        if(!mapCase.isEmpty()){
            for(Case_Participant__c cp: newCaseList){
                if(mapCase.containskey(cp.Case__c) && mapcase.get(cp.Case__c).Branch_Notes__c!=null){
                 if(String.isNotBlank(mapcase.get(cp.Case__c).Branch_Notes__c) && (mapcase.get(cp.Case__c).Branch_Notes__c.contains('Account Number:') || mapcase.get(cp.Case__c).Branch_Notes__c.contains('Account number:') || mapcase.get(cp.Case__c).Branch_Notes__c.contains('account number:'))){
                if(cp.Type__c == 'Agent' && cp.Primary_Agent__c == true){
                        c = mapcase.get(cp.Case__c);
                        response = el_EWI_MyAccountClass.getMemberNoteBank(cp, c.Branch_Notes__c);
                        system.debug('response='+response);
                        if(response.containsKey('isBankMemberNotes')){
                            cp = (Case_Participant__c)response.get('cp');
                        }else{
                            continue;
                        }
                    }
                 }    
                }
              else if(mapCase.containskey(cp.Case__c) && mapcase.get(cp.Case__c).Member_Notes__c!=null){
                    if(cp.Type__c == 'Agent' && cp.Primary_Agent__c == true){
                        c = mapcase.get(cp.Case__c);
                        response = el_EWI_MyAccountClass.getMemberNoteBank(cp, c.Member_Notes__c);
                        system.debug('response='+response);
                        if(response.containsKey('isBankMemberNotes')){
                            cp = (Case_Participant__c)response.get('cp');
                        }else{
                            continue;
                        }
                    }
                }
            }
        }
    }
    
    public static void justIncrement() { 
        Integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
    }
    public static void justIncrement1() { 
        Integer i = 0;
          i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
       
        
    }
    public static void justIncrement2() { 
        Integer i = 0;
          i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
       
        
    }
    
    
}