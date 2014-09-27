What is domineer.js?
====================

See https://github.com/MiffOttah/domineer.js for a full description of this
package.

How to use it
=============

The `domineer` package exports an object with a single function: `create()`.

    create(options)

`options` is an object that may contain the following properties:

* `templateDirectory`
* * The directory in which the template files are stored. Defaults to `'.'`.
* `templateSuffix`
* * The string appended to every template name to get the name of the template
    file. Defaults to `'.html'`.

The `create` function returns an object with the following methods:

    render(templateFile, [templateParameters], callback)
    renderTemplateHtml(templateHtml, [templateParameters], callback)

* `templateFile`
* * The name of the template file to render, relative to `templateDirectory`
   and with `templateSuffix` appended.

* `templateHtml`
* * The raw HTML source code for the template to render.

* `templateParameters`
* * The parameters to the template, which will become repersented by `this`
    in the template code.

* `callback`
* * The function called when rendering is complete. The callback function's
    parameters are in the form of `(error, html)`.

List of tags
============

expr
----

The `<expr>` tag evaluates JavaScript code and replaces itself with a text node
containing the result of the expression.

If you specify the `html` attribute, the resulting HTML code will be parsed
instead of being treated as text.

If you specify the `void` attribute, nothing will be inserted into the page.

    <p>2 * 3 = <expr>2 * 3</expr></p>
    <expr html>'<p>' + this.profilehtml + '</p>'</expr>
    <expr void>document.title = this.title || '(Untitled)'</expr>

setup
-----

The `<setup>` tag contains JavaScript code that is to be run before any further
processing of the page takes place.

if
--

The `<if>` tag will test the JavaScript code in the `expr` attribute. If false,
all child elements except for `<elseif>` and `<else>` will be removed. If true,
the remaining content of the `<if>` tag will be shown.

    <if expr="this.fullname"><p>My name is <expr>this.fullname</expr></p></if>

else
----

If in an `<if>` element where the `expr` attribute is false, then the content
of this tag will be shown instead.

    <if expr="this.count != 1">
        <expr>this.count</expr> items
        <else>1 item</else>
    </if>

elseif
------

Similar to `<else>`, except it takes its own `expr` attribute, which works
simular to that of `<if>`. You may nest additional `<elseif>` and `<else>`
tags in an `<elseif>` tag.

    <if expr="this.user.permissionlevel >= 10">
        Administrator
        <elseif expr="this.user.permissionlevel >= 2">
            Staff
            <else>
                User
            </else>
        </elseif>
    </if>

foreach
-------

The `<foreach>` tag can be used to iterate over an array or collection of
objects.

The `from` parameter is a JS expression that evaluates to the object to
iterate over.

The `site` parameter is the name of the field in `locals` that each value in
the object will be assigned to.

    <foreach from="this.sites" as="site">
        <p><a $href="locals.site.url"><expr>locals.site.name</expr></a></p>
    </foreach>

input
-----

The standard HTML `<input>` tag has an additional attribute, `jsvalue`. If this
attribute is present, the tag's value will be set to the value of `this[name]`
where `name` is the name of the tag. For example.

    <setup>this.example = 42;</setup>
    <input name="example" jsvalue>

FAQ
===

How do I set the title progamatically?
--------------------------------------

HTML does not allow the use of child tags in the `<title>` element. To
specify a title at runtime, set `document.title` in a `<setup>` or
`<expr void>` tag.

    <title>My Website</title>
    <setup>
        if (locals.title){
           document.title += locals.title + ' - ' + document.title;
        }
    </setup>
