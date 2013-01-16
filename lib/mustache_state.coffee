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
    remainingLength = @currentString.length - @currentIndex
    parseLength = if remainingLength > @startDelimiter.length then @startDelimiter.length else remainingLength
    endIndex = currentIndex + parseLength
    delimiterIndex = 0
    for index in [currentIndex...endIndex]
      @currentIndex = index
      if @currentString[index] != @startDelimiter[delimiterIndex]
        return @reject()
      delimiterIndex += 1
    if @currentIndex + 1 != currentIndex + @startDelimiter.length
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
    @emit('reject', index: @currentIndex)

  accept: ->
    @isComplete = true
    @emit('accept', index: @currentIndex)

  initial: (input) ->
    if input == '#' || input == '^'
      @advanceState('section')
    else if input == '{' || input == '}'
      @reject()
    else
      @advanceState('tag')

  unknown: ->
    @emit('unknown', index: @currentIndex)

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
