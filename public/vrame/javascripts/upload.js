jQuery(function ($) {
	$('.file-upload').each(function () {
		new Upload(this);
	});
});

function Upload (containerEl) {
	
	/* Get the jQuery-wrapped container element */
	var c = jQuery(containerEl);
	
	/* Get the elements and options from DOM */
	
	var o = {
		/* Upload token */
		token                       : c.attr('data-upload-token'),
		
		/* Upload type (single or multiple files, e.g. 'asset' or 'collection') */
		uploadType                  : c.attr('data-upload-type'),
		
		/* Current collection id, if already present */
		collectionId                : c.attr('data-collection-id') || '',
		
		/* Parent object (asset/collection owner) type */
		parentType                  : c.attr('data-parent-type'),
		
		/* Parent object (asset/collection owner) id */
		parentId                    : c.attr('data-parent-id'),
		
		/* Upload button element id */
		buttonId                    : c.find('.upload-button').attr('id'),
		
		/* Upload queue HTML element (jQuery collection) */
		queue                       : c.find('.upload-queue'),
		
		/* Image list HTML element (jQuery collection) */
		assetList                   : c.find('.asset-list'),
		
		/* Form field(s) for the new asset id (jQuery collection) */
		assetIdInput                : c.find('input.asset-id'),
		
		/* Form field(s) for the new collection id (jQuery collection) */
		collectionIdInput           : c.find('input.collection-id'),

		// Information needed for the asset controller to determine the correct styles 
		schema                      : {
																	class:     c.attr('data-schema-class'),
																	id:        c.attr('data-schema-id'),
																	attribute: c.attr('data-schema-attr'),
																	uid:       c.attr('data-schema-uid')
																	}
	};
	
	//console.log('new Upload', o);
	
	/* Intialize SWFUpload */
	
	var handlers = this.handlers;
	
	new SWFUpload({
	
		/* The Flash Movie */
		flash_url : '/vrame/javascripts/swfupload/swfupload.swf',
		
		/* Upload URL (AssetsController/create) */
		upload_url : '/vrame/assets',
		
		/* Button settings */
		button_placeholder_id : o.buttonId,
		button_image_url : '/vrame/images/admin/upload_button.png',
		button_width : 69,
		button_height : 27,
		//button_window_mode: SWFUpload.WINDOW_MODE.OPAQUE,
		
		/* File Upload Settings */
		file_size_limit : 20 * 1024,
		file_types : '*.*',
		file_types_description : 'Files',
		file_upload_limit : o.uploadType == 'asset' ? 1 : 0,

		/* POST parameters with authentication and relation ids */
		post_params : {
			'user_credentials'  : o.token,
			'upload_type'       : o.uploadType,
			'parent_id'         : o.parentId,
			'parent_type'       : o.parentType,
			'collection_id'     : o.collectionId,
			'schema[class]'     : o.schema.class,
			'schema[id]'        : o.schema.id,
			'schema[attribute]' : o.schema.attribute,
			'schema[uid]'       : o.schema.uid
		},

		/* Pass our settings */
		custom_settings : o,

		/* Event handlers */
		file_queued_handler             : handlers.fileQueued,
		file_queue_error_handler        : handlers.fileQueueError,
		file_dialog_complete_handler    : handlers.fileDialogComplete,
		upload_start_handler            : handlers.uploadStart,
		upload_progress_handler         : handlers.uploadProgress,
		upload_error_handler            : handlers.uploadError,
		upload_success_handler          : handlers.uploadSuccess,
		upload_complete_handler         : handlers.uploadComplete,
		queue_complete_handler          : handlers.queueComplete

		/* Debugging */
		//,debug : true
	});
}

