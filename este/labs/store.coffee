goog.provide 'este.labs.Store'

goog.require 'goog.array'
goog.require 'goog.asserts'
goog.require 'goog.events.Event'
goog.require 'goog.events.EventTarget'

class este.labs.Store extends goog.events.EventTarget

  ###*
    Store holds application state and provides methods to manipulate with it.
    Store can orchestrate change of one or more app models. Store can even
    orchestrate other stores. React component read data from store and propagate
    actions on it. Store itself can update model immediately or use events or
    Flux dispatcher or even communicating sequential processes. It's up to
    developer to choose right implementation with only small overengineering.
    After update it's up to developer to call notify method, which dispatches
    change events for listening React component. React component should rerender
    itself when store is changed. Change event can be also used for syncing with
    server. Stores are initialy fulfiled by client and server storages. The
    pattern is simple. Storage load method fetches data from source by passed
    route and params. If successful, concrete store is updated.
    @param {string} name
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (name) ->
    super()

    ###*
      Name is used for localStorage persistence for example.
      @const
      @type {string}
    ###
    @name = name

  ###*
    @return {Object}
  ###
  toJson: goog.abstractMethod

  ###*
    @param {Object} json
  ###
  fromJson: goog.abstractMethod

  ###*
    Helper method to create instance fulfiled with provided json.
    @param {function(new:T)} constructor
    @param {Object=} json
    @return {?} I don't know how to annotate this properly.
    @template T
  ###
  instanceFromJson: (constructor, json) ->
    # Example for one instance:
    # @newSong = @instanceFromJson app.songs.Song, songJson
    if arguments.length == 2
      instance = new constructor
      goog.mixin instance, json || {}
      return instance
    # Example for array map:
    # @songs = (@asArray(json.songs) || []).map @instanceFromJson app.songs.Song
    (json) =>
      @instanceFromJson constructor, json

  ###*
    Call this method after any change you made on store.
    @param {Object=} target Which object invoked change. By default, it's store.
  ###
  notify: (target = @) ->
    @dispatchEvent new goog.events.Event 'change', target

  ###*
    Transform array to object where key is item id.
    PATTERN(steida): Never use array if you need concurrent access to its items.
    On the contrary, use array for items without id's, where array is always
    overriden with new version.
    https://www.firebase.com/docs/web/guide/saving-data.html#section-push
    @param {Array} array
    @return {Object}
  ###
  asObject: (array) ->
    goog.asserts.assertArray array
    object = {}
    for item in array
      goog.asserts.assertString item.id
      object[item.id] = item
    object

  ###*
    Transform object to array.
    https://www.firebase.com/docs/web/guide/saving-data.html#section-push
    @param {Object} object
    @return {Array}
  ###
  asArray: (object) ->
    goog.asserts.assertObject object
    for key, value of object
      goog.asserts.assertString value.id
      value
