%%%% Romeo Francesco 885880
%%%% Trombella Mattia 885881
%%%% -*- Mode: Prolog -*-

% jsonparsing.pl
%
% This file contains the predicates to parse a JSON string into a Prolog term.
%
% @author Romeo Francesco, Trombella Mattia

%%%% jsonparse/2
%
% is true if the first item is a JSON string and the second is the Prolog term
% representing the JSON string

jsonparse({}, jsonobj([])) :-
    !.

jsonparse(JSON, jsonobj(ParsedObject)) :-
    JSON = {Object},
    !,
    jsonobj([Object], ParsedObject).

jsonparse(JSONAtom, Object) :-
    atom(JSONAtom),
    !,
    atom_string(JSONAtom, JSONString),
    jsonparse(JSONString, Object).

jsonparse(JSONString, jsonobj(Object)) :-
    string(JSONString),
    !,
    cleanString(JSONString, CleanJSONString),
    catch(term_string(InternJSON, CleanJSONString), _, fail),
    InternJSON = {JSONObject},
    jsonobj([JSONObject], Object).

jsonparse([], jsonarray([])) :-
    !.

jsonparse(Array, jsonarray(ParsedArray)) :-
    jsonarray(Array, ParsedArray),
    !.

jsonparse(JSONArrayString, jsonarray(Array)) :-
    string(JSONArrayString),
    !,
    catch(term_string(InternJSON, JSONArrayString), _, fail),
    jsonarray(InternJSON, Array).

jsonparse(JSONAtomArray, ArrayObject) :-
    atom(JSONAtomArray),
    !,
    atom_string(JSONAtomArray, JSONArrayString),
    jsonparse(JSONArrayString, ArrayObject).

%%%% jsonobj/2
%
% is true if the first element is a JSON object and the second is a list of
% pairs (key : value)

jsonobj([], []) :-
    !.

jsonobj([Elements], [Pairs]) :-
    jsonElements(Elements, Pairs),
    !.

jsonobj([Object], [Pair | Pairs]) :-
    Object =.. [',', Element | T],
    jsonElements(Element, Pair),
    jsonobj(T, Pairs),
    !.

%%%% jsonarray/2
%
% is true if the first element is a JSON array and 
% the second is a list of the elements

jsonarray([], []) :-
    !.

jsonarray([Element | Elements], [Value | Values]) :-
    toBeValueted(Element, Value),
    jsonarray(Elements, Values),
    !.

%%%% cleanString/2
%
% is true if the second item is the first item without the characters
% ' \n \t

cleanString([], []) :-
    !.

cleanString(JSONString, JSONCleanString) :-
    stringFromChars(JSONString, Characters),
    exclude(toBeRemoved, Characters, CleanCharacters),
    atomics_to_string(CleanCharacters, JSONCleanString),
    !.

%%%% stringFromChars/2
%
% is true if the second item is the first item converted 
% into a list of characters

stringFromChars(String, Characters) :-
    name(String, CodeList),
    !,
    maplist(codeToCharacter, CodeList, Characters).

%%%% codeToCharacter/2
%
% is true if the second item is the first item converted in code

codeToCharacter(Number, Character) :-
    name(Character, [Number]),
    !.
    
% characters to removed from the JSON string
toBeRemoved('\'').
toBeRemoved('\n').
toBeRemoved('\t').
toBeRemoved('\r').

%%%% jsonElements/2
%
% is true if the first element is a JSON element 
% and the second is a pair (key : value) that compose the JSON object

jsonElements(Member, (Key, Value)) :-
    Member =.. [':', EvalKey, EvalValue],
    saveForEval(EvalKey, EvalValue, Key, Value),
    !.

%%%% saveForEval/4
%
% is true if the first and the third elements are the key and the second
% and the fourth are the value 
% used to store data for the evaluation

saveForEval(Key, Value, Key, EvalValue) :-
    string(Key),
    !,
    toBeValueted(Value, EvalValue).

%%%% toBeValueted/2
%
% is true if the first elemt is a String, Number, Array or Object 
% and the second is the same

toBeValueted([], []) :-
    !.

toBeValueted(Value, Value) :-
    string(Value),
    !.

toBeValueted(Value, Value) :-
    number(Value), 
    !.

toBeValueted(Value, EvalValue) :-
    jsonparse(Value, EvalValue),
    !.

%%%% jsonaccess/3 
%
% is true if the third item is optnable following the chain of fields 
% present in the second item starting from the first item 

jsonaccess(jsonobj(Jsonobj), [], jsonobj(Jsonobj)) :-
    var(Jsonobj),
    !.
    
jsonaccess(jsonobj([Jsonobj]), [], jsonobj([Jsonobj])) :-
    var(Jsonobj),
    !.

jsonaccess(jsonobj([]), [], jsonobj([])) :-
    !.

jsonaccess(jsonobj([(Key, Value) | T]), [], jsonobj([(Key, Value) | T])) :-
    jsonaccess(jsonobj([(_, Value) | T]), [], jsonobj(T)).

jsonaccess(jsonobj(Jsonobj), [Field | []], Value) :-
    string(Field),
    !,
    accessValue(Jsonobj, Field, Value).

