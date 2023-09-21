({  
    // Load current profile picture
    onInit: function(component) {  
        let evidanceAttachment =component.get("v.evidanceAttachment");
        let evidenceCategories =component.get("v.evidenceCategories");
        let userType =component.get("v.userType");
        let totalNoOfEvidance = 0;
        if(evidanceAttachment)
        {
            for(let i =0;i<evidanceAttachment.length; i++)
            {
                if(evidenceCategories ==evidanceAttachment[i].Evidence_Categories__c && userType == evidanceAttachment[i].User_Type__c) 
                {
                    totalNoOfEvidance++;
                    component.set("v.showFileList",true);
                    if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
                       evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
                    {
                        component.set("v.showFileUpload",false);
                    }
                    else if(totalNoOfEvidance >= 5) {
                        component.set("v.showFileUpload",false); 
                    }
                    
                    
                    
                    /* component.set("v.flType",evidanceAttachment[i].File_Type__c);
                    component.set("v.fileName",evidanceAttachment[i].Filename__c);
                    component.set("v.fileSize",evidanceAttachment[i].File_Size__c);
                    component.set("v.azureLink",evidanceAttachment[i].Location__c);
                    component.set("v.fileSFId",evidanceAttachment[i].Id);
                    component.set("v.fileNameInAzure",evidanceAttachment[i].Azure_File_Name__c);*/
                    
                    
                    
                }
            }
            
        }
        component.set("v.totalNoOfEvidance",totalNoOfEvidance);
       
        var action = component.get("c.getSecureURI"); 
        action.setParams({
            scheme : component.get('v.scheme')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                let ReturnValue = a.getReturnValue();
                component.set("v.secureURI", ReturnValue); 
            }
        });
        $A.enqueueAction(action);
    },
    
    /*onDragOver: function(component, event) {
        event.preventDefault();
    },
 
    onDrop: function(component, event, helper) {
        console.log('line 12');
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        component.set("v.flName", files[0].name);
        helper.readFile(component, helper, files[0]);
    },*/
    handleFilesChange: function(component, event, helper) {
        var filess = component.set("v.fileList",component.get("v.fileList")); 
        var files = component.get("v.fileList");
        let icon = files[0].name.toLowerCase();
        component.set("v.fileName", files[0].name);
        const ext = ['.png', '.jpeg', '.jpg', '.gif', '.tiff', '.tif', '.bmp'];
        //const ext = ['.pngooo099'];
        var fileTypeCheck = ext.some(el => icon.endsWith(el));
        if(fileTypeCheck==true){
            component.set("v.flName", files[0].name);
            component.set("v.flType", files[0].name.split('.').pop().toUpperCase());
            component.set("v.fileLableVisible", true);
        }else{
            component.set("v.fileLableVisible", false);
            var getFileLabel = document.getElementById("filelabel").value;
            component.set("v.fileLable", '');
            component.set("v.upload", true);
            component.set("v.flName", files[0].name);
            component.set("v.flType", files[0].name.split('.').pop().toUpperCase());
            component.set("v.uploadBar", 25);
            helper.readFile(component, helper, files[0],getFileLabel);
        } 
    },
    addEvidence : function(component, event, helper) {
        component.set("v.isUploading", true);
        //var files = event.getSource().get("v.files");
        var files = component.get("v.fileList");  
        var getFileLabel = document.getElementById("filelabel").value;
        if(getFileLabel=='' && component.get("v.fileLableVisible")==true){
            component.set("v.fileLable", 'Please provide a label to upload image.');
        }else if(getFileLabel.length > 50){
            component.set("v.fileLable", 'Character limit is 50.');
        }else{
            component.set("v.fileLable", '');
            component.set("v.upload", true);
            component.set("v.uploadBar", 25);
            helper.readFile(component, helper, files[0],getFileLabel);
            //component.set("v.isUploading", false);
        }
    },
    fileUploaded: function(component, event, helper) {
        //var getFileLabel = component.find("filelabel").get("v.value");   
        var getFileLabel = document.getElementById("filelabel").value;
        if(getFileLabel==''){
            component.set("v.fileLable", 'Please provide a label to upload image.');
        }
    },
    deleteFile: function(component, event, helper) { 
        let selectedFileId = event.currentTarget.dataset.myid;
        let fileNameInAzure =event.currentTarget.name;
        //let fileNameInAzure = component.get("v.fileNameInAzure");
        let totalNoOfEvidance =component.get("v.totalNoOfEvidance");
        let evidenceCategories = component.get('v.evidenceCategories');
        
        var action = component.get("c.deleteFileAzure"); 
        action.setParams({
            fileNameInAzure: fileNameInAzure,
            RecordId: selectedFileId,
            evidenceCategories :evidenceCategories,
            claimId :component.get('v.recordId'),
            scheme : component.get('v.scheme')
        })
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                // var cmpEvent = component.getEvent("EI_ZD_refreshParentView"); 
                //cmpEvent.fire();
                
                let evidanceAttachmentlist = component.get("v.evidanceAttachment");
                let indexfile =-1 ;
                
                
                
                for(let i=0;i< evidanceAttachmentlist.length;i++)
                {
                    if(evidanceAttachmentlist[i].Id ==selectedFileId)
                    {
                        indexfile=i;
                    }
                }
                
                evidanceAttachmentlist.splice(indexfile,1);
                component.set("v.evidanceAttachment",evidanceAttachmentlist);
                
                
                
                component.set("v.flType",'');
                component.set("v.fileName",'');
                component.set("v.fileSize",'');
                component.set("v.azureLink",'');
                component.set("v.fileSFId",'');
                component.set("v.fileNameInAzure",'');
                component.set("v.upload",false);
                component.set("v.success",'');
                component.set("v.message",'');
                component.set("v.flName",'No file Selected');
                totalNoOfEvidance--;
                component.set("v.totalNoOfEvidance", totalNoOfEvidance);
                if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
                   evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
                {
                    component.set("v.showFileUpload",true);
                    component.set("v.showFileList",false);
                }
                else if(totalNoOfEvidance <= 5) {
                    component.set("v.showFileUpload",true);
                    if(totalNoOfEvidance ==0)
                    {
                        component.set("v.showFileList",false);
                    }
                    else{
                        component.set("v.showFileList",true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
        
        // helper.deleteUploadedFile(component);
    }
    
})