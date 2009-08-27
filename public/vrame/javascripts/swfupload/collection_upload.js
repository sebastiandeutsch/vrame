jQuery(function () {
	jQuery(".collection-upload").each(function () {
		var c = $(this),
			o = {
				uploadUrl         : '/vrame/assets',
				collectionId      : c.attr('data-collection-id'),
				uploadToken       : c.attr('data-upload-token'),
				buttonId          : c.find('.upload-button').attr('id'),
				uploadQueue       : c.find('.upload-queue'),
				collectionIdInput : c.find('.collection-id'),
				collectionItems   : c.find('.collection-items'),
				submitButton      : jQuery('#document_submit'),
			};
		new CollectionUpload(o);
	});
});

function CollectionUpload (o) {
	var handlers = this.handlers;
	new SWFUpload({
	
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

		custom_settings : o,

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
			var uploadQueue = this.customSettings.uploadQueue;
			uploadQueue.show();
			new FileProgress(file, uploadQueue);
		},
		
		fileQueueError: function (file, errorCode, message) {
			
			if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
				alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
				return;
			}
			
			var progress = new FileProgress(file, this.customSettings.uploadQueue);
			
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
			var settings = this.customSettings,
				collection_id = settings.collectionId;
			if (collection_id != '') {
				this.addPostParam('collection_id', collection_id);
			}
			
			var progress = new FileProgress(file, settings.uploadQueue);
			progress.setProgress();
			
			/* No file validation, accept all files */
			return true;
		},

		uploadProgress: function (file, bytesLoaded, bytesTotal) {
			var percent = Math.ceil((bytesLoaded / bytesTotal) * 100),
				progress = new FileProgress(file, this.customSettings.uploadQueue);
			progress.setProgress(percent);
		},

		uploadSuccess: function (file, serverResponse) {
			var settings = this.customSettings,
				progress = new FileProgress(file, settings.uploadQueue),
				responseO,
				url;
			progress.setComplete();
			
			// Evaluate JSON
			responseO = eval("(" + serverResponse + ")");
			url = responseO.url;
			
			settings.collectionId = responseO.collection_id;
			settings.collectionIdInput.val(settings.collectionId);
			
			window.setTimeout(loadImage, 2000);
			
			function imageLoadSuccess () {
				settings.collectionItems.append("<li><p class='image-wrapper'><img src='" + url + "' alt=''></p></li>");
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
			var progress = new FileProgress(file, this.customSettings.uploadQueue);
			
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
				// this.customSettings.submitButton.attr("disabled", false);
			}
		}
	
	} /* end handlers */

}; /* end CollectionUpload prototype */

function FileProgress (file, target) {

	var id = file.id,
		instances = FileProgress.instances = FileProgress.instances || {},
		instance,
		jQuery = window.jQuery,
		wrapper,
		progressElement,
		progressText,
		progressBar,
		progressStatus;
	
	instance = instances[id];
	if (instance) {
		return instance;
	}
	 instance = instances[id] = this;
	
	instance.id = id;
	instance.height = 0;
	
	wrapper = jQuery("<li>").addClass("progressWrapper").attr("id", id);
	progressElement = jQuery("<li>").addClass("progressContainer");
	progressText = jQuery("<span>").addClass("progressName").append(file.name);
	progressBar = jQuery("<div>").addClass("progressBar");
	progressStatus = jQuery("<span>").addClass("progressStatus");
	
	progressElement.append(progressText).append(progressStatus).append(progressBar);
	wrapper.append(progressElement);
	target.append(wrapper);
	
	instance.wrapper = wrapper;
	instance.progressElement = progressElement;
	instance.progressText = progressText;
	instance.progressBar = progressBar;
	instance.progressStatus = progressStatus;
	
	instance.height = wrapper.offsetHeight;
	instance.setStatus(Math.floor(file.size / 1024) + "kb");
}

FileProgress.prototype = {

	setProgress : function (percentage) {
		this.progressElement.attr("className", "progressContainer progressUploading");
		this.setStatus("Uploading...");
		this.progressBar.width(percentage + "%");
	},

	setComplete : function () {
		this.progressElement.attr("className", "progressContainer progressComplete");
		this.setStatus("Finished");
		this.progressBar.css("width", "");
		this.disappear(750);
	},

	setError : function (errorMessage) {
		this.progressElement.attr("className", "progressContainer progressError");
		this.setStatus(errorMessage || "Error");
		this.progressBar.css("width", "");
		this.disappear(5000);
	},

	setCancelled : function () {
		this.progressElement.attr("className", "progressContainer progressCancelled");
		this.setStatus(errorMessage || "Cancelled");
		this.progressBar.css("width", "");
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
			this.wrapper.fadeOut();
		}
	}
};