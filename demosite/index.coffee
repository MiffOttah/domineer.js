fs = require 'fs'

domineer = require('../domineer/domineer').create({ 
    templateDirectory: __dirname + '/templates'
});

templates = fs.readdirSync(domineer.templateDirectory).map((filename) -> filename.replace /\.html$/, '')

app = (require 'express')()

app.get '/', (req, res) ->
    domineer.render 'index', { templates }, (error, html) ->
        if error
            console.warn error
            res.send 'Something went wrong. :('
        else
            res.send html

app.get '/:template.html', (req, res) ->
    templateToShow = req.param('template')
    if templateToShow in templates
        templateParameters = { templates }
        
        domineer.render templateToShow, templateParameters, (error, html) ->
            if error
                console.warn error
                res.send 'Something went wrong. :('
            else
                res.send html

    else
        res.send 'Template not found!'

server = app.listen 3000, ->
    console.log 'Listening on port %d', server.address().port
