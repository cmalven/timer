Meteor.publish 'timers', ->
  return Timers.find()