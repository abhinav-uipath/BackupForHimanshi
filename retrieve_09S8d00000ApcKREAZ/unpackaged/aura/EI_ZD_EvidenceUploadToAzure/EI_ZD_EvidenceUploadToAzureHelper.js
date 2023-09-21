({
    readFile: function(component, helper, file,fileLable) {
        let recordId = component.get("v.recordId");
        const currentDate = new Date();
        const timestamp = currentDate.getTime();
        if (!file) return;
        /*if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }*/
        
        let icon = file.name.toLowerCase();
        //alert('icon '+icon);
        const ext = ['.pdf', '.doc', '.docx', '.txt', '.rtf','.odt', '.xls', '.xlsx', '.ods', '.msg', '.csv', '.png', '.jpeg', '.jpg', '.gif', '.tiff', '.tif', '.bmp', '.mp3', '.mp4', '.wmv', '.wav', '.ppt', '.pptx', '.mov'];
        var fileTypeCheck = ext.some(el => icon.endsWith(el));
        if (!fileTypeCheck) {
            component.set("v.upload", false);
            component.set("v.flType", "");
            component.set("v.flName", "No file Selected");
           return alert("File type not supported!");
        }
        
        var sizeInMB = (file.size / (1024*1024)).toFixed(2);
        if(sizeInMB > 20){
            component.set("v.upload", false);
            component.set("v.flType", "");
            component.set("v.flName", "No file Selected");
             return alert("File size is greater than 20mb");
        }
         
        //var baseUrl = 'https://zdstoragetest.blob.core.windows.net/agll?sp=rw&st=2021-05-24T15:07:09Z&se=2026-05-24T23:07:09Z&spr=https&sv=2020-02-10&sr=c&sig=G2g4B8EcSVSHPc4EDVltbnEJFNx%2FtQzP30b8wuuNXrU%3D';
        var baseUrl = component.get("v.secureURI");
        var baseUrlLength = baseUrl.length;
        var indexOfQueryStart = baseUrl.indexOf("?");
        var sasKeys = baseUrl.substring(indexOfQueryStart, baseUrlLength);
        var submitUri = baseUrl.substring(0, indexOfQueryStart) + '/'+recordId+'-'+timestamp +'-'+ file.name+ baseUrl.substring(indexOfQueryStart);
        component.set("v.azureLink", baseUrl.substring(0, indexOfQueryStart) + '/'+recordId+'-'+timestamp +'-'+ file.name+sasKeys);
        component.set("v.fileNameInAzure", recordId+'-'+timestamp +'-'+ file.name);
        
        var reader = new FileReader();
        reader.onload = function() {
            var dataURL = reader.result;
            component.set("v.uploadBar", 45);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1],submitUri,fileLable);
        };
        reader.readAsDataURL(file);
    },
    
    upload: function(component, file, base64Data,submitUri,fileLable) {
        
        
        
        var xhr = new XMLHttpRequest();
        var endPoint = submitUri;
        //var authToken = 'Bearer '+component.get("v.sessionId");
        //console.log('authToken '+authToken);
        
        component.set("v.uploadBar", 75);
        component.set("v.message", "Uploading...");
        
        xhr.open("PUT", endPoint, true);
        // xhr.setRequestHeader("Content-Type", "application/json");
        //xhr.setRequestHeader("Authorization", authToken);
        xhr.setRequestHeader('x-ms-blob-type', 'BlockBlob');
        //xhr.setRequestHeader('Content-Length', file.length);
        xhr.setRequestHeader('Content-Type', file.type);
        xhr.onreadystatechange = function () {
            
            if (xhr.readyState === 4 && xhr.status === 201) {
                //  var json = JSON.parse(xhr.responseText);
                // console.log('line  6222 '+JSON.stringify(json));
                
                
                let evidenceCategories = component.get('v.evidenceCategories');
                let totalNoOfEvidance =component.get("v.totalNoOfEvidance");                
                component.set("v.uploadBar", 85);
                
                component.set("v.truthy",true);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.truthy",true)
                    })
                    ,1000);
                
                var action = component.get("c.saveFile"); 
                action.setParams({
                    parentId: component.get("v.recordId"),
                    disputeId :component.get("v.disputeId"),
                    //disputeId: null,
                    fileName: file.name,
                    azureLink: component.get('v.azureLink'),
                    userType: component.get('v.userType'),
                    fileType :(file.name).split('.').pop(),
                    fileSize :file.size,
                    fileLable :fileLable,
                    evidenceCategories : evidenceCategories,
                    fileNameInAzure : component.get('v.fileNameInAzure'),
                    source : component.get('v.source'),
                    scheme : component.get('v.scheme')
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        
                        
                        let ReturnValue = a.getReturnValue();
                        //component.set("v.uploadedFileId", ReturnValue);
                       /* component.set("v.uploadBar", 100);
                        component.set("v.success", " success");
                        component.set("v.message", "Image uploaded");
                        component.set("v.fileName", file.name);
                        component.set("v.fileSize", file.size);*/
                        if(ReturnValue == null)
                        {
                            alert('An error occurred. Please contact your system administrator');
                        }
                        else
                        {
                            component.set("v.showFileList", true);
                            component.set("v.fileSFId", ReturnValue.Id);
                            
                            component.set("v.success", "");
                            component.set("v.flType", "");
                            component.set("v.flName", "No file Selected");
                            component.set("v.upload", false);
                            component.set("v.message", '');
                            component.set("v.fileLable", '');
                            document.getElementById("filelabel").value='';
                            component.set("v.fileLableVisible", false); 
                            component.set("v.isUploading", false);
                            let evidanceAttachment=[];
                            if(component.get("v.evidanceAttachment"))
                            {
                                evidanceAttachment= component.get("v.evidanceAttachment");
                            }
                            evidanceAttachment.push(ReturnValue);
                            component.set("v.evidanceAttachment", evidanceAttachment);
                            totalNoOfEvidance++;
                            component.set("v.totalNoOfEvidance", totalNoOfEvidance);
                            
                            if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
                               evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
                            {
                                component.set("v.showFileUpload",false);
                            }
                            else if(totalNoOfEvidance >= 5) {
                                component.set("v.showFileUpload",false); 
                            }
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'File uploaded successfully',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            
                        }
                        
                         
                        
                    }
                });
                $A.enqueueAction(action);
                
            }else{
                //image error code
            }
        };
        /*console.log('li  65');
        var data = base64Data;
        console.log('data '+data);*/
        xhr.send(file);
        
    },
    deleteUploadedFile: function(component) { 
        
        var action = component.get("c.deleteFiles"); 
        action.setParams({
            recordId: component.get("v.uploadedFileId")
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                let ReturnValue = a.getReturnValue();
                component.set("v.success", "");
                component.set("v.flType", "");
                component.set("v.flName", "No file Selected");
                component.set("v.upload", false);
                component.set("v.message", '');
                
            }
        });
        //$A.enqueueAction(action);
    }
})