Template.timers_show.helpers

  foo: ->
    return "You're in the timers_show view!"

Template.timers_show.events
  'click .js-timer-play': (evt) ->
    Meteor.call 'updateTimer', @timer._id,
    started_at: moment().format()