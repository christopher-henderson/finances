#!/usr/bin/env swipl --quiet
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_header)).

:- initialization main.

server(Port) :- http_server(http_dispatch, [port(Port)]).

% say_hi(_Request) :-
%         format('Content-type: text/plain~n~n'),
%         format('Hello World!~n').

say_boo(Request) :-
  http_parameters(Request, [name(Name, [length >= 2])]),
  format('Content-type: text/plain'),
  http_read_data(Request, Data, []),
  pp(Data).
  % format(Name), write(Name).

main :-
  % http_handler(/, say_hi, []),
  http_handler(/, say_boo, []),
  server(8080).
  % http_handler(root(.), entry_page, []),
  % http_handler(root(home), home_page, []),
  % write("yeah?"),
  % halt.
