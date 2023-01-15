Linguaggi di Programmazione Progetto Prolog e Common Lisp 202301 (E1P)
JSON Parsing
Marco Antoniotti, Gabriella Pasi e Fabio Sartori
Consegna:
15 gennaio 2023, ore 23:59 GMT+1
Introduzione
Lo sviluppo di applicazioni web su Internet, ma non solo, richiede di scambiare dati fra applicazioni eterogenee, ad esempio tra un client web scritto in Javascript e un server, e viceversa. Uno standard per lo scambio di dati molto diffuso è lo standard JavaScript Object Notation, o JSON. Lo scopo di questo progetto è di realizzare due librerie, una in Prolog e l’altra in Common Lisp, che costruiscano delle strutture dati che rappresentino degli oggetti JSON a partire dalla loro rappresentazione come stringhe.
La sintassi delle stringhe JSON
La sintassi JSON è definita nel sito https://www.json.org.
Dalla grammatica data, un oggetto JSON può essere scomposto ricorsivamente nelle seguenti parti:

1. Object 2. Array
2. Value
3. String 5. Number
   Potete evitare di riconoscere caratteri Unicode.
   Esempi
   L’oggetto vuoto:
   {}
   L’array vuoto:
   []
   Un oggetto con due “items”:
   {
   "nome" : "Arthur",
   "cognome" : "Dent"
   }
   1

Un oggetto complesso, contenente un sotto-oggetto, che a sua volta contiene un array di numeri (notare che, in generale, gli array non devono necessariamente avere tutti gli elementi dello stesso tipo)
{
"modello" : "SuperBook 1234",
"anno di produzione" : 2014,
"processore" : {
}
"produttore" : "EsseTi",
"velocità di funzionamento (GHz)" : [1, 2, 4, 8]
}
Un esempio tratto da Wikipedia (una possibile voce di menu)
{
"type": "menu",
"value": "File",
"items": [
{"value": "New", "action": "CreateNewDoc"},
{"value": "Open", "action": "OpenDoc"},
{"value": "Close", "action": "CloseDoc"}
] }
Indicazioni e requisiti
Dovete costruire un parser per le stringhe JSON che abbiamo descritto. La stringa in input va analizzata ricorsivamente per comporre una struttura adeguata a memorizzarne le componenti. Si cerchi di costruire un parser guidato dalla struttura ricorsiva del testo in input. Ad esempio, un eventuale array (e la sua composizione interna in elements) va individuato dopo l’individuazione del member del quale fa parte, e il meccanismo di ricerca non deve ripartire dalla stringa iniziale ma bensì dal risultato della ricerca del member stesso.
In altre parole, approcci del tipo “ora cerco la posizione del ‘:’ e poi prendo la sottostringa...”, non sono il modo migliore di affrontare in problema. Anzi: quasi sicuramente porteranno ad un programma estremamente complicato, poco funzionante e quindi... insufficiente.
Errori di sintassi
Se la sintassi che incontrate non è corretta dovete fallire in Prolog o segnalare un errore in Common Lisp chiamando la funzione error.
Realizzazione Prolog
La realizzazione in Prolog del parser richiede la definizione di due predicati: jsonparse/2 e jsonaccess/3.
Il predicato jsonparse/2 è definibile come: jsonparse(JSONString, Object).
che risulta vero se JSONString (una stringa SWI Prolog o un atomo Prolog) può venire scorporata come stringa, numero, o nei termini composti:
Object = jsonobj(Members)
Object = jsonarray(Elements)
e ricorsivamente:
Members = [] or
Members = [Pair | MoreMembers]
2

