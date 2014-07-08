###*
  @fileoverview Compile-time save app routes. Auto registration for
  este.Router and Express.js app.
###

goog.provide 'este.Routes'
goog.provide 'este.Routes.EventType'

goog.require 'este.Route'
goog.require 'este.labs.storage.Base'
goog.require 'goog.Promise'
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
  storage: null

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
        @onRouteMatch route

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @forEachRouteInList (route) =>
      expressRoute = app['route'] route.path
      # TODO(steida): Handle promise error.
      expressRoute['get'] (req, res) =>
        route.params = req['params']
        @onRouteMatch route
          .then -> onRequest req, res
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
  onRouteMatch: (route) ->
    maybePromise = @storage?.load route, @
    if @isPromise maybePromise
      maybePromise.then =>
        @trySetActive route
        return
    else
      @trySetActive route
      goog.Promise.resolve()

  ###*
    TODO(steida): Move into own place.
    @return {boolean}
  ###
  isPromise: (maybePromise) ->
    # Detect Closure promise.
    maybePromise instanceof goog.Promise ||
    # Detect third-party promise.
    goog.isFunction maybePromise?['then']

  ###*
    @param {este.Route} route
    @protected
  ###
  trySetActive: (route) ->
    previous = @active
    @active = route
    try
      # NOTE(steida): Measure performance impact of firing events in Node.js
      @dispatchEvent Routes.EventType.CHANGE
    catch e
      @active = previous
      throw e
    return

  ###*
    @param {string} path
    @return {este.Route}
    @protected
  ###
  route: (path) ->
    route = new este.Route path
    @list.push route
    route