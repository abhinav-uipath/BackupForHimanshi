/**********************************************************************************************************
* Author: Garima Bansal, Swati Ahirkar
* Purpose:This class has all mapping and logic to send email         
* *******************************************************************************************************/
/* 
* *******************************************************************************************************/

public without sharing class EI_MailJetUtilityHelper {
    public Map<String, Map<String, String>> mapTemplateLabel;
    public Map<String, Map<String, String>> mapSubjects;
    public Map<Id, String> keyMap = new Map<Id, String>();
    public Map<Id, Case> oldCaseMap = new Map<Id, Case>();
    Map<Id, Map<String, String>> mapVariables = new Map<Id, Map<String, String>>();
    Map<Id, String> oldEmailCaseMap = new Map<Id, String>();
    Map<Id, Case_Participant__c> selectiveCPMap = new Map<Id, Case_Participant__c>();
    
    public void sendMailJetEmail(MailJetWrapper wrapper){
        Map<Id,Case> newMap = wrapper.newMap;
        if(wrapper.keyMap != null && !wrapper.keyMap.isEmpty()){ keyMap = wrapper.keyMap;}
        if(wrapper.oldCaseMap != null && !wrapper.oldCaseMap.isEmpty()){ oldCaseMap = wrapper.oldCaseMap; }
        
        if((mapTemplateLabel == null || mapTemplateLabel.isEmpty()) || (mapSubjects == null || mapSubjects.isEmpty())) {
            getMailJetMetaData(keyMap.values()); 
        }
        
        if(wrapper.oldEmailCaseMap != null && !wrapper.oldEmailCaseMap.isEmpty()){ oldEmailCaseMap = wrapper.oldEmailCaseMap;}
        if(wrapper.selectiveCPMap != null && !wrapper.selectiveCPMap.isEmpty()){ selectiveCPMap = wrapper.selectiveCPMap; }
        if(wrapper.mapVariables != null && !wrapper.mapVariables.isEmpty()){ mapVariables = wrapper.mapVariables; }
        
        sendMailJetEmail(newMap);
    }
    
    public void sendMailJetEmailWithVars(Map<Id,Case> newMap, Map<String, Map<String, String>> mapTemplateLabel, Map<String, Map<String, String>> mapSubjects, Map<String, String> mapVariables){
        //this.mapVariables = mapVariables;
        this.mapTemplateLabel = mapTemplateLabel;
        this.mapSubjects = this.mapSubjects;
        sendMailJetEmail(newMap);
    }
    
    public void sendMailJetEmail(Map<Id,Case> newMap){
        
        List<EI_MailJetUtility.EmailWrapper> emailWrapperList = new List<EI_MailJetUtility.EmailWrapper>();
        String  emailValue ='';
        
        if((mapTemplateLabel == null || mapTemplateLabel.isEmpty()) && (mapSubjects == null || mapSubjects.isEmpty())) {
            getMailJetMetaData(keyMap.values()); 
        }
        
        Map<String, String> mapParticipantLabel;
        Map<String, String> mapParticipantSubject;
        Case c; String key; String space = ' ';
        //String accessCode;
        
        /*String CTAbtn ='<a style="background-color: #457cbf;color: #fff;font-size: 1rem;text-transform: initial;padding-top: 0.5rem;padding-bottom:' 
                    +'0.5rem;padding-left: 0.5rem; padding-right: 0.5rem; display: inline-block; outline: 0!important; text-decoration: none!important'
                    +'text-align: center; width: 220px; border-radius: 3rem;"  href="'+System.Label.EWI_Deposit_Allocation_Summary+'?accessCode='; */
        
       // system.debug('debugg++'+CTAbtn);
        //mailjet code start
        List<Case_Participant__c> caseParlist = [select Id,Access_Code__c,Case__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Bank_Name__c,
                                                 Contact__r.Sort_Code__c,Contact__r.Account_Number__c,Account__c, Account__r.Name, Account__r.Email__c, 
                                                 Account__r.PersonEmail, Is_Lead__c, Type__c,Case__r.Disputed_Amount__c,Bank_Account__c,Bank_Account__r.Name,
                                                 International_Payment__c,Swift_Code__c,International_Bank_Name__c,Primary_Agent__c,Bank_Account_Number__c,Bank_Sort_Code__c,
                                                 Case__r.V_External_Id__c,case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Incorrect_Bank_Details__c,
                                                 Case__r.Respond_Date__c, Case__r.Amount_to_tenants__c,Disputes_credit_control__c,Case__r.No_of_Tenants__c,
                                                 Case__r.Amount_to_agent_landlord__c, Case__r.Status, Case__r.Amount_of_Disputed_Funds_Remaining__c,
                                                 Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c,
                                                 Case__r.Total_amount_in_dispute__c, AGLL_Raised_Respond__c, Case__r.owner.Email, Case__r.owner.Phone,
                                                 Case__r.owner.Name, Case__r.owner.FirstName, Case__r.owner.LastName, Case__r.owner.title, 
                                                 case__r.Lead_Tenant_Name__c, case__r.Deposit_Account_Number__r.Let_Only__c,
                                                 Primary_Email__c, Other_Emails__c,Case__r.Split_amount_to_tenant__c, Phone__c, House_No__c, Street__c, City__c, Postal_Code__c, Country__c
                                                 from Case_Participant__c where Case__c In :newMap.keySet()];
        
        Map<Id, String> caseIdAndLeadTenantMap = new Map<Id, String>();
        for(Case_Participant__c casePar : caseParlist){
            if(casePar.Is_Lead__c && !caseIdAndLeadTenantMap.containsKey(casePar.Case__c) ){
                caseIdAndLeadTenantMap.put(casePar.Case__c, casePar.Account__r.Name);
            }
        }
        
        List<Dispute_Item__c> despiteItemsList = [Select Id, Dispute__c, Type__c, Claimed_by_Landlord__c, Agreed_by_AGLL__c, Tenant_Response__c, Agreed_by_Tenant__c 
                                                  From Dispute_Item__c where Dispute__c IN :newMap.keySet() ];
        Map<Id, List<Dispute_Item__c>> caseIdAndDisputeItemsMap = new Map<Id, List<Dispute_Item__c>>();
        for(Dispute_Item__c dispItem : despiteItemsList){
            if(!caseIdAndDisputeItemsMap.containsKey(dispItem.Dispute__c)){
                caseIdAndDisputeItemsMap.put(dispItem.Dispute__c, new List<Dispute_Item__c>{});
            }
            caseIdAndDisputeItemsMap.get(dispItem.Dispute__c).add(dispItem);
        }
        
        
        //EID 43
        List<Installment__c> instlist = [select Amount__c,Case__c, Contact__c from Installment__c where Case__c In :newMap.keySet()];
        Map<String,Installment__c> casecontactandinstallmentmap = New Map<String,Installment__c>();
        for(Installment__c inst : instlist){
            casecontactandinstallmentmap.put(inst.Case__c+''+inst.Contact__c,inst);
            
        }
        
        User usr = [select Id, Name ,FirstName, LastName, Title, email,Phone from User where Id =: UserInfo.getUserId()];
        String userName = '';
        userName += usr.Title!=null?usr.Title+' ':'';
        userName += usr.FirstName!=null?usr.FirstName+' ':'';
        userName += usr.LastName!=null?usr.LastName:'';
        for(Case_Participant__c cs: caseParlist){
            c = newMap.get(cs.Case__c);
            key = keyMap.get(cs.Case__c);
            
            mapParticipantLabel = new Map<String, String>();
            mapParticipantSubject = new Map<String, String>();

            if(String.isNotBlank(key) && mapTemplateLabel.containsKey(key)){
                mapParticipantLabel = mapTemplateLabel.get(key);
            } else if(mapTemplateLabel.containsKey(c.Status)){ 
                mapParticipantLabel = mapTemplateLabel.get(c.Status);
            }
            
            if(String.isNotBlank(key) && mapSubjects.containsKey(key)){
                mapParticipantSubject = mapSubjects.get(key);
            } else if(mapSubjects.containsKey(c.Status)){ 
                mapParticipantSubject = mapSubjects.get(c.Status);
            }
            if(mapParticipantLabel.isEmpty()){continue;}
            
            if(!selectiveCPMap.isEmpty() && !selectiveCPMap.containsKey(cs.Id)){ continue; }
            String accessCode = '';
            if(String.isNotEmpty(cs.Access_Code__c)){
                accessCode = cs.Access_Code__c;
            }
            //String CTAbtn ='<a href="'+System.Label.EWI_Deposit_Allocation_Summary+'" target="_blank" >CTA</a>';
            String CTAbtn ='<a href="https://www.tenancydepositscheme.com/log-in/" target="_blank" >login here</a>';

            String dateformat;
            system.debug('debugg++1'+CTAbtn);
            
            if(cs.Case__r.Respond_Date__c !=null){
            dateformat = DateTime.newInstance(cs.Case__r.Respond_Date__c.year(), cs.Case__r.Respond_Date__c.month(), cs.Case__r.Respond_Date__c.day()).format('dd-MM-YYYY');
            }
            List<EI_MailJetUtility.recipient> emailRecipientList = new List<EI_MailJetUtility.recipient>();
            Map<String, String> variableMap = new Map<String, String>();
            
           	emailRecipientList.add(new EI_MailJetUtility.recipient(cs.Primary_Email__c, cs.Account__r.Name, c.Id, cs.Account__c, cs.Id));
            emailRecipientList = getOtherEmail(emailRecipientList, c, cs);
            String ownerName = '';
            ownerName += cs.Case__r.owner.Title!=null?cs.Case__r.owner.Title+' ':'';
            ownerName += cs.Case__r.owner.FirstName!=null?cs.Case__r.owner.FirstName+' ':'';
            ownerName += cs.Case__r.owner.LastName!=null?cs.Case__r.owner.LastName:'';
            variableMap.put('name', cs.Account__r.Name!=null? cs.Account__r.Name : '');
            variableMap.put('TDSN_No', cs.Case__r.V_External_Id__c!=null?cs.Case__r.V_External_Id__c:'');
            variableMap.put('property_address', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'') ;
            variableMap.put('CTA_link', CTAbtn!=null?CTAbtn:'');
            variableMap.put('deadline_date', dateformat!=null? dateformat:'');
            variableMap.put('resolution_executive_name', ownerName); // cs.Case__r.owner.Name!=null?cs.Case__r.owner.Name:''
            variableMap.put('resolution_executive_email', cs.Case__r.owner.Email!=null?cs.Case__r.owner.Email:'');
            variableMap.put('direct_dial', cs.Case__r.owner.Phone!=null?cs.Case__r.owner.Phone:'');
            variableMap.put('user_name', userName); // usr.Name!=null?usr.Name:''
            variableMap.put('user_email', usr.Email!=null?usr.Email:'');
            variableMap.put('user_phone', usr.Phone!=null?usr.Phone:'');
            variableMap.put('Amount_to_tenant', string.valueOf(cs.Case__r.Amount_to_tenants__c)!=null?string.valueOf(cs.Case__r.Amount_to_tenants__c):'');
            variableMap.put('Split_Amount_to_tenant', string.valueOf(cs.Case__r.Split_amount_to_tenant__c)!=null?string.valueOf(cs.Case__r.Split_amount_to_tenant__c):'');
            variableMap.put('Amount_to_agll', string.valueOf(cs.Case__r.Amount_to_agent_landlord__c)!=null?string.valueOf(cs.Case__r.Amount_to_agent_landlord__c):'');
            variableMap.put('disputed_amount', string.valueOf(cs.Case__r.Disputed_Amount__c)!=null?string.valueOf(cs.Case__r.Disputed_Amount__c):'');
            //variableMap.put('Amount_Tenant', string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c)!=null?string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c):'');
            variableMap.put('Disputed_Funds_Remaining', string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c)!=null?string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c):'');
            variableMap.put('Amount_of_Disputed_Funds_Required', string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Required__c)!=null?string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Required__c):'');
            variableMap.put('Amount_of_Disputed_Funds_Remaining', string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c)!=null?string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Remaining__c):'');
            variableMap.put('Amount_of_Disputed_Funds_Received', string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Received__c)!=null?string.valueOf(cs.Case__r.Amount_of_Disputed_Funds_Received__c):'');
             system.debug('======='+casecontactandinstallmentmap.get(cs.Case__c+''+cs.Contact__c));
            if(casecontactandinstallmentmap.get(cs.Case__c+''+cs.Contact__c)!=null){
            variableMap.put('Amount_Tenant_Installment', string.valueOf(casecontactandinstallmentmap.get(cs.Case__c+''+cs.Contact__c).Amount__c)!=null?string.valueOf(casecontactandinstallmentmap.get(cs.Case__c+''+cs.Contact__c).Amount__c):'');
            }
            variableMap.put('total_disputed_Deposit', cs.Case__r.Total_amount_in_dispute__c !=null? string.valueOf(cs.Case__r.Total_amount_in_dispute__c):'');
            String agllRepatProposal = '<table>';
            if(caseIdAndDisputeItemsMap.ContainsKey(cs.Case__c) && caseIdAndDisputeItemsMap.get(cs.Case__c).size() > 0){
                for(Dispute_Item__c dispItem : caseIdAndDisputeItemsMap.get(cs.Case__c)){
                    agllRepatProposal += '<tr>';
                    agllRepatProposal += '<td>'+ dispItem.Type__c +':'+'<td>';
                    agllRepatProposal += '<td>'+'£'+ dispItem.Claimed_by_Landlord__c +'<td>';
                    agllRepatProposal += '</tr>';
                }
            }
            agllRepatProposal += '</table><br/><br/>';
            variableMap.put('AGLL_deposit_repayment_proposal', agllRepatProposal);
            // variableMap.put('Lead_tenant_name', caseIdAndLeadTenantMap.get(cs.Case__c));
            variableMap.put('Lead_tenant_name', cs.Case__r.Lead_Tenant_Name__c!=null? cs.Case__r.Lead_Tenant_Name__c: '');
            
            Decimal Amounttotenent = cs.Case__r.Amount_to_tenants__c;
            Decimal NoofTenants = 1;
            if(cs.Case__r.No_of_Tenants__c!= null && cs.Case__r.No_of_Tenants__c >0 ){
                NoofTenants = cs.Case__r.No_of_Tenants__c;
            }
            
            variableMap.put('distributedamounttoTT',String.valueOf(Amounttotenent/NoofTenants));
            
            //EID 43
            if(cs.Case__c != null && cs.Contact__c != null){
                Installment__c inst = casecontactandinstallmentmap.get(cs.Case__c+''+cs.Contact__c);
                     variableMap.put('Amount_Tenant_Installment',inst !=null &&  string.valueOf(inst.Amount__c)!=null?string.valueOf(inst.Amount__c):'');
            }
       
            variableMap.put('new_email', cs.Primary_Email__c);
            
            if(oldEmailCaseMap.containsKey(cs.Id)){
            	variableMap.put('old_email', oldEmailCaseMap.get(cs.Id));
            }
            
            if(mapVariables != null && !mapVariables.isEmpty() && mapVariables.containsKey(c.Id)){ variableMap.putAll(mapVariables.get(c.Id)); }

            String SubjectOfEmail = '';
            
            if(cs.Type__c == 'Tenant' && mapParticipantLabel.containsKey(cs.Type__c)){
                SubjectOfEmail = mapParticipantSubject.get(cs.Type__c);
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get(cs.Type__c), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); // mapParticipantSubject.get(cs.Type__c)));                
            	
                if(mapParticipantLabel.containsKey('TenantOldEmail') && oldEmailCaseMap.containsKey(cs.Id)){
                    SubjectOfEmail = mapParticipantSubject.get('TenantOldEmail'); 
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailRecipientList = getOldEmailList(emailRecipientList, c, cs); // get Old email if exists.
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantOldEmail'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('Agent') ));                
                }            
            } 
            else if(cs.Type__c =='Agent' && mapParticipantLabel.containsKey('Agent') ){
                SubjectOfEmail = mapParticipantSubject.get('Agent');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('Agent'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('Agent') ));                
                if( mapParticipantLabel.containsKey('Agent_2') ){
                    SubjectOfEmail = mapParticipantSubject.get('Agent_2');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    
                    emailRecipientList = getOldEmailList(emailRecipientList, c, cs); // get Old email if exists.
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('Agent_2'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('Agent') ));                
                }
            }
            
            else if((cs.case__r.Deposit_Account_Number__r.Let_Only__c == false && cs.Type__c =='Non-Member Landlord' && cs.AGLL_Raised_Respond__c == true && mapParticipantLabel.containsKey('NonMemberLld'))
                   || (cs.case__r.Deposit_Account_Number__r.Let_Only__c == true && cs.Type__c =='Non-Member Landlord' && mapParticipantLabel.containsKey('NonMemberLld'))){
                SubjectOfEmail = mapParticipantSubject.get('NonMemberLld');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('NonMemberLld'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); // mapParticipantSubject.get('NonMemberLld') ));                
                if( mapParticipantLabel.containsKey('NonMemberLld_2') ){
                    SubjectOfEmail = mapParticipantSubject.get('NonMemberLld_2');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailRecipientList = getOldEmailList(emailRecipientList, c, cs); // get Old email if exists.
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('NonMemberLld_2'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('NonMemberLld_2') ));                
                }    
            }
            else if((cs.Type__c =='Independent-Landlord') && mapParticipantLabel.containsKey('IndependentLld') ){
                SubjectOfEmail = mapParticipantSubject.get('IndependentLld');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('IndependentLld'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); // mapParticipantSubject.get('IndependentLld') ));                
                if( mapParticipantLabel.containsKey('IndependentLld_2') ){
                    SubjectOfEmail = mapParticipantSubject.get('IndependentLld_2');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailRecipientList = getOldEmailList(emailRecipientList, c, cs); // get Old email if exists.
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('IndependentLld_2'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('Agent') ));                
                }     
            }
            
            else if(cs.Type__c == 'Tenant' && cs.Is_Lead__c == True && mapParticipantLabel.containsKey('TenantLeadTrue')){
                SubjectOfEmail = mapParticipantSubject.get('TenantLeadTrue');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantLeadTrue'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('TenantLeadTrue')));  
            } 
            else if(cs.Type__c == 'Tenant' && cs.Is_Lead__c == false && mapParticipantLabel.containsKey('TenantLeadFalse')){
                SubjectOfEmail = mapParticipantSubject.get('TenantLeadFalse');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantLeadFalse'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('TenantLeadFalse')));  
            }
            else if(cs.Type__c == 'Agent' && cs.Primary_Agent__c == true && mapParticipantLabel.containsKey('PrimaryAgent') ){
                SubjectOfEmail = mapParticipantSubject.get('PrimaryAgent');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('PrimaryAgent'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('PrimaryAgent')));  
                if( mapParticipantLabel.containsKey('Agent_2') ){
                    SubjectOfEmail = mapParticipantSubject.get('Agent_2');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('Agent_2'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('Agent') ));                
                }
            }
            
            //For EID 118
            if(cs.International_Payment__c == True){
                if(cs.Type__c == 'Tenant' && cs.Swift_Code__c == null && cs.International_Bank_Name__c == null && mapParticipantLabel.containsKey('TenantAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('TenantAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('TenantAccBlank')));  
                }
                else if(cs.Type__c == 'Agent' && cs.Primary_Agent__c == true && cs.Swift_Code__c == null && cs.International_Bank_Name__c == null && mapParticipantLabel.containsKey('AgentAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('AgentAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('AgentAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('AgentAccBlank')));  
                }
                else if(cs.Type__c == 'Independent-Landlord'  && cs.Swift_Code__c == null && cs.International_Bank_Name__c == null && mapParticipantLabel.containsKey('IndLLAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('IndLLAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('IndLLAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('IndLLAccBlank')));  
                } 
            }
            
            else if(cs.International_Payment__c == false){
                if(cs.Type__c == 'Tenant' && cs.Bank_Account_Number__c == null && cs.Bank_Sort_Code__c == null && mapParticipantLabel.containsKey('TenantAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('TenantAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('TenantAccBlank')));  
                }
                else if(cs.Type__c == 'Agent' && cs.Primary_Agent__c == true  && cs.Bank_Account_Number__c == null && cs.Bank_Sort_Code__c == null && mapParticipantLabel.containsKey('AgentAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('AgentAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('AgentAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail, cs)); // mapParticipantSubject.get('AgentAccBlank')));  
                }
                else if(cs.Type__c == 'Independent-Landlord'  && cs.Bank_Account_Number__c == null && cs.Bank_Sort_Code__c == null && mapParticipantLabel.containsKey('IndLLAccBlank')){
                    SubjectOfEmail = mapParticipantSubject.get('IndLLAccBlank');
                    if(SubjectOfEmail.contains('[property-Address]')){
                        SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                    }
                    emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('IndLLAccBlank'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('IndLLAccBlank')));  
                } 
            } 
            
            //EID 43
            if(cs.Type__c == 'Tenant' && cs.Incorrect_Bank_Details__c == True && mapParticipantLabel.containsKey('TenantIncorrectDetail')){
                SubjectOfEmail = mapParticipantSubject.get('TenantIncorrectDetail');
                if(SubjectOfEmail.contains('[property-Address]')){
                    SubjectOfEmail = SubjectOfEmail.replace('[property-Address]', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'');
                }
                emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, mapParticipantLabel.get('TenantIncorrectDetail'), cs.Case__r.V_External_Id__c +space+ SubjectOfEmail,cs)); //mapParticipantSubject.get('TenantIncorrectDetail')));  
            }
      
        }
        if(emailWrapperList.size()>0) {
            if(System.isBatch() || System.isFuture()){
                EI_MailJetUtility.sendEmailFromBatch(JSON.serialize(emailWrapperList));                
            }else{
                EI_MailJetUtility.sendEmail(JSON.serialize(emailWrapperList));
            }
        } 
        
    }
    
    public List<EI_MailJetUtility.recipient> getOldEmailList(List<EI_MailJetUtility.recipient> emailRecipientList, Case c, Case_Participant__c cs){
        if(oldEmailCaseMap.containsKey(cs.Id)){
            emailRecipientList = new List<EI_MailJetUtility.recipient>();
            emailRecipientList.add(new EI_MailJetUtility.recipient(oldEmailCaseMap.get(cs.Id), cs.Account__r.Name, c.Id, cs.Account__c, cs.Id));
            emailRecipientList = getOtherEmail(emailRecipientList, c, cs);
        }
        return emailRecipientList;
    }
    
    public List<EI_MailJetUtility.recipient> getOtherEmail(List<EI_MailJetUtility.recipient> emailRecipientList, Case c, Case_Participant__c cs){
        if(cs.Other_Emails__c != null && cs.Other_Emails__c != '' && cs.Other_Emails__c != 'undefined'){
            List<String> otherEmailsList = cs.Other_Emails__c.split(',');
            for(String otherEmail : otherEmailsList){
                emailRecipientList.add(new EI_MailJetUtility.recipient(otherEmail, cs.Account__r.Name, c.Id, cs.Account__c, cs.Id));
            }
        }
        return emailRecipientList;
    }
    
   	/*
    * public Map<String, Map<String, String>> getTemplateLabel(){
        Map<String, Map<String, String>> mapTemplateLabel = new Map<String, Map<String, String>>();
        
        Map<String, String> mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWICaseMoveToEvidGathAGLLMailToTT');
        mapParticipantLabel.put('Agent', 'EWICaseMoveToEvidGathAGLLMailToAGLL');
        mapParticipantLabel.put('IndependentLld', 'EWICaseMoveToEvidGathAGLLMailToAGLL');
        mapTemplateLabel.put('EvidenceGatherEmailSent', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantLeadTrue', 'EID24AC2MailToLeadTenant');
        mapParticipantLabel.put('TenantLeadFalse', 'EID24AC2MailToJointTenant');
        mapParticipantLabel.put('Agent', 'EID24AC2MailToAgLL');
        mapTemplateLabel.put('Evidence gathering tenant', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID15AC11mailToTT');
        mapParticipantLabel.put('Agent', 'EID15AC11mailToAGLL');
        mapParticipantLabel.put('Non-Member Landlord', 'EID15AC11mailToAGLL');
        mapParticipantLabel.put('Independent-Landlord', 'EID15AC11mailToAGLL');
        mapTemplateLabel.put('Self-resolution', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWINoResponseFromTTMailToTT');
        mapParticipantLabel.put('Agent', 'EWINoResponseFromTTMailToAGLL');
        mapParticipantLabel.put('Non-Member Landlord', 'EWINoResponseFromTTMailToAGLL');
        mapParticipantLabel.put('Independent-Landlord', 'EWINoResponseFromTTMailToAGLL');
        mapTemplateLabel.put('Case closed – no dispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID24AC2MailToJointTenant');
        mapParticipantLabel.put('Agent', 'EID24AC2MailToAgLL');
        mapParticipantLabel.put('Non-Member Landlord', 'EID24AC2MailToAgLL');
        mapParticipantLabel.put('Independent-Landlord', 'EID24AC2MailToAgLL');
        mapTemplateLabel.put('Evidence gathering tenant', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWIConfirmationCasetoProgressMaitToTT');
        mapParticipantLabel.put('Agent', 'EWIConfirmationCasetoProgressMaitToAGLL');
        mapParticipantLabel.put('Non-Member Landlord', 'EWIConfirmationCasetoProgressMaitToAGLL');
        mapParticipantLabel.put('Independent-Landlord', 'EWIConfirmationCasetoProgressMaitToAGLL');
        mapTemplateLabel.put('Proposal submitted – awaiting tenant response', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWISendEmailToTTForConfirmationCaseProgr');
        mapParticipantLabel.put('Agent', 'EWISendEmailToAGLLForConfirmationCasePro');
        mapParticipantLabel.put('Non-Member Landlord', 'EWISendEmailToAGLLForConfirmationCasePro');
        mapParticipantLabel.put('Independent-Landlord', 'EWISendEmailToAGLLForConfirmationCasePro');
        mapTemplateLabel.put('Proposal submitted – awaiting agent/landlord response', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID27AC131MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID27AC131MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID27AC131MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID27AC131MailToAllParties');
        mapTemplateLabel.put('Consent to resolution not given', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID27AC36MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID27AC36MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID27AC36MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID27AC36MailToAllParties');
        mapTemplateLabel.put('Deposit to be repaid - resolved without adjudication', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID27AC16MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID27AC16MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID27AC16MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID27AC16MailToAllParties');
        mapTemplateLabel.put('Evidence review complete', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID63AC10MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID63AC10MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID63AC10MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID63AC10MailToAllParties');
        mapTemplateLabel.put('Case closed – court order', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID63AC85MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID63AC85MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID63AC85MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID63AC85MailToAllParties');
        mapTemplateLabel.put('Deposit to be repaid - court order', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID27AC29MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID27AC29MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID27AC29MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID27AC29MailToAllParties');
        mapTemplateLabel.put('ProtectAmountEqualToZero', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EWISendNoResponseRequestForFundMailToAL');
        mapParticipantLabel.put('Non-Member Landlord', 'EWISendNoResponseRequestForFundMailToAL');
        mapParticipantLabel.put('Independent-Landlord', 'EWISendNoResponseRequestForFundMailToAL');
        mapTemplateLabel.put('requestforfundtrue', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWISelfResAGLLRejectTTOfferMailtoTT');
        mapParticipantLabel.put('Agent', '');
        mapParticipantLabel.put('Non-Member Landlord', '');
        mapParticipantLabel.put('Independent-Landlord', '');
        mapTemplateLabel.put('ttmadeofferkey', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID31AC1MailToAllParties');
        mapParticipantLabel.put('Agent', 'EID31AC1MailToAllParties');
        mapParticipantLabel.put('Non-Member Landlord', 'EID31AC1MailToAllParties');
        mapParticipantLabel.put('Independent-Landlord', 'EID31AC1MailToAllParties');
        mapTemplateLabel.put('AdjudicationBatch', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID63AC15MailToTT');
        mapParticipantLabel.put('Agent', 'EID63AC15MailToAGLL');
        mapParticipantLabel.put('Non-Member Landlord', 'EID63AC15MailToAGLL');
        mapParticipantLabel.put('Independent-Landlord', 'EID63AC15MailToAGLL');
        mapTemplateLabel.put('tenantwithdrawconsent', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EID63AC15MailToTT4118494');
        mapParticipantLabel.put('Agent', 'EID63AC15MailToAGLL4118351');
        mapParticipantLabel.put('Non-Member Landlord', 'EID63AC15MailToAGLL4118351');
        mapParticipantLabel.put('Independent-Landlord', 'EID63AC15MailToAGLL4118351');
        mapTemplateLabel.put('agentwithdrawconsent', mapParticipantLabel);

        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC31MailToAGLL');
        mapParticipantLabel.put('IndependentLld', 'EID30AC31MailToAGLL');
        mapTemplateLabel.put('DisputedFundEmail', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC3MailToAGLL4116466');
        mapParticipantLabel.put('IndependentLld', 'EID30AC3MailToAGLL4116466');
        mapTemplateLabel.put('FinanceEID30Batch', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC3MailToAGLL4116346');
        mapParticipantLabel.put('IndependentLld', 'EID30AC3MailToAGLL4116346');
        mapTemplateLabel.put('FinanceEID30Batch1', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Tenant', 'EWISend5WorkingDaysReminderMailToTT');
        mapParticipantLabel.put('Agent', 'EWIRemainderRespondEmailToAGLL');
        mapTemplateLabel.put('caseStatusUpdateNoResponse5workingDayBatch', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC3MailToAGLL4116272');
        mapParticipantLabel.put('IndependentLld', 'EID30AC3MailToAGLL4116272');
        mapTemplateLabel.put('FinanceEID30Batch2', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC2MailToAGLL');
        mapParticipantLabel.put('IndependentLld', 'EID30AC2MailToAGLL');
        mapTemplateLabel.put('FinanceEID30Batch3', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Agent', 'EID30AC61MailToAgLL');
        mapParticipantLabel.put('IndependentLld', 'EID30AC61MailToAgLL');
        mapTemplateLabel.put('EID30ChaserEmail', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantAccBlank', 'EID118AC2MailToTT4116537');
        mapParticipantLabel.put('AgentAccBlank', 'EID118AC2MailToTT4116537');
        mapParticipantLabel.put('Non-Member Landlord', 'EID118AC2MailToTT4116537');
        mapParticipantLabel.put('IndLLAccBlank', 'EID118AC2MailToTT4116537');
        mapTemplateLabel.put('FinanceEID118Batch1', mapParticipantLabel);
                
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantAccBlank', 'EID118AC2MailToTT4116493');
        mapParticipantLabel.put('AgentAccBlank', 'EID118AC2MailToTT4116493');
        mapParticipantLabel.put('Non-Member Landlord', 'EID118AC2MailToTT4116493');
        mapParticipantLabel.put('IndLLAccBlank', 'EID118AC2MailToTT4116493');
        mapTemplateLabel.put('FinanceEID118Batch2', mapParticipantLabel);
        
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantAccBlank', 'EID118AC2MailToTT4116464');
        mapParticipantLabel.put('AgentAccBlank', 'EID118AC2MailToTT4116464');
        mapParticipantLabel.put('Non-Member Landlord', 'EID118AC2MailToTT4116464');
        mapParticipantLabel.put('IndLLAccBlank', 'EID118AC2MailToTT4116464');
        mapTemplateLabel.put('FinanceEID118Batch3', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantAccBlank', 'EID118AC2MailToTT');
        mapParticipantLabel.put('AgentAccBlank', 'EID118AC2MailToTT');
        mapParticipantLabel.put('Non-Member Landlord', 'EID118AC2MailToTT');
        mapParticipantLabel.put('IndLLAccBlank', 'EID118AC2MailToTT');
        mapTemplateLabel.put('FinanceEID118Batch4', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantAccBlank', 'NoBankDetailsEmail');
        mapParticipantLabel.put('Agent', '');        
        mapParticipantLabel.put('Independent-Landlord', '');
        mapTemplateLabel.put('NoBankDetailsProvidedEvidGatherAGLL', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('PrimaryAgent', 'EWIRemindertoSubmitDepoAllocPropMailtoAL');
        mapTemplateLabel.put('EID61AC5AgentInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantLeadTrue', 'EWIRemindertoSubmitDepoAllocPropMailtoAL');
        mapTemplateLabel.put('EID61AC5TenantInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Independent-Landlord', 'EWIRemindertoSubmitDepoAllocPropMailtoAL');
        mapTemplateLabel.put('EID61AC5IndependentLldInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Non-Member Landlord', 'EWIRemindertoSubmitDepoAllocPropMailtoAL');
        mapTemplateLabel.put('EID61AC5NonMemberLldInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('PrimaryAgent', 'EWIDepoAllocPropDeletedConfirmMailtoAGLL');
        mapTemplateLabel.put('EID61AC52AgentInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantLeadTrue', 'EWIDepoAllocPropDeletedConfirmMailtoAGLL');
        mapTemplateLabel.put('EID61AC52TenantInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Independent-Landlord', 'EWIDepoAllocPropDeletedConfirmMailtoAGLL');
        mapTemplateLabel.put('EID61AC52IndependentLldInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('Non-Member Landlord', 'EWIDepoAllocPropDeletedConfirmMailtoAGLL');
        mapTemplateLabel.put('EID61AC52NonMemberLldInitiatedDispute', mapParticipantLabel);
        
        mapParticipantLabel = new Map<String, String>();
        mapParticipantLabel.put('TenantIncorrectDetail', 'EID43AC28MailToTT');
        mapTemplateLabel.put('EID43AC28ToTenant', mapParticipantLabel);
        
        

        return mapTemplateLabel;
    }
    
    public Map<String, Map<String, String>> getSubjects(){
        Map<String, Map<String, String>> mapSubjects = new Map<String, Map<String, String>>();
        
        Map<String, String> mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Agent/Landlord evidence requested');
        mapParticipantSubject.put('Agent', ' - Action required – Evidence required');
        mapParticipantSubject.put('IndependentLld', ' - Action required – Evidence required');
        mapSubjects.put('EvidenceGatherEmailSent', mapParticipantSubject);
       
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantLeadTrue', ' - Action required – Tenant evidence required');
        mapParticipantSubject.put('TenantLeadFalse', ' - Tenant evidence required');
        mapParticipantSubject.put('Agent', ' - Tenant evidence requested');
        mapSubjects.put('Evidence gathering tenant', mapParticipantSubject);
        
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Action Required - Preliminary assessment of Proposal');
        mapParticipantSubject.put('Agent', ' - Action Required - Preliminary assessment of Proposal');
        mapParticipantSubject.put('Non-Member Landlord', ' - Action Required - Preliminary assessment of Proposal');
        mapParticipantSubject.put('Independent-Landlord', ' - Action Required - Preliminary assessment of Proposal');
        mapSubjects.put('Self-resolution', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Case not accepted – No response submitted by tenant(s)');
        mapParticipantSubject.put('Agent', ' - Case not accepted – No response submitted by tenant(s)');
        mapParticipantSubject.put('Non-Member Landlord', ' - Case not accepted – No response submitted by tenant(s)');
        mapParticipantSubject.put('Independent-Landlord', ' - Case not accepted – No response submitted by tenant(s)');
        mapSubjects.put('Case closed – no dispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Proposal received and accepted');
        mapParticipantSubject.put('Agent', ' - Proposal received and accepted');
        mapParticipantSubject.put('Non-Member Landlord', ' - Proposal received and accepted');
        mapParticipantSubject.put('Independent-Landlord', ' - Proposal received and accepted');
        mapSubjects.put('Proposal submitted – awaiting tenant response', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Proposal received and accepted');
        mapParticipantSubject.put('Agent', ' - Proposal received and accepted');
        mapParticipantSubject.put('Non-Member Landlord', ' - Proposal received and accepted');
        mapParticipantSubject.put('Independent-Landlord', ' - Proposal received and accepted');
        mapSubjects.put('Proposal submitted – awaiting agent/landlord response', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - No consent to resolution');
        mapParticipantSubject.put('Agent', ' - No consent to resolution');
        mapParticipantSubject.put('Non-Member Landlord', ' - No consent to resolution');
        mapParticipantSubject.put('Independent-Landlord', ' - No consent to resolution');
        mapSubjects.put('Consent to resolution not given', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Resolution confirmation');
        mapParticipantSubject.put('Agent', ' - Resolution confirmation');
        mapParticipantSubject.put('Non-Member Landlord', ' - Resolution confirmation');
        mapParticipantSubject.put('Independent-Landlord', ' - Resolution confirmation');
        mapSubjects.put('Deposit to be repaid - resolved without adjudication', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Dispute referred to adjudicator');
        mapParticipantSubject.put('Agent', ' - Dispute referred to adjudicator');
        mapParticipantSubject.put('Non-Member Landlord', ' - Dispute referred to adjudicator');
        mapParticipantSubject.put('Independent-Landlord', ' - Dispute referred to adjudicator');
        mapSubjects.put('Evidence review complete', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Court order received – Case closed');
        mapParticipantSubject.put('Agent', ' - Court order received – Case closed');
        mapParticipantSubject.put('Non-Member Landlord', ' - Court order received – Case closed');
        mapParticipantSubject.put('Independent-Landlord', ' - Court order received – Case closed');
        mapSubjects.put('Case closed – court order', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Court order received – funds released');
        mapParticipantSubject.put('Agent', ' - Court order received – funds released');
        mapParticipantSubject.put('Non-Member Landlord', ' - Court order received – funds released');
        mapParticipantSubject.put('Independent-Landlord', ' - Court order received – funds released');
        mapSubjects.put('Deposit to be repaid - court order', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Resolution confirmation');
        mapParticipantSubject.put('Agent', ' - Resolution confirmation');
        mapParticipantSubject.put('Non-Member Landlord', ' - Resolution confirmation');
        mapParticipantSubject.put('Independent-Landlord', ' - Resolution confirmation');
        mapSubjects.put('ProtectAmountEqualToZero', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' -   Request for disputed funds');
        mapParticipantSubject.put('Non-Member Landlord', ' -   Request for disputed funds');
        mapParticipantSubject.put('Independent-Landlord', ' -   Request for disputed funds');
        mapSubjects.put('requestforfundtrue', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Action Required – offer rejected');
        mapParticipantSubject.put('Agent', ' ');
        mapParticipantSubject.put('Non-Member Landlord', '');
        mapParticipantSubject.put('Independent-Landlord', '');
        mapSubjects.put('ttmadeofferkey', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Case Update – Adjudication Decision Pending');
        mapParticipantSubject.put('Agent', ' - Case Update – Adjudication Decision Pending');
        mapParticipantSubject.put('Non-Member Landlord', ' - Case Update – Adjudication Decision Pending');
        mapParticipantSubject.put('Independent-Landlord', ' - Case Update – Adjudication Decision Pending');
        mapSubjects.put('AdjudicationBatch', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Parties have withdrawn from dispute resolution');
        mapParticipantSubject.put('Agent', ' - Parties have withdrawn from dispute resolution');
        mapParticipantSubject.put('Non-Member Landlord', ' - Parties have withdrawn from dispute resolution');
        mapParticipantSubject.put('Independent-Landlord', ' - Parties have withdrawn from dispute resolution');
        mapSubjects.put('tenantwithdrawconsent', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' - Agent/landlord has withdrawn from dispute resolution');
        mapParticipantSubject.put('Agent', ' - Agent/landlord has withdrawn from dispute resolution');
        mapParticipantSubject.put('Non-Member Landlord', ' - Agent/landlord has withdrawn from dispute resolution');
        mapParticipantSubject.put('Independent-Landlord', ' - Agent/landlord has withdrawn from dispute resolution');
        mapSubjects.put('agentwithdrawconsent', mapParticipantSubject);
        
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('DisputedFundEmail', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('FinanceEID30Batch', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Tenant', ' -  Reminder – Complete your deposit allocation proposal');
        mapParticipantSubject.put('Agent', ' -  Reminder – Complete your deposit allocation proposal');
        mapSubjects.put('caseStatusUpdateNoResponse5workingDayBatch', mapParticipantSubject);

        
         mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('FinanceEID30Batch1', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('FinanceEID30Batch2', mapParticipantSubject);
           
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('FinanceEID30Batch3', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Agent', ' - Disputed deposit required for [property-Address]');
        mapParticipantSubject.put('IndependentLld', ' - Disputed deposit required for [property-Address]');
        mapSubjects.put('EID30ChaserEmail', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('AgentAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('Non-Member Landlord', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('IndLLAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapSubjects.put('FinanceEID118Batch1', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('AgentAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('Non-Member Landlord', ' - ACTION REQUIRED – Contact us to get paid');
        mapParticipantSubject.put('IndLLAccBlank', ' - ACTION REQUIRED – Contact us to get paid');
        mapSubjects.put('FinanceEID118Batch2', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantAccBlank', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('AgentAccBlank', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('Non-Member Landlord', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('IndLLAccBlank', ' - Action required – Contact us to get paid');
        mapSubjects.put('FinanceEID118Batch3', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantAccBlank', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('AgentAccBlank', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('Non-Member Landlord', ' - Action required – Contact us to get paid');
        mapParticipantSubject.put('IndLLAccBlank', ' - Action required – Contact us to get paid');
        mapSubjects.put('FinanceEID118Batch4', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantAccBlank', ' - Action required – We need your bank details ');
        mapParticipantSubject.put('AgentAccBlank', '');        
        mapParticipantSubject.put('IndLLAccBlank', '');
        mapSubjects.put('NoBankDetailsProvidedEvidGatherAGLL', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('PrimaryAgent', ' - Reminder - Complete your deposit allocation proposal');
        mapSubjects.put('EID61AC5AgentInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantLeadTrue', ' - Reminder - Complete your deposit allocation proposal');
        mapSubjects.put('EID61AC5TenantInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Independent-Landlord', ' - Reminder - Complete your deposit allocation proposal');
        mapSubjects.put('EID61AC5IndependentLldInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Non-Member Landlord', ' - Reminder - Complete your deposit allocation proposal');
        mapSubjects.put('EID61AC5NonMemberLldInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('PrimaryAgent', ' - Proposal deleted');
        mapSubjects.put('EID61AC5AgentInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('TenantLeadTrue', ' - Proposal deleted');
        mapSubjects.put('EID61AC52TenantInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Independent-Landlord', ' - Proposal deleted');
        mapSubjects.put('EID61AC52IndependentLldInitiatedDispute', mapParticipantSubject);
        
        mapParticipantSubject = new Map<String, String>();
        mapParticipantSubject.put('Non-Member Landlord', ' - Proposal deleted');
        mapSubjects.put('EID61AC52NonMemberLldInitiatedDispute', mapParticipantSubject);
        return mapSubjects;
        
        //mapParticipantSubject = new Map<String, String>();
        //mapParticipantSubject.put('TenantIncorrectDetail', ' - Action required – We need your bank details to make payment');
        //mapSubjects.put('EID43AC28ToTenant', mapParticipantSubject);
        //return mapSubjects; 
        
       
        
    }
    */
    public void getMailJetMetaData(List<String>uniqueKeys){
        List<MailJetUtility__mdt> metaDataList = QuerySelectorHelper.getMailJetMetaData(uniqueKeys);
        
        //MailJetUtility__mdt m;
        mapTemplateLabel = new Map<String, Map<String, String>>();
        mapSubjects = new Map<String, Map<String, String>>();
        Map<String, String> mapParticipantLabel;
        Map<String, String> mapParticipantSubject;
        
        for(MailJetUtility__mdt m: metaDataList){
            
            mapParticipantLabel = new Map<String, String>();
            if(String.isNotBlank(m.Agent_Label__c)){ mapParticipantLabel.put('Agent', m.Agent_Label__c); }
            if(String.isNotBlank(m.Agent_2_Label__c)){ mapParticipantLabel.put('Agent_2', m.Agent_2_Label__c); }
            if(String.isNotBlank(m.Tenant_Label__c)){ mapParticipantLabel.put('Tenant', m.Tenant_Label__c); }
            if(String.isNotBlank(m.TenantAccBlank_Label__c)){ mapParticipantLabel.put('TenantAccBlank', m.TenantAccBlank_Label__c); }
            if(String.isNotBlank(m.PrimaryAgent_Label__c)){ mapParticipantLabel.put('PrimaryAgent', m.PrimaryAgent_Label__c	); }
            if(String.isNotBlank(m.IndependentLld_Label__c)){ mapParticipantLabel.put('IndependentLld', m.IndependentLld_Label__c); }
            if(String.isNotBlank(m.IndependentLld_2_Label__c)){ mapParticipantLabel.put('IndependentLld_2', m.IndependentLld_2_Label__c); }
            if(String.isNotBlank(m.NonMemberLld_Label__c)){ mapParticipantLabel.put('NonMemberLld', m.NonMemberLld_Label__c); }
            if(String.isNotBlank(m.NonMemberLld_2_Label__c)){ mapParticipantLabel.put('NonMemberLld_2', m.NonMemberLld_2_Label__c); }
            if(String.isNotBlank(m.AgentAccBlank_Label__c)){ mapParticipantLabel.put('AgentAccBlank', m.AgentAccBlank_Label__c); }
            if(String.isNotBlank(m.IndLLAccBlank_Label__c)){ mapParticipantLabel.put('IndLLAccBlank', m.IndLLAccBlank_Label__c); }
            if(String.isNotBlank(m.TenantLeadTrue_Label__c)){ mapParticipantLabel.put('TenantLeadTrue', m.TenantLeadTrue_Label__c); }
            if(String.isNotBlank(m.TenantLeadFalse_Label__c)){ mapParticipantLabel.put('TenantLeadFalse', m.TenantLeadFalse_Label__c); }
            if(String.isNotBlank(m.Tenant_Old_Email_Label__c)){ mapParticipantLabel.put('TenantOldEmail', m.Tenant_Old_Email_Label__c); }
            if(String.isNotBlank(m.TenantIncorrectDetail_Label__c)){ mapParticipantLabel.put('TenantIncorrectDetail', m.TenantIncorrectDetail_Label__c); }
            mapTemplateLabel.put(m.Key__c, mapParticipantLabel);
            
            mapParticipantSubject = new Map<String, String>();
            if(String.isNotBlank(m.Agent_Subject__c)){ mapParticipantSubject.put('Agent', m.Agent_Subject__c); }
            if(String.isNotBlank(m.Agent_2_Subject__c)){ mapParticipantSubject.put('Agent_2', m.Agent_2_Subject__c); }
            if(String.isNotBlank(m.Tenant_Subject__c)){ mapParticipantSubject.put('Tenant', m.Tenant_Subject__c); }
            if(String.isNotBlank(m.TenantAccBlank_Subject__c)){ mapParticipantSubject.put('TenantAccBlank', m.TenantAccBlank_Subject__c); }
            if(String.isNotBlank(m.PrimaryAgent_Subject__c)){ mapParticipantSubject.put('PrimaryAgent', m.PrimaryAgent_Subject__c); }
            if(String.isNotBlank(m.NonMemberLld_Subject__c)){ mapParticipantSubject.put('NonMemberLld', m.NonMemberLld_Subject__c); }
            if(String.isNotBlank(m.NonMemberLld_2_Subject__c)){ mapParticipantSubject.put('NonMemberLld_2', m.NonMemberLld_2_Subject__c); }
            if(String.isNotBlank(m.IndependentLld_Subject__c)){ mapParticipantSubject.put('IndependentLld', m.IndependentLld_Subject__c); }
            if(String.isNotBlank(m.IndependentLld_2_Subject__c)){ mapParticipantSubject.put('IndependentLld_2', m.IndependentLld_2_Subject__c); }
            if(String.isNotBlank(m.AgentAccBlank_Subject__c)){ mapParticipantSubject.put('AgentAccBlank', m.AgentAccBlank_Subject__c); }
            if(String.isNotBlank(m.IndLLAccBlank_Subject__c)){ mapParticipantSubject.put('IndLLAccBlank', m.IndLLAccBlank_Subject__c); }
            if(String.isNotBlank(m.TenantLeadTrue_Subject__c)){ mapParticipantSubject.put('TenantLeadTrue', m.TenantLeadTrue_Subject__c); }
            if(String.isNotBlank(m.TenantLeadFalse_Subject__c)){ mapParticipantSubject.put('TenantLeadFalse', m.TenantLeadFalse_Subject__c);}
            if(String.isNotBlank(m.Tenant_Old_Email_Subject__c)){ mapParticipantSubject.put('TenantOldEmail', m.Tenant_Old_Email_Subject__c);}
            if(String.isNotBlank(m.TenantIncorrectDetail_Subject__c)){ mapParticipantSubject.put('TenantIncorrectDetail', m.TenantIncorrectDetail_Subject__c);}
            mapSubjects.put(m.Key__c, mapParticipantSubject);
        }
        
    }
    
    public class MailJetWrapper{
        public Map<Id,Case> newMap = new Map<Id,Case>();
        public Map<String, Map<String, String>> mapTemplateLabel;
        public Map<String, Map<String, String>> mapSubjects;
        public Map<Id, Map<String, String>> mapVariables = new Map<Id, Map<String, String>>();
        public Map<Id, String> keyMap = new Map<Id,String>();
        public Map<Id, Case> oldCaseMap;
        public Map<Id, Case_Participant__c> selectiveCPMap = new Map<Id, Case_Participant__c>(); // store Case_Participant__c for selective email send
        public Map<Id, String> oldEmailCaseMap = new Map<Id, String>();
        public Map<Id, String> newEmailCaseMap = new Map<Id, String>();
        
        public MailJetWrapper(){}
        public MailJetWrapper(Case c, String key){
            this.newMap.put(c.Id, c);
            this.keyMap.put(c.Id, key);
        }
        
        public MailJetWrapper(Case c, String key, Map<String, String> variables){
            this.newMap.put(c.Id, c);
            this.keyMap.put(c.Id, key);
            this.mapVariables.put(c.Id, variables);
        }
        
        public MailJetWrapper(Map<Id,Case> mapCase, Map<Id, String> mapKey){
            this.newMap.putAll(mapCase);
            this.keyMap.putAll(mapKey);
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
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
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