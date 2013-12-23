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
    startInterval id
  else
    console.log 'stopping timer!'
    Meteor.clearInterval(timerInterval)
    if fields.started_at is null
      Session.set('current_timer_time', 0) 

startInterval = (timerId) ->
  timerInterval = Meteor.setInterval(
    =>
      onInterval timerId
  , 1000)

onInterval = (timerId) ->
  timer = Timers.findOne(timerId)
  timeInMs = moment().diff(timer.started_at, 'milliseconds')
  Session.set('current_timer_time', timeInMs + timer.elapsed_time_in_ms)

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
