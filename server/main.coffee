Meteor.startup ->
  # Bootstrap Collections
  if not Timers.find().count()
    timer_id = Meteor.call 'addTimer',
      _id: 'gADbgtuXXAE3ZEMQd'
      name: 'Sample Timer'
      created_at: moment().format()
      is_active: false
      current_time: 0

    # First Set

    set_id = Meteor.call 'addSet', timer_id,
      repeats: 1

    Meteor.call 'addStep', timer_id, set_id,
      type: 'work'
      duration: 20000
      position: 0

    Meteor.call 'addStep', timer_id, set_id,
      type: 'rest'
      duration: 10000
      position: 1

    # Second Set
    
    set_id = Meteor.call 'addSet', timer_id,
      repeats: 2

    Meteor.call 'addStep', timer_id, set_id,
      type: 'work'
      duration: 30000
      position: 0

    Meteor.call 'addStep', timer_id, set_id,
      type: 'rest'
      duration: 15000
      position: 1