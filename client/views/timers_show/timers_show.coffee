Template.timers_show.helpers

  foo: ->
    return "You're in the timers_show view!"

Template.timers_show.events
  'click .foo': (evt) ->
    # Event Callback