'use strict';

var now = new Date();
var domineer = require('./domineer').create({ 
    templateDirectory: __dirname + '/templates'
});

domineer.render('hello', {
    now: now,
    languages: ['JavaScript', 'CoffeeScript', 'ECMAScript', 'JSON'],
    languageChoice: 0,
    n: 8,
    html: '<em>HTML<strong>5</strong></em>',
    link: {
        url: 'https://www.github.com/',
        title: 'Github'
    },
    name: 'John Smith',
    password: 'hunter2',
    error: 'Invalid username or password.'
}, function(error, html){
    if (error){
        throw error;
    } else {
        console.log(html);
    }
});
