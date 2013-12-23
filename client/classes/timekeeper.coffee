root = exports ? this

class root.Timekeeper

  constructor: (@options) ->
    @timer = @options.timer
    @timerInterval = null

    # Update the state of the timer whenver the model changes
    @timer.observeChanges
      added: @_timerUpdated
      added: @_updateTimer
      changed: @_timerUpdated

  _timerUpdated: (id, fields) =>
    if fields.is_active
      console.log 'starting timer!'
      @_startInterval id
    else
      console.log 'stopping timer!'
      Meteor.clearInterval(@timerInterval)
      if fields.started_at is null
        Session.set('current_timer_time', 0) 

  _startInterval: (timerId) =>
    @timerInterval = Meteor.setInterval(
      =>
        @_updateTimer timerId
    , 1000)

  _updateTimer: (timerId) ->
    timer = Timers.findOne(timerId)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
    Session.set('current_timer_time', timeInMs)