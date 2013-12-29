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
      currentTime = Session.get("current_timer_time")

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
        Session.set("current_timer_time", 0)

  _updateTimerTime: (id) =>
    timer = Timers.findOne(id)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
      roundedTime = @_roundToThousand timeInMs
    Session.set("current_timer_time", roundedTime)

  _updateCurrentStepTime: (currentTime) =>
    currentStepPosition = @currentStep.position
    timeBefore = @_getTimeBeforeStep currentStepPosition, currentTime
    elapsedTimeForStep = currentTime - timeBefore
    Session.set('current_step_time', elapsedTimeForStep)

    # Announce if the step is over
    if @currentStep.duration is elapsedTimeForStep
      console.log 'Step Ended!'
      # Is the last step of a set?
      if @_isLastStepOfSet()
        console.log 'Set Ended!'
      # Is the last step of the timer?
      if @_isLastStepOfTimer()
        console.log 'Timer Ended!'
        Meteor.call 'updateTimer', @timer._id,
          is_active: false

  _isLastStepOfSet: =>
    setSteps = @_getStepsForSet @currentSet
    return true unless @currentStep.position < setSteps.count() - 1

  _isLastStepOfTimer: =>
    return true unless @currentStep.position < Steps.find().count() - 1

  _getCurrentSet: (currentTime) =>
    timeSearched = 0
    currentSet = _.find Sets.find().fetch(), (set) =>
      totalSetDuration = @_getSetDuration set
      return false if currentTime < timeSearched
      timeSearched += totalSetDuration
      return false if currentTime > timeSearched
      return true
    Session.set 'current_set', currentSet._id
    return currentSet

  _getCurrentStep: (currentTime) =>
    stepsForSet = @_getStepsForSet @currentSet
    timeSearched = @_getTimeBeforeSet @currentSet
    currentStep = _.find stepsForSet.fetch(), (step) =>
      return false if currentTime < timeSearched
      timeSearched += step.duration
      return false if currentTime > timeSearched
      return true
    Session.set 'current_step', currentStep._id
    return currentStep

  _getStepsForSet: (setCursor) =>
    return setSteps = Steps.find
      set_id: setCursor._id

  _getSetDuration: (setCursor) =>
    setSteps = @_getStepsForSet setCursor
    return totalSetDuration = _.reduce(setSteps.fetch(), (memo, step) =>
      return memo + step.duration
    , 0)

  _getTimeBeforeStep: (currentStepPosition, currentTime) =>
    stepsForSet = @_getStepsForSet @currentSet
    time = _.reduce(stepsForSet.fetch(), (memo, step) =>
      if step.position < currentStepPosition
        return memo + step.duration
      else
        return memo
    , 0)
    return @_roundToThousand time

  _getTimeBeforeSet: (setCursor) =>
    time = _.reduce(Steps.find().fetch(), (memo, step) =>
      set = Sets.findOne(step.set_id)
      if set.position < setCursor.position
        return memo + step.duration
      else
        return memo
    , 0)
    return @_roundToThousand time

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
        color : "#2e2e2e"
      }
    ]

    options = {
      segmentShowStroke : true,
      segmentStrokeColor : "#1a1718",
      segmentStrokeWidth : 1,
      percentageInnerCutout : 95,
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