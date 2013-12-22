timerInterval = null

Template.timers_active.helpers

  current_time: ->
    currentTime = Session.get('current_timer_time')
    return if currentTime then currentTime else 0

Template.timers_active.rendered = ->
  unless @rendered
    # Update the state of the timer whenver the model changes
    Timers.find(@data.timer._id).observeChanges
      added: timerUpdated
      changed: timerUpdated
    @rendered = true

timerUpdated = (id, fields) =>
  if fields.is_active
    console.log 'starting timer!'
    startInterval fields.started_at
  else
    console.log 'stopping timer!'
    Meteor.clearInterval(timerInterval)
    if fields.started_at is null
      Session.set('current_timer_time', 0) 

startInterval = (startedAt) ->
  # Update the local time every second
  timerInterval = Meteor.setInterval(
    =>
      startedTime = startedAt
      timeInMs = moment().diff(startedTime, 'milliseconds')
      Session.set('current_timer_time', timeInMs)
  , 1000)

Template.timers_active.events
  'click .js-timer-play': (evt) ->
    timerObj =
      is_active: true
    unless @started_at
      timerObj.started_at = moment().format()
    Meteor.call 'updateTimer', @_id, timerObj

  'click .js-timer-pause': (evt) ->
    Meteor.call 'updateTimer', @_id,
      is_active: false

  'click .js-timer-reset': (evt) ->
    # Reset the local timer at 0  
    Meteor.call 'updateTimer', @_id,
      started_at: null
      is_active: false
