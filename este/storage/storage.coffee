goog.provide 'este.Storage'

goog.require 'goog.Promise'
goog.require 'goog.net.HttpStatus'

class este.Storage

  ###*
    For isomorphic apps, storage is responsible for store data persistence.
    @constructor
  ###
  constructor: ->

  ###*
    @protected
  ###
  ok: ->
    goog.Promise.resolve goog.net.HttpStatus.OK

  ###*
    @protected
  ###
  notFound: ->
    goog.Promise.reject goog.net.HttpStatus.NOT_FOUND
