{MustacheTransformer} = require '../lib/mustache_transformer.coffee'

describe 'MustacheTransformer', ->
  transformer = null
  data = ''

  beforeEach ->
    data = ''
    transformer = new MustacheTransformer
    transformer.on 'data', (newData) ->
      data = "#{data}#{newData}"

  it 'removes entire mustache tags', ->
    transformer.write('test {{tag}} here')
    transformer.end()
    expect(data).toEqual 'test  here'

  it 'only removes until the first ending curly braces', ->
    transformer.write('test {{tag}} here}}')
    transformer.end()
    expect(data).toEqual 'test  here}}'

  it 'removes on multiple calls', ->
    transformer.write('test {{tag}} here')
    transformer.write('and {{test}} tag {{here}}')
    transformer.end()
    expect(data).toEqual 'test  hereand  tag '

  it 'removes 3/4 tags on a chunk boundary', ->
    transformer.write('test {{that}')
    transformer.write('} this tag is {{removed}')
    transformer.write('}')
    transformer.end()
    expect(data).toEqual 'test  this tag is '

  it 'does not get hung up if there is nothing further to remove', ->
    transformer.write('test {{that}')
    transformer.write('this tag is removed')
    transformer.end()
    expect(data).toEqual 'test {{that}this tag is removed'

  it 'removes 1/2 tags on a chunk boundary', ->
    transformer.write('test {{that')
    transformer.write('}} this tag is removed')
    transformer.end()
    expect(data).toEqual 'test  this tag is removed'

  it 'does not get hung up if there is nothing further to remove with a 1/2 tag', ->
    transformer.write('test {{that')
    transformer.write('does not get hung up')
    transformer.write(' at all')
    transformer.end()
    expect(data).toEqual 'test {{thatdoes not get hung up at all'

  it 'removes 1/4 tags on a chunk boundary', ->
    transformer.write('test {')
    transformer.write('{that this}} tag is removed')
    transformer.end()
    expect(data).toEqual('test  tag is removed')

  it 'doesn\'t remove a non-mustache 3/4 tag', ->
    transformer.write('this tag {{here} should not be removed')
    transformer.end()
    expect(data).toEqual('this tag {{here} should not be removed')

  it 'doesn\'t remove a non-mustache 1/2 tag', ->
    transformer.write('this tag {{here shouldn\'t be removed either')
    transformer.end()
    expect(data).toEqual('this tag {{here shouldn\'t be removed either')

  it 'doesn\'t remove a non-mustache 1/4 tag', ->
    transformer.write('none of {these things are tags')
    transformer.end()
    expect(data).toEqual('none of {these things are tags')
