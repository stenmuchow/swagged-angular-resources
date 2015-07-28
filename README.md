swagged-angular-resource
========================
AngularJS $resource service generator for Swagger documentated endpoints.


*Building to .bin directory*
```bash
$ npm install
$ npm install uglify-js -g
```
*Usage*
```bash
node .bin/swagged-angular-resource <endpoint> <filename.js>
```
* endpoint (ie. 'http:/localhost:8000/docs/api-docs')
* filename.js is output filename for generated AngularJS file (relative to npm current working directory) 

or

```bash
$ npm run build
$ npm run pretty
```

We end up with a lot of unneeded code duplication in the original file, so we fire an uglify --compress task over it which will remove unused variables. 

If we want to keep an uncompressed version of the file as well run the pretty task, this will fire the build task and then uglify --beautify task which will make it pretty again. 