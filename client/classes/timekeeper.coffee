root = exports ? this

class root.Timekeeper

  constructor: (@options) ->
    @timer = Timers.find @options.timerId
    @timerInterval = null
    @updateInterval = 1000

    # Update the state of the timer whenver the model changes
    @timer.observeChanges
      added: @_updateTimerState
      added: @_updateTimerTime
      changed: @_updateTimerState

    # Listen for session to change
    Deps.autorun =>
      currentTime = Session.get("#{@timer.selector_id}_current_timer_time")
      @_updateChart()

      # Calculate the total timer time
      timerSteps = Steps.find()
      @totalTimerTime = _.reduce(timerSteps.fetch(), (memo, step) =>
        return memo + step.duration
      , 0)

  _updateTimerState: (id, fields) =>
    if fields.is_active
      console.log 'starting timer!'
      @timerInterval = Meteor.setInterval(
        =>
          @_updateTimerTime id
      , @updateInterval)
    else
      console.log 'stopping timer!'
      Meteor.clearInterval(@timerInterval)
      if fields.started_at is null
        Session.set("#{@timer.selector_id}_current_timer_time", 0)

  _updateTimerTime: (id) =>
    timer = Timers.findOne(id)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
    Session.set("#{timer._id}_current_timer_time", timeInMs)

  _updateChart: =>
    currentTime = Session.get("#{@timer.selector_id}_current_timer_time")
    timePct = (currentTime / @totalTimerTime) * 100

    data = [
      {
        value : timePct,
        color : "#F7464A"
      },
      {
        value : 100 - timePct,
        color : "#E2EAE9"
      }
    ]

    options = {
      # Boolean - Whether we should show a stroke on each segment
      segmentShowStroke : true,
      # String - The colour of each segment stroke
      segmentStrokeColor : "#fff",
      # Number - The width of each segment stroke
      segmentStrokeWidth : 2,
      # The percentage of the chart that we cut out of the middle.
      percentageInnerCutout : 80,
      # Boolean - Whether we should animate the chart 
      # animation : true,
      animation : false,
      # Number - Amount of animation steps
      animationSteps : 100,
      # String - Animation easing effect
      animationEasing : "easeOutBounce",
      # Boolean - Whether we animate the rotation of the Doughnut
      animateRotate : true,
      # Boolean - Whether we animate scaling the Doughnut from the centre
      animateScale : false,
      # Function - Will fire on animation completion.
      onAnimationComplete : null
    }

    @chartCanvas = $('.js-active-timer-canvas').get(0).getContext('2d')
    @chart = new Chart(@chartCanvas).Doughnut(data, options)
