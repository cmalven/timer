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

      # Update current set and step
      @currentSet = @_getCurrentSet currentTime
      @currentStep = @_getCurrentStep currentTime

      # Update current step time
      @_updateCurrentStepTime currentTime

      # Update the chart graphic
      @_updateChart currentTime

  _updateTimerState: (id, fields) =>
    if fields.is_active
      @timerInterval = Meteor.setInterval(
        =>
          @_updateTimerTime id
      , @updateInterval)
    else
      Meteor.clearInterval(@timerInterval)
      if fields.started_at is null
        Session.set("#{@timer.selector_id}_current_timer_time", 0)

  _updateTimerTime: (id) =>
    timer = Timers.findOne(id)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
      roundedTime = @_roundToThousand timeInMs
      console.log 'roundedTime', roundedTime
    Session.set("#{timer._id}_current_timer_time", roundedTime)

  _updateCurrentStepTime: (currentTime) =>
    currentStepPosition = @currentStep.position
    timeBefore = @_getTimeBeforeStep currentStepPosition, currentTime
    timeForStep = currentTime - timeBefore
    Session.set('current_timer_time', timeForStep)

  _getCurrentSet: (currentTime) =>
    timeSearched = 0
    return currentSet = _.find Sets.find().fetch(), (set) =>
      totalSetDuration = @_getSetDuration set
      return false if currentTime < timeSearched
      timeSearched += totalSetDuration
      return false if currentTime > timeSearched
      return true

  _getSetDuration: (setCursor) =>
    setSteps = @_getStepsForSet setCursor
    return totalSetDuration = _.reduce(setSteps.fetch(), (memo, step) =>
      return memo + step.duration
    , 0)

  _getStepsForSet: (setCursor) =>
    return setSteps = Steps.find
      set_id: setCursor._id

  _getTimeBeforeStep: (currentStepPosition, currentTime) =>
    stepsForSet = @_getStepsForSet @currentSet
    time = _.reduce(stepsForSet.fetch(), (memo, step) =>
      if step.position < currentStepPosition
        return memo + step.duration
      else
        return memo
    , 0)
    return @_roundToThousand time

  _getCurrentStep: (currentTime) =>
    stepsForSet = @_getStepsForSet @currentSet
    timeSearched = 0
    return currentStep = _.find stepsForSet.fetch(), (step) =>
      return false if currentTime < timeSearched
      timeSearched += step.duration
      return false if currentTime > timeSearched
      return true

  _updateChart: (currentTime) =>
    timeBeforeStep = @_getTimeBeforeStep @currentStep.position, currentTime
    elapsedTimeForStep = currentTime - timeBeforeStep
    timePct = (elapsedTimeForStep / @currentStep.duration) * 100

    data = [
      {
        value : timePct,
        color : @_getStepColor @currentStep.type
      },
      {
        value : 100 - timePct,
        color : "#E2EAE9"
      }
    ]

    options = {
      segmentShowStroke : true,
      segmentStrokeColor : "#fff",
      segmentStrokeWidth : 2,
      percentageInnerCutout : 80,
      animation : false,
      animationSteps : 100,
      animationEasing : "easeOutBounce",
      animateRotate : true,
      animateScale : false,
      onAnimationComplete : null
    }

    @chartCanvas = $('.js-active-timer-canvas').get(0).getContext('2d')
    @chart = new Chart(@chartCanvas).Doughnut(data, options)

  _getStepColor: (stepType) =>
    return if stepType is 'work' then 'green' else 'red'

  _roundToThousand: (number) =>
    Math.round(number / 1000) * 1000