Pair = (Attribute, Value)
Attribute = <string SWI Prolog>
Number = <numero Prolog>
Value = <string SWI Prolog> | Number | Object
Elements = [] or
Elements = [Value | MoreElements]
Il predicato jsonaccess/3 è definibile come: jsonaccess(Jsonobj, Fields, Result).
che risulta vero quando Result è recuperabile seguendo la catena di campi presenti in Fields (una lista) a partire da Jsonobj. Un campo rappresentato da N (con N un numero maggiore o uguale a 0) corrisponde a un indice di un array JSON.
Come caso speciale dovete anche gestire il caso
jsonaccess(Jsonobj, Field, Result).
Dove Field è una stringa SWI Prolog. Notate anche che:
?- jsonaccess(jsonobj(Members), [], jsonobj(Members)). true
Mentre...
?- jsonaccess(jsonarray(_), [], _). false
Esempi
?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', O), jsonaccess(O, ["nome"], R).
O = jsonobj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)])
R = ”Arthur”
?- jsonparse('{"nome": "Arthur", "cognome": "Dent"}', O),
jsonaccess(O, "nome", R). % Notare le differenza.
O = jsonobj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)])
R = ”Arthur”
?- jsonparse('{"nome" : "Zaphod",
"heads" : ["Head1", "Head2"]}', % Attenzione al newline.
Z),
jsonaccess(Z, ["heads", 1], R).
Z = jsonobj([(”name”, ”Zaphod”), (”heads”, jsonarray([”Head1”, ”Head2”]))])
R = ”Head2”
?- jsonparse(’[]’, X). X = jsonarray([]).
?- jsonparse(’{}’, X). X = jsonobj([]).
?- jsonparse(’[}’, X). false
?- jsonparse(’[1, 2, 3]’, A), jsonaccess(A, [3], E). false
Notate che nel corso dell’elaborazione potrebbe essere necessario gestire le stringhe in termini di liste di “codici di caratteri”, utilizzando i predicati di conversione atom_chars, string_codes e
3

atom*string1. Tali liste non vengono però visualizzate in modo leggibile da parte di utenti umani, e.g., ”http” è visualizzata come [104, 116, 116, 112]. Nella costruzione dei valori di tipo String è richiesta l’eventuale conversione da liste di questo genere a stringhe leggibili.
La costruzione di un predicato invertibile in grado di risolvere questo problema non è immediata, però, il vostro programma dovrebbe essere in grado di rispondere correttamente a query nelle quali i termini fossero parzialmente istanziati, come ad esempio:
?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', jsonobj([jsonarray(*) | _]).
No.
?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', jsonobj([("nome", N) | _]).
N = ”Arthur”
?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', JSObj), jsonaccess(JSObj, ["cognome"], R),
R = ”Dent”
Input/Output da e su file
La vostra libreria dovrà anche fornire due predicati per la lettura da file e la scrittura su file.
jsonread(FileName, JSON).
jsondump(JSON, FileName).
Il predicato jsonread/2 apre il file FileName e ha successo se riesce a costruire un oggetto JSON. Se FileName non esiste il predicato fallisce. Il suggerimento è di leggere l’intero file in una stringa e poi di richiamare jsonparse/2.
Ilpredicatojsondump/2scrivel’oggettoJSONsulfileFileNameinsintassiJSON. SeFileName non esiste, viene creato e se esiste viene sovrascritto. Naturalmente ci si aspetta che
?- jsondump(jsonobj([/* stuff */]), ’foo.json’), jsonread(’foo.json’, JSON).
JSON = jsonobj([/* stuff */])
Attenzione! Ilcontenutodelfilefoo.jsonscrittodajsondump/2dovràessereJSONstandard.
Ciò significa che gli attributi dovranno essere scritti come stringhe e non come atomi.
Realizzazione Common Lisp
La realizzazione Common Lisp deve fornire due funzioni. (1) una funzione
jsonparse che accetta in ingresso una stringa e produce una struttura simile a quella illustrata perlarealizzazioneProlog. (2)unafunzionejsonaccesscheaccettaunoggettoJSON (rappresentato in Common Lisp, così come prodotto dalla funzione jsonparse) e una serie di “campi”, recupera l’oggetto corrispondente. Un campo rappresentato da N (con N un numero maggiore o uguale a 0) rappresenta un indice di un array JSON.
La sintassi degli oggetti JSON in Common Lisp è:
Object = ’(’ jsonobj members ’)’ Object = ’(’ jsonarray elements ’)’
e ricorsivamente:
members = pair\*
pair = ’(’ attribute value ’)’ attribute = <stringa Common Lisp> number = <numero Common Lisp>
1 Si assume che stiate usando SWIPL.
4

