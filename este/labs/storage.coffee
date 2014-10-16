goog.provide 'este.labs.Storage'

goog.require 'goog.Promise'
goog.require 'goog.net.HttpStatus'

class este.labs.Storage

  ###*
    @constructor
    @deprecated
  ###
  constructor: ->

  ###*
    Helper for sync storage load method.
    @protected
  ###
  ok: ->
    goog.Promise.resolve goog.net.HttpStatus.OK

  ###*
    Helper for sync storage load method.
    @protected
  ###
  notFound: ->
    goog.Promise.reject goog.net.HttpStatus.NOT_FOUND
