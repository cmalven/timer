Meteor.publish 'steps', (timer_id) ->
  return Steps.find({'timer_id': timer_id})