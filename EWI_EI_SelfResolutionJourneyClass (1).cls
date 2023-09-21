/**********************************************************************************************************
* Author: Himanshu Modi, Abhinav sharma
* Purpose:This class has all the methods related to complete Self - journey.
*          
* *******************************************************************************************************/
/* Changes: 29 March 2022 -
*
* *******************************************************************************************************/
public without sharing class EWI_EI_SelfResolutionJourneyClass {
    
    
    /*
Created by:- Himanshu Modi
Created Date:- 14/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-14/03/22
Method used for:- This method is user for get all the claim data form case and its relative objects
that was raised in repayment request journey. 
*/
    @AuraEnabled(cacheable = true)
    public static list<case> getClaimDetailsByAccessCode(String AccessCode)
    { 
        system.debug('logLeveldffd'+ AccessCode);
        try{
            List<Case_Participant__c> cpList = [select Id,Case__c from Case_Participant__c where Access_Code__c=:AccessCode ];
            
            if(cpList.isEmpty()){ return null; }
            String claimId = cpList[0].Case__c;
            list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                    Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                                    Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                    Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                    Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                    AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                    Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                    inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                    Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                                    AGLL_Respond_Evidance_Gathering__c,Amount_Returned_to_Tenant__c,Amount_Returned_to_Landlord__c,Total_Claimed_by_Landlord__c,
                                    Claimed_by_Tenant__c,Not_reach_an_agreement_Reason_Tenant__c,AGLL_agreed_in_self_res__c,TT_agreed_in_self_res__c,
                                    (select id,Name,Type__c,Primary_Email__c,Access_Code__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
                                     from Case_Participants__r),
                                    (select id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                                     Agreed_by_AGLL__c,Agreed_by_Tenant__c,Claim_breakdown_other_AGLL__c,
                                     Claim_description_for_cleaning_agll__c,Claim_description_for_damage_agll__c,
                                     Claim_description_for_gardening_agll__c,Claim_description_for_redecoration_agll__c,
                                     Claimed_by_Landlord__c,Dispute__c,Evidence_at_tenancy_end_for_cleaning_agl__c,
                                     Evidence_at_tenancy_end_for_damage_agll__c,Evidence_at_tenancyend_gardening_agll__c,
                                     Evidence_at_tenancyend_redecoration_agll__c,Evidence_at_tenancystart_cleaning_agll__c,
                                     Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancystart_gardening_agll__c,
                                     Evidence_at_tenancystart_redecoration_ag__c,External_ID__c,Landlord_Statement__c,
                                     Other_Reason__c,Rent_arrears_description_agll__c,Supporting_clause_cleaning_agll__c,
                                     Supporting_clause_damage_agll__c,Supporting_clause_gardening_agll__c,Supporting_clause_other_agll__c,
                                     Supporting_clause_redecoration_agll__c,Supporting_clause_rent_agll__c,
                                     Supporting_evidence_for_cleaning_agll__c,Supporting_evidence_for_damage_agll__c,
                                     Supporting_evidence_for_gardening__c,Supporting_evidence_for_other_agll__c,
                                     Supporting_evidence_for_redecoration_agl__c,Supporting_evidence_for_rent_agll__c,
                                     Tenant_Response__c,Tenant_Statement__c,Type__c,Was_the_property_re_let_rent_agll__c,Is_Tenant_Agree__c,
                                     Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c
                                     from Dispute_Items__r order by createddate asc)
                                    //  ,
                                    // (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                    //  Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                                    //  from Evidence_Attachments__r)
                                    
                                    from case where id=:claimId];
            return caseparti;
        }
        catch(Exception e){
            return  null;
        }
        
    }
    
    /*
Created by:- Himanshu Modi
Created Date:- 16/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-16/03/22
Method used for:- This method is used to update case when AGll Repayment request agreed by Tenant. 
*/
    @AuraEnabled
    public static string updateCaseInRepaymentAgreementbyTenant(Id caseId, decimal agreedAmount, decimal depositAmount ){
        set<Id> caseIds = new set<Id>();
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Case closed – resolved without adjudication';
            cs.Bypass_validation__c = true;
            cs.Amount_to_agent_landlord__c = agreedAmount;
            cs.Amount_to_tenants__c = depositAmount - agreedAmount;
            cs.TT_respond_Self_resolution__c = true;
            cs.TT_agreed_in_self_res__c = true;
            if(cs.Amount_to_tenants__c ==0){
                cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by Tenant without AmountToTT in Selfres';
            }else{
                cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by Tenant in Self-Resolution';
            }
            
            cs.Respond_Date__c = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            system.debug('line-->68'+cs );
            update cs;
            for(Dispute_Item__c DI : [select Id,Agreed_by_AGLL__c,Agreed_by_Tenant__c,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c from Dispute_Item__c where recordtype.name='EWI Dispute Item' AND Dispute__c =: cs.Id])
            {
              DI.Agreed_by_Tenant__c = DI.Agreed_by_AGLL__c;
              DI.Adjustment_Percentage_by_TT__c = DI.Adjustment_Percentage_by_AGLL__c;
              Update DI;
            }
            caseIds.add(cs.Id);
            makePaymentsInSelfres(caseIds);
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseInRepaymentAgreementbyTenant');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);
            
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
        
        
        
    }
    
    /*
Orphan Method need to confirm where it is used but not using in self resolution 
*/
    @AuraEnabled
    public static string updateCaseInRepaymentAgreementbyAGLL(Id caseId, decimal depositAmount ){
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Case closed – resolved without adjudication';
            cs.Bypass_validation__c = true;
            cs.Amount_to_agent_landlord__c = 0;
            cs.Amount_to_tenants__c = depositAmount;
            cs.Respond_Date__c = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            system.debug('line-->68'+cs );
            update cs;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    /*
Created by:- Abhinav sharma
Created Date:- 16/03/22
Last Modified by:- Abhinav sharma
Last Modified Date:-16/03/22
Method used for:- This method is used to update case when Tenant Repayment request agreed by AGLL. 
*/
    @AuraEnabled
    public static string UpdateCaseInRepaymentAgreementbyAgll(Id caseId, decimal agreedAmount, decimal depositAmount ){
        String message='';
        set<Id> caseIds = new set<Id>();
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Case closed – resolved without adjudication';
            cs.Bypass_validation__c = true;
            cs.Amount_to_agent_landlord__c = agreedAmount;
            cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by AGLL in Self-Resolution';
            cs.AGLL_Respond_Self_resolution__c = true;
            cs.Amount_to_tenants__c = depositAmount - agreedAmount;
            cs.AGLL_agreed_in_self_res__c = true;
            cs.Respond_Date__c = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            system.debug('line-->68'+cs );
            update cs;
            caseIds.add(cs.Id);
            makePaymentsInSelfres(caseIds);
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'UpdateCaseInRepaymentAgreementbyAgll');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);    
            
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    /*
Created by:- Himanshu Modi
Created Date:- 18/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-18/03/22
Method used for:- This method is used to update case when Tenant making offer to AGLL. 
*/
    @AuraEnabled
    public static string updateCaseInOfferMadebyTenant(Id caseId, decimal offeramount, decimal depositAmount ){
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.TT_Made_offer__c  = true;
            cs.TT_Offer_Amount__c = offeramount;
            cs.AGLL_made_Offer__c=false ;
            cs.AGLL_Offer_Amount__c=null; 
            cs.TT_respond_Self_resolution__c = true;
            system.debug('line-->68'+cs );
            update cs;
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseInOfferMadebyTenant');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);
            
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    /*
Created by:- Abhinav sharma
Created Date:- 18/03/22
Last Modified by:- Abhinav sharma
Last Modified Date:-18/03/22
Method used for:- This method is used to update case when AGLL making offer to Tenant. 
*/
    @AuraEnabled
    public static string updateCaseInOfferMadebyAGll(Id caseId, decimal offeramount, decimal depositAmount ){
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.AGLL_made_Offer__c    = true;
            cs.AGLL_Offer_Amount__c = offeramount;
            cs.TT_Made_offer__c  = false;
            cs.AGLL_Respond_Self_resolution__c = true;
            cs.TT_Offer_Amount__c = null;
            system.debug('line-->124'+cs );
            update cs;
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseInOfferMadebyAGll');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);  
            
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Himanshu Modi
Created Date:- 19/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-19/03/22
Method used for:- This method is used to update case when Tenant Cancelled his own offer. 
*/
    @AuraEnabled
    public static string updateCaseInSelfOfferCancelledbyTenant(Id caseId){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,status,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.TT_Made_offer__c == true && caseobj.status=='Self-resolution'){
                Case cs = new Case();
                cs.Id = caseId;
                cs.TT_Made_offer__c  = false;
                cs.TT_Offer_Amount__c = null;
                cs.TT_respond_Self_resolution__c =true;
                system.debug('line-->68'+cs );
                update cs;
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseInSelfOfferCancelledbyTenant');
                if(!test.isRunningTest())
                    helper.sendMailJetEmail(wrapper);  
                
                return 'Success';
            }
            else{
                return 'Fail';  
            }
        }catch(Exception e){            
            return e.getMessage();
        }
    }
    
    
    /*
Created by:- Abhinav sharma
Created Date:- 19/03/22
Last Modified by:- Abhinav sharma
Last Modified Date:-19/03/22
Method used for:- This method is used to update case when AGLL Cancelled his own offer. 
*/
    @AuraEnabled
    public static string updateCaseInSelfOfferCancelledbyAGll(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,status,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.AGLL_made_Offer__c == true && caseobj.status=='Self-resolution'){
                Case cs = new Case();
                cs.Id = caseId;
                cs.AGLL_made_Offer__c    = false;
                cs.AGLL_Offer_Amount__c = null;
                cs.TT_respond_Self_resolution__c = true;
                system.debug('line-->158'+cs );
                update cs;
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseInSelfOfferCancelledbyAGll');
                if(!test.isRunningTest())
                    helper.sendMailJetEmail(wrapper);  
                
                return 'Success';
            }
            else{
                return 'Fail';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    /*
Created by:- Himanshu Modi
Created Date:- 25/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-25/03/22
Method used for:- This method is used to update case when Tenant is accepted AGLL offer. 
*/
    @AuraEnabled
    public static string updateCaseWhenTenantAcceptAGllOffer(Id caseId, Decimal amounttoagll ,Decimal depositamount ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        
        set<Id> caseIds = new set<Id>();
        try{
            If(caseobj.AGLL_made_Offer__c == true){
                Case cs = new Case();
                cs.Id = caseId;
                cs.Status = 'Case closed – resolved without adjudication';
                cs.Bypass_validation__c = true;
                cs.Amount_to_agent_landlord__c = amounttoagll;
                cs.TT_respond_Self_resolution__c = true;
                cs.Amount_to_tenants__c = depositamount-amounttoagll;
                cs.Resolved_Without_Adjudication_Reason__c = 'Offer Accepted by Tenant';
                cs.TT_agreed_in_self_res__c = true;
                cs.Respond_Date__c = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
                system.debug('line-->68'+cs );
                update cs;
                caseIds.add(cs.Id);
                makePaymentsInSelfres(caseIds);
                
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseWhenTenantAcceptAGllOffer');
                if(!test.isRunningTest()) 
                    helper.sendMailJetEmail(wrapper);  
                
                return 'Success';    
            }
            else{
                return 'Fail';    
            }
            
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Himanshu Modi
Created Date:- 25/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-25/03/22
Method used for:- This method is used to update case when Tenant is rejected AGLL offer. 
*/
    @AuraEnabled
    public static string updateCaseWhenTenantRejectAGllOffer(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.AGLL_made_Offer__c == true){
                Case cs = new Case();
                cs.Id = caseId;
                cs.AGLL_made_Offer__c=false; 
                cs.AGLL_Offer_Amount__c=null;
                cs.TT_respond_Self_resolution__c = true;
                update cs;
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseWhenTenantRejectAGllOffer');
                if(!test.isRunningTest()) 
                    helper.sendMailJetEmail(wrapper);  
                
                return 'Success';
            }
            else{
                return 'Fail';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to update case when AGll is accepted Tenant offer. 
*/
    @AuraEnabled
    public static string updateCaseWhenAGllAcceptTenantOffer(Id caseId, Decimal amounttoagll ,Decimal depositamount ){
        String message='';
        set<Id> caseIds = new set<Id>();
        system.debug('line-->304'+amounttoagll );
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        
        try{
            If(caseobj.TT_Made_offer__c == true){
                Case cs = new Case();
                cs.Id = caseId;
                cs.Status = 'Case closed – resolved without adjudication';
                cs.Bypass_validation__c = true;
                cs.Amount_to_agent_landlord__c = amounttoagll;
                cs.Amount_to_tenants__c = depositamount-amounttoagll;
                cs.Resolved_Without_Adjudication_Reason__c = 'Offer Accepted by AGLL';
                cs.AGLL_Respond_Self_resolution__c = true;
                cs.AGLL_agreed_in_self_res__c = true;
                cs.Respond_Date__c = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
                update cs;
                caseIds.add(cs.Id);
                makePaymentsInSelfres(caseIds);
                
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseWhenAGllAcceptTenantOffer');
                if(!test.isRunningTest()) 
                    helper.sendMailJetEmail(wrapper);
                
                return 'Success';
            }
            else{
                return 'Fail';        
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to update case when AGll is rejected Tenant offer. 
*/
    @AuraEnabled
    public static string updateCaseWhenAGllRejectTenantOffer(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.TT_Made_offer__c == true){
                Case cs = new Case();
                cs.Id = caseId;
                cs.TT_Made_offer__c=false; 
                cs.TT_Offer_Amount__c=null;
                cs.AGLL_Respond_Self_resolution__c = true;
                update cs;
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'ttmadeofferkey');
                helper.sendMailJetEmail(wrapper);
                return 'Success';
            }
            else{
                return 'Fail';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to make counter offer by agll. 
*/
    @AuraEnabled
    public static string updateCaseWhenAGllmadecounterOffer(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.TT_Made_offer__c == true){
                
                return 'Success';
            }
            else{
                return 'Fail';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
        /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to initiate offer by agll. 
*/
    @AuraEnabled
    public static string updateCaseWheninitiateofferbyagll(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.TT_Made_offer__c == true){
                
             return 'Fail';   
            }
            else{
                return 'Success';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to made counter offer by  tenant. 
*/
    @AuraEnabled
    public static string updateCaseWhenTenantmadecounterOffer(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.AGLL_made_Offer__c == true){
                
                return 'Success';
            }
            else{
                return 'Fail';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }    
    
            /*
Created by:- Abhinav Sharma
Created Date:- 25/03/22
Last Modified by:- Abhinav Sharma
Last Modified Date:-25/03/22
Method used for:- This method is used to initiate offer by tenant. 
*/
    @AuraEnabled
    public static string updateCaseWheninitiateofferbytenant(Id caseId ){
        String message='';
        Case caseobj = [select Id,AGLL_made_Offer__c,TT_Made_offer__c from case where Id=:caseId limit 1 ];
        try{
            If(caseobj.AGLL_made_Offer__c == true){
                
             return 'Fail';   
            }
            else{
                return 'Success';    
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /*
Created by:- Himanshu Modi
Created Date:- 27/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-27/03/22
Method used for:- This method is used to update case when Tenant adjust repayment. 
*/
    @AuraEnabled
    public static String updateRepaymentAdjustmentbyTenant(String caseId, decimal depositAmount, decimal adjustedAmount, String claimedItems){
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Amount_Returned_to_Tenant__c = depositAmount - adjustedAmount;
            cs.TT_respond_Self_resolution__c = true;
            system.debug('line-->291'+cs );
            update cs;
            
            Map<String, Object> ClaimItemsTypeAndDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(claimedItems);
            List<Dispute_Item__c> disputItemList = new List<Dispute_Item__c>();
            
            for(String ClaimItemId : ClaimItemsTypeAndDetailsMap.keySet()) {
                System.debug('ClaimItemsTypeAndDetailsMap key => '+ ClaimItemId +' ClaimItemsTypeAndDetailsMap value => '+ ClaimItemsTypeAndDetailsMap.get(ClaimItemId) );
                Map<String, Object> ClaimItemDetailsMap =  (Map<String, Object>) (ClaimItemsTypeAndDetailsMap.get(ClaimItemId));
                
                Dispute_Item__c disputObj = new Dispute_Item__c();
                disputObj.Id = ClaimItemId;
                disputObj.Agreed_by_Tenant__c = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('amountagreedbytt')));
                disputObj.Adjustment_Percentage_by_TT__c = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('AdjprcntbyTT')));
                
                disputItemList.add(disputObj);
            }
            System.debug('disputItemList => ' + disputItemList);
            update disputItemList;
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateRepaymentAdjustmentbyTenant');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);  
            
            message = 'SuccessFully Updated';
        }
        catch(exception e){
            message = e.getMessage();
        }
        return message;
    }
    
    
    
    /*
Created by:- Abhinav sharma
Created Date:- 28/03/22
Last Modified by:- Abhinav sharma
Last Modified Date:-28/03/22
Method used for:- This method is used to update case when AGLL adjust repayment. 
*/
    @AuraEnabled
    public static String updateRepaymentAdjustmentbyAGLL(String caseId, decimal depositAmount, decimal adjustedAmount, String claimedItems){
        String message='';
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Amount_Returned_to_Landlord__c = depositAmount - adjustedAmount;
            cs.AGLL_Respond_Self_resolution__c = true;
            system.debug('line-->291'+cs );
            update cs;
            
            Map<String, Object> ClaimItemsTypeAndDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(claimedItems);
            List<Dispute_Item__c> disputItemList = new List<Dispute_Item__c>();
            
            for(String ClaimItemId : ClaimItemsTypeAndDetailsMap.keySet()) {
                System.debug('ClaimItemsTypeAndDetailsMap key => '+ ClaimItemId +' ClaimItemsTypeAndDetailsMap value => '+ ClaimItemsTypeAndDetailsMap.get(ClaimItemId) );
                Map<String, Object> ClaimItemDetailsMap =  (Map<String, Object>) (ClaimItemsTypeAndDetailsMap.get(ClaimItemId));
                
                Dispute_Item__c disputObj = new Dispute_Item__c();
                disputObj.Id = ClaimItemId;
                disputObj.Agreed_by_AGLL__c = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('amountagreedbyagll')));
                disputObj.Adjustment_Percentage_by_AGLL__c = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('adjperbyAGLL')));
                
                disputItemList.add(disputObj);
            }
            System.debug('disputItemList => ' + disputItemList);
            update disputItemList;
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateRepaymentAdjustmentbyAGLL');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);  
            
            message = 'SuccessFully Updated';
        }
        catch(exception e){
            message = e.getMessage();
        }
        return message;
    }
    
    
    /*
Created by:- Himanshu Modi
Created Date:- 29/03/22
Last Modified by:- Himanshu Modi
Last Modified Date:-29/03/22
Method used for:- This method is used to update case when TT Reached No agreement. 
*/
    @AuraEnabled
    public static string UpdateCaseNoAgreementBYTT(string cmnts, string claimId)
    {
        case updatecase = new case(id=claimId,Not_reach_an_agreement_Reason_Tenant__c=cmnts,TT_respond_Self_resolution__c =true);
        update updatecase;
        // EI_ZD_EmailUtility.sendEmailtoLandlordSelfResolution(claimId,'Invite landlord to respond self resolution');
        return 'Record successfully updated';
    }
    
    /*
Created by:- Abhinav sharma
Created Date:- 29/03/22
Last Modified by:- Abhinav sharma
Last Modified Date:-29/03/22
Method used for:- This method is used to update case when AGLL Reached No agreement. 
*/
    @AuraEnabled
    public static string UpdateCaseNoAgreementBYAGll(string cmnts, string claimId)
    {
        case updatecase = new case(id=claimId,Not_reach_an_agreement_Reason_AG_LL__c=cmnts,AGLL_Respond_Self_resolution__c =true);
        update updatecase;
        // EI_ZD_EmailUtility.sendEmailtoLandlordSelfResolution(claimId,'Invite landlord to respond self resolution');
        return 'Record successfully updated';
    }
    
    
    
    public class ChatWrapper{
        @AuraEnabled public  list<Chat_History__c> chatList{get;set;}
        @AuraEnabled public  String  otherPartyName{get;set;}
        @AuraEnabled public  String  selfName{get;set;}
        @AuraEnabled public  String  currentContactId{get;set;}
        @AuraEnabled public  String  otherPartyContactId{get;set;}
        @AuraEnabled public  Decimal  numberOfEvidences{get;set;}
        @AuraEnabled public  String  currentContactemail{get;set;}
        
        
    }
    
    @AuraEnabled
    public static ChatWrapper updateChatFields(String caseId,string accessCode){
        
        Decimal evidenceCount =0;
        String otherPartyContactId = '';
        String otherPartyName = '';
        
        
        // list<User> userList = [Select Id,Name,ProfileId,Profile.Name,ContactId from User where Id=:UserInfo.getUserId()];
        // String profileName = userList[0].Profile.Name;
        system.debug('logLevel 494 '+ caseId);
        system.debug('logLevel 495 '+ accessCode);
        Case_Participant__c participant = [Select Id,Participant_name__c,Contact__c,Primary_Email__c,AGLL_Raised_Respond__c,Contact__r.Name,Type__c from Case_Participant__c where Case__c =: caseId AND Access_Code__c =: accessCode ];
        
        
        if(participant.Type__c == 'Tenant'){
            
            list<Case_Participant__c> participantsList = [Select Id,Participant_name__c,Contact__c,AGLL_Raised_Respond__c ,Contact__r.Name from Case_Participant__c where Case__c =: caseId AND Type__c != 'Tenant' and AGLL_Raised_Respond__c = True];
            
            if(!participantsList.isEmpty()){
                otherPartyContactId = participantsList[0].Id;
                otherPartyName = participantsList[0].Participant_name__c;
                
            }
            
        }if(participant.Type__c != 'Tenant'){
            
            list<Case_Participant__c> participantsList = [Select Id,Participant_name__c,Contact__c,Contact__r.Name from Case_Participant__c where Case__c =: caseId AND  Is_Lead__c = true AND Type__c = 'Tenant' ];
            
            if(!participantsList.isEmpty()){
                otherPartyContactId = participantsList[0].Id;
                otherPartyName = participantsList[0].Participant_name__c;
                
            }
            
        }
        
        system.debug('otherPartyContactId  518'+ otherPartyContactId);
        system.debug('otherPartyName  519'+ otherPartyName);
        
        //   list<User> userName = [Select Id,Name,ContactId from User where Id =: UserInfo.getUserId()];
        
        list<Chat_History__c> chatList = [Select Id,Azure_File_Name__c,ewi_from__c,ewi_to__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__c =: caseId ORDER BY CreatedDate];
        
        for(Chat_History__c chat :chatList){
            if(String.isNotBlank(chat.File_Location__c) && chat.ewi_from__c == participant.Id){
                chat.File_Location__c = chat.File_Location__c.UnescapeHTML4();
                evidenceCount++;
            }else if(String.isNotBlank(chat.File_Location__c)){
                chat.File_Location__c = chat.File_Location__c.UnescapeHTML4();
            }
            
        }
        
        list<Chat_History__c> updateLastSeen = [Select Id,Azure_File_Name__c,ewi_from__c,ewi_to__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__c =: caseId AND Seen_at__c = null AND ewi_to__c =: participant.Id ORDER BY CreatedDate];
        
        for(Chat_History__c chat : updateLastSeen){
            chat.Seen_at__c = System.now();
        }
        if(updateLastSeen != null && !updateLastSeen.isEmpty()){
            Update updateLastSeen;
        }        
        ChatWrapper wrap = new ChatWrapper();
        wrap.currentContactId = participant.Id;
        wrap.selfName = participant.Participant_name__c;
        wrap.otherPartyName = otherPartyName;
        wrap.chatList = chatList;
        wrap.otherPartyContactId = otherPartyContactId;
        wrap.numberOfEvidences = evidenceCount;
        
        
        return wrap;
        
        
        
    }
    
    @AuraEnabled
    public static ChatWrapper updateChatHistory(String caseId, String message, String fromId, String toId,string accessCode){
        
        insert new Chat_History__c(Case__c = caseId,/*From__c='0033L00000MVGnPQAX' ,*/ ewi_from__c = fromId, Message__c = message, ewi_to__c =toId);
        List<Chat_History__c> lst = [select id,Case__c,From__c, ewi_from__c,ewi_to__c,Message__c ,To__c from Chat_History__c ];
        system.debug('line--> 562 ' +  lst);
        return updateChatFields(caseId,accessCode);
        
    }
    @AuraEnabled
    public static String getSecureURI(String scheme){
        System.debug('Line 296 -> '+scheme);
        Azure_Storage_Credentials_per_Scheme__mdt settings = EWI_EI_SelfResolutionJourneyClass.getAzureMetadata(scheme);
        System.debug('Line 297 -> '+(EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c));
        return EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        
    }
    
    private static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
        Azure_Storage_Credentials_per_Scheme__mdt settings;
        try {
            settings = [
                SELECT Account_Name_Production__c,
                Account_Name_Sandbox__c,
                Container_Name_Production__c,
                Container_Name_Sandbox__c,
                Endpoint_Production__c,
                Endpoint_Sandbox__c,
                Secure_URI_Production__c,
                Secure_URI_Sandbox__c,
                Storage_Key_Production__c,
                Storage_Key_Sandbox__c
                FROM Azure_Storage_Credentials_per_Scheme__mdt
                WHERE Label = :scheme
            ];
        }
        catch(QueryException exc) {
            //throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ');
        }
        return settings;
    }
    @AuraEnabled
    public static ChatWrapper saveFile(String caseId, string accessCode, String fromId, String toId, String fileName, String azureLink, String fileType, String fileSize, String fileLable, String fileNameInAzure, String scheme){
        
        insert new Chat_History__c(Case__c = caseId, 
                                   ewi_from__c = fromId, 
                                   Azure_File_Name__c = fileNameInAzure, 
                                   ewi_to__c =toId,
                                 //  From__c='0033L00000MVGnPQAX',
                                   File_Name__c = fileName,
                                   File_Location__c = azureLink,
                                   File_Type__c = fileType,
                                   File_Size__c = decimal.valueOf(fileSize),
                                   File_Description__c = fileLable,
                                   Scheme__c = scheme
                                  );
        return updateChatFields(caseId,accessCode);
        
    }
    
    @AuraEnabled(cacheable = true)
    public static Integer returnUnreadMessages(String accessCode){
        
        Integer unreadMessageCount = 0;
        system.debug('line-->861' + accessCode); 
        List<Case_Participant__c> cpList = [Select Id,Participant_name__c,Contact__c,Case__c,Contact__r.Name,Type__c from Case_Participant__c where  Access_Code__c =: accessCode ];
        system.debug('line-->863' + cpList);
        if(cpList.isEmpty()){ return unreadMessageCount; }
       
        Case_Participant__c participant = cpList[0];
         system.debug('line-->866' + participant.Id); 
        // list<Chat_History__c> unseenMessages = [Select Id,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__r.Deposit_Account_Number__c =: depositId AND Seen_at__c = null AND To__c =: userList[0].ContactId ORDER BY CreatedDate];
        list<Chat_History__c> unseenMessages = [Select Id,ewi_from__c,ewi_to__c,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__c =: participant.Case__c AND Seen_at__c = null AND ewi_to__c =: participant.Id ORDER BY CreatedDate];
        
        if(unseenMessages != null && !unseenMessages.isEmpty()){
            unreadMessageCount = unseenMessages.size();
        }
        system.debug('line-->818' + unreadMessageCount); 
        return unreadMessageCount;
        
        
    }
    
    public static void makePaymentsInSelfres (set<Id> setOfCaseIds ){
        system.debug('line--> 765 ' + setOfCaseIds);
        Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
            ([SELECT Id, Remaining_deposit_amount__c, Total_Agreed_by_Tenant__c,Amount_to_agent_landlord__c,Amount_to_tenants__c,Total_Agreed_by_AG_LL__c,Status, Total_Deposit__c, Deposit_Account_Number__r.Name, 
              Total_amount_in_dispute__c,Deposit_Account_Number__c ,Respond_Date__c,Agreed_amount_paid_to_agent_landlord__c,Agreed_amount_paid_to_tenant__c,
              (SELECT Id, Account__c, Contact__c, Case__c,Case__r.Deposit_Account_Number__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName
               FROM Case_Participants__r) FROM Case where Id In :setOfCaseIds
             ]);
        
        EI_InstallmentUtilityHelper installmentHelper = new EI_InstallmentUtilityHelper();
        Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper> installmentUtilityMap = new Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper>();
        
        EI_InstallmentUtilityHelper.InstallmentUtilityWrapper instWrap = new EI_InstallmentUtilityHelper.InstallmentUtilityWrapper();
        instWrap.eachCase = mapOfCaseWithCasePar.values()[0];
        instWrap = installmentHelper.getSelfResolutionAmount(instWrap);
        installmentUtilityMap.put(instWrap.eachCase.Id, instWrap);
        
        installmentHelper.createEWIInstallment(installmentUtilityMap);
        
        
        
    }
    
    
    
    
}