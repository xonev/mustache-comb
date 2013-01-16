Stream = require('stream')
{MustacheState} = require('./mustache_state.coffee')

class MustacheTransformer extends Stream
  writableStream: null

  currentData: ''
  currentIndex: 0
  writable: true
  readable: true
  mustacheStateStack: []

  write: (data) ->
    @filterData("#{@currentData}#{data}")
    if @mustacheStateStack.length == 0
      @flushData(@currentData)

  end: ->
    if @currentData
      @flushData(@currentData)
    if @writableStream
      @writableStream.end()

  flushData: (data) ->
    @emit('data', data)
    @currentIndex = 0
    @currentData = ''

  pipe: (stream) ->
    @writableStream = stream
    super

  filterData: (data) ->
    @currentData = data
    console.log(@currentIndex)
    if @mustacheStateStack.length > 0
      state = @mustacheStateStack.pop()
      state.currentString = data
      state.continue(@currentIndex)
    else
      for i in [@currentIndex...data.length]
        @currentIndex = i
        if data[i] == '{'
          @startIndex = i
          mustacheState = new MustacheState
          mustacheState.on 'accept', (acceptState) =>
            @currentData = [@currentData.slice(0, @startIndex), @currentData.slice(acceptState.index + 1)].join('')
            @currentIndex = @startIndex
            @filterData(@currentData)
          mustacheState.on 'reject', (rejectState) =>
            @currentIndex = rejectState.index + 1
            @filterData(@currentData)
          mustacheState.on 'unknown', (unknownState) =>
            @currentIndex = unknownState.index
            @mustacheStateStack.push(mustacheState)
          mustacheState.process(data, @currentIndex)
          break

exports.MustacheTransformer = MustacheTransformer
