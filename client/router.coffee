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

  @route 'timers_active',
    path: '/timer/:_id/active',
    template: 'timers_active'
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

  @route 'steps_edit',
    path: '/timer/:timer_id/step/:_id/edit',
    template: 'steps_edit'
    waitOn: ->
      return [
        Meteor.subscribe('timers')
        Meteor.subscribe('sets', @params.timer_id)
        Meteor.subscribe('steps', @params.timer_id)
      ]
    data: ->
      {
        timer: Timers.findOne({_id: @params.timer_id})
        step: Steps.findOne({_id: @params._id})
      }
