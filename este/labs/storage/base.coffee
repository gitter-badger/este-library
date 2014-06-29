goog.provide 'este.labs.storage.Base'

goog.require 'goog.Promise'
goog.require 'goog.events.EventTarget'

class este.labs.storage.Base extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()

  ###*
    @param {este.Route} route
    @param {este.Routes} routes
    @return {!goog.Promise}
  ###
  load: (route, routes) ->
    goog.Promise.resolve()