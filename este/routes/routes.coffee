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
    # @home = new este.Route '/', 'Home'
    # @listOfProducts = new este.Route '/products', 'Products'
    #
    # @list = [
    #   @home
    #   @listOfProducts
    # ]

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    @type {este.Route}
    @private
  ###
  active_: null

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
    @active_ = route
    route.params = params
    @dispatchEvent Routes.EventType.CHANGE

  ###*
    @return {este.Route}
  ###
  getActive: ->
    @active_

  ###*
    @param {este.Router} router
  ###
  addToEste: (router) ->
    @addTo (route) =>
      router.add route, (params) =>
        @setActive route, params
        return

  ###*
    @param {Object} app Express.js app.
    @param {Function} onRequest
  ###
  addToExpress: (app, onRequest) ->
    @addTo (route) =>
      expressRoute = app['route'] route.path
      expressRoute['get'] (req, res) =>
        @setActive route, req['params']
        onRequest.apply @, arguments
        return

  ###*
    @param {Function} addRoute
    @private
  ###
  addTo: (addRoute) ->
    addRoute route for route in @list
    return