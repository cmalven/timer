Template.set.helpers

  steps: ->
    return Steps.find
      set_id: @_id
      {sort: {position: 1}}

Template.set.rendered = ->
  unless @rendered
    $ =>
      $(@find('.js-sortable-steps'))
        .sortable()
        .on "sortupdate", (evt, ui) ->
          $.each $(this).find('li'), () ->
            position = $(this).index()
            id = $(this).data('step-id')
            Meteor.call 'updateStep', id,
              position: position
    @rendered = true

Template.set.events
  'click .js-repeating-subtract': (evt) ->
    newRepeats = @repeats - 1
    return if newRepeats < 1
    Meteor.call 'updateSet', @_id,
      repeats: newRepeats

  'click .js-repeating-add': (evt) ->
    newRepeats = @repeats + 1
    Meteor.call 'updateSet', @_id,
      repeats: newRepeats