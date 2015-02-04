fs = require "fs"
request = require "request"
url = require "url"
_ = require "underscore"
_.str = require "underscore.string"
async = require "async"
handlebars = require "handlebars"

log = () -> console.log.apply this, arguments

if process.argv.length < 4
  return log("Expected: npm run build-service <endpoint> <file.js>")

registerHelpers = (fns) ->
  candidateHelpers = _.filter(_.keys(fns), (fnName) -> _.isFunction fns[fnName])
  _.each(candidateHelpers, (fnName) ->
    handlebars.registerHelper(fnName, () ->
      args = Array.prototype.slice.call(arguments, 0).slice(0, -1);
      fns[fnName].apply(this, args);
    )
  )
registerHelpers(_.str)

getJson = (url, cb) -> request.get({url: url, json: true}, (err, res, result) -> cb(result))

getResources = (apiUrl, outputFile) ->
  getJson apiUrl.href, (resourceApis) ->
    resourceApis = _.filter resourceApis.apis
    , (apiResource) ->
      apiResource.path != "/"

    async.reduce(resourceApis
    , []
    , (memo, apiResource, cb) ->
      apiResourceUrl = url.parse "#{apiUrl.href}#{apiResource.path}"
      getJson apiResourceUrl.href, (apiResourceObject) ->
        _.each(apiResourceObject.apis, (resourceApis) ->
          _.each(_.filter(resourceApis.operations, (operation) -> operation.type != null)
          , (operation) ->

            model = apiResourceObject.models[operation.type]

            singleNestedResource = _.pick(model.properties, (property) -> property.format && property.format.indexOf('/') > -1)
            multipleNestedResource = _.pick(model.properties, (property) -> property.items)

            memo.push({
              type: _.str.camelize(apiResource.path.replace('/', ''))
              nickname: _.str.classify(operation.nickname)

              isQuery: operation.method == "GET" and _.all(operation.parameters, (parameter) -> parameter.paramType == 'query')
              isGet: operation.method == 'GET' and _.some(operation.parameters, (parameter) -> parameter.paramType == 'path')
              isPost: operation.method == 'POST'
              isDelete: operation.method == 'DELETE'
              isPut: operation.method == 'PUT'
              isPatch: operation.method == 'PATCH'

              swaggerPath: resourceApis.path
              angularPath: (resourceApis.path || '').replace(/\{(.+)\}/g, ":$1")

              singleNestedResource: singleNestedResource
              multipleNestedResource: multipleNestedResource
            })
          )
        )
        cb(null, memo)
    , (err, results) ->

      byNestedApiResource = _.groupBy(_.filter(results, (result) -> result.isGet), 'swaggerPath')

      _.each(results, (result, k) ->
        results[k].singleNestedResource =
          _.map(result.singleNestedResource, (vs, ks) ->
            format = vs.format.replace('{pk}', '{id}')
            nested =  byNestedApiResource[format][0]
            {
              name: ks
              type: nested.type
              nickname: nested.nickname
            }
          )

        results[k].multipleNestedResource =
          _.map(result.multipleNestedResource, (vm, ks) ->
            format = vm.items.format.replace('{pk}', '{id}')
            nested =  byNestedApiResource[format][0]
            {
              name: ks
              type: nested.type
              nickname: nested.nickname
            }
          )
      )

      byApiResources = _.groupBy(results, 'type')

      data = {
        angularProviderType: "service"
        angularProviderSuffix: "ResourceService"
        apiUrl: "http://#{apiUrl.host}"
        apiTypes: _.keys(byApiResources)
        apiResources: byApiResources
        apiNestedResources: byNestedApiResource
      }

      tpl = fs.readFileSync("src/templates/swagged-resources.hbs", {encoding: "utf-8"})
      code = handlebars.compile(tpl)(data)
      fs.writeFileSync(outputFile, code, {flags: "w+"})
    )

apiUrl = url.parse process.argv[2]
outputFile = process.argv[3]

getResources apiUrl, outputFile
