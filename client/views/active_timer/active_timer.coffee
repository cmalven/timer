timerInterval = null

Template.active_timer.helpers

  current_time: ->
    Session.get('current_timer_time')

Template.active_timer.rendered = ->
  unless @rendered
    timerInterval = Meteor.setInterval(
      =>
        startedTime = @data.timer.started_at
        timeInMs = moment().diff(startedTime, 'milliseconds')
        Session.set('current_timer_time', timeInMs)
    , 1000)
    @rendered = true

Template.active_timer.events
  'click .js-timer-pause': (evt) ->
    Meteor.clearInterval timerInterval
    Meteor.call 'updateTimer', @timer._id,
      started_at: null