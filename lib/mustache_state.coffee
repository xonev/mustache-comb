{EventEmitter} = require('events')
class MustacheState extends EventEmitter
  constructor: (options = {}) ->
    @startDelimiter = options.startDelimiter || '{{'
    @endDelimiter = options.endDelimiter || '}}'
    @currentIndex = 0
    @currentString = ''
    @isComplete = false
    @lastState = null

  process: (string, currentIndex = 0) ->
    @currentString = string
    @currentIndex = currentIndex
    @lastState = null
    parseLength = if @currentString.length - @currentIndex > @startDelimiter.length then @startDelimiter.length else @currentString.length
    endIndex = currentIndex + parseLength
    delimiterIndex = 0
    for index in [currentIndex...endIndex]
      @currentIndex = index
      if @currentString[index] != @startDelimiter[delimiterIndex]
        return @reject()
      delimiterIndex += 1
    if @currentIndex + 1 != currentIndex + @startDelimiter.length
      @currentIndex = currentIndex
      @unknown()
    else
      @advanceState('initial')

  continue: (fromIndex) ->
    @currentIndex = fromIndex || @currentIndex
    if @lastState != null
      @continueState(@lastState)
    else
      @process(@currentString, @currentIndex)

  advanceState: (state) ->
    @lastState = state
    @currentIndex += 1
    @continueState(state)

  continueState: (state) ->
    if @currentIndex < @currentString.length
      this[state](@currentString[@currentIndex])
    else
      @unknown()

  reject: ->
    @isComplete = true
    @emit('reject', @currentIndex)

  accept: ->
    @isComplete = true
    @emit('accept', @currentIndex)

  initial: (input) ->
    if input == '#' || input == '^'
      @advanceState('section')
    else if input == '{' || input == '}'
      @reject()
    else
      @advanceState('tag')

  unknown: ->
    @emit('unknown')

  tag: (input) ->
    if input != '}' && input != '{'
      @advanceState('tag')
    else if input == '{'
      @reject()
    else
      @advanceState('endTag')

  endTag: (input) ->
    if input == '}'
      @accept()
    else
      @reject()

exports.MustacheState = MustacheState
