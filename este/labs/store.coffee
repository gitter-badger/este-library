goog.provide 'este.labs.Store'
goog.provide 'este.labs.Store.Event'

goog.require 'goog.array'
goog.require 'goog.events.EventTarget'

class este.labs.Store extends goog.events.EventTarget

  ###*
    @param {string} name
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (name) ->
    super()

    ###*
      @const
      @type {string}
    ###
    @name = name

  ###*
    @return {Object}
  ###
  toJson: goog.abstractMethod

  ###*
    @param {Object} json
  ###
  fromJson: goog.abstractMethod

  ###*
    Helper method to create instance filled by json.
    @param {function(new:T)} constructor
    @param {Object=} json
    @return {T}
    @template T
  ###
  instanceFromJson: (constructor, json) ->
    if arguments.length == 2
      instance = new constructor
      goog.mixin instance, json || {}
      return instance
    (json) =>
      @instanceFromJson constructor, json

  ###*
    PATTERN(steida): Whenever store changes anything, just call notify to
    dispatch change event.
  ###
  notify: ->
    @dispatchEvent new este.labs.Store.Event

class este.labs.Store.Event extends goog.events.Event

  ###*
    @constructor
    @extends {goog.events.Event}
    @final
  ###
  constructor: ->
    super 'change'