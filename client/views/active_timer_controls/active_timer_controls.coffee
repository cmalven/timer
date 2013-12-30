Template.active_timer_controls.helpers

  foo: ->
    return "You're in the active_timer_controls view!"

Template.active_timer_controls.events
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