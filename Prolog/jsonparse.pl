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

jsonparse({}, ([])) :- 
    !.

% JSON Atom ( make Atom a String )
jsonparse(JSONAtom, Object) :-
    atom(JSONAtom),
    atom_string(JSONAtom, JSONString),
    jsonparse(JSONString, Object),
    !.

% JSON String 
jsonparse(JSONString, jsonobj(Object)) :-
    string(JSONString),
    cleanstring(JSONString, CleanJSONString),
    term_string(InternJSON, CleanJSONString),
    InternJSON =.. [{}, JSONObject],
    jsonobj([JSONObject], Object),
    !.

jsonparse(JSON, jsonobj(ParsedObject)) :-
    JSON =.. [{}, Object],
    jsonobj([Object], ParsedObject),
    !.

% JSON Array 
jsonparse(JSONAtomArray, ArrayObject) :-
    atom(JSONAtomArray),
    atom_string(JSONAtomArray, JSONArrayString),
    jsonparse(JSONArrayString, ArrayObject),
    !.

jsonparse(JSONArrayString, jsonarray(Array)) :-
    string(JSONArrayString),
    term_string(InternJSON, JSONArrayString),
    jsonarray(InternJSON, Array),
    !.

jsonparse(Array, jsonarray(ParsedArray)) :-
    jsonarray(Array, ParsedArray),
    !.

%% jsonarray/2
%
% is true if the first element is a JSON array and 
% the second is a list of the elements

jsonarray([], []) :- 
    !.

jsonarray([Element | Elements], [Value | Values]) :-
    tobeevaluated((Value, Element)),
    jsonarray(Elements, Values),
    !.

%% cleanstring/2
%
% is true if the second item is the first item without the characters
% ' \n \t

cleanstring([], []) :- 
    !.

cleanstring(JSONString, JSONCleanString) :-
    stringfromcharacters(JSONString, Characters),
    exclude(toBeRemoved, Characters, CleanCharacters),
    atomics_to_string(CleanCharacters, JSONCleanString).

%% stringfromcharacters/2
%
% is true if the second item is the first item converted 
% into a list of characters

stringfromcharacters(String, Characters) :-
    name(String, Xs),
    maplist( numbertocharacter, Xs, Characters ).

%% numbertocharacter/2
%
% is true if the second item is the first item converted

numbertocharacter(Number, Character) :- 
    name(Character, [Number]).

    
% characters to remove from the JSON string

toBeRemoved('\'').
toBeRemoved('\n').
toBeRemoved('\t').
toBeRemoved('\r').


%% jsonobj/2
%
% is true if the first element is a JSON object and the second is a list of
% pairs (key : value)

jsonobj([], []) :- 
    !.

jsonobj([Elements], [Pairs]) :-
    json_elements(Elements, Pairs),
    !.

jsonobj([Object], [Pair | Pairs]) :-
    Object =.. [',', Element | T],
    json_elements(Element, Pair),
    jsonobj(T, Pairs),
    !.

%% json_elements/2
%
% is true if the first element is a list of the form [key : value]
% composed by the elements of the second element

json_elements(Member, (Key, Value)) :-
    Member =.. [':', EvalKey, EvalValue],
    storeKV(EvalKey, EvalValue, Key, Value),
    !.

%% storeKV/4
%
% is true if the first and the third elements are a key and the second
% and the fourth are the value

storeKV(Key, Value, Key, EvalValue) :-
    string(Key),
    tobeevaluated((Value, EvalValue)),
    !.

%%tobeevaluated/2
%
% is true if the first elemt is a String, Number, Array or Object 
% and the second is the same

tobeevaluated(([], [])) :-
    !.

tobeevaluated((Value, Value)) :-
    string(Value),
    !.

tobeevaluated((Value, Value)) :-
    number(Value), 
    !.

tobeevaluated((Value, EvalValue)) :-
    jsonparse(Value, EvalValue),
    !.

%%%% jsonaccess/3 
%
% is true if the third item is optnable following the chain of fields present in the second item 
% starting from the first item 

% Fields is a list of fields

jsonaccess(Jsonobj, [], Jsonobj) :- 
    !.

% Fields is a list of fields and Jsonobj is an object

jsonaccess(jsonobj(Jsonobj), [Field | Fields], Value) :-
    jsonaccess(jsonobj(Jsonobj), Field , SemiValue),
    jsonaccess(SemiValue, Fields, Value),
    !.

% Field is a list of fileds and Jsonobj is an array

jsonaccess(jsonarray(Jsonarray), [Field | Fields], Value) :-
    jsonaccess(jsonarray(Jsonarray), Field , Semivalue),
    jsonaccess(Semivalue, Fields, Value),
    !.

% Fields is a SWI Prolog String

jsonaccess(jsonobj(Jsonobj), Field, Value) :-
    string(Field),
    accessvalue(Jsonobj, Field, Value),
    !.

% Fileds is a number

jsonaccess(jsonarray(Jsonarray), Field, Value) :-
    number(Field),
    accessvalueindex(Jsonarray, Field, Value),
    !.

%%%% accessvalue/3
%
% is true if the third element matches the value of the first 
% using the second as the key

accessvalue(_, [], _) :-
    fail, 
    !.

accessvalue([(Key, Value) | _], Requiredkey, Returnvalue) :-
    Requiredkey = Key,
    Returnvalue = Value,
    !.

accessvalue([_ | T], Requiredkey, Returnvalue) :-
    accessvalue(T, Requiredkey, Returnvalue),
    !.

%%%% accessvalueindex/3
%
% is true if the third item is the value of 
% the second item position in the first item

accessvalueindex([], _, _) :-
    fail, 
    !.

accessvalueindex([Value | _], 0, Value) :-
    !.

accessvalueindex([_ | T], Index, Value) :-
    Index > 0,
    NewIndex is Index - 1,
    accessvalueindex(T, NewIndex, Value),
    !.

%%%% end of file -- jsonparsing.pl

%%%% to-do
% - read/write file 
% - correggere commenti
% - chiedere chiarimenti nome predicati