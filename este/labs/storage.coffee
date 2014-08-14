goog.provide 'este.labs.Storage'

goog.require 'goog.Promise'
goog.require 'goog.events.EventTarget'

class este.labs.Storage extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()

  ###*
    @param {este.Route} route
    @param {Object} params
    @param {este.Routes} routes
    @return {*}
  ###
  load: goog.abstractMethod

  ###*
    PATTERN(steida): Whenever store changes anything, just call notify to
    dispatch change event.
    @protected
  ###
  notify: ->
    @dispatchEvent 'change'
