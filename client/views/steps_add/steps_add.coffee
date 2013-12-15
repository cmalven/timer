digitString = ''
maxDigitStringLength = 4

Template.steps_add.helpers

  foo: ->
    return "You're in the steps_add view!"

Template.steps_add.events
  'click .js-duration-digit': (evt) ->
    value = $(evt.currentTarget).data 'value'
    switch value
      when 'clear'
        digitString = ''
      when 'back'
        digitString = digitString.substr(1)
      else
        return if digitString.length is maxDigitStringLength
        digitString += value
    displayString = formatString digitString
    $('.js-duration-display').text displayString

  'click .js-add-work-step': (evt) ->
    duration = parseTime $('.js-duration-display').text()
    return alert('Duration can’t be zero.') if duration is 0
    Meteor.call 'addStep', @timer._id, @set._id,
      type: 'work'
      duration: duration
    , (error, result) =>
      Router.go('timers_show', {_id: @timer._id}) unless error?

  'click .js-add-rest-step': (evt) ->
    duration = parseTime $('.js-duration-display').text()
    return alert('Duration can’t be zero.') if duration is 0
    Meteor.call 'addStep', @timer._id, @set._id,
      type: 'rest'
      duration: duration
    , (error, result) =>
      Router.go('timers_show', {_id: @timer._id}) unless error?

parseTime = (time) ->
  splitChar = ':'
  vals = time.split splitChar
  minutes = vals[0].replace(/^0+/, '') * 60000
  seconds = vals[1].replace(/^0+/, '') * 1000
  # Return the duration as total milliseconds
  return minutes + seconds

formatString = (string) ->
  s = ("0000" + string).slice(-maxDigitStringLength)
  return [s.slice(0, -2), ':', s.slice(-2)].join ''
