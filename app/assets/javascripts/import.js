$(document).ready(function() {

    // Toggle sub-options of the "Use folders as item names" option
    // 
    var toggleFolderOptions = function(toggleElement) {
        var optionSets = $('.folders-as-item-names-options');
        if ($(toggleElement).is(':checked')) {
            $(optionSets).toggle(true);
        } else {
            $(optionSets).toggle(false);
        }
    }
    
    $('#option_folders_as_item_names').off('click').on('click', function() {
        toggleFolderOptions($(this));
    });
    toggleFolderOptions($('#option_folders_as_item_names')); // Run on page load

    // 
    // Toggle sub-options of the "Extract metadata from filenames" option
    //
    var toggleMetaOptions = function(toggleElement) {
        var optionSets = $('.meta-in-filename-options');
        if ($(toggleElement).is(':checked')) {
            $(optionSets).toggle(true);
        } else {
            $(optionSets).toggle(false);
        }
    }
    
    $('#option_meta_in_filename').off('click').on('click', function() {
        toggleMetaOptions($(this));
    });
    toggleMetaOptions($('#option_meta_in_filename')); // Run on page load

    //
    // Manage dynamic number of metadata fields
    // 
    var writeFilenameMetaFields = function(numberOfFieldsElement) {
        var numFields = $(numberOfFieldsElement).val(),
            numExistingFields = $('.meta-fields input').length;

        if (numExistingFields > numFields) {
            // We have too many fields, remove some
            var x = numExistingFields;
            while (x > numFields) {
                $('.meta-field').last().remove();
                $('.meta-delimiter').last().remove();
                x = x - 1;
            }
        } else if (numExistingFields < numFields) {
            // Need more fields, add some
            var addFields = numFields - numExistingFields;
            console.log("Adding " + addFields);
            for(i=0; i < addFields; i++) {
                $('.meta-fields').append('<input type="text" name="option_meta_fields[]" class="span2 meta-field">');
                // The last delimiter gets hidden via .meta-delimiter:last-child style
                $('.meta-fields').append('<span class="meta-delimiter">'+$('#option_meta_delimiter').val()+'</span>');
            }
        }
    }

    $('#option_num_meta_fields').change(function() {
        writeFilenameMetaFields($(this));
    });
    writeFilenameMetaFields($('#option_num_meta_fields'));
    
    // Change display of meta field delimiter 
    $('#option_meta_delimiter').change(function() {
        $('.meta-delimiter').text($(this).val());
    });
});