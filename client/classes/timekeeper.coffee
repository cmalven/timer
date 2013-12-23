root = exports ? this

class root.Timekeeper

  constructor: (@options) ->
    @timer = @options.timer
    @timerInterval = null

    # Update the state of the timer whenver the model changes
    @timer.observeChanges
      added: @_updateTimerState
      added: @_updateTimerTime
      changed: @_updateTimerState

  _updateTimerState: (id, fields) =>
    if fields.is_active
      console.log 'starting timer!'
      @timerInterval = Meteor.setInterval(
        =>
          @_updateTimerTime id
      , 1000)
    else
      console.log 'stopping timer!'
      Meteor.clearInterval(@timerInterval)
      if fields.started_at is null
        Session.set('current_timer_time', 0)

  _updateTimerTime: (timerId) ->
    timer = Timers.findOne(timerId)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
    Session.set('current_timer_time', timeInMs)