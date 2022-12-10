%%%% Romeo Francesco 885880

%%%% -*- Mode: Prolog -*-
% jsonparsing.pl
%
% This file contains the predicates to parse a JSON string into a Prolog term.
%
% @author Romeo Francesco

%% jsonparse/2
%
% is true if the first item is a JSON string and the second is the Prolog term
%
% @param JSONAtom JSONString
% @param Object Prolog term

jsonparse({}, (json_obj([]))) :- 
    !.

% JSON string
jsonparse(JSONAtom, Object) :-
    atom(JSONAtom),
    atom_string(JSONAtom, JSONString),
    jsonparse(JSONString, Object),
    !.

jsonparse(JSONString, json_obj(Object)) :-
    string(JSONString),
    string_chars(JSONString, JSONChars),
    clean_string(JSONChars, CleanJSONChars),
    string_chars(CleanJSONString, CleanJSONChars),
    term_string(InternJSON, CleanJSONString),
    InternJSON =.. [{}, JSONObject],
    json_obj([JSONObject], Object),
    !.

% JSON Arry
jsonparse(ArrayAtom, Array) :-
    atom(ArrayAtom),
    atom_string(ArrayAtom, ArrayString),
    jsonparse(ArrayString, Array),
    !.

jsonparse(JSONArray, json_array(Array)) :-
    string(JSONArray),
    term_string(InternJSON, JSONArray),
    json_array([InternJSON], Array),
    !.



%% json_array/2
%
% is true if the first element is a JSON array and 
% the second is a list of the elements
%
% @param list of JSON arrays
% @param list of elements

json_array([], []) :- 
    !.

json_array([Element | Elements], [Value | Values]) :-
    valued(Value, Element),
    json_array(Elements, Values),
    !.

%% clean_string/2
%
% is true if the second item is a list of characters without the characters
% ' \n \t
%
% @param JSONChars JSON string
% @param CleanJSONChars JSON string without the characters ' \n \t

clean_string([], []) :- 
    !.

clean_string(['\''|JSONChars], CleanJSONChars) :-
    clean_string(JSONChars, CleanJSONChars).

clean_string(['\n'|JSONChars], CleanJSONChars) :-
    clean_string(JSONChars, CleanJSONChars).

clean_string(['\t'|JSONChars], CleanJSONChars) :-
    clean_string(JSONChars, CleanJSONChars).

clean_string([JSONChar|JSONChars], [JSONChar|CleanJSONChars]) :-
    clean_string(JSONChars, CleanJSONChars).


%% json_obj/2
%
% is true if the first element is a JSON object and the second is a list of
% pairs (key : value)
%
% @param list of JSON objects
% @param list of pairs (key : value)

json_obj([], []) :- 
    !.

json_obj([Elements], [Pairs]) :-
    json_elements(Elements, Pairs),
    !.

json_obj([Object], [Pair | Pairs]) :-
    Object =.. [',', Element | T],
    json_elements(Element, Pair),
    json_obj(T, Pairs),
    !.

%% json_elements/2
%
% is true if the first element is a list of the form [key : value]
% composed by the elements of the second element
%
% @param list
% @param pair (key : value)

json_elements(Member, (Key, Value)) :-
    Member =.. [':', EvalKey, EvalValue],
    storeKV(EvalKey, EvalValue, Key, Value),
    !.

%% storeKV/4
%
% is true if the first and the third elements are a key and the second
% and the fourth are the value
% 
% @param Key String, Value and EvalValue can be a string, number, array or object
% @param evaluate kay and value

storeKV(Key, Value, Key, EvalValue) :-
    string(Key),
    valued((Value, EvalValue)),
    !.

%% valued/1
%
% is true if the first elemt is a String, Number, Array or Object and the second
% is the same
% 
% @param Value String, number or array, EvalValure object
% @param evaluate value or recursively call jsonparse to evaluate the value

valued(([], [])) :-
    !.

valued((Value, Value)) :-
    string(Value),
    !.

valued((Value, Value)) :-
    number(Value), 
    !.

valued((Value, EvalValue)) :-
    jsonparse(Value, EvalValue),
    !.


%%%% end of file -- jsonparsing.pl

%%%% to-do
% - add support for array 
