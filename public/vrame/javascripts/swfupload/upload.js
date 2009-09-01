jQuery(function () {
	jQuery(".file-upload").each(function () {
		var c = $(this);
		
		var o = {
			/* Upload type (File, Collection) */
			type						: c.attr('data-upload-type'),
			
			/* Upload token */
			token						: c.attr('data-upload-token'),
			
			/* Parent document (database) id */
			documentId					: c.attr('data-document-id'),
			
			/* Upload button (HTML) id */
			buttonId					: c.find('.upload-button').attr('id'),
			
			/* Upload queue HTML element (jQuery collection) */
			queue						: c.find('.upload-queue'),
			
			/* Form submit button */
			submitButton				: jQuery('#document_submit'),
			
			/* Image list HTML element (jQuery collection) */
			assetList					: c.find('.asset-list'),
			
			/* Form field(s) for the new asset id (jQuery collection) */
			assetIdInput				: c.find('.asset-id'),
			
			/* Current collection id, if already present */
			collectionId				: c.attr('data-collection-id') || '',
			
			/* Form field(s) for the new collection id (jQuery collection) */
			collectionIdInput			: c.find('.collection-id')
			
		};
		
		new Upload(o);
	});
});

function Upload (o) {
	var handlers = this.handlers;
	
	//console.log('CollectionUpload', o);
	
	new SWFUpload({
	
		// Flash Movie
		flash_url : '/vrame/javascripts/swfupload/swfupload.swf',
		
		// Upload URL
		upload_url : '/vrame/assets',
		
		// Button settings
		button_placeholder_id : o.buttonId,
		button_image_url : '/vrame/images/admin/upload_button.png',
		button_width : 69,
		button_height : 27,
		
		// File Upload Settings
		file_size_limit : 20 * 1024,
		file_types : '*.jpg;*.png,*.swf;*.flv',
		file_types_description : 'JPG, PNG, SWF, FLV',
		file_upload_limit : o.type == 'File' ? 1 : 0,

		// Authentication
		post_params : {
			user_credentials	: o.token,
			document_id			: o.documentId,
			create_collection	: o.type == 'Collection' ? 'true' : '',
			collection_id		: o.collectionId
		},

		custom_settings : o,

		file_queued_handler				: handlers.fileQueued,
		file_queue_error_handler		: handlers.fileQueueError,
		file_dialog_complete_handler	: handlers.fileDialogComplete,
		upload_start_handler			: handlers.uploadStart,
		upload_progress_handler			: handlers.uploadProgress,
		upload_error_handler			: handlers.uploadError,
		upload_success_handler			: handlers.uploadSuccess,
		upload_complete_handler			: handlers.uploadComplete,
		queue_complete_handler			: handlers.queueComplete

		//,debug : true
	});
}

