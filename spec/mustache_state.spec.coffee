{MustacheState} = require('../lib/mustache_state.coffee')

describe 'MustacheState', ->
  state = null

  beforeEach ->
    state = new MustacheState

  describe 'process', ->

    it 'rejects if the passed in string is not a mustache tag or section', ->
      rejectIndex = null
      state.on 'reject', (index) ->
        rejectIndex = index
      state.process('{test}')
      expect(rejectIndex).toBe 1

    it 'emits an unknown event if the beginning of a tag is not complete', ->
      unknownFired = false
      state.on 'unknown', ->
        unknownFired = true
      state.process('{')
      expect(unknownFired).toBe true

    it 'emits an accept event when the string is a tag', ->
      acceptFired = false
      state.on 'accept', ->
        acceptFired = true
      state.process('{{test}}')
      expect(acceptFired).toBe true

    it 'emits an accept event when the string contains a tag', ->
      acceptFired = false
      state.on 'accept', ->
        acceptFired = true
      state.process('{{test}} some stuff')
      expect(acceptFired).toBe true

    it 'emits an accept event when the string contains a tag and is passed a currentIndex', ->
      acceptFired = false
      state.on 'accept', ->
        acceptFired = true
      state.process('ff to {{test}}', 6)
      expect(acceptFired).toBe true

    it 'emits an unknown event with the passed in string if not accepted or rejected', ->
      unknownFired = false
      state.on 'unknown', ->
        unknownFired = true
      state.process('{{test}')
      expect(unknownFired).toBe true

  describe 'isComplete', ->

    it 'returns true if the current data has been accepted or rejected', ->
      state.process('{{test}} some more')
      expect(state.isComplete).toBe true

    it 'returns false if the current state is unknown', ->
      state.process('{{test}')
      expect(state.isComplete).toBe false

  describe 'continue', ->

    it 'continues from the currentIndex with an extended string', ->
      acceptFired = false
      state.process('this is a {{test}', 10)
      expect(state.isComplete).toBe false
      state.currentString = 'this is a {{test}} right here'
      state.on 'accept', ->
        acceptFired = true
      state.continue()
      expect(acceptFired).toBe true

    it 'continues and rejects with an extended string', ->
      rejectFired = false
      state.process('this is a {{test}', 10)
      expect(state.isComplete).toBe false
      state.currentString = 'this is a {{test} right here'
      state.on 'reject', ->
        rejectFired = true
      state.continue()
      expect(rejectFired).toBe true
