(($) ->
  #in options we can give the following: onstart, onstop, delay, resultsEl and param.
  #resultEl: element that will display list results in given element
  #delay: time after which ajax request fires to fetch data.
  #url = www.somurl.com?address=xyz, here the param will be passed as address into plugin options
  #usage= $(elementSelector).suggestSearch({delay:1000, resultEl: "#results", param: "address", url:"www.someurl.com"})

  $.suggestSearch = (element, options) ->
    defaults = 
      delay: 1000

    search = this
    search.settings = {}
    $element = $(element)

    resetTimer = (timer) ->
      if timer
        clearTimeout timer
      return

    process = (searchTerm) ->
      endpoint = search.settings.url + "?" + search.settings.param + "=" + searchTerm
      $.ajax
        method: 'GET'
        url: endpoint
        beforeSend: (xhr, settings)->
          if typeof options.onStart != 'undefined'
            options.onStart()
        success: (data, xhr, status)->
          html = generateHTML data
          $(search.settings.resultsEl).html html
          if typeof options.onStop != 'undefined'
            options.onStop()
      return   

    generateHTML = (response)->
      html = response.map((address, index, list)->
        
        line = '<span class="address-line-1">' + address.line1 + '</span>' + (if address.line2!=null then ',' else '') + '<span class="address-line-2">' + address.line2 + '</span>'
        
        location = '<span class="city">' + address.city + '</span>' + (if address.state!=null then ',' else '') + '<span class="state">' + address.state + '</span>' + (if address.zip!=null then ',' else '') + '<span class="zip">' + address.zip + '</span>'

        htmlString = '<li>' + line + '<br>' + location + '</li>'
      ).join('')

      html = '<ul class="suggested-locations">' + html + '</ul>'
      return html

    search.init = ->
      search.settings = $.extend({}, defaults, options)
      $element.keyup(->
        if $element.val() != @previousValue
          resetTimer @timer
          @timer = setTimeout((->
            process $element.val()
            return
          ), search.settings.delay)
          @previousValue = $element.val()
        return
      )
      return

    search.init()
    return

  $.fn.suggestSearch = (options) ->
    @each ->
      if undefined == $(this).data('suggestSearch')
        search = new ($.suggestSearch)(this, options)
        $(this).data 'suggestSearch', search
      return

  return
) jQuery