jsonaccess(jsonobj(Jsonobj), [Field | Fields], Value) :-
    string(Field),
    !,
    accessValue(Jsonobj, Field, NewJsonobj),
    jsonaccess(NewJsonobj, Fields, Value).

jsonaccess(jsonobj(Jsonobj), Field, Result) :-
    number(Field),
    !,
    jsonaccess(jsonobj(Jsonobj), [Field], Result).

jsonaccess(jsonobj(Jsonobj), Field, Result) :-
    string(Field),
    !,
    jsonaccess(jsonobj(Jsonobj), [Field], Result).

/* jsonaccess(jsonobj(Jsonobj), Field, Result) :-
    atom(Field),
    atom_string(Field, FieldString),
    !,
    jsonaccess(jsonobj(Jsonobj), FieldString, Result). */

jsonaccess(jsonarray(Jsonarray), [Field | []], Value) :-
    integer(Field),
    !,
    accessValueIndex(Jsonarray, Field, Value).

jsonaccess(jsonarray(Jsonarray), [Field | Fields], Value) :-
    integer(Field),
    !,
    accessValueIndex(Jsonarray, Field, SemiValue), 
    jsonaccess(SemiValue, Fields, Value).

%%%% accessValue/3
%
% is true if the third element matches the value of the first 
% using the second as the key

accessValue(_, [], _) :-
    fail, 
    !.

accessValue([(Key, Value) | _], Requiredkey, Returnvalue) :-
    Requiredkey = Key,
    Returnvalue = Value,
    !.

accessValue([_ | T], Requiredkey, Returnvalue) :-
    accessValue(T, Requiredkey, Returnvalue),
    !.

%%%% accessValueIndex/3
%
% is true if the third item is the value of 
% the second item position in the first item

accessValueIndex([], _, _) :-
    fail, 
    !.

accessValueIndex([Value | _], 0, Value) :-
    !.

accessValueIndex([_ | T], Index, Value) :-
    Index > 0,
    NewIndex is Index - 1,
    accessValueIndex(T, NewIndex, Value),
    !.

%%%% jsonread/2
%
% is true if can open "FileName" and can read the JSON object

jsonread(FileName, JSON) :-
    open(FileName, read, In),
    read_string(In, _, JSONString),
    close(In),
    jsonparse(JSONString, JSON),
    !.

%%%% jsondump/2
%
% is true if can open or create "FileName" and 
% can write the JSON object

jsondump(JSON, FileName) :-
    open(FileName, write, Out),
    formattedWrite(JSON, Out),
    close(Out),
    !.

%%%% formattedWrite/2
%
% is true if can write the JSON object in the second item
% in a human readable format

formattedWrite(jsonobj(Members), Out) :-
    write(Out, '{\n\t'),
    formattedMembers(Members, Out),
    write(Out, '\n}').

formattedWrite(jsonarray(Elements), Out) :-
    write(Out, '['),
    formattedElements(Elements, Out),
    write(Out, ']').

%%%% formattedMembers/2
%
% is true if can write the JSON member in the second item
% in a human readable format

formattedMembers([], _Out) :-
    !.

formattedMembers([(Key, Value)], Out) :-
    string(Key),
    string(Value),
    !,
    writeq(Out, Key),
    write(Out, " : "),
    writeq(Out, Value).

formattedMembers([(Key, Value)], Out) :-
    string(Key),
    number(Value),
    !,
    writeq(Out, Key),
    write(Out, " : "),
    writeq(Out, Value).

formattedMembers([(Key, jsonobj(Members))], Out) :-
    string(Key),
    writeq(Out, Key),
    formattedWrite(jsonobj(Members), Out),
    !.

formattedMembers([(Key, jsonobj(Members)) | T], Out) :-
    string(Key),
    writeq(Out, Key),
    write(Out, " : "),    
    formattedWrite(jsonobj(Members), Out),
    formattedMembers(T, Out),
    !.

formattedMembers([(Key, jsonarray(Elements))], Out) :-
    string(Key),
    writeq(Out, Key),
    write(Out, " : "),
    formattedWrite(jsonarray(Elements), Out),
    !.

formattedMembers([(Key, Value) | T], Out) :-
    formattedMembers([(Key, Value)], Out),
    write(Out, ", "),
    write(Out, '\n\t'),
    formattedMembers(T, Out),
    !.

%%%% formattedElements/2
%
% is true if the second item is a list of JSON elements
% in a human readable format

formattedElements([], _Out) :-
    !.

formattedElements([Element], Out) :-
    string(Element),
    !,
    writeq(Out, Element).

formattedElements([Element], Out) :-
    number(Element),
    !,
    writeq(Out, Element).

formattedElements([jsonobj(Members)], Out) :-
    write(Out, '\n\t\t'),
    formattedWrite(jsonobj(Members), Out),
    !.

formattedElements([jsonarray(Elements)], Out) :-
    formattedWrite(jsonarray(Elements), Out),
    !.

formattedElements([Element | Elements], Out) :-
    formattedElements([Element], Out),
    write(Out, ", "),
    formattedElements(Elements, Out),
    !.

% end of jsonparse.pl
