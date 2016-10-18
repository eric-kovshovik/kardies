# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->

  $('.city-selection').hide()
  $('.city-selection-label').hide()

  $('.like-link').on("ajax:success", (e, data, status, xhr) ->
    username  = this.id.split("__");
    getID = this.id
    url = this.href
    if url.includes("dislike")
      this.href = '/users/' + username[1] + "/like"
      $('#'+getID).html('<i class="fa fa-heart-o fa-2x"></i>')
    else
      this.href = '/users/' + username[1] + "/dislike"
      $('#'+getID).html('<i class="fa fa-heart fa-2x"></i>')
  ).on "ajax:error", (e, xhr, status, error) ->
    getID = this.id
    alert('Something went wrong, check your internet connection')


  $('.state-selection').change ->

    $.getJSON '/cities/' + $(this).val(), (data) ->

      $('.city-selection').empty()
      $('.city-selection-not-hidden').empty()
      $.each data, (key, val) ->
        opt = '<option value=' + val[1] + '>' + val[0] + '</option>'
        $('.city-selection').append opt
        $('.city-selection-not-hidden').append opt
    $('.city-selection').show()
    $('.city-selection-label').show()
