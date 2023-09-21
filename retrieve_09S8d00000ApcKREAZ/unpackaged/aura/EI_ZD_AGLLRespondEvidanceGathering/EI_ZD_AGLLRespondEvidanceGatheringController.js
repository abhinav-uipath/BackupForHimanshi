({
    doInit : function(component, event, helper) {
        let currentURL = window.location.href;
        let AccessCode = currentURL.split("id=")[1];
        var action = component.get("c.getClaimDetailsByAccessCode");
        action.setParams({
            "AccessCode": AccessCode
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.ClaimsDetails",a.getReturnValue());
                let disputOldRecMap = new Map();
                let caseItemRec =a.getReturnValue()[0].Dispute_Items__r;
                for(let i=0; i<caseItemRec.length;i++)
                {
                    var AmountObj = new Object();
                    AmountObj.Amount = caseItemRec[i].Agreed_by_AGLL__c;
                    AmountObj.Percentage = caseItemRec[i].Adjustment_Percentage_by_AGLL__c;
                    disputOldRecMap.set(caseItemRec[i].Id,AmountObj);
                    if(caseItemRec[i].Type__c=='Rent')
                    {
                        component.set("v.isClaimForRent",true);
                    }
                }
                component.set("v.disputOldRecMap",disputOldRecMap);
                if(component.get("v.ClaimsDetails[0].Status") =='Closed' || component.get("v.ClaimsDetails[0].Status") =='Invitation to view the claim'  )
                {
                    component.set("v.showContinueBtn",false);
                }
                else
                {
                    
                    component.set("v.showContinueBtn",true);
                }
                if(component.get("v.ClaimsDetails[0].Status") =='Evidence gathering agent/landlord')
                {
                    var appEvent = $A.get("e.c:EI_ZD_refreshParentView");
                    appEvent.setParams({"pageName" : "Submit evidence"}); 
                    appEvent.fire();
                }
                
                
                
            }
            else {
                let errormessage = JSON.stringify(a.getReturnValue());
                if (errormessage.includes("<br>")) {
                    errormessage = errormessage.replaceAll("<br>", " ");
                    component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message: errormessage,
                        closeCallback: function() {}
                    });
                }
            }
        });
        $A.enqueueAction(action);
         
    },
    
    goToCliamSummary : function(component, event, helper) {
        var divId = event.getSource().getLocalId();
        // Jump to first Item in claim catagories
        //component.set("v.currentItem",0);
        if(divId=='div0'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div1'){
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div2'){
            if(component.get("v.currentItem")==0){
                component.set("v.keyDocuments",true);
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",false);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConsentError",false);
                component.set("v.showKeyDocumentsError",false);
                component.set("v.showDisputeItemError",false);
            }else{
                component.set("v.currentItem",component.get("v.currentItem") - 1); 
                component.set("v.showConsentError",false);
                component.set("v.showKeyDocumentsError",false);
                component.set("v.showDisputeItemError",false);
            }
        }
        
        if(divId=='div3'){
            component.set("v.showClaimBreakdown",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div4'){
            component.set("v.showAdditionalComments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        if(divId=='div5'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        //location.reload();
    },
    goToHomePage : function(component, event, helper) { 
        location.reload();
    },
    showContinue : function(component, event, helper) {        
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        // document.getElementById('scrollView121').scrollIntoView(true);
        
    },
    goToKeyDocuments : function(component, event, helper) {
        var sel ; 
        var isEditable = component.get("v.isEditable");
        component.set("v.consentBoxValue",sel);
        if(isEditable){
            sel = document.getElementById("exampleCheck2").checked;
        }
        else{
            sel=true;
            //  
        }
        if(sel)
        {
            var action = component.get("c.updateClaimAGLL");
            action.setParams({
                    "claimId":component.get("v.ClaimsDetails[0].Id")
                });
            action.setCallback(this, function(a) {
                    var state = a.getState();
                    var errors = a.getError();
                    if (state == "SUCCESS") {
                        component.set("v.ViewContinue",false);
                        component.set("v.viewClaim",false);
                        component.set("v.keyDocuments",true);
                        component.set("v.showConsentError",false);
                        document.getElementById('scrollView121').scrollIntoView(true);
                    }
                    else {
                        alert('An error has occured');
                    }
                });
                $A.enqueueAction(action); 
            
            
        }
        else
        {
            component.set("v.showConsentError",true);
        }
        if(!isEditable){
            document.getElementById("TenantObligations").className = "disabled-link";     
        }
    },
    clickYes : function(component, event, helper) {  
        let selectRecordId = event.target.id;
        if(selectRecordId =='TenantObligations')
        {
            component.set("v.ClaimsDetails[0].Tenant_obligations__c",'Yes');
        }
        else if(selectRecordId =='inventorycheck')
        {
            component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'Yes');
        }
            else if(selectRecordId =='checkoutReport')
            {
                component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'Yes');
            }
                else if(selectRecordId =='rentStatement')
                {
                    component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'Yes');
                }
        
    },
    clickNo : function(component, event, helper) {  
        let selectRecordId = event.target.id;
        if(selectRecordId =='TenantObligations')
        {
            component.set("v.ClaimsDetails[0].Tenant_obligations__c",'No');
        }
        else if(selectRecordId =='inventorycheck')
        {
            component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'No');
        }
            else if(selectRecordId =='checkoutReport')
            {
                component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'No');
            }
                else if(selectRecordId =='rentStatement')
                {
                    component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'No');
                }
    },
    charCountDisplay : function(component, event, helper) {
    	
/*        //var exceedComment= event.getSource().get("v.value");
        //var exceedComment=component.find("input1").get("v.value");
        //let exceedComment = component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c"); //test removal
        let exceedComment =component.find("claimExceedsCommentField").get("v.value"); console.log(exceedComment); //test addn
        var exceedCommentChars = exceedComment.length;
        //test addn below
        if (exceedCommentChars >= 50 && exceedCommentChars < 1000) {
            console.log('hi111111');
    	$A.util.addClass(exceedCommentChars, "slds-has-success");
            console.log('hi222222222');
		} else {
            console.log('hi22222222dkdv2');
    	$A.util.removeClass(exceedCommentChars, "slds-has-success");
		}
        //test addn below complete
        component.set("v.exceedCommentCharsCount", exceedCommentChars);   */
let textarea = component.find("claimExceedsCommentField"); console.log('textarea',textarea);
let value = textarea.get("v.value"); console.log('value',value);
let length = value.length; console.log('length',length);
let depositAmount = component.get("v.ClaimsDetails[0].Deposit_Account_Number__r.Deposit_Amount__c"); if(!depositAmount){console.log('Deposit amount is null or undefined');}else{console.log('depositAmount', depositAmount);}
let formatednumber = depositAmount ? Number(depositAmount).toFixed(2) : ''; console.log('formatednumber',formatednumber);
let depositamtformated = formatednumber ? formatednumber.toLocaleString('en-GB') : ''; console.log('depositamtformated',depositamtformated);
let message = `You have told us that your claim is higher than the maximum guarantee value which is £${depositamtformated}. Please tell us why in the field above. You should also provide the total value of your claim in the box above.`; console.log('message',message);

if (length >= 50 && length <= 1000) {
	$A.util.addClass(textarea, "slds-has-success");
	$A.util.removeClass(textarea, "slds-has-error");
    textarea.setCustomValidity("");
} else if(length==0){
	//textarea.setCustomValidity("You have told us that your claim is higher than the maximum guarantee value which is £" + depositamtformated + ". Please tell us why in the field above. You should also provide the total value of your claim in the box above.");
    textarea.setCustomValidity(message);
    //var form = component.find("Form");
    //form.reportValidity();
    console.log('HI');
} else if (length < 50) {
	$A.util.addClass(textarea, "slds-has-error");
	$A.util.removeClass(textarea, "slds-has-success");
    textarea.setCustomValidity("Detail relating to excess guarantee is too short. Please provide additional information. If you do not provide specific or relevant information here, your claim may be delayed or the award affected.");
} else {
	$A.util.removeClass(textarea, "slds-has-error slds-has-success");
}

component.set("v.exceedCommentCharsCount", length);
        
    },
    //below is new 
    charCountDisplayDI : function(component, event, helper){
        console.log('charCountDisplayDI triggered');

    /*let textarea = component.find("Cleaning");
        console.log('textarea:',textarea);
let value = textarea.get("v.value");
let length = value.length;
        console.log('length:',length);*/
        let textareaName = event.getSource();

        //let textarea = component.find(textareaName);
        //console.log('textarea:',textarea);
        //let value = textarea.getElement().value;
        let value= textareaName.get("v.value");
		console.log('value:',value);
		let length = value.length;
        console.log('length:',length);
        let textareaId= event.getSource().getLocalId();

if (length >= 50 && length <= 1000) {
    console.log('length1:',length);
	$A.util.addClass(textareaName, "slds-has-success");
	$A.util.removeClass(textareaName, "slds-has-error");
    textareaName.setCustomValidity("");
} else if(length == 0){
    console.log('length:',length);
   textareaName.setCustomValidity('Please provide a breakdown of your ' + textareaId + ' claim.');
    console.log('test for custom error at o length');
} else if (length < 50 && length > 0) {
    console.log('length2:',length);
	$A.util.addClass(textareaName, "slds-has-error");
	$A.util.removeClass(textareaName, "slds-has-success");
    textareaName.setCustomValidity("Detail relating to excess guarantee is too short. Please provide additional information. If you do not provide specific or relevant information here, your claim may be delayed or the award affected."); 
} else {
	$A.util.removeClass(textareaName, "slds-has-error slds-has-success");
    textareaName.setCustomValidity(""); 
}
	},
    
   /* handleClaimValue : function(component, event, helper) {
        
        let guaranteeAmt= component.get("v.ClaimsDetails[0].Deposit_Account_Number__r.Deposit_Amount__c");
        let excessClaimVal= component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c");
        //let excessClaimVal= component.get("v.excessClaimVal"); // new add
        //let excessClaimVal= component.find("totalclaimvalue").get("v.value");
        //var pattern = /^£?\d+(\.\d{2})?$/;
		var pattern = /^£?\d+(\.\d{2})?$|^[^etkbm\+]*$/;
		//var pattern = /[^0-9£.]+/g;
        //var excessClaimVal= component.get("v.excessClaimVal");
        //test addn start
          var currencyFormatter = new Intl.NumberFormat('en-GB', {
    		style: 'currency',
    		currency: 'GBP'
  			});
          //excessClaimVal = currencyFormatter.format(parseFloat(excessClaimVal));
 		  //excessClaimVal = excessClaimVal.replace(/£/g, "");
        //test addn end
        //let numericValue = excessClaimVal.replace(/[^0-9.]+/g, "");
        console.log('value of excessClaimVal',excessClaimVal);
        console.log('value of guaranteeAmt',guaranteeAmt); 
        console.log('value of parseFloat(excessClaimVal)',parseFloat(excessClaimVal));
        console.log('value of parseFloat(guaranteeAmt)',parseFloat(guaranteeAmt));
        console.log('helo ujwal');
        //var formattedExcessClaimVal = "£" + excessClaimVal.toFixed(2);
        //console.log('value of formattedExcessClaimVal',formattedExcessClaimVal);
        //console.log('value of numericValue',numericValue); 
        if (excessClaimVal < guaranteeAmt){
            console.log('helo ujwal2');
            var isTotalClaimGreaterThanGuaranteeAmt =  true;
            component.set("v.isTotalClaimGreaterThanGuaranteeAmt",isTotalClaimGreaterThanGuaranteeAmt);
            var errorMsg= "You have told us that the claim exceeds the guarantee value. Please enter the true value of your claim into this box.";
			component.set("v.errorMsg",errorMsg);
            //test addn notice 
            //excessClaimVal = currencyFormatter.format(parseFloat(excessClaimVal));
            //component.set("v.excessClaimVal", excessClaimVal.replace(/£/g, "")); //component.find("totalclaimvalue").set("v.value", excessClaimVal);
            //console.log('value of excessClaimVal0.5:',(component.get("v.excessClaimVal")));
          // component.set("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c", excessClaimVal); //removed for test
            //component.set("v.excessClaimVal", excessClaimVal); //added for test
            console.log('value of Excess_Guarantee_Claim_Value__c',(component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c")));            
            console.log('value of excessClaimVal1',excessClaimVal);
            // component.find("totalclaimvalue").reportValidity();
            //if(excessClaimVal==0){
              //  excessClaimVal = currencyFormatter.format(0);
            //}
            //test addn notice end
            //component.set("v.showClaimBreakdown",false);
            //component.set("v.keyDocuments",true);
            //component.set("v.showKeyDocumentsError",true);
            //ADDN
            //addn on 18/4
            component.find("totalclaimvalue").set("v.value", excessClaimVal);
            //$A.getCallback(function() {
//  			component.find("totalclaimvalue").set("v.value", excessClaimVal);
			//})();
			console.log('value of ligthning input:',component.find("totalclaimvalue").get("v.value", excessClaimVal));
            //addn on 18/4 end
            component.find("totalclaimvalue").setCustomValidity(errorMsg);
			console.log('hi ujwal');
        } else{
            //if(pattern.test(excessClaimVal)){
                console.log('value of pattern.test(excessClaimVal) ',pattern.test(excessClaimVal));
            var isTotalClaimGreaterThanGuaranteeAmt =  false;
            component.set("v.isTotalClaimGreaterThanGuaranteeAmt", isTotalClaimGreaterThanGuaranteeAmt);
            component.set("v.errorMsg","");
            component.set("v.excessClaimVal",excessClaimVal);
            
            // component.find("totalclaimvalue").setCustomValidity("");
            var action = component.get("c.updateCaseTotalClaim");
            action.setParams({
                            "caseID":component.get("v.ClaimsDetails[0].Id").toString(),
                			"excessClaimVal":parseFloat(excessClaimVal)
                        });
            			action.setCallback(this, function(a) {
                            var state = a.getState();
                            var errors = a.getError();
                			if (state === "SUCCESS") {
                                console.log('hi');
                                //component.set("v.excessClaimVal",excessClaimVal);
                                //component.set("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c", component.get("v.excessClaimVal"));
								//component.set("v.showClaimBreakdown",true);
                                //component.set("v.keyDocuments",false);
                                //component.set("v.showKeyDocumentsError",false);
                			}
                            else {
                        	//alert('An error has occured');
                                component.find("totalclaimvalue").setCustomValidity("Invalid input. Please enter a valid value.");
                    		}
        				});
     					$A.enqueueAction(action);
                //ADDN
                component.find("totalclaimvalue").setCustomValidity("");
                //// component.find("totalclaimvalue").set("v.value", excessClaimVal);
       // }//ADDN
           // else {component.find("totalclaimvalue").setCustomValidity("Invalid input. Please enter a valid value."); alert('An error has occured');}
            }
        component.find("totalclaimvalue").reportValidity();
    }, */
    
    handleClaimValue : function(component, event, helper) {
        let guaranteeAmt= component.get("v.ClaimsDetails[0].Deposit_Account_Number__r.Deposit_Amount__c");
        let excessClaimVal= component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c");
        //let pattern = /^£?\d+(\.\d{2})?$|^[^etkbm\+]*$/;
        //let pattern = /^£?\d+(\.\d{2})?$|^[^etkbm\+]*$|^[\d\.]*£?[\d\.]*$/;
    	if (excessClaimVal >= guaranteeAmt){
           // if(pattern.test(excessClaimVal)){
           console.log('hi');
		var action = component.get("c.updateCaseTotalClaim");
            action.setParams({
                            "caseID":component.get("v.ClaimsDetails[0].Id").toString(),
                			"excessClaimVal":excessClaimVal
                        });
            			action.setCallback(this, function(a) {
                            var state = a.getState();
                            var errors = a.getError();
                			if (state === "SUCCESS") {
                                console.log('hi');
                                }
                            else {
                                alert('An error has occured');}
                            });
     					$A.enqueueAction(action);
            } //else {component.find("totalclaimvalue").setCustomValidity("");}}else if(!excessClaimVal){component.find("totalclaimvalue").setCustomValidity("");}
    },
    
	goToClaimBreakdown : function(component, event, helper) {
        var pattern = /^£?\d+(\.\d{2})$/;
        var elements = document.getElementsByClassName("file_section");
        var elements1 = document.getElementsByClassName("custom_file");
        if (elements1.length == 0)
        {
            console.log('Line 233');
            var isEditable = component.get("v.isEditable");
            if(!isEditable){
                component.set("v.showClaimBreakdown",true);
                component.set("v.keyDocuments",false);
                component.set("v.showKeyDocumentsError",false);
                
                let index= component.get("v.currentItem");
                let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                window.scrollTo(0, 0);
                //document.getElementById('scrollView121').scrollIntoView(true);
                // just yo test 
                component.set("v.currentItem",0);
            }
            else{
                console.log('hi2');
                console.log('pattern:',pattern);
                let validExcessAmount = false;
                if(!component.get("v.ClaimsDetails[0].Claim_exceeds_the_total_level_of_cover__c"))
                {
                    validExcessAmount = true;
                }
                else if( component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c") && component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c")>=component.get("v.ClaimsDetails[0].Deposit_Account_Number__r.Deposit_Amount__c")  && component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c").length >= 50)
                {
                    let claimExceedsComment = component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c");

                        if(claimExceedsComment.length > 32768)
                        {
                            validExcessAmount = false;
                            alert('You have exceeded the character limit of 32768');
                        }
                    else
                    {
                        validExcessAmount = true;
                    }
                    
                }
                else
                {
                    validExcessAmount = false;
                }
                
                console.log('503-->>'+validExcessAmount);
               console.log('503-->>'+component.get("v.ClaimsDetails[0].Tenant_obligations__c"));   
                console.log('503-->>'+component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c"));   
                 console.log('503-->>'+component.get("v.ClaimsDetails[0].check_out_report_AGLL__c"));   
                 console.log('503-->>'+component.get("v.isClaimForRent"));   
                 console.log('503-->>'+component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c"));   
                
                if(validExcessAmount && component.get("v.ClaimsDetails[0].Tenant_obligations__c") && component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") &&
                   component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") && ((component.get("v.isClaimForRent")) ? component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") : true))
                { 
                    let claimExceedsComment = component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c");
                    let excessClaimValue= component.get("v.ClaimsDetails[0].Excess_Guarantee_Claim_Value__c");
                    let flag  = true;
                    console.log('line for test');
                   // console.log('length:',(component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c").length != 0));
                    
                    if(flag)
                    {
                        var action = component.get("c.updatekeyDocuments");
                        action.setParams({
                            "caseRecID":component.get("v.ClaimsDetails[0].Id"),
                            "tenantObligation":component.get("v.ClaimsDetails[0].Tenant_obligations__c"),
                            "inventryChekReport":component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c"),
                            "checkOutReport":component.get("v.ClaimsDetails[0].check_out_report_AGLL__c"),
                            "rentStatement":component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c"),
                            "claimExceedsComment" : component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c")
                        });
                        action.setCallback(this, function(a) {
                            var state = a.getState();
                            var errors = a.getError();
                            if (state == "SUCCESS") {
                                
                                component.set("v.showClaimBreakdown",true);
                                component.set("v.keyDocuments",false);
                                component.set("v.showKeyDocumentsError",false);
                                
                                let index= component.get("v.currentItem");
                                let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                                component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                                document.getElementById('scrollView121').scrollIntoView(true);
                                // just yo test 
                                component.set("v.currentItem",0);
                                
                            }
                            else {
                                alert('An error has occured');
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }                   
                }
                else
                {	                    
                    console.log('Line 296');
                    component.set("v.showKeyDocumentsError",true);
                    component.set("v.keyDocuments",true);
                    component.set("v.showClaimBreakdown",false);   
                }
            }
        }else{
            alert("Without this document, your chances of success are significantly reduced. If you do not have the evidence to support a claim, you can opt to withdraw your claim by selecting 'Cancel Claim'.");
        }
        
    },
    goToNextItem : function(component, event, helper) {
        
        
        /* var elements = document.getElementsByClassName("file_section");
        var elements1 = document.getElementsByClassName("custom_file");
        
        if (elements.length > 1 || elements1.length == 0)
        {*/
        let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
        let index= component.get("v.currentItem");
        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let disputeItemsCatagories = Dispute_Item[index].Type__c;
        let validateItem = false;
        let validatelength = true;
        let Errormsg='';
        if(disputeItemsCatagories =='Cleaning')
        {
            validateItem = component.find('Cleaning').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            //new addtion for empty error on 14/3/2023 with else if addtion
           /* if (!validateItem) {
            component.set("v.showDisputeItemError", true);
            component.find('Cleaning').setCustomValidity('Please provide a breakdown of your ' + disputeItemsCatagories + ' claim.');    
            //Errormsg = "Please provide a breakdown of your " + disputeItemsCatagories + " claim.";
        } else*/ if(Dispute_Item[index].Claim_description_for_cleaning_agll__c &&
               Dispute_Item[index].Supporting_clause_cleaning_agll__c &&
               Dispute_Item[index].Evidence_at_tenancystart_cleaning_agll__c &&
               Dispute_Item[index].Evidence_at_tenancy_end_for_cleaning_agl__c &&
               Dispute_Item[index].Supporting_evidence_for_cleaning_agll__c)
            {
                if(Dispute_Item[index].Claim_description_for_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: Please describe your claim for cleaning.';
                }
                if(Dispute_Item[index].Supporting_clause_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim for cleaning.';
                }
                if(Dispute_Item[index].Evidence_at_tenancystart_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the property’s cleanliness at the start of the tenancy.';
                }
                if(Dispute_Item[index].Evidence_at_tenancy_end_for_cleaning_agl__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the property’s cleanliness at the end of the tenancy.';
                }
                if(Dispute_Item[index].Supporting_evidence_for_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What evidence supports the value of the claim you are making.';
                }
                
            }
            
        }
        else if (disputeItemsCatagories =='Damage')
        {
            validateItem = component.find('Damage').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            
            if(Dispute_Item[index].Claim_description_for_damage_agll__c &&
               Dispute_Item[index].Supporting_clause_damage_agll__c &&
               Dispute_Item[index].Evidence_at_tenancystart_damage_agll__c &&
               Dispute_Item[index].Evidence_at_tenancy_end_for_damage_agll__c &&
               Dispute_Item[index].Supporting_evidence_for_damage_agll__c)
            {
                if(Dispute_Item[index].Claim_description_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: Please describe your claim for damage.';
                }
                if(Dispute_Item[index].Supporting_clause_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim for damage.';
                }
                if(Dispute_Item[index].Evidence_at_tenancystart_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the property’s condition at the start of the tenancy.';
                }
                if(Dispute_Item[index].Evidence_at_tenancy_end_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the property’s condition at the end of the tenancy.';
                }
                if(Dispute_Item[index].Supporting_evidence_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 characters for: What evidence supports the value of the claim you are making.';
                }
                
            }
        }
            else if(disputeItemsCatagories =='Redecoration')
            {
                validateItem = component.find('Redecoration').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                
                if(Dispute_Item[index].Claim_description_for_redecoration_agll__c &&
                   Dispute_Item[index].Supporting_clause_redecoration_agll__c &&
                   Dispute_Item[index].Evidence_at_tenancystart_redecoration_ag__c &&
                   Dispute_Item[index].Evidence_at_tenancyend_redecoration_agll__c &&
                   Dispute_Item[index].Supporting_evidence_for_redecoration_agl__c)
                {
                    if(Dispute_Item[index].Claim_description_for_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 characters for: Please describe your claim for redecoration.';
                    }
                    if(Dispute_Item[index].Supporting_clause_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim for redecoration.';
                    }
                    if(Dispute_Item[index].Evidence_at_tenancystart_redecoration_ag__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the standard of decoration at the start of the tenancy.';
                    }
                    if(Dispute_Item[index].Evidence_at_tenancyend_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the standard of decoration at the end of the tenancy.';
                    }
                    if(Dispute_Item[index].Supporting_evidence_for_redecoration_agl__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 characters for: What evidence supports the value of the claim you are making.';
                    }
                    
                }
                
            }
                else if(disputeItemsCatagories =='Gardening')
                {
                    validateItem = component.find('Gardening').reduce(function (validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                        return validSoFar && inputCmp.get('v.validity').valid;
                    }, true);
                    
                    if(Dispute_Item[index].Claim_description_for_gardening_agll__c &&
                       Dispute_Item[index].Supporting_clause_gardening_agll__c &&
                       Dispute_Item[index].Evidence_at_tenancystart_gardening_agll__c &&
                       Dispute_Item[index].Evidence_at_tenancyend_gardening_agll__c &&
                       Dispute_Item[index].Supporting_evidence_for_gardening__c)
                    {
                        if(Dispute_Item[index].Claim_description_for_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 characters for: Please describe your claim for gardening.';
                        }
                        if(Dispute_Item[index].Supporting_clause_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim for gardening.';
                        }
                        if(Dispute_Item[index].Evidence_at_tenancystart_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the garden’s condition at the start of the tenancy.';
                        }
                        if(Dispute_Item[index].Evidence_at_tenancyend_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of the garden’s condition at the end of the tenancy.';
                        }
                        if(Dispute_Item[index].Supporting_evidence_for_gardening__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 characters for: What evidence supports the value of the claim you are making.';
                        }
                        
                    }
                }
                    else if(disputeItemsCatagories =='Rent')
                    {
                        validateItem = component.find('Rent').reduce(function (validSoFar, inputCmp) {
                            inputCmp.showHelpMessageIfInvalid();
                            return validSoFar && inputCmp.get('v.validity').valid;
                        }, true);
                        
                        if(Dispute_Item[index].Rent_arrears_description_agll__c &&
                           Dispute_Item[index].Was_the_property_re_let_rent_agll__c &&
                           Dispute_Item[index].Supporting_clause_rent_agll__c &&
                           Dispute_Item[index].Supporting_evidence_for_rent_agll__c)
                        {
                            if(Dispute_Item[index].Rent_arrears_description_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 characters for: How much are the arrears and how did they arise.';
                            }
                            if(Dispute_Item[index].Was_the_property_re_let_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 characters for: Was the property re-let during the period being claimed for and if so, when.';
                            }
                            if(Dispute_Item[index].Supporting_clause_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim for rent arrears.';
                            }
                            if(Dispute_Item[index].Supporting_evidence_for_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 characters for: What is your evidence of rent arrears.';
                            }
                            
                        }
                        
                    }
                        else if(disputeItemsCatagories =='Other')
                        {
                            validateItem = component.find('Other').reduce(function (validSoFar, inputCmp) {
                                inputCmp.showHelpMessageIfInvalid();
                                return validSoFar && inputCmp.get('v.validity').valid;
                            }, true);
                            if(Dispute_Item[index].Claim_breakdown_other_AGLL__c &&
                               Dispute_Item[index].Supporting_clause_other_agll__c &&
                               Dispute_Item[index].Supporting_evidence_for_other_agll__c )
                            {
                                if(Dispute_Item[index].Claim_breakdown_other_AGLL__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 characters for: Please provide a breakdown of your other claims.';
                                }
                                if(Dispute_Item[index].Supporting_clause_other_agll__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 characters for: What clause(s) in the tenancy agreement support your claim.';
                                }
                                if(Dispute_Item[index].Supporting_evidence_for_other_agll__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 characters for: How does this evidence support your claim.';
                                }
                                
                            }
                        }
        
        
        if(Errormsg != '')
        {
            alert(Errormsg);
        }
        if(validateItem && validatelength)
        {
            component.set("v.showDisputeItemError",false);
            let CurrentItem = component.get("v.currentItem") +1;
            var action = component.get("c.updateClaimBreakdown");
            action.setParams({
                "disputeItemRec":JSON.stringify(component.get("v.ClaimsDetails[0].Dispute_Items__r"))
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    if(totalItem == CurrentItem)
                    {
                        component.set("v.showAdditionalComments",true);
                        component.set("v.showClaimBreakdown",false);
                        component.set("v.keyDocuments",false);
                        document.getElementById('scrollView121').scrollIntoView(true);
                    }
                    else
                    {
                        component.set("v.currentItem",(component.get("v.currentItem")+1));
                        let index= component.get("v.currentItem");
                        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                        document.getElementById('scrollView121').scrollIntoView(true);
                    }
                    
                }
                else {
                    alert('An error has occured');
                }
            });
            $A.enqueueAction(action); 
        }
        else
        {
            component.set("v.showDisputeItemError",true);
        }
        /* }else{
            alert("Please upload file before continue.");
        }*/
        
    },
    goToReviewsubmission : function(component, event, helper) {
        var action = component.get("c.updateAdditionalComments");
       /* let consentBoxValue ='';
        if(component.get("v.consentBoxValue"))
        {
            consentBoxValue='Yes'; 
        }
        else
        {
            consentBoxValue='No';
        }
        */
        let addComment = component.get("v.ClaimsDetails[0].Additional_comments_AGLL__c");
        let charlength  = 0;
            if(addComment)
            {
                charlength= addComment.length
            }
        if(charlength < 2000)
        {
            action.setParams({
                "caseId":component.get("v.ClaimsDetails[0].Id"),
                "additionalComment":component.get("v.ClaimsDetails[0].Additional_comments_AGLL__c")
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    component.set("v.showAdditionalComments",false);
                    component.set("v.showDisputeItemError",false);
                    component.set("v.showReviewsubmission",true);
                    document.getElementById('scrollView121').scrollIntoView(true);
                }
                else {
                    alert('An error has occured');
                }
            });
            $A.enqueueAction(action);
            
        }
        else
        {
            alert('You have exceeded the character limit of 2000.');
        }
        
        
    },
    handleUploadFinished : function(component, event, helper)
    {
        let fileName = event.getSource().get("v.files")[0]['name'];
        var fileInput = component.find("fileId").get("v.files");
        
        var file = fileInput[0];
        
        
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var action = component.get("c.uploadDoc");
            action.setParams({
                "base64Data": encodeURIComponent(fileContents),
                "fileType":file.type
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    
                }
                else {
                    let errormessage = JSON.stringify(a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        });
        
        objFileReader.readAsDataURL(file);
        
        
    },
    refreshParentViewEvent :function(component, event, helper){
        //$A.get('e.force:refreshView').fire();
    },
    cancelClaim : function(component, event, helper) {
        component.set("v.showConfirmDialog",true);
    },
    CloseCancelPopup : function(component, event, helper) { 
        component.set("v.showConfirmDialog",false);
    },
    doCancelClaim : function(component, event, helper) {
        var action = component.get("c.UpdateClaimDetails");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType":"AGLL"
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",false);
                component.set("v.keyDocuments",false);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConfirmDialog",false);
                component.set("v.showCancelDiv",true);
            }
            else
            {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info',
                    message: 'Something went wrong please Contact Administrator',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
        
        
        
    },
    
})