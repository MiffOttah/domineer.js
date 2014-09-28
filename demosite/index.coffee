fs = require 'fs'

app = (require 'express')()
app.engine 'domineer', require('../domineer/domineer').__express
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'domineer'

templates = fs.readdirSync(__dirname + '/templates').map((filename) -> filename.replace /\.domineer$/, '')

app.get '/', (req, res) ->
    res.render 'index', { templates }

app.get '/:template.html', (req, res) ->
    templateToShow = req.param 'template'
    if templateToShow in templates
        templateParameters = { templates }
        res.render templateToShow, templateParameters
    else
        res.send 'Template not found!'

server = app.listen 3000, ->
    console.log 'Listening on port %d', server.address().port
