%%%% Romeo Francesco 885880
%%%% Trombella Mattia 885881
%%%% -*- Mode: Prolog -*-
% jsonparsing.pl
%
% This file contains the predicates to parse a JSON string into a Prolog term.
%
% @author Romeo Francesco, Trombella Mattia

%% jsonparse/2
%
% is true if the first item is a JSON string and the second is the Prolog term
% representing the JSON string

jsonparse({}, (json_obj([]))) :- 
    !.

% JSON Atom ( make Atom a String )
jsonparse(JSONAtom, Object) :-
    atom(JSONAtom),
    atom_string(JSONAtom, JSONString),
    jsonparse(JSONString, Object),
    !.

% JSON String 
jsonparse(JSONString, json_obj(Object)) :-
    string(JSONString),
    clean_string(JSONString, CleanJSONString),
    term_string(InternJSON, CleanJSONString),
    InternJSON =.. [{}, JSONObject],
    json_obj([JSONObject], Object),
    !.

% JSON Array ( make Array a String )
jsonparse(JSONArray, ArrayObject) :-
    atom(JSONArray),
    atom_string(JSONArray, JSONArrayString),
    jsonparse(JSONArrayString, ArrayObject),
    !.

jsonparse(JSONArrayString, json_array(Array)) :-
    string(JSONArrayString),
    term_string(InternJSON, JSONArrayString),
    json_array([InternJSON], Array),
    !.

%% json_array/2
%
% is true if the first element is a JSON array and 
% the second is a list of the elements

json_array([], []) :- 
    !.

json_array([Element | Elements], [Value | Values]) :-
    valued(Value, Element),
    json_array(Elements, Values),
    !.

%% clean_string/2
%
% is true if the second item is the first item without the characters
% ' \n \t

clean_string([], []) :- 
    !.

clean_string(JSONString, JSONCleanString) :-
    string_to_list_of_characters(JSONString, Characters),
    exclude(toBeRemoved, Characters, CleanCharacters),
    atomics_to_string(CleanCharacters, JSONCleanString).

%% string_to_list_of_characters/2
%
% is true if the second item is the first item converted 
% into a list of characters

string_to_list_of_characters(String, Characters) :-
    name(String, Xs),
    maplist( number_to_character, Xs, Characters ).

%% number_to_character/2
%
% is true if the second item is the first item converted

number_to_character(Number, Character) :- 
    name(Character, [Number]).

    
% characters to remove from the JSON string

toBeRemoved('\'').
toBeRemoved('\n').
toBeRemoved('\t').
toBeRemoved('\r').


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
% @param Key String, Value and EvalValue can be a string, 
% number, array or object
% @param evaluate kay and value

storeKV(Key, Value, Key, EvalValue) :-
    string(Key),
    valued((Value, EvalValue)),
    !.

%% valued/2
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
% - jsonacces 
% - read/write file 
