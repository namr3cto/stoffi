# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@toggleSearchMode = () ->
    v = $('#search').val()
    
    if $('#search').val() == ''
        $('.large-logo').show()
        $('.small-logo').hide()
        $('#loading-search').hide()
    else
        $('.large-logo').hide()
        $('.small-logo').show()
        $('#loading-search').show()
        
@search = (query, categories, sources) ->
    url = "/search/fetch?q=#{query}&c=#{categories}&s=#{sources}"
    div = $('#search-results')
    req = $.get url
    req.success (html) -> div.html(html)
    req.error (jqXHR, status, error) ->
        div.html("<p>#{status}</p><p>#{error}</p>")
        
ready = ->
    $('#search').autocomplete({
        source: "/search/suggest.json",
        minLength: 2,
        focus: (event,ui) ->
            $('#search').val(ui.item.query)
            false
        select: (event,ui) ->
            $('#search-form').submit()
            false
    })
    .autocomplete('instance')._renderItem = (ul, item) ->
        l = $('#search').val().length
        str = item.query[0..l-1] + '<b>' + item.query[l..]
        $('<li>'+str+'</b></li>').appendTo(ul)

$(document).ready(ready)
$(document).on('page:load', ready)