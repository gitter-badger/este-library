###*
  @fileoverview Compile-time save app routes. Auto registration for
  este.Router and Express.js app.
  PATTERN(steida): Is much better to deal with app route represented as
  instance then as string. Not only code is static safe, but instance also
  provides convenient methods like redirect or createUrl.
###

goog.provide 'este.Routes'
goog.provide 'este.Routes.EventType'

goog.require 'este.Route'
goog.require 'este.labs.Storage'
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
    Storage is optional and super useful. When defined, it allows us to prefetch
    stores inside storage or do async routing. Matched route calls storage.load
    method like this: var promise = storage.load(requestedRoute, routes);
    Active route is set only when storage.load returns resolved promise.
    Promise can be rejected inside storage or este.Router.
    @type {este.labs.Storage}
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
        @onRouteMatch route, params

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @forEachRouteInList (route) =>
      expressRoute = app['route'] route.path
      # TODO(steida): Handle promise error.
      expressRoute['get'] (req, res) =>
        @onRouteMatch route, req['params']
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
    TODO(steida): Add return goog.Promise or promise-like objects.
    @param {este.Route} route
    @param {Object} params
    @protected
  ###
  onRouteMatch: (route, params) ->
    promise = @loadFromStorage route, params
    if !promise
      @trySetActive route, params
      return goog.Promise.resolve()

    promise.then =>
      @trySetActive route, params
      return

  ###*
    @param {este.Route} route
    @param {Object} params
    @return {*}
    @protected
  ###
  loadFromStorage: (route, params) ->
    return null if !@storage
    promise = @storage.load route, params, @
    return null if !@isPromise promise
    promise

  ###*
    @param {*} promise
    @return {boolean}
    @protected
  ###
  isPromise: (promise) ->
    # Detect Closure promise.
    promise instanceof goog.Promise ||
    # Detect third-party promise.
    goog.isFunction promise?['then']

  ###*
    @param {este.Route} route
    @param {Object} params
    @protected
  ###
  trySetActive: (route, params) ->
    # TODO(steida): Reconsider again this try-set-active pattern.
    # previous = @active
    route.params = params
    @active = route
    # try
    @dispatchEvent Routes.EventType.CHANGE
    # catch e
    #   @active = previous
    #   throw e
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
