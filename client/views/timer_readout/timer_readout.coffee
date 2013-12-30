Template.timer_readout.helpers
  
  step_type: ->
    step = Steps.findOne Session.get('current_step')
    return if step? then step.type else ''

  current_time: ->
    currentTime = Session.get('current_step_time')
    return if currentTime then currentTime else 0