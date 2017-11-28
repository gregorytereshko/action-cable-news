$(document).on('turbolinks:load', function(){
  $('input').each(function(){
    $input = $(this);
    if ($input.val() != '') {
      $input.focus();
    }
  });

  if ($(".datetimepicker").length) {
    oldDateTimeVal = $(".datetimepicker").val();
    if (oldDateTimeVal != '') {
      $(".datetimepicker").val(convertToHumanDateTime(oldDateTimeVal));
    }
    $(".datetimepicker").datepicker({
      timepicker: true,
      onSelect: function(){
        // $('form').resetClientSideValidations();
      }
    });
  }


});
