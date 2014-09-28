domineer.js
===========

> Making this worse is the common cry for “sanitizing your inputs”. That’s
> completely wrong; you can’t wave a magic wand to make a chunk of data
> inherently “clean”. What you need to do is speak the language: use
> placeholders with SQL, use argument lists when spawning processes, etc.

&mdash; [Eevee](http://eev.ee/blog/2012/04/09/php-a-fractal-of-bad-design/#language-boundaries)

Do you know what does it mean?
------------------------------

One of the design goals of XHTML on the web was to elimate the use of
the `innerHTML` property. While this was never acheived (lousy Internet
Explorer), the notion stuck in the heads of JavaScript developers that
the best way to assign text to HTML was with DOM.

Surprisingly, this notion doesn't carry over to the server side. We have
dozens upon dozens of templating engines and languages to choose from,
some of which rely on building a DOM directly from JavaScript objects,
but none of them (that I know of) let you manipulate the DOM of an
existing HTML document on the server.

**domineer.js** introduces new HTML elements that are replaced, removed,
or duplicated based on the data provided to the HTML template.

It's sort of a proof of concept right now, but it's something that exists!

What does it do?
----------------

Embed JavaScript expressions in HTML!

    <p>Hello, <expr>this.username</expr>!</p>

If/else

    <p><if test="Math.random() &gt;= 0.5">Heads!<else>Tails!</else></if></p>

Foreach

    <ul><foreach in="this.notes" as="note"><li><expr>locals.note</expr></li></foreach></ul>

Complex functions. Anything that evaluates to a value in JavaScript can be used
in **domineer.js**!

    <p>The factorial of <expr>this.n</expr> is <expr>(function(){
        var value = 1;
        for (var i = 1; i &lt; this.n; i++){
            value *= i;
        }
        return value;
    }).apply(this)</expr>.</p>

More details
------------

The full documentation is available at https://github.com/MiffOttah/domineer.js/blob/master/domineer/README.md

Copyright
---------

Copyright © 2014 [MiffTheFox](https://miffthefox.info/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.


