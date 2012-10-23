{EventEmitter} = require('events')
fs = require('fs')
expat = require('node-expat')

class FileParse extends EventEmitter

  constructor: (@filepath) ->
    super()
    @errors = []
    @openElements = {}
    @parser = null

  run: ->
    @parser = @parser || expat.createParser()
    @parser.on 'error', (error) =>
      console.error 'Parsing error', error

    @parser.on 'startElement', (name, attrs) =>
      @openElements[name] = 0 unless @openElements[name]?
      @openElements[name]++

    @parser.on 'endElement', (name) =>
      @openElements[name]--

    @parser.on 'end', =>
      for element, count of @openElements
        if count > 0
          elementText = if count == 1 then 'element has' else 'elements have'
          console.log "#{@filepath}: #{count} '#{element}' #{elementText} not been closed."
    fileStream = fs.createReadStream(@filepath)
    fileStream.pipe(@parser)

exports.FileParse = FileParse
