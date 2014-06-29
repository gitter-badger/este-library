###*
  @fileoverview Compile-time save app routes. Auto registration for
  este.Router and Express.js app.
###

goog.provide 'este.Routes'
goog.provide 'este.Routes.EventType'

goog.require 'este.Route'
goog.require 'este.labs.storage.Base'
goog.require 'goog.events.EventTarget'

class este.Routes extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()
    @list = []

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    @type {este.Route}
  ###
  active: null

  ###*
    @type {este.labs.storage.Base}
    @protected
  ###
  storage: new este.labs.storage.Base

  ###*
    @type {Array.<este.Route>}
    @protected
  ###
  list: null

  ###*
    @param {este.Router} router
  ###
  addToEste: (router) ->
    @forEachRouteInList (route) =>
      router.add route, (params) =>
        route.params = params
        @storage.load(route, @).then =>
          @setActive route

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @forEachRouteInList (route) =>
      expressRoute = app['route'] route.path
      expressRoute['get'] (req, res) =>
        route.params = req['params']
        @storage.load(route, @).then =>
          @setActive route
          onRequest req, res
        return

  ###*
    @param {Function} fn
    @protected
  ###
  forEachRouteInList: (fn) ->
    fn route for route in @list
    return

  ###*
    @param {este.Route} route
    @protected
  ###
  setActive: (route) ->
    @active = route
    @dispatchEvent Routes.EventType.CHANGE

  ###*
    @param {string} path
    @return {este.Route}
    @protected
  ###
  route: (path) ->
    route = new este.Route path
    @list.push route
    route