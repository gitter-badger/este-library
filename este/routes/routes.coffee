###*
  @fileoverview Use this class to define compile time safe routes and list
  for este.Router and Express.js app.
###

goog.provide 'este.Routes'
goog.provide 'este.Routes.EventType'

goog.require 'este.Route'
goog.require 'goog.events.EventTarget'

class este.Routes extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()
    @list = []
    # Example:
    # @home = @route '/'
    # @products = @route '/products'
    # @product = @route '/product/:id'

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
        @setActive route, params
        return

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @forEachRouteInList (route) =>
      expressRoute = app['route'] route.path
      expressRoute['get'] (req, res) =>
        @setActive route, req['params']
        onRequest.apply @, arguments
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
    @param {Object} params
    @protected
  ###
  setActive: (route, params) ->
    @active = route
    route.params = params
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