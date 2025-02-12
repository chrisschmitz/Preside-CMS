( function( $ ){

    $(".object-picker").presideObjectPicker();
    $(".object-configurator").presideObjectConfigurator();
    $(".asset-picker").uberAssetSelect();
    $(".image-dimension-picker").imageDimensionPicker();

    $(".auto-slug").each( function(){
        var $this         = $(this)
          , $basedOn      = $this.parents("form:first").find("[name='" + $this.data( 'basedOn' ) + "']")
          , slugDelimiter = $this.data( "slugDelimiter" ) || "-"
          , repeatRegex   = new RegExp( slugDelimiter+"+", "g" )
          , startRegex    = new RegExp( "^"+slugDelimiter, "g" )
          , endRegex      = new RegExp( slugDelimiter+"$", "g" )
        ;

        $basedOn.keyup( function(e){
            var slug = $basedOn.val()
                .replace( /\W/g      , slugDelimiter )
                .replace( repeatRegex, slugDelimiter )
                .replace( startRegex , "" )
                .replace( endRegex   , "" )
                .toLowerCase();

            $this.val( slug ).trigger( "keyup" );
        } );
    });

    $( 'textarea[class*=autosize]' ).autosize( {append: "\n"} );
    $( 'textarea[class*=limited]' ).each(function() {
        var limit = parseInt($(this).attr('data-maxlength')) || 100;
        $(this).inputlimiter({
            "limit": limit,
            remText: '%n character%s remaining...',
            limitText: 'max allowed : %n.'
        });
    });
    $( 'textarea.richeditor' ).not( '.frontend-container' ).each( function(){
        new PresideRichEditor( this );
    } );

    $('[data-rel=popover]').popover({container:'body'});

    $('.timepicker').each( function(){
        var $thisPicker  = $( this )
          , pickerConfig = $thisPicker.data();

        $thisPicker.datetimepicker({
              icons: {
                  time:     'fa fa-clock-o'
                , date:     'fa fa-calendar'
                , up:       'fa fa-chevron-up'
                , down:     'fa fa-chevron-down'
                , previous: 'fa fa-chevron-left'
                , next:     'fa fa-chevron-right'
                , today:    'fa fa-screenshot'
                , clear:    'fa fa-trash'
              }
            , format         : 'HH:mm'
            , useCurrent     : false
            , defaultHour    : pickerConfig.defaultHour    || 0
            , defaultMinutes : pickerConfig.defaultMinutes || 0
            , sideBySide     : true
            , locale         : pickerConfig.language       || "en"
        });
    });

    $(".derivative-select-option").each( function(){
        var $derivativeField   = $( this )
          , $parentForm        = $derivativeField.closest( "form" )
          , $dimensionField    = $parentForm.find( "[name=dimension]" )
          , $widthField        = $parentForm.find( ".image-dimensions-picker-width" )
          , $heightField       = $parentForm.find( ".image-dimensions-picker-height" )
          , $qualityField      = $parentForm.find( "#quality" )
          , $choosenDerivative = $parentForm.find( "[name=derivative]" );

        $derivativeField.change( function(){
            if( $choosenDerivative.val() === "none"){
                $widthField.prop('disabled', false);
                $heightField.prop('disabled', false);
                $qualityField.prop( "disabled", false ).data("uberSelect").search_field_disabled();
            } else {
                $widthField.prop('disabled', true);
                $heightField.prop('disabled', true);
                $qualityField.prop( "disabled", true );
                $qualityField.data("uberSelect").search_field_disabled();
            }
        });

        if( $choosenDerivative.val() != "none" ){
            $widthField.prop('disabled', true);
            $heightField.prop('disabled', true);
            $qualityField.prop( "disabled", true );
            $qualityField.data("uberSelect").search_field_disabled();
        }
    });

    $( 'input[type="file"]' ).on("change", function() {
        var $this = $( this );
        $( ".form-control-filename", $this.parent() ).text( $this.val().split( "\\" ).pop() );
    } );

} )( presideJQuery );
