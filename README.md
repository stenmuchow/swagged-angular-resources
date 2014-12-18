swagged-angular-resource
========================
AngularJS $resource service generator for Swagger documentated endpoints.


*Building to .bin directory*
```bash
$ npm install && gulp
```
*Usage*
```bash
node .bin/swagged-angular-resource <endpoint> <filename.js>
```
* endpoint (ie. 'http:/localhost:8000/docs/api-docs')
* filename.js is output filename for generated AmgularJS file (relative to npm current working directory) 

*TODO*
* Make .bin/swagged-angular-resource.js executable for global execution
