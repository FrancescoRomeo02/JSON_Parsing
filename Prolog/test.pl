clean_string2(String, CleanString) :-
    string_to_list_of_characters(String, Characters),
    exclude(toremove2, Characters, CleanCharacters),
    atomics_to_string(CleanCharacters, CleanString).

string_to_list_of_characters(String, Characters) :-
    name(String, Xs),
    maplist( number_to_character, Xs, Characters ).

number_to_character(Number, Character) :- 
    name(Character, [Number]).

    

toremove('\'').
toremove('\n').
toremove('\t').
toremove('\r').


%% include test


