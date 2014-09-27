###
    domineer.js - A DOM and HTML based templating engine.
    Copyright © 2014 MiffTheFox

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

fs = require 'fs'
path = require 'path'

jsdom = require 'jsdom'

class DomineerEngine
    constructor: (@templateDirectory) ->

    templateSuffix: ''
    maxDepth = 10

    render: (templateFile, templateParametersArray..., callback) ->
        try
            templateParameters = if templateParametersArray.length >= 1 then templateParametersArray[0] else null
            childState = if templateParametersArray.length >= 2 then templateParametersArray[1] else null
            throw new Error('Too many arguments for render().') if templateParametersArray.length > 2

            templateFile = path.join @templateDirectory, (templateFile + @templateSuffix)

            fs.readFile templateFile, (err, data) =>
                if err
                    callback err, null
                else
                    @renderTemplateHtml data, templateParameters, childState, callback
        catch err
            callback err, null
        

    renderTemplateHtml: (templateHtml, templateParametersArray..., callback) ->
        try
            templateParameters = if templateParametersArray.length >= 1 then templateParametersArray[0] else null
            childState = if templateParametersArray.length >= 2 then templateParametersArray[1] else null
            throw new Error('Too many arguments for renderTemplateHtml().') if templateParametersArray.length > 2

            throw new Error('Maximum template depth exceeded') if childState and childState.depth > maxDepth

            engine = this

            jsdom.env({
                html: templateHtml
                scripts: []

                done: (errors, window) ->
                    if errors
                        callback errors, null
                    else
                        processor = new DomineerDocumentProcessor window, templateParameters, childState

                        inheritsElements = window.document.getElementsByTagName 'inherits'

                        if inheritsElements.length == 0
                            for rootNode in shallowCopy(window.document.childNodes)
                                processor.processNode rootNode

                            html = jsdom.serializeDocument window.document
                            callback null, html
                        else if inheritsElements.length == 1
                            from = inheritsElements[0].getAttribute 'from'
                            throw new Error 'No from attribute given for an <inherits> element.' unless from

                            processor.processNode inheritsElements[0]

                            newChildState = new ChildState(inheritsElements[0].innerHTML.trim(), if childState? then (childState.depth + 1) else 0)
                            engine.render from, processor.templateParameters, newChildState, callback
                        else
                            throw new Error 'Only one <inherits> element is permitted per template.'
                    true
            })
        catch err
            callback err, null

class DomineerDocumentProcessor
    constructor: (@window, @templateParameters, @childState) ->

    locals: {}

    processNode: (node) ->
        if node.nodeType == 1 # element
            document = @window.document
            evalNode = document.createElement 'div'
            node.appendChild evalNode

            # Insert childcontent
            for childContentNode in node.getElementsByTagName 'childcontent'
                if @childState
                    childContentNode.innerHTML = @childState.content
                removeNodePreservingChildren childContentNode

            # Process setup elements
            for setupNode in node.getElementsByTagName 'setup'
                @processExpr setupNode.textContent
                if setupNode.parentNode
                    setupNode.parentNode.removeChild setupNode

            # Process foreach elements
            for foreachNode in shallowCopy node.getElementsByTagName 'foreach'
                feCollection = foreachNode.getAttribute 'in'
                feVarName = foreachNode.getAttribute 'as' or '_'

                if feCollection
                    collection = shallowCopy @processExpr(feCollection)

                    htmlToDuplicate = foreachNode.innerHTML
                    for collectionItem in collection
                        foreachNode.innerHTML = htmlToDuplicate
                        @locals[feVarName] = collectionItem
                        @processNode foreachNode
                        for newNode in shallowCopy(foreachNode.childNodes)
                            foreachNode.removeChild(newNode)
                            foreachNode.parentNode.insertBefore newNode, foreachNode
                    foreachNode.setAttribute 'in', ''
                    foreachNode.parentNode.removeChild foreachNode


            # Process if elements
            for ifNode in node.getElementsByTagName 'if'
                @processIf ifNode

            # Process expr elements
            for exprNode in node.getElementsByTagName 'expr'
                result = @processExpr exprNode.textContent

                if (not exprNode.hasAttribute 'void') and (result isnt undefined) and (result isnt null)
                    if exprNode.hasAttribute 'html'
                        evalNode.innerHTML = '' + result
                        for newNode in shallowCopy(evalNode.childNodes)
                            evalNode.removeChild(newNode)
                            exprNode.parentNode.insertBefore newNode, exprNode
                    else
                        newNode = document.createTextNode('' + result)
                        exprNode.parentNode.insertBefore newNode, exprNode
                
                if exprNode.parentNode
                    exprNode.parentNode.removeChild exprNode

            # Process inputs with jsvalue
            for childNode in node.getElementsByTagName 'input' when childNode.hasAttribute 'jsvalue'
                childNode.removeAttribute 'jsvalue'
                name = childNode.getAttribute 'name'
                value = @templateParameters[name]
                if name and value
                    childNode.setAttribute 'value', value

            # Process attribute expressions
            for childNode in node.getElementsByTagName '*'
                for attribute in shallowCopy(childNode.attributes)
                    if attribute.name[0] == '$'
                        result = @processExpr attribute.value
                        childNode.setAttribute attribute.name.substr(1), result
                        childNode.removeAttribute attribute.name

            node.removeChild evalNode
        null

    processIf: (ifNode) ->
        test = ifNode.getAttribute 'test'
        throw new Error('if/elseif element requires a test attribute') unless test
        result = @processExpr test

        for childNode in shallowCopy ifNode.childNodes
            if result
                if childNode.tagName == 'ELSE' or childNode.tagName == 'ELSEIF'
                    ifNode.removeChild childNode
            else
                if childNode.tagName == 'ELSE'
                    removeNodePreservingChildren childNode
                else if childNode.tagName == 'ELSEIF'
                    @processIf childNode
                else
                    childNode.parentNode.removeChild(childNode)
        removeNodePreservingChildren ifNode

    processExpr: ($domineer_expression) ->
        window = @window
        document = @window.document
        locals = @locals
        f = ->
            return eval($domineer_expression)
        f.call @templateParameters

class ChildState
    constructor: (@content, depth) ->
        @depth = 10 if depth?
    content: ''
    depth: 10

shallowCopy = (collection) ->
    if collection.length
        x for x in collection
    else
        []

removeNodePreservingChildren = (node) ->
    for child in shallowCopy(node.childNodes)
        node.removeChild(child)
        node.parentNode.insertBefore child, node
    node.parentNode.removeChild node
    node.setAttribute('test', '1')


create = (options) ->
    engine = new DomineerEngine(options.templateDirectory or '.')
    engine.templateSuffix = options.templateSuffix or '.html'
    engine.maxDepth = options.maxDepth or 10
    return engine

module.exports = { create }
