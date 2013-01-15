Stream = require('stream')

class MustacheTransformer extends Stream
  writableStream: null

  currentData: ''
  currentIndex: 0
  writable: true
  readable: true

  write: (data) ->
    data = @filterData("#{@currentData}#{data.toString()}")
    if !@possibleMatchOnBoundary(data)
      @currentData = ''
      @flushData(data)
    else
      @currentData = data
    true

  end: ->
    if @currentData
      @flushData(@currentData)
    if @writableStream
      @writableStream.end()

  flushData: (data) ->
    @emit('data', data)

  pipe: (stream) ->
    @writableStream = stream
    super

  filterData: (data) ->
    data.replace(@tagRegex, '')

  possibleMatchOnBoundary: (data) ->
    if data.match(@incompleteEndTagRegex)
      true
    else if data.match(@openBraceRegex)
      true
    else
      false

exports.MustacheTransformer = MustacheTransformer
