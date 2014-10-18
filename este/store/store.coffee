goog.provide 'este.Store'

goog.require 'goog.events.Event'
goog.require 'goog.events.EventTarget'

class este.Store extends goog.events.EventTarget

  ###*
    Store holds app state and methods to manipulate with it. Store represents
    specific app feature, and orchestrates one or several app models. React
    component can listen any store and then update itself. Store can handle
    own persistence for SPA's by listening dispatcher and then changing itself
    via XHR or something else. For isomorphic SPA's is recommended to extract
    such responsibility into separate client/server storage class.
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    Name is used for localStorage persistence for example.
    @type {string}
  ###
  name: ''

  ###*
    Override this method to return only that props which should be serialized.
    @return {Object}
  ###
  toJson: goog.abstractMethod

  ###*
    Override this method for deserialization.
    @param {Object} json
  ###
  fromJson: goog.abstractMethod

  ###*
    Call this method after any change made on store to notify React component.
    @param {Object=} target Object invoked change. By default it's store itself.
  ###
  notify: (target = @) ->
    @dispatchEvent new goog.events.Event Store.EventType.CHANGE, target