Upload.prototype = {    
	handlers : {
		
		fileQueued : function (file) {
			var queue = this.customSettings.queue;
			queue.show();
			new FileProgress(file, queue);
		},
		
		fileQueueError : function (file, errorCode, fileNumberLimit) {
			
			if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
				alert("You have attempted to queue too many files.\n" + (fileNumberLimit === 0 ? "You have reached the upload limit." : "You may select " + (fileNumberLimit > 1 ? "up to " + fileNumberLimit + " files." : "one file.")));
				return;
			}
			
			var progress = new FileProgress(file, this.customSettings.queue),
				errorMessage = "";
			
			switch (errorCode) {
			
				case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT :
					errorMessage = "File is too big";
					break;
				
				case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE :
					errorMessage = "Won't upload empty files";
					break;
				
				case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE :
					errorMessage = "Invalid file type";
					break;
					
				default :
					errorMessage = "Unhandled Error";
				
			} /* End switch */
			
			progress.setError(errorMessage);
			this.debug("Error " + errorCode + ": " + errorMessage + ", File name: " + file.name + ", File size: " + file.size + ", Limit: " + fileNumberLimit);
		},

		fileDialogComplete : function (numFilesSelected, numFilesQueued) {
			if (numFilesSelected > 0) {
				/* Start the upload immediately */
				this.startUpload();
			}
		},

		uploadStart : function (file) {
			var progress = new FileProgress(file, this.customSettings.queue);
			
			progress.setProgress();
			
			/* No file validation, accept all files */
			return true;
		},

		uploadProgress : function (file, bytesLoaded, bytesTotal) {
			var progress = new FileProgress(file, this.customSettings.queue),
				percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
			
			progress.setProgress(percent);
		},

		uploadSuccess : function (file, serverResponse) {
			//console.log('uploadSuccess', file);
			
			var settings = this.customSettings,
				progress = new FileProgress(file, settings.queue),
				response,
				collectionId,
				imageLoadInterval,
				imageLoadAttempts;
			
			progress.setComplete();
			
			//console.log('serverResponse', serverResponse);
			
			/* Evaluate JSON response */
			response = eval("(" + serverResponse + ")");
			
			/* Update asset id form field (if any) */
			settings.assetIdInput.val(response.id);
			
			/* Handler collection id */
			collectionId = response.collection_id;
			if (collectionId) {
				//console.log('collectionId:', collectionId);
				
				/* Update collection id form field (if any) */
				settings.collectionIdInput.val(collectionId);
				
				/* Once we have a collection id, reuse it in future uploads */
				settings.collectionId = collectionId;
				this.addPostParam('collection_id', collectionId);
			}
			
			/* Image thumbnail loading */
			if (response.is_image) {
				new ThumbnailLoader(response.url, settings.assetList);
			} else {
				/* Append file name directly */
				settings.assetList.append("<li><p>" + response.url + "</p></li>");
			}
			
		},
		
		uploadError : function (file, errorCode, message) {
			var progress = new FileProgress(file, this.customSettings.queue);
			
			switch (errorCode) {
				
				case SWFUpload.UPLOAD_ERROR.HTTP_ERROR :
					errorMessage = "HTTP Error";
					break;
					
				case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED :
					errorMessage = "Upload Failed";
					break;
					
				case SWFUpload.UPLOAD_ERROR.IO_ERROR :
					errorMessage = "Server IO Error";
					break;
					
				case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR :
					errorMessage = "Security Error";
					break;
					
				case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED :
					errorMessage = "Upload Limit Exceeded";
					break;
					
				case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED :
					errorMessage = "Failed Validation";
					break;
					
				case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED :
					errorMessage = "Cancelled";
					progress.setCancelled();
					break;
					
				case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED :
					errorMessage = "Stopped";
					break;
					
				default :
					errorMessage = "Unhandled Error";
					
			} /* End switch */
			
			//console.log('uploadError', errorMessage, message);
			progress.setError(errorMessage);
			this.debug("Error " + errorCode + ": " + errorMessage + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
		},

		uploadComplete : function (file) {
			if (this.getStats().files_queued > 0) {
				/* Continue with queue */
				this.startUpload();
			} else {
				// this.customSettings.submitButton.attr("disabled", false);
			}
		}
	
	} /* end handlers */

}; /* end CollectionUpload prototype */

function ThumbnailLoader (url, targetElement) {
	//console.log('ThumbnailLoader', url, targetElement);
	
	var loadAttempts = 0,
		loadInterval = window.setTimeout(loadImage, 1000);
		
	function loadImage () {
		//console.log('ThumbnailLoader.loadImage attempt:', loadAttempts);
		var image = new Image;
		image.onload = imageLoadSuccess;
		//image.onerror = imageLoadError;
		image.src = url;
		loadAttempts++;
		if (loadAttempts >= 10) {
			clearInterval(loadInterval);
		}
	}
	
	function imageLoadSuccess () {
		//console.log('ThumbnailLoader.imageLoadSuccess', url);
		clearInterval(loadInterval);
		targetElement.prepend("<li><p class='image-wrapper'><img src='" + url + "' alt=''></p></li>");
	}
}

function FileProgress (file, target) {

	if (!file) {
		return;
	}
	
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