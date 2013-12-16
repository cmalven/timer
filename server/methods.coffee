Meteor.methods

  addTimer: (opts) ->
    return Timers.insert opts

  updateSet: (set_id, opts) ->
    return Sets.update {_id: set_id}, {$set: opts}

  addSet: (timer_id, opts) ->
    opts = _.extend opts, { timer_id: timer_id }
    return Sets.insert opts

  addStep: (timer_id, set_id, opts) ->
    opts = _.extend opts,
      timer_id: timer_id
      set_id: set_id
    return Steps.insert opts

  removeStep: (step_id) ->
    return Steps.remove({_id: step_id})