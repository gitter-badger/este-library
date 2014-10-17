suite 'este.Store', ->

  Store = este.Store
  store = null

  setup ->
    store = new Store

  suite 'name', ->
    test 'should be an empty string', ->
      assert.equal store.name, ''

  suite 'toJson', ->
    test 'should throw error because method is abstract', ->
      assert.throw store.toJson

  suite 'fromJson', ->
    test 'should throw error because method is abstract', ->
      assert.throw store.fromJson

  suite 'notify', ->
    test 'should dispatch change event with right target', (done) ->
      store.listen 'change', (e) ->
        assert.equal e.target, store
        done()
      store.notify()

    test 'should dispatch change event with custom target', (done) ->
      target = {}
      store.listen 'change', (e) ->
        assert.equal e.target, target
        done()
      store.notify target
