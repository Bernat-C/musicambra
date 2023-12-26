include "globals.mzn";

int: nPeces;         % Nombre de peces a tocar
int: nInstruments;   % Nombre d'instruments a tocar
int: nMusics;        % Nombre de musics

array[1..nPeces] of int: durada;                    % Durada de les peces.
array[1..nPeces] of int: d = [durada[i] div 5 | i in 1..nPeces];
array[1..nPeces,1..nInstruments] of int: requereix;   % Instruments requerits per cada peça
array[1..nMusics,1..nInstruments] of bool: saptocar;  % True si el music sap tocar l'instrument en qüestió
%array[1..nMusics] of int: saptocarNum;
int: pressupost;      
array[1..nMusics] of int: salari;

int: nPrecs;
array[1..nPrecs] of 1..nPeces: pred;
array[1..nPrecs] of 1..nPeces: succ;

int: dummyUB = sum(i in 1..nPeces)(d[i]);

array[1..nPeces,1..nMusics] of var 0..nInstruments: musicsAssignats;

array [1..nPeces, 0..dummyUB] of var bool: x;  % Si una peça s'està executant en un temps
var 0..pressupost: preu = sum([d[i]*salari[j]| j in 1..nMusics, i in 1..nPeces where musicsAssignats[i,j]!=0]);               % Pressupost

% Constraint que assegura que es respecta la prioritat
constraint forall(i in 1..nPrecs, j in 0..dummyUB, t in j..dummyUB) (
    not x[succ[i],j] \/ not x[pred[i],t]
);

% La primera cançó ha de començar al principi del festival
constraint exists(i in 1..nPeces)(x[i,0]);

% Que cada peça tingui els instruments que necessita durant l'execució
constraint forall(i in 1..nPeces, j in 1..nInstruments)(
    count([musicsAssignats[i,k]|k in 1..nMusics], j) == requereix[i,j]
);


% Que un music toqui un instrument que li toca.
constraint forall(i in 1..nPeces, j in 1..nMusics)(
    if musicsAssignats[i,j]!=0 then saptocar[j,musicsAssignats[i,j]] endif
);

% Constraint que assegura que un músic no pugui de tocar dos peces simultàniament
constraint forall(i in 1..nPeces, j in i..nPeces, t in 0..dummyUB, m in 1..nMusics)( % Per tots els inicis, Per tots els músics
      if x[i,t] /\ x[j,t] /\ i!=j then musicsAssignats[i,m]*musicsAssignats[j,m]=0 endif
);

%solve minimize max([s[i]+d[i]| i in 1..nPeces])*pressupost + preu;
solve minimize max([t| i in 1..nPeces, t in 0..dummyUB where x[i,t]]);

var int: max_value = max([t*5| i in 1..nPeces, t in 0..dummyUB where x[i,t]]);

output[
  "Hora d’inici del festival: 10h 0min \nHora d'acabada del festival: " ++ show(10 + max_value div 60)++ "h " ++
  show(max_value mod 60) ++ 
  "min \nCost de contractació: " ++ show(fix(preu)) ++ "\n"
] ++ [
  "Peça " ++ show(p) ++ ":\n" ++ 
  "  Inici: " ++ show(fix(10+min([t| t in 0..dummyUB where x[p,t]])*5 div 60)) ++ "h " ++ show(fix(min([t| t in 0..dummyUB where x[p,t]])*5 mod 60)) ++ " min\n" ++ 
  "  Final: " ++ show(fix(10+((min([t| t in 0..dummyUB where x[p,t]])*5+d[p]*5) div 60))) ++ "h " ++ show(fix((min([t| t in 0..dummyUB where x[p,t]])*5+d[p]*5) mod 60)) ++ " min\n" ++ 
  concat(["  Music " ++ show(m) ++ " toca instrument " ++ show(fix(musicsAssignats[p,m])) ++ "\n" | m in 1..nMusics where fix(musicsAssignats[p,m])!=0]) |  
  p in 1..nPeces
];

