Handlebars.registerHelper 'formatMsAsMinSec', (duration) ->
  totalSeconds = duration / 1000
  minutes = Math.floor(totalSeconds / 60)
  seconds = totalSeconds - (minutes * 60)
  paddedSeconds = ("00" + seconds).slice(-2)
  return "#{minutes}:#{paddedSeconds}"