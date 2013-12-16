Template.set.helpers

  steps: ->
    return Steps.find
      set_id: @_id

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