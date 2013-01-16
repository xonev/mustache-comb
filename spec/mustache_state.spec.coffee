{MustacheState} = require('../lib/mustache_state.coffee')

describe 'MustacheState', ->
  state = null

  beforeEach ->
    state = new MustacheState

  describe 'process', ->

    it 'rejects if the passed in string is not a mustache tag or section', ->
      rejectIndex = null
      state.on 'reject', (rejectState) ->
        rejectIndex = rejectState.index
      state.process('{test}')
      expect(rejectIndex).toBe 1

    it 'emits an unknown event if the beginning of a tag is not complete', ->
      unknownFired = false
      state.on 'unknown', ->
        unknownFired = true
      state.process('{')
      expect(unknownFired).toBe true

    it 'emits an unknown event if there might be a tag starting at the end of the string', ->
      unknownFired = false
      state.on 'unknown', ->
        unknownFired = true
      state.process('this {', 5)
      expect(unknownFired).toBe true

    it 'emits an unknown event if everything but the close of a tag is present', ->
      unknownIndex = -1
      state.on 'unknown', (unknownState) ->
        unknownIndex = unknownState.index
      state.process('test {{that', 5)
      expect(unknownIndex).toBe(11)

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
      acceptIndex = -1
      state.process('this is a {{test}', 10)
      expect(state.isComplete).toBe false
      state.currentString = 'this is a {{test}} right {{here}'
      state.on 'accept', (acceptState) ->
        acceptFired = true
        acceptIndex = acceptState.index
      state.continue()
      expect(acceptFired).toBe true
      expect(acceptIndex).toBe 17

    it 'continues and rejects with an extended string', ->
      rejectFired = false
      state.process('this is a {{test}', 10)
      expect(state.isComplete).toBe false
      state.currentString = 'this is a {{test} right here'
      state.on 'reject', ->
        rejectFired = true
      state.continue()
      expect(rejectFired).toBe true

    it 'continues and accepts a tag that was only started', ->
      acceptIndex = -1
      state.process('this {', 5)
      expect(state.isComplete).toBe false
      state.currentString = 'this {{test}} tag'
      state.on 'accept', (acceptState) ->
        acceptIndex = acceptState.index
      state.continue()
      expect(acceptIndex).toBe 12
