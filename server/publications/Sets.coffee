Meteor.publish 'sets', (timer_id) ->
  return Sets.find("timer_id": timer_id)