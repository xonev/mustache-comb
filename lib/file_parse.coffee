{EventEmitter} = require('events')
{MustacheTransformer} = require('./mustache_transformer')
fs = require('fs')
sax = require('sax')

class FileParse extends EventEmitter

  constructor: (@filepath) ->
    super()
    @errors = []
    @openElements = {}
    @parser = null
    @transformer = new MustacheTransformer

  run: ->
    @parser = @parser || sax.createStream(true)
    @parser.on 'error', (error) =>
      errorObj = @parseError(error.message)
      console.log "#{@filepath}:#{errorObj.line}: Parsing error: #{errorObj.message}"

    @parser.on 'opentag', (tag) =>
      name = tag.name
      @openElements[name] = 0 unless @openElements[name]?
      @openElements[name]++

    @parser.on 'closetag', (name) =>
      @openElements[name]--

    @parser.on 'end', =>
      for element, count of @openElements
        if count > 0
          elementText = if count == 1 then 'element has' else 'elements have'
          console.log "#{@filepath}: #{count} '#{element}' #{elementText} not been closed."
    fileStream = fs.createReadStream(@filepath)
    fileStream.pipe(@transformer).pipe(@parser)

  parseError: (error) ->
    matches = error.match(/^([^\n]*)\nLine: (\d+)\n/)
    newError =
      message: ''
      line: null
    if matches
      newError.message = matches[1]
      newError.line = matches[2]
    newError


exports.FileParse = FileParse
