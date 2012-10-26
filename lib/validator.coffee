{argv} = require('optimist')
{Glob} = require('glob')
{FileParse} = require('./file_parse')

fileglobs = argv._
for fileglob in fileglobs
  glob = new Glob(fileglob, strict: true)
  glob.on 'match', (match) ->
    parse = new FileParse(match)
    parse.run()
