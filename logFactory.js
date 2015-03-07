void function () {

var p = function prefix (str) {
  return 'logFactory_' + str
}

angular.module('Falcon')

// .value(p('whiteList'), /.*/)
.value(p('whiteList'), /!|.*Ctrl|run/)
.value(p('piercingMethods'), {warn:true, error:true})

.factory(p('localStorage'), function ($window) {
  return $window.localStorage
})
.factory(p('console'), ['$window', '$log', function ($window, $log) {
  return $window.console || $log
}])

.factory('logFactory',
['console', 'whiteList' , 'piercingMethods', 'localStorage'].map(p).concat([
function (console, whiteList, piercing, localStorage) {
  piercing = piercing || {}
  whiteList = new RegExp(null
    || localStorage.logFactory_whiteList
    || whiteList
    || /.*/
  )

  return function (prefix, parentLog) {
    var log = parentLog || console
    var match = prefix.match(whiteList)

    function e(fnName) {
      if (!log[fnName]) {
        fnName = 'log'
      }

      return (piercing[fnName] || match)
        // ? log[fnName].bind(log, '[' + prefix + ']')
        ? angular.bind(log, log[fnName], '[' + prefix + ']')
        : angular.noop
    }

    var vehicle = e('log')

    vehicle.log = e('log')
    vehicle.info = e('info')
    vehicle.warn = e('warn')
    vehicle.error = e('error')
    vehicle.debug = e('debug')

    return vehicle
  }
}]))

}()

