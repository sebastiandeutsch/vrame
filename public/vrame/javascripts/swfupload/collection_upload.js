function CollectionUpload (o) {
	var handlers = this.handlers;
	CollectionUpload.swfupload = new SWFUpload({
	
		// Flash Movie
		flash_url: '/vrame/javascripts/swfupload/swfupload.swf',
		
		// Upload URL
		upload_url: o.uploadUrl,
		
		// Button settings
		button_placeholder_id: o.buttonId,
		button_image_url: '/vrame/images/admin/upload_button.png',
		button_width: 69,
		button_height: 27,
		
		// File Upload Settings
		file_size_limit: 20480,	// 20MB
		file_types: '*.jpg;*.png,*.swf;*.flv',
		file_types_description: 'JPG, PNG, SWF, FLV',
		file_upload_limit: 0,

		// Authentication
		post_params: {
			user_credentials: o.uploadToken
		},

		custom_settings : {
			progressTarget : document.getElementById(o.uploadQueue),
		    submitButton : document.getElementById(o.submitButton),
			idInput : jQuery(o.idInput),
			finishedTarget : document.getElementById(o.finishedTarget),
			collectionId : o.collectionId
		},

		file_queued_handler : handlers.fileQueued,
		file_queue_error_handler : handlers.fileQueueError,
		file_dialog_complete_handler : handlers.fileDialogComplete,
		upload_start_handler : handlers.uploadStart,
		upload_progress_handler : handlers.uploadProgress,
		upload_error_handler : handlers.uploadError,
		upload_success_handler : handlers.uploadSuccess,
		upload_complete_handler : handlers.uploadComplete,
		queue_complete_handler : handlers.queueComplete,

		//debug: true
	});
}

CollectionUpload.prototype = {    
	handlers : {
		
		fileQueued : function (file) {
			var settings = this.customSettings;
			
			settings.progressTarget.style.display = "block";
            // settings.submitButton.disabled = true;
			
			var progress = new FileProgress(file, settings.progressTarget);
		},
		
		fileQueueError: function (file, errorCode, message) {
			
			if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
				alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
				return;
			}
			
			var progress = new FileProgress(file, this.customSettings.progressTarget);
			
			switch (errorCode) {
			
			case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
				progress.setError("File is too big");
				this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
				
			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
				progress.setError("Won't upload empty files");
				this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
				
			case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
				progress.setError("Invalid file type");
				this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
				
			default:
				if (file !== null) {
					progress.setError("Unhandled Error");
				}
				this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
			
			} /* End switch */
		},

		fileDialogComplete: function (numFilesSelected, numFilesQueued) {
			if (numFilesSelected > 0) {
				/* Start the upload immediately */
                this.startUpload();
			}
		},

		uploadStart: function (file) {
		    var collection_id = this.customSettings.collectionId;
		    
		    if (collection_id != '')
		        this.addPostParam('collection_id', collection_id);
		    
			var progress = new FileProgress(file, this.customSettings.progressTarget);
			progress.setProgress();
			/* No file validation, accept all */
			return true;
		},

		uploadProgress: function (file, bytesLoaded, bytesTotal) {
			var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
			var progress = new FileProgress(file, this.customSettings.progressTarget);
			progress.setProgress(percent);
		},

		uploadSuccess: function (file, serverResponse) {
		    var settings = this.customSettings;
		    
			var progress = new FileProgress(file, settings.progressTarget);
			progress.setComplete();
			
			// Evaluate JSON
			var responseO = eval("(" + serverResponse + ")"),
				url = responseO.url;

			settings.collectionId = responseO.collection_id;
				
			settings.idInput.val(settings.collectionId);
						
			window.setTimeout(loadImage, 2000);
			
			function imageLoadSuccess () {
				jQuery(settings.finishedTarget).append("<li><p class='image-wrapper'><img src='" + url + "' alt=''></p></li>");
			}
			function imageLoadError () {
				loadImage();
			}
			function loadImage () {
				var image = new Image;
				image.onload = imageLoadSuccess;
				image.onerror = imageLoadError;
				image.src = url;
			}
		},

		uploadError: function (file, errorCode, message) {
			var progress = new FileProgress(file, this.customSettings.progressTarget);
			
			switch (errorCode) {
			case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
				progress.setError("Upload Error: " + message);
				this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
				progress.setError("Upload Failed.");
				this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.IO_ERROR:
				progress.setError("Server (IO) Error");
				this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
				progress.setError("Security Error");
				this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
				progress.setError("Upload limit exceeded.");
				this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
				progress.setError("Failed Validation.  Upload skipped.");
				this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
			case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
				progress.setCancelled();
				break;
			case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
				progress.setError("Stopped");
				break;
			default:
				progress.setError("Unhandled Error: " + errorCode);
				this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
				break;
			}
		},

		uploadComplete: function (file) {
			if (this.getStats().files_queued > 0) {
				/* Continue with queue */
				this.startUpload();
			} else {
                // this.customSettings.submitButton.disabled = false;
			}
		}
	
	} /* end handlers */

}; /* end CollectionUpload prototype */

function FileProgress (file, targetElement) {

	var id = file.id,
		instances = FileProgress.instances = FileProgress.instances || {},
		instance;
	
	instance = instances[id];
	if (instance) {
		return instance;
	}
	instances[id] = instance = this;
	
	instance.id = id;
	instance.height = 0;
	
	var wrapper = document.createElement("li");
	instance.wrapper = wrapper;
	wrapper.className = "progressWrapper";
	wrapper.id = id;

	progressElement = document.createElement("div");
	instance.progressElement = progressElement;
	progressElement.className = "progressContainer";
	
	var progressText = document.createElement("span");
	instance.progressText = progressText;
	progressText.className = "progressName";
	progressText.appendChild(document.createTextNode(file.name));

	var progressBar = document.createElement("div");
	instance.progressBar = progressBar;
	progressBar.className = "progressBar";

	var progressStatus = document.createElement("span");
	instance.progressStatus = progressStatus;
	progressStatus.className = "progressStatus";

	//progressElement.appendChild(progressCancel);
	progressElement.appendChild(progressText);
	progressElement.appendChild(progressStatus);
	progressElement.appendChild(progressBar);

	wrapper.appendChild(progressElement);

	targetElement.appendChild(wrapper);
	
	instance.height = wrapper.offsetHeight;
	instance.setStatus(Math.floor(file.size / 1024) + "kb");
}

FileProgress.prototype = {

	setProgress : function (percentage) {
		this.progressElement.className = "progressContainer progressUploading";
		this.setStatus("Uploading...");
		this.progressBar.style.width = percentage + "%";
	},

	setComplete : function () {
		this.progressElement.className = "progressContainer progressComplete";
		this.setStatus("Finished");
		this.progressBar.style.width = "";
		this.disappear(750);
	},

	setError : function (errorMessage) {
		this.progressElement.className = "progressContainer progressError";
		this.setStatus(errorMessage || "Error");
		this.progressBar.style.width = "";
		this.disappear(5000);
	},

	setCancelled : function () {
		this.progressElement.className = "progressContainer progressCancelled";
		this.setStatus(errorMessage || "Cancelled");
		this.fileProgressBar.style.width = "";
		this.disappear(2000);
	},

	setStatus : function (status) {
		this.progressStatus.innerHTML = status;
	},

	// Fades out and clips away the FileProgress box.
	disappear : function (delay) {
		var self = this;
		if (typeof delay == "number") {
			setTimeout(function () {
				self.disappear();
			}, delay);
		} else {
			jQuery(this.wrapper).fadeOut();
		}
	}
};