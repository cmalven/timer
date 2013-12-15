Meteor.methods

  addTimer: (opts) ->
    return Timers.insert opts

  addSet: (timer_id, opts) ->
    opts = _.extend opts, { timer_id: timer_id }
    return Sets.insert opts

  addStep: (timer_id, set_id, opts) ->
    opts = _.extend opts,
      timer_id: timer_id
      set_id: set_id
    return Steps.insert opts