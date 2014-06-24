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

    # Example of app.Routes constructor:
    #
    # @home = new este.Route '/'
    # @products = new este.Route '/products'
    # @productDetail = new este.Route '/product/:id'
    #
    # @list = [
    #   @home
    #   @products
    #   @productDetail
    # ]

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
    @param {este.Route} route
    @param {Object} params
  ###
  setActive: (route, params) ->
    @active = route
    route.params = params
    @dispatchEvent Routes.EventType.CHANGE

  ###*
    @param {este.Router} router
  ###
  addToEste: (router) ->
    @addTo_ (route) =>
      router.add route, (params) =>
        @setActive route, params
        return

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @addTo_ (route) =>
      expressRoute = app['route'] route.path
      expressRoute['get'] (req, res) =>
        @setActive route, req['params']
        onRequest.apply @, arguments
        return

  ###*
    @param {Function} addRoute
    @private
  ###
  addTo_: (addRoute) ->
    addRoute route for route in @list
    return