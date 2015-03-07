describe 'logFactory', ->
  Given -> @consoleSpy = jasmine.createSpy('consoleSpy')
  Given -> mod logFactory_console: => log: @consoleSpy
  Given -> mod logFactory_whiteList: => /.*/
  When  inject (@logFactory) ->

  describe 'core', ->
    When  -> @console = @logFactory('Scope')
    Then  ->
      @console.log('Message1')
      expect(@consoleSpy).toHaveBeenCalledWith('[Scope]', 'Message1')
    Then  ->
      @console.log('Message2')
      expect(@consoleSpy).toHaveBeenCalledWith('[Scope]', 'Message2')

    describe 'sub-console', ->
      When  -> @console2 = @logFactory('SubScope', @console)
      Then  ->
        @console2.log('Message')
        expect(@consoleSpy).toHaveBeenCalledWith('[Scope]', '[SubScope]', 'Message')

  describe 'filtering', ->
    Given -> mod logFactory_whiteList: => /a/
    Then  ->
      @logFactory('a').log('Message A')
      @logFactory('b').log('Message B')
      expect(@consoleSpy).toHaveBeenCalledWith('[a]', 'Message A')
      expect(@consoleSpy).not.toHaveBeenCalledWith('[b]', 'Message B')

  describe 'piercing', ->
    Given -> @consoleErrorSpy = jasmine.createSpy('consoleErrorSpy')
    Given -> mod logFactory_whiteList: => /a/
    Given -> mod logFactory_console: (noop) => error: @consoleErrorSpy, log: noop

    describe 'errors should pirece through, even if non-whitelisted', ->
      When  -> @logFactory('b').error('Message B')
      Then  -> expect(@consoleErrorSpy).toHaveBeenCalledWith('[b]', 'Message B')

    describe 'errors should pirece through, especially if whitelisted', ->
      When  -> @logFactory('a').error('Message A')
      Then  -> expect(@consoleErrorSpy).toHaveBeenCalledWith('[a]', 'Message A')

  describe 'shorthand', ->
    When  -> @console = @logFactory('Scope')
    Then  ->
      @console('Message1')
      expect(@consoleSpy).toHaveBeenCalledWith('[Scope]', 'Message1')

  describe 'strategies', ->
    assert = ->
      Then  -> expect(@consoleSpy).toHaveBeenCalledWith '[a]', 'a1'
      And   -> expect(@consoleSpy).toHaveBeenCalledWith '[a]', '[b]', 'b1'
      And   -> expect(@consoleSpy).toHaveBeenCalledWith '[a]', 'a2'

    describe 'self-invoking', ->
      When  ->
        logFactory = @logFactory
        `
        var console = logFactory('a')

        b = function() { (function(parentConsole) {
         var console = logFactory('b', parentConsole)
         console.log('b1')
        })(console) }

        console.log('a1')
        b()
        console.log('a2')
        `
        return

      assert()

    describe 'binding to this', ->
      When  ->
        logFactory = @logFactory
        `
        var console = logFactory('a')

        b = function() {
         var console = logFactory('b', this.parentConsole)
         console.log('b1')
        }.bind({parentConsole: console})

        console.log('a1')
        b()
        console.log('a2')
        `
        return

      assert()
