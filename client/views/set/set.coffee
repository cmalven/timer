Template.set.helpers

  steps: ->
    return Steps.find
      set_id: @_id

Template.set.events
  'click .foo': (evt) ->
    # Event Callback