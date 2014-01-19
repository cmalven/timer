root = exports ? this

class root.Timekeeper

  constructor: (@options) ->
    @timer = Timers.find @options.timerId
    @timeout = null
    @updateInterval = 500

    # Update the state of the timer/sets/steps whenver they change
    @timer.observeChanges
      added: @_updateTimerState
      added: @_updateTimerTime
      changed: @_updateTimerState

    Sets.find().observeChanges
      added: @_buildTimeline
      changed: @_buildTimeline
      removed: @_buildTimeline

    Steps.find().observeChanges
      added: @_buildTimeline
      changed: @_buildTimeline
      removed: @_buildTimeline

    # Create the initial timeline
    @timeline = @_buildTimeline()

    # Listen for session to change
    Deps.autorun =>
      currentTime = Session.get("current_timer_time")

      # Update current set and step
      @currentSet = @_getSetForTime currentTime
      @currentStep = @_getStepForTime currentTime

      # Update current step time
      @_updateCurrentStepTime currentTime

      # Update the chart graphic
      @_updateChart currentTime

  _buildTimeline: =>
    elapsedTime = 0
    sets = []

    Sets.find().forEach (set) =>
      i = set.repeats
      while i--
        setObj = {}
        setObj.min = elapsedTime
        setObj._id = set._id
        setObj.steps = []

        Steps.find({set_id: set._id}).forEach (step) =>
          stepObj = step
          stepObj.min = elapsedTime
          elapsedTime += step.duration
          stepObj.max = elapsedTime
          setObj.steps.push stepObj

        setObj.max = elapsedTime
        sets.push setObj
    return sets

  _updateTimerState: (id, fields) =>
    if fields.is_active
      @_updateTimerTime id
    else
      Meteor.clearTimeout(@timeout)
      if fields.started_at is null
        Session.set("current_timer_time", 0)


  _updateTimerTime: (id) =>
    timer = Timers.findOne(id)
    timeInMs = timer.elapsed_time_in_ms
    if timer.is_active
      @timeout = Meteor.setTimeout(
        =>
          @_updateTimerTime id
      , @updateInterval)
      timeInMs += moment().diff(timer.started_at, 'milliseconds')
      roundedTime = @_roundToThousand timeInMs
    Session.set("current_timer_time", roundedTime)

  _updateCurrentStepTime: (currentTime) =>
    timeBefore = @_getTimeBeforeStep currentTime
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
    # XXX: This currently doesn't work, so it will always return true
    # return true unless @_getStepForTime(@currentStep.max + 1)?
    return true

  _getSetForTime: (currentTime) =>
    currentSet = _.find @timeline, (set) =>
      return false if currentTime < set.min
      return false if currentTime > set.max
      return true
    return false unless currentSet?
    Session.set 'current_set', currentSet._id
    return currentSet

  _getStepForTime: (currentTime) =>
    set = _.where @timeline, {_id: @currentSet._id}
    currentStep = _.find set[0].steps, (step) =>
      return false if currentTime < step.min
      return false if currentTime > step.max
      return true
    return false unless currentStep?
    Session.set 'current_step', currentStep._id
    return currentStep

  _getStepsForSet: (setCursor) =>
    return setSteps = Steps.find
      set_id: setCursor._id

  _getTimeBeforeStep: (currentTime) =>
    set = @_getSetForTime currentTime
    step = @_getStepForTime currentTime
    timeBefore = step.min
    return @_roundToThousand timeBefore

  _updateChart: (currentTime) =>
    timeBeforeStep = @_getTimeBeforeStep currentTime
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