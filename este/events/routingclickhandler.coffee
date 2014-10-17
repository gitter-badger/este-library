goog.provide 'este.events.RoutingClickHandler'

goog.require 'este.dom'
goog.require 'goog.events.BrowserEvent'
goog.require 'goog.events.EventHandler'
goog.require 'goog.events.EventTarget'

class este.events.RoutingClickHandler extends goog.events.EventTarget

  ###*
    Click handler for client side routing. It handles only relevant anchors,
    check este.dom.isRoutingEvent. For fast click, check:
    https://plus.google.com/u/0/+RickByers/posts/ej7nsuoaaDa
    For iOS or pages where double tap for zoom is required, you have to use
    library like polymer-gestures and onCustomClick method.
    @param {Element=} element
    @constructor
    @extends {goog.events.EventTarget}
    @final
  ###
  constructor: (element) ->
    super()
    @element_ = element ? document.documentElement
    @eventHandler_ = new goog.events.EventHandler @
    @registerEvents_()

  ###*
    Set this attribute to true on anchor which uses custom click.
    @type {string}
  ###
  dataCustomClick: 'data-este-custom-click'

  ###*
    @type {Element}
    @private
  ###
  element_: null

  ###*
    @type {goog.events.EventHandler}
    @private
  ###
  eventHandler_: null

  ###*
    @private
  ###
  registerEvents_: ->
    # Click must be always listened to preventDefault redirection.
    @eventHandler_.listen @element_, 'click', @onElementClick_

  ###*
    Hook for polymer-gestures or similar "fast click" library.
    @param {Event} e
  ###
  onCustomClick: (e) ->
    googEvent = @googEventFrom e
    anchor = @tryGetRoutingAnchor googEvent
    return if !anchor
    @dispatchClick anchor

  ###*
    Mark element with data attribute to prevent double dispatching.
    @param {Element} element
  ###
  enableCustomClick: (element) ->
    element.setAttribute @dataCustomClick, 'true'

  ###*
    @param {Event} e
  ###
  googEventFrom: (e) ->
    googEvent = new goog.events.BrowserEvent e
    # Ensure type it's click, can override tap for example.
    googEvent.type = 'click'
    # Ensure it's mouse button.
    googEvent.isMouseActionButton = -> true
    googEvent

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementClick_: (e) ->
    anchor = @tryGetRoutingAnchor e
    return if !anchor
    # Always prevent redirection because changing url is router responsibility.
    e.preventDefault()
    # It seems sync dispatching/rendering confuses React somehow with error:
    # Invariant Violation: ReactMount: Two valid but unequal nodes with the same `data-reactid`:
    # e.stopPropagation() fixes it.
    e.stopPropagation()
    return if anchor.hasAttribute @dataCustomClick
    @dispatchClick anchor

  ###*
    @param {goog.events.BrowserEvent} e
    @return {Element}
    @protected
  ###
  tryGetRoutingAnchor: (e) ->
    return null if !este.dom.isRoutingEvent e
    anchor = goog.dom.getAncestorByTagNameAndClass e.target, goog.dom.TagName.A
    return null if !anchor || !este.dom.isRoutingAnchor anchor
    anchor

  ###*
    @param {Element} anchor
    @protected
  ###
  dispatchClick: (anchor) ->
    @dispatchEvent
      type: goog.events.EventType.CLICK
      target: anchor

  ###*
    @override
  ###
  disposeInternal: ->
    @eventHandler_.dispose()
    super()
    return
