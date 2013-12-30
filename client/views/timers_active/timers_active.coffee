timekeeper = null

Template.timers_active.helpers

  foo: ->
    return "You're in the active_timer_controls view!"

Template.timers_active.rendered = ->
  unless @rendered
    timekeeper = new Timekeeper
      timerId: @data.timer._id
    @rendered = true