Upload.prototype.handlers = {
	
	fileQueued : function (file) {
		//console.log('fileQueued', file.name);
		var queue = this.customSettings.queue;
		queue.show();
		new FileProgress(file, queue);
	},
	
	fileQueueError : function (file, errorCode, fileNumberLimit) {
		//console.log('fileQueueError file:', file, 'errorCode:', errorCode, 'fileNumberLimit:', fileNumberLimit);
		
		if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
			alert('You have attempted to queue too many files.\n' + (fileNumberLimit === 0 ? 'You have reached the upload limit.' : 'You may select ' + (fileNumberLimit > 1 ? 'up to ' + fileNumberLimit + ' files.' : 'one file.')));
			return;
		}
		
		var progress = new FileProgress(file, this.customSettings.queue),
			errorMessage = '';
		
		switch (errorCode) {
		
			case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT :
				errorMessage = 'File is too big';
				break;
			
			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE :
				errorMessage = 'Won\'t upload empty files';
				break;
			
			case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE :
				errorMessage = 'Invalid file type';
				break;
				
			default :
				errorMessage = 'Unhandled Error';
			
		} /* End switch */
		
		progress.setError(errorMessage);
		this.debug('Error ' + errorCode + ': ' + errorMessage + ', File name: ' + file.name + ', File size: ' + file.size + ', Limit: ' + fileNumberLimit);
	},

	fileDialogComplete : function (numFilesSelected, numFilesQueued) {
		if (numFilesSelected > 0) {
			/* Start the upload immediately */
			this.startUpload();
		}
	},

	uploadStart : function (file) {
		//console.log('uploadStart', file.name);
		vrame.unsavedChanges = true;
		
		var progress = new FileProgress(file, this.customSettings.queue);
		progress.setProgress(0);
		/* No file validation, accept all files */
		return true;
	},

	uploadProgress : function (file, bytesLoaded, bytesTotal) {
		var progress = new FileProgress(file, this.customSettings.queue),
			percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
		
		progress.setProgress(percent);
	},

	uploadSuccess : function (file, serverResponse) {
		//console.log('uploadSuccess', file.name);
		
		var settings = this.customSettings,
			progress = new FileProgress(file, settings.queue),
			response,
			collectionId,
			imageLoadInterval,
			imageLoadAttempts;
		
		progress.setComplete();
		
		//console.log('serverResponse', serverResponse);
		
		/* Evaluate JSON response */
		response = eval('(' + serverResponse + ')');
		//console.log('response', response);
		
		/* Update asset id form field(s) (if any) */
		//console.log('new asset id:', response.id);
		settings.assetIdInput.val(response.id);
		
		/* Handle collection id */
		collectionId = response.collection_id;
		if (collectionId) {
			//console.log('collection id:', collectionId);
			
			/* Update collection id form field(s) (if any) */
			settings.collectionIdInput.val(collectionId);
			
			/* Once we have a collection id, reuse it in future uploads */
			settings.collectionId = collectionId;
			this.addPostParam('collection_id', collectionId);
			
			/* Append item to asset list */
			settings.assetList.append(response.asset_list_item);
		} else {
			/* Replace asset list items */
			settings.assetList.html(response.asset_list_item);
		}
	},
	
	uploadError : function (file, errorCode, message) {
		var progress = new FileProgress(file, this.customSettings.queue);
		
		switch (errorCode) {
			
			case SWFUpload.UPLOAD_ERROR.HTTP_ERROR :
				errorMessage = 'HTTP Error';
				break;
				
			case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED :
				errorMessage = 'Upload Failed';
				break;
				
			case SWFUpload.UPLOAD_ERROR.IO_ERROR :
				errorMessage = 'Server IO Error';
				break;
				
			case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR :
				errorMessage = 'Security Error';
				break;
				
			case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED :
				errorMessage = 'Upload Limit Exceeded';
				break;
				
			case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED :
				errorMessage = 'Failed Validation';
				break;
				
			case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED :
				errorMessage = 'Cancelled';
				progress.setCancelled();
				break;
				
			case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED :
				errorMessage = 'Stopped';
				break;
				
			default :
				errorMessage = 'Unhandled Error';
				
		} /* End switch */
		
		//console.log('uploadError', errorMessage, message);
		progress.setError(errorMessage);
		this.debug('Error ' + errorCode + ': ' + errorMessage + ', File name: ' + file.name + ', File size: ' + file.size + ', Message: ' + message);
	},

	uploadComplete : function (file) {
		//console.log('uploadComplete', file.name);
		if (this.getStats().files_queued > 0) {
			/* Continue with queue */
			this.startUpload();
		} else {
			//console.log('uploadComplete: no more filed queued');
		}
	},

	queueComplete : function () {
		//console.log('uploadComplete this:', this, 'arguments:', arguments);
	}

} /* end Upload.prototype.handlers */

function FileProgress (file, target) {

	if (!file) {
		return;
	}
	
	var id = file.id,
		instances = FileProgress.instances = FileProgress.instances || {},
		instance,
		$ = window.jQuery,
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
	
	wrapper         = $('<li>').addClass('progressWrapper').attr('id', id);
	progressElement = $('<li>').addClass('progressContainer');
	progressText    = $('<span>').addClass('progressName').append(file.name);
	progressBar     = $('<div>').addClass('progressBar');
	progressStatus  = $('<span>').addClass('progressStatus');
	
	progressElement.append(progressText).append(progressStatus).append(progressBar);
	wrapper.append(progressElement);
	target.append(wrapper);
	
	instance.wrapper = wrapper;
	instance.progressElement = progressElement;
	instance.progressText = progressText;
	instance.progressBar = progressBar;
	instance.progressStatus = progressStatus;
	
	instance.height = wrapper.offsetHeight;
	instance.setStatus(Math.floor(file.size / 1024) + 'kb');
}

FileProgress.prototype = {

	setProgress : function (percentage) {
		this.progressElement.attr('className', 'progressContainer progressUploading');
		this.setStatus('Uploading...');
		this.progressBar.width(percentage + '%');
	},

	setComplete : function () {
		this.progressElement.attr('className', 'progressContainer progressComplete');
		this.setStatus('Finished');
		this.progressBar.css('width', '');
		this.disappear(750);
	},

	setError : function (errorMessage) {
		this.progressElement.attr('className', 'progressContainer progressError');
		this.setStatus(errorMessage || 'Error');
		this.progressBar.css('width', '');
		this.disappear(5000);
	},

	setCancelled : function () {
		this.progressElement.attr('className', 'progressContainer progressCancelled');
		this.setStatus(errorMessage || 'Cancelled');
		this.progressBar.css('width', '');
		this.disappear(2000);
	},

	setStatus : function (status) {
		this.progressStatus.innerHTML = status;
	},

	/* Fades out and clips away the FileProgress box. */
	disappear : function (delay) {
		var self = this;
		if (typeof delay == 'number') {
			setTimeout(function () {
				self.disappear();
			}, delay);
		} else {
			this.wrapper.fadeOut();
		}
	}
	
};