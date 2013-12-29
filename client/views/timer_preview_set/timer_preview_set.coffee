Template.timer_preview_set.helpers

  steps: ->
    return Steps.find
      set_id: @_id
      {sort: {position: 1}}

  is_current_set: ->
    return Session.equals('current_set', @_id)

  is_current_step: ->
    return Session.equals('current_step', @_id)

Template.timer_preview_set.events
  'click .foo': (evt) ->
    # Event Callback