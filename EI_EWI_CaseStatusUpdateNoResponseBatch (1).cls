/*
Created by:- Vidhi Agrawal
Created Date:- 27/07/22
Last Modified by:- Vidhi Agrawal
Last Modified Date:- 27/07/22
Method used for:- EID-62 
AC-9 : If the case is in the status of ‘Proposal submitted - awaiting tenant response’ for 5 working days send reminder email,
AC-9.1 : If the case is in the status of ‘Proposal submitted - awaiting tenant response’ for 10 working days UPDATE case status to 'No response from tenant',
AC-10.2 : If the case is in the status of ‘Proposal submitted – awaiting agent/landlord response’ for 5 working days send reminder email,
AC-10.3 : If the case is in the status of ‘Proposal submitted – awaiting agent/landlord response’ for 10 working UPDATE case status to 'No response from agent/landlord'
UPDATE => EID 1172
AC-10.2 : If the case is in the status of ‘Proposal submitted – awaiting agent/landlord response’ for 10 working days send reminder email,
AC-10.3 : If the case is in the status of ‘Proposal submitted – awaiting agent/landlord response’ for 20 working UPDATE case status to 'No response from agent/landlord'

*/

public class EI_EWI_CaseStatusUpdateNoResponseBatch implements DataBase.Batchable<sObject>, database.AllowsCallouts, Database.Stateful, Schedulable {
	
    public void execute(SchedulableContext SC){
        Database.executeBatch(new EI_EWI_CaseStatusUpdateNoResponseBatch(), 1);
    }
    
    public static List<Holiday> holidayList;
    public Date check_5_workingdaycompleted = calculateWorkingDaysBetweenTwoDates(System.today(), 4);
   	public Date check_10_workingdaycompleted = System.today();
    public Date check_10_workingdaycompleted_AGLL = calculateWorkingDaysBetweenTwoDates(System.today(), 9); // EID 1172
    public Date check_20_workingdaycompleted_AGLL = System.today(); // EID 1172
    
    public EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
    Public Map<Id, Case> caseMap = new Map<Id, Case>();
    Public Map<Id, String> keyMap = new Map<Id, String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('check_5_workingdaycompleted => '+check_5_workingdaycompleted);
        system.debug('check_10_workingdaycompleted => '+check_10_workingdaycompleted);
        
         Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
         string query ='Select Id,Status,Respond_Date__c,createdDate,TDSN_Reference_Number__c, Deposit_Account_Number__r.Property_Address_WO_Country__c,(Select Id,Type__c, Case__c,Account__c, Account__r.Name, Account__r.Email__c, Account__r.PersonEmail, Contact__c, Contact__r.Email, Contact__r.Name, Access_Code__c From Case_Participants__r  )'+
             ' from Case where Respond_Date__c != null AND RecordtypeId=:devRecordTypeId  AND '+
             ' ((Status=\'Proposal submitted – awaiting tenant response\' AND (Respond_Date__c <:check_10_workingdaycompleted OR Respond_Date__c =:check_5_workingdaycompleted)) ' + 
             ' OR (Status=\'Proposal submitted – awaiting agent/landlord response\' AND (Respond_Date__c <:check_20_workingdaycompleted_AGLL OR Respond_Date__c =:check_10_workingdaycompleted_AGLL))) ';
         return database.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList) {
         
        system.debug('caseList='+caseList);
        Map<Id, case> modifycase = new Map<Id, case>();
       
        if(!caseList.isEmpty()){
            for(Case caseObj : caseList){
                // If the case is in the status of ‘Proposal submitted - awaiting tenant response’ for 10 working days
                if(caseObj.Status == 'Proposal submitted – awaiting tenant response' && caseObj.Respond_Date__c < check_10_workingdaycompleted){
                    caseObj.Status='No response from tenant';
                    if(!modifycase.containsKey(caseObj.Id)){
                        modifycase.put(caseObj.Id, caseObj);
                    }
                }
                // If the case is in the status of ‘Proposal submitted – awaiting agent/landlord response’ for 20 working days
                if(caseObj.Status == 'Proposal submitted – awaiting agent/landlord response' && caseObj.Respond_Date__c < check_20_workingdaycompleted_AGLL){
                    caseObj.Status='No response from agent/landlord';
                    if(!modifycase.containsKey(caseObj.Id)){
                        modifycase.put(caseObj.Id, caseObj);
                    }
                }
                
                if(caseObj.Status == 'Proposal submitted – awaiting tenant response' && caseObj.Respond_Date__c == check_5_workingdaycompleted){
                    /* EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
					EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(caseObj, 'caseStatusUpdateNoResponse5workingDayBatch');*/
                    
                    caseMap.put(caseObj.Id, caseObj);
                    keyMap.put(caseObj.Id, 'caseStatusUpdateNoResponse5workingDayBatch');
                }
                
                if(caseObj.Status == 'Proposal submitted – awaiting agent/landlord response' && caseObj.Respond_Date__c == check_10_workingdaycompleted_AGLL){
                    caseMap.put(caseObj.Id, caseObj);
                    keyMap.put(caseObj.Id, 'caseStatusUpdateNoResponse5workingDayBatch1');
                } 
                
                   /* for(Case_Participant__c csPar : caseobj.Case_Participants__r){
                        String emailValue ='';
                        if(csPar.Account__r.PersonEmail != null || csPar.Account__r.PersonEmail !='' ||csPar.Account__r.PersonEmail != 'undefined'){
                            emailValue = csPar.Account__r.PersonEmail;
                        }
                        else if(csPar.Account__r.Email__c != null || csPar.Account__r.Email__c !='' ||csPar.Account__r.Email__c != 'undefined'){
                            emailValue = csPar.Account__r.Email__c;
                        }
                        if(caseObj.Status == 'Proposal submitted – awaiting tenant response'){
                            if(csPar.Type__c == 'Tenant'){
                                string accessCode = csPar.Access_Code__c;
           		   				String CTAbtn ='<a style="background-color: #457cbf;color: #fff;font-size: 1rem;text-transform: initial;padding-top: 0.5rem;padding-bottom: 0.5rem;padding-left: 0.5rem; padding-right: 0.5rem; display: inline-block; outline: 0!important; text-decoration: none!important; text-align: center; width: 220px; border-radius: 3rem;"  href="'+System.Label.EWI_Deposit_Allocation_Summary+'?accessCode='+accessCode+'">CTA</a>';
            					System.debug('link => ' + CTAbtn);
                                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                                Map<String, String> variableMap = new Map<String, String>();
                                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(emailValue, csPar.Account__r.Name, caseObj.Id, csPar.Account__c));
                                variableMap.put('name', csPar.Account__r.Name);
                                variableMap.put('TDSN_no', caseObj.TDSN_Reference_Number__c);
                                variableMap.put('property_address', caseObj.Deposit_Account_Number__r.Property_Address_WO_Country__c) ;
                                variableMap.put('CTA_link', CTAbtn);
                                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap,'EWISend5WorkingDaysReminderMailToTT',  caseObj.TDSN_Reference_Number__c+'-  Reminder – Complete your deposit allocation proposal'));
                                system.debug('emailWrapperList2='+emailWrapperList); 
                            } 
                        }
                        else if(caseObj.Status == 'Proposal submitted – awaiting agent/landlord response'){
                           	    if(csPar.Type__c =='Agent' || csPar.Type__c =='Non-Member Landlord' || csPar.Type__c =='Independent-Landlord'){
                                string accessCode = csPar.Access_Code__c;
           		   				String CTAbtn ='<a style="background-color: #457cbf;color: #fff;font-size: 1rem;text-transform: initial;padding-top: 0.5rem;padding-bottom: 0.5rem;padding-left: 0.5rem; padding-right: 0.5rem; display: inline-block; outline: 0!important; text-decoration: none!important; text-align: center; width: 220px; border-radius: 3rem;"  href="'+System.Label.EWI_Deposit_Allocation_Summary+'?accessCode='+accessCode+'">CTA</a>';
            					System.debug('link => ' + CTAbtn);
                                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                                Map<String, String> variableMap = new Map<String, String>();
                                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(emailValue, csPar.Account__r.Name, caseObj.Id, csPar.Account__c));
                                variableMap.put('name', csPar.Account__r.Name);
                                variableMap.put('TDSN_no', caseObj.TDSN_Reference_Number__c);
                                variableMap.put('property_address', caseObj.Deposit_Account_Number__r.Property_Address_WO_Country__c) ;
                                variableMap.put('CTA_link', CTAbtn);
                                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap,'EWIRemainderRespondEmailToAGLL',  caseObj.TDSN_Reference_Number__c+'-  Reminder – Complete your deposit allocation proposal'));
                                system.debug(':emailWrapperList='+emailWrapperList); 
                        }
                    }
                }*/
            }
            // update case
            if(!modifycase.isempty()){
                Database.update(modifycase.values(),false);
            } 
        }   
    }
     
    
    public void finish(DataBase.BatchableContext BC) {
        EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
        wrapper.keyMap = keyMap;
        wrapper.newMap = caseMap;
        helper.sendMailJetEmail(wrapper);
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = listOfHolidayCountryWise('England and Wales');
            //holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays) {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) == 5 || weekStart.daysBetween(currentDate) == 6) {
            return false;
        } else {
            return true;    
        }
    }
    
    public static List<Holiday> listOfHolidayCountryWise(String businessHoursName){
        Map<Id, BusinessHours> businessHoursMap = new Map<Id, BusinessHours>();
        Map<Id, Holiday> holidayMap = new Map<Id, Holiday>([SELECT Id, StartTimeInMinutes,ActivityDate, Name, Description 
                                                            FROM Holiday 
                                                            ORDER BY ActivityDate, Id]);
        
        List<Holiday> listOfHolidays = new List<Holiday>(); 
        if(businessHoursName!='') {
            String likeValue = '%'+businessHoursName+'%';
            businessHoursMap = new Map<Id, BusinessHours>([SELECT Id, Name, IsActive 
                                                           FROM BusinessHours 
                                                           WHERE (Name LIKE:likeValue AND IsActive = TRUE)]);
        }
        if(!businessHoursMap.isEmpty() && businessHoursMap.size() > 0 && !holidayMap.isEmpty() && holidayMap.size() > 0) {
            for(BusinessHours businessHoursVar : businessHoursMap.values()) {
                for(Holiday holidayVar : holidayMap.values()){
                    if(!BusinessHours.isWithin(businessHoursVar.Id, holidayVar.ActivityDate)) {
                        listOfHolidays.add(holidayVar);
                    }
                }
            }
        }
        if(!listOfHolidays.isEmpty() && listOfHolidays.size() > 0) {
            return listOfHolidays;
        }
        return null;
    }
}