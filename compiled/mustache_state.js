// Generated by CoffeeScript 1.3.3
(function() {
  var EventEmitter, MustacheState,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  MustacheState = (function(_super) {

    __extends(MustacheState, _super);

    function MustacheState(options) {
      if (options == null) {
        options = {};
      }
      this.startDelimiter = options.startDelimiter || '{{';
      this.endDelimiter = options.endDelimiter || '}}';
      this.currentIndex = 0;
      this.currentString = '';
      this.isComplete = false;
      this.lastState = null;
    }

    MustacheState.prototype.process = function(string, currentIndex) {
      var delimiterIndex, endIndex, index, parseLength, remainingLength, _i;
      if (currentIndex == null) {
        currentIndex = 0;
      }
      this.currentString = string;
      this.currentIndex = currentIndex;
      this.lastState = null;
      remainingLength = this.currentString.length - this.currentIndex;
      parseLength = remainingLength > this.startDelimiter.length ? this.startDelimiter.length : remainingLength;
      endIndex = currentIndex + parseLength;
      delimiterIndex = 0;
      for (index = _i = currentIndex; currentIndex <= endIndex ? _i < endIndex : _i > endIndex; index = currentIndex <= endIndex ? ++_i : --_i) {
        this.currentIndex = index;
        if (this.currentString[index] !== this.startDelimiter[delimiterIndex]) {
          return this.reject();
        }
        delimiterIndex += 1;
      }
      if (this.currentIndex + 1 !== currentIndex + this.startDelimiter.length) {
        return this.unknown();
      } else {
        return this.advanceState('initial');
      }
    };

    MustacheState.prototype["continue"] = function(fromIndex) {
      this.currentIndex = fromIndex || this.currentIndex;
      if (this.lastState !== null) {
        return this.continueState(this.lastState);
      } else {
        return this.process(this.currentString, this.currentIndex);
      }
    };

    MustacheState.prototype.advanceState = function(state) {
      this.lastState = state;
      this.currentIndex += 1;
      return this.continueState(state);
    };

    MustacheState.prototype.continueState = function(state) {
      if (this.currentIndex < this.currentString.length) {
        return this[state](this.currentString[this.currentIndex]);
      } else {
        return this.unknown();
      }
    };

    MustacheState.prototype.reject = function() {
      this.isComplete = true;
      return this.emit('reject', {
        index: this.currentIndex
      });
    };

    MustacheState.prototype.accept = function() {
      this.isComplete = true;
      return this.emit('accept', {
        index: this.currentIndex
      });
    };

    MustacheState.prototype.initial = function(input) {
      if (input === '#' || input === '^') {
        return this.advanceState('tag');
      } else if (input === '{' || input === '}') {
        return this.reject();
      } else {
        return this.advanceState('tag');
      }
    };

    MustacheState.prototype.unknown = function() {
      return this.emit('unknown', {
        index: this.currentIndex
      });
    };

    MustacheState.prototype.tag = function(input) {
      if (input !== '}' && input !== '{') {
        return this.advanceState('tag');
      } else if (input === '{') {
        return this.reject();
      } else {
        return this.advanceState('endTag');
      }
    };

    MustacheState.prototype.endTag = function(input) {
      if (input === '}') {
        return this.accept();
      } else {
        return this.reject();
      }
    };

    return MustacheState;

  })(EventEmitter);

  exports.MustacheState = MustacheState;

}).call(this);
