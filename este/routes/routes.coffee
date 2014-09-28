goog.provide 'este.Routes'

goog.require 'este.Route'
goog.require 'goog.array'
goog.require 'goog.asserts'
goog.require 'goog.net.HttpStatus'
goog.require 'goog.object'
goog.require 'goog.string'

class este.Routes

  ###*
    App routes definition with auto-registration to este.Router and expressjs.
    @constructor
  ###
  constructor: ->
    # Define routes here. Example:
    # @home = @route '/'
    # @api = @routes '/api',
    #   home: '/:id'

  ###*
    Placeholder for route you always need.
    @type {este.Route}
  ###
  notFound: new este.Route

  ###*
    @type {este.Route}
  ###
  active: null

  ###*
    List of routes to be registered in este.Router or expressjs.
    @type {Array.<este.Route>}
    @protected
  ###
  list: null

  ###*
    Create and register route in one step.
    @param {string} path
    @return {este.Route}
    @protected
  ###
  route: (path) ->
    @list ?= []
    route = new este.Route path
    if !@isApiPath path
      @list.push route
    route

  ###*
    @param {string} path
    @return {boolean}
    @protected
  ###
  isApiPath: (path) ->
    goog.string.startsWith path, '/api'

  ###*
    Create and register many nested routes with path prefix in one step.
    @param {string} pathPrefix
    @param {Object.<string, (string|Object)>} routes Object for another routes.
    @return {Object}
    @protected
  ###
  routes: (pathPrefix, routes) ->
    goog.object.map routes, (value, key) =>
      switch goog.typeOf value
        when 'string'
          @route pathPrefix + value
        when 'object'
          goog.object.map value, (route, key) =>
            goog.asserts.assertInstanceof route, este.Route
            goog.array.remove @list, route
            @route pathPrefix + route.path
        else
          goog.asserts.fail 'Value has to be string or object.'

  ###*
    It's up your app to set active route.
    @param {este.Route} route
    @param {Object} params
  ###
  setActive: (route, params) ->
    route.params = params
    @active = route

  ###*
    You can override this method and add error route for any reason.
    @param {*} reason
  ###
  trySetErrorRoute: (reason) ->
    switch reason
      when goog.net.HttpStatus.NOT_FOUND
        @setActive @notFound, null
      # Rethrow unknown reason.
      else throw reason

  ###*
    Register routes on este.Router.
    @param {este.Router} router
    @param {function(este.Route, Object): (goog.Promise|undefined)} onRouteMatch
  ###
  addToEste: (router, onRouteMatch) ->
    @list.forEach (route) ->
      router.add route, (params) ->
        # este.Router can use promise for async routing and pending navigation.
        onRouteMatch route, params
    @handleEsteRouter404_ router, onRouteMatch

  ###*
    @private
  ###
  handleEsteRouter404_: (router, onRouteMatch) ->
    router.add '*', (params) =>
      onRouteMatch @notFound, params
      return

  ###*
    Register routes on expressjs.
    @param {Object} app Express instance.
    @param {function(este.Route, Object, Object)} onRouteMatch
  ###
  addToExpress: (app, onRouteMatch) ->
    @list.forEach (route) ->
      app['route'](route.path)['get'] (req, res) ->
        onRouteMatch route, req, res
        return
    @handleExpressApp404_ app, onRouteMatch

  ###*
    @private
  ###
  handleExpressApp404_: (app, onRouteMatch) ->
    app['use'] (req, res) =>
      onRouteMatch @notFound, req, res
