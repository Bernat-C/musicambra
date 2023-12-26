include "globals.mzn";

int: nPeces;         % Nombre de peces a tocar
int: nInstruments;   % Nombre d'instruments a tocar
int: nMusics;        % Nombre de musics

array[1..nPeces] of int: durada;                    % Durada de les peces.
array[1..nPeces] of int: d = [durada[i] div 5 | i in 1..nPeces];
array[1..nPeces,1..nInstruments] of int: requereix;   % Instruments requerits per cada peça
array[1..nMusics,1..nInstruments] of bool: saptocar;  % True si el music sap tocar l'instrument en qüestió

int: pressupost;      
array[1..nMusics] of int: salari;

int: nPrecs;
array[1..nPrecs] of 1..nPeces: pred;
array[1..nPrecs] of 1..nPeces: succ;

int: dummyUB = sum(i in 1..nPeces)(d[i]);

array[1..nPeces,1..nMusics, 0..dummyUB] of var 0..nInstruments: musicsAssignats;

array [1..nPeces, 0..dummyUB] of var bool: x;  % Si una peça s'està executant en un temps
var 0..pressupost: preu = sum([d[i]*salari[j] | i in 1..nPeces, j in 1..nMusics where exists(k in 0..dummyUB)(musicsAssignats[i,j,k] != 0)]);
% Constraint que assegura que es respecta la prioritat
constraint forall(i in 1..nPrecs, j in 0..dummyUB, t in j..dummyUB) (
    % x[succ[i],j] -> not x[pred[i],t]
    % si el successor s'està tocant a j, no pot ser que el predecessor es toqui a t (j o més tard) 
    not x[succ[i],j] \/ not x[pred[i],t]
);

% La primera cançó ha de començar al principi del festival
constraint exists(i in 1..nPeces)(x[i,0]);


% Si en algun moment no es toca cap cançó, vol dir que ja estem, de manera que no se n'ha de tocar cap altra més nedavant
/*constraint forall(t in 0..dummyUB-1) (
  not (sum([x[p,t] | p in 1..nPeces]) = 0) \/ forall(u in t+1..dummyUB) (sum([x[p,u] | p in 1..nPeces]) = 0)
);*/

/*
array[1..nPeces] of var 0..dummyUB: min_values = [ min([t | t in 0..dummyUB where x[p,t]]) | p in 1..nPeces ];
array[1..nPeces] of var 0..dummyUB: max_values = [ max([t | t in 0..dummyUB where x[p,t]]) | p in 1..nPeces ];

% L'inici d'una cançó ha de ser 0 o just després que acabi una altra cançó
constraint forall(p in 1..nPeces) (
  min_values[p] = 0 \/ exists(q in 1..nPeces where q != p) (min_values[p] = max_values[q] + 1)
);*/

% Que cada peça tingui els instruments que necessita durant l'execució
constraint forall(i in 1..nPeces, j in 1..nInstruments, m in min_values[i]..max_values[i])(
    count([musicsAssignats[i,k,m]|k in 1..nMusics], j) == requereix[i,j]
);

% Que cada cançó duri el que ha de durar
constraint forall(i in 1..nPeces)(
    count([x[i,t]|t in 0..dummyUB], true) == d[i]
);

% Un músic ha de tocar el mateix instrument durant una cançó
constraint forall(i in 1..nPeces, j in 1..nMusics, k in min_values[i]+1..max_values[i]) (
    musicsAssignats[i,j,k] = musicsAssignats[i,j,min_values[i]]
);

% Que un music toqui un instrument que li toca.
constraint forall(i in 1..nPeces, j in 1..nMusics, k in min_values[i]..max_values[i])(
    if musicsAssignats[i,j,k]!=0 then saptocar[j,musicsAssignats[i,j,k]] endif
);

% Constraint que assegura que un músic no pugui de tocar dos peces simultàniament
constraint forall(i in 1..nPeces, m in 1..nMusics, j in i..nPeces, k in max(min_values[i], min_values[j])..min(max_values[i], max_values[j])) (
  if (min_values[i] <= min_values[j] /\ max_values[i] > min_values[j] \/ min_values[j] <= min_values[i] /\ max_values[j] > min_values[i]) /\ i!=j then musicsAssignats[i,m,k]*musicsAssignats[j,m,k]=0 endif
);


%solve minimize max([s[i]+d[i]| i in 1..nPeces])*pressupost + preu;
solve minimize max([t| i in 1..nPeces, t in 0..dummyUB where x[i,t]]);

%var int: max_value = max([t*5| i in 1..nPeces, t in 0..dummyUB where x[i,t]]);

array[1..nPeces] of var 0..dummyUB: min_values = [ min([t | t in 0..dummyUB where x[p,t]]) | p in 1..nPeces ];
array[1..nPeces] of var 0..dummyUB: max_values = [ max([t | t in 0..dummyUB where x[p,t]]) | p in 1..nPeces ];
var int: max_value = max(max_values);

%output [ "max_values" ++ show(i) ++ ": " ++ show(max_values[i]) ++ "\n" | i in index_set(min_values) ];


output [
  "Hora d’inici del festival: 10h 0min \nHora d'acabada del festival: " ++ show(10 + ((max_value+1)*5) div 60)++ "h " ++
  show(((max_value+1)*5) mod 60) ++ 
  "min \nCost de contractació: " ++ show(fix(preu)) ++ "\n"
] ++ [
  "Peça " ++ show(p) ++ ":\n" ++ 
  "  Inici: " ++ show(fix(10+min_values[p]*5 div 60)) ++ "h " ++ show(fix(min_values[p]*5 mod 60)) ++ " min\n" ++ 
  "  Final: " ++ show(fix(10+((max_values[p]+1)*5 div 60))) ++ "h " ++ show(fix((max_values[p]+1) * 5 mod 60)) ++ " min\n" ++ 
  concat(["  Music " ++ show(m) ++ " toca instrument " ++ show(fix(musicsAssignats[p,m,min_values[p]])) ++ "\n" | m in 1..nMusics where fix(musicsAssignats[p,m,min_values[p]])!=0]) |  p in 1..nPeces ];

