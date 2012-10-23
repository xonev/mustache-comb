{argv} = require('optimist')
{FileParse} = require('./file_parse')

file = argv._[0]
parse = new FileParse(file)
parse.run()