value = string | number | Object elements = value\*
Esempio
CL-prompt> (defparameter x (jsonparse "{\"nome\" : \"Arthur\", \"cognome\" : \"Dent\"}"))
X
;; Attenzione al newline!
CL-prompt> x
(JSONOBJ ("nome" "Arthur") ("cognome" "Dent"))
CL-prompt> (jsonaccess x "cognome") "Dent"
CL-prompt> (jsonaccess (jsonparse
"{\"name\" : \"Zaphod\",
\"heads\" : [[\"Head1\"], [\"Head2\"]]}")
"heads" 1 0)
"Head2"
CL-prompt> (jsonparse "[1, 2, 3]") (JSONARRAY 1 2 3)
CL-prompt> (jsonparse "{}") (JSONOBJ)
CL-prompt> (jsonparse "[]") (JSONARRAY)
CL-prompt> (jsonparse "{]") ERROR: syntax error
CL-prompt> (jsonaccess (jsonparse " [1, 2, 3] ") 3) ; Arrays are 0-based. ERROR: ...
Input/Output da e su file
La vostra libreria dovrà anche fornire due funzioni per la lettura da file e la scrittura su file.
(jsonread filename)  JSON (jsondump JSON filename)  filename
LafunzionejsonreadapreilfilefilenameritornaunoggettoJSON(ogeneraunerrore). Se filename non la funzione genera un errore. Il suggerimento è di leggere l’intero file in una stringa e poi di richiamare jsonparse.
Lafunzionejsondumpscrivel’oggettoJSONsulfilefilenameinsintassiJSON. Sefilename non esiste, viene creato e se esiste viene sovrascritto. Naturalmente ci si aspetta che
CL-PROMPT> (jsonread (jsondump ’(jsonobj #| stuff |#) ”foo.json”)) (JSONOBJ #| stuff |#)
Da consegnare
LEGGERE MOLTO ATTENTATMENTE LE ISTRUZIONI!!!
Dovrete consegnare un file .zip (i files .7z, .rar o .tar etc, non sono accettabili!!!) dal nome
MATRICOLA*Cognome_Nome_LP_E1P_JSON_2023.zip
Nome e Cognome devono avere solo la prima lettera maiuscola, Matricola deve avere lo zero iniziale se presente. Cognomi e nomi multipli vanno inframmezzati con il carattere ‘*’; ad esempio: Pravettoni_Brambilla_Gian_Giac_Pier_Carluca.
5

Questo file compresso deve contenere una sola directory con lo stesso nome. Al suo interno ci deve essere una sottodirectory chiamata ‘Prolog’ e una sottodirectory chiamata ‘Lisp’. Al loro interno queste directory devono contenere i files caricabili e interpretabili, più tutte le istruzioni che riterrete necessarie. Il file Prolog si deve chiamare ‘jsonparse.pl’, e il file Lisp si deve chiamare ‘jsonparse.lisp’. Le due sottodirectory devono contenere un file chiamato README.txt. In altre parole, questa è la struttura della directory (folder, cartella) una volta spacchettata.
$ cd cartella_JSON
$ unzip MATRICOLA_Cognome_Nome_LP_E1P_JSON_2023.zip
...
$ ls
MATRICOLA_Cognome_Nome_LP_E1P_JSON_2023
Il contenuto dovrà essere il seguente. In Windows i comandi sono simili...
MATRICOLA_Cognome_Nome_LP_E1P_JSON_2023
Prolog
jsonparse.pl
README.txt
Lisp
jsonparse.lisp
README.txt
Potete aggiungere altri files, ma il loro caricamento dovrà essere effettuato automaticamente al momento del caricamento (“loading”) dei files sopracitati.
Come sempre, valgono le direttive standard (reperibili sulla piattaforma Moodle) circa la formazione dei gruppi.
Ogni file deve contenere all’inizio un commento con il nome e matricola di ogni membro del gruppo. Ogni persona deve consegnare un elaborato, anche quando ha lavorato in gruppo.
Il termine ultimo della consegna sulla piattaforma Moodle è il 15 gennaio 2023, ore 23:59 GMT+1
Valutazione
In aggiunta a quanto detto nella sezione “Indicazioni e requisiti” seguono ulteriori informazioni sulla procedura di valutazione.
Abbiamo a disposizione una serie di esempi standard che saranno usati per una valutazione oggettiva dei programmi. Se i files sorgente non potranno essere letti/caricati nell’ambiente Prolog (nb.: SWI-Prolog, ma non necessariamente in ambiente Windows, Linux, Mac), o nelll’ambiente Common Lisp (Lispworks, ma non necessariamente in ambiente Windows, Linux, Mac), il progetto non sarà ritenuto sufficiente.
Il mancato rispetto dei nomi indicati per funzioni e predicati, o anche delle strutture proposte e della semantica esemplificata nel testo del progetto, oltre a comportare ritardi e possibili fraintendimenti nella correzione, può comportare una diminuzione nel voto ottenuto.
6
