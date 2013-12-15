Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

Router.map ->

  @route 'timers_index',
    path: '/',
    template: 'timers_index'
    waitOn: ->
      return Meteor.subscribe('timers')
    data: ->
      {
        timers: Timers.find()
      }

  @route 'timers_show',
    path: '/timer/:_id',
    template: 'timers_show'
    waitOn: ->
      return [
        Meteor.subscribe('timers')
        Meteor.subscribe('sets', @params._id)
        Meteor.subscribe('steps', @params._id)
      ]
    data: ->
      {
        timer: Timers.findOne({_id: @params._id})
        sets: Sets.find()
        steps: Steps.find()
      }

  @route 'steps_add',
    path: '/timer/:timer_id/set/:_id/add',
    template: 'steps_add'
    waitOn: ->
      return [
        Meteor.subscribe('timers')
        Meteor.subscribe('sets', @params.timer_id)
        Meteor.subscribe('steps', @params.timer_id)
      ]
    data: ->
      {
        timer: Timers.findOne({_id: @params.timer_id})
        set: Sets.findOne({_id: @params._id})
      }
