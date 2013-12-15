Template.steps_edit.helpers

  foo: ->
    return "You're in the steps_edit view!"

Template.steps_edit.events
  'click .js-delete-step': (evt) ->
    Meteor.call 'removeStep', @step._id, (error, result) =>
      Router.go('timers_show', {_id: @timer._id}) unless error?
