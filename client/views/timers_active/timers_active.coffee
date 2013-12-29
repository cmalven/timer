timekeeper = null

Template.timers_active.helpers

  current_time: ->
    currentTime = Session.get('current_step_time')
    return if currentTime then currentTime else 0

Template.timers_active.rendered = ->
  unless @rendered
    timekeeper = new Timekeeper
      timerId: @data.timer._id
    @rendered = true

Template.timers_active.events
  'click .js-timer-play': (evt) ->
    Meteor.call 'updateTimer', @_id,
      is_active: true
      started_at: moment().format()

  'click .js-timer-pause': (evt) ->
    Meteor.call 'updateTimer', @_id,
      is_active: false
      elapsed_time_in_ms: Session.get('current_timer_time')

  'click .js-timer-reset': (evt) ->
    # Reset the local timer at 0  
    Meteor.call 'updateTimer', @_id,
      started_at: null
      is_active: false
      elapsed_time_in_ms: 0
