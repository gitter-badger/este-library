suite 'este.Routes', ->

  Routes = este.Routes
  routes = null

  setup ->
    routes = new Routes

  suite 'route', ->
    test 'should create este.Route from path and add route to list', ->
      route = routes.route '/'
      assert.instanceOf route, este.Route
      assert.equal routes.list[0], route

  suite 'isApiPath', ->
    test 'should ensure routes with api path will not be added to list', ->
      route = routes.route '/api/foo'
      assert.instanceOf route, este.Route
      assert.equal routes.list.length, 0

  suite 'routes', ->
    test 'should create prefixed routes', ->
      api = routes.routes '/api',
        error: '/error'
        songs: routes.routes '/songs',
          recentlyUpdated: '/recently-updated'
      assert.instanceOf api.error, este.Route
      assert.equal api.error.path, '/api/error'
      assert.instanceOf api.songs.recentlyUpdated, este.Route
      assert.equal api.songs.recentlyUpdated.path, '/api/songs/recently-updated'
      assert.equal routes.list.length, 0

  suite 'setActive', ->
    test 'should assign params to route and make it active', ->
      route = new este.Route '/'
      params = {}
      routes.setActive route, params
      assert.equal route.params, params
      assert.equal routes.active, route

  suite 'trySetErrorRoute', ->
    test 'should set notFound as active for 404', ->
      routes.trySetErrorRoute 404
      assert.equal routes.active, routes.notFound

    test 'should rethrow unknown reason for anything else', (done) ->
      reason = {}
      try
        routes.trySetErrorRoute reason
      catch e
        assert.equal e, reason
        done()
