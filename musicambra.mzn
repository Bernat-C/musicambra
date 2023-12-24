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

array [1..nPeces] of var 0..dummyUB: s;  % Temps d'inici de cada peça
var 0..pressupost: preu = sum([d[i]*salari[j]| j in 1..nMusics, i in 1..nPeces where musicsAssignats[i,j]!=0]);               % Pressupost

%array[1..nInstruments] of int: poolInstruments = [sum(j in 1..nMusics)(saptocar[j,i])| i in 1..nInstruments]; % Number of each instrument we have.
array[1..nPeces,1..nMusics] of var 0..nInstruments: musicsAssignats;

% Que un music toqui un instrument que li toca.
constraint forall(i in 1..nPeces, j in 1..nMusics)(
    if musicsAssignats[i,j]!=0 then saptocar[j,musicsAssignats[i,j]] endif
);

% Que cada peça tingui els instruments que necessita durant l'execució
constraint forall(i in 1..nPeces, j in 1..nInstruments)(
    count([musicsAssignats[i,k]|k in 1..nMusics], j) == requereix[i,j]
);

% Constraint que assegura que un músic no pugui de tocar dos peces simultàniament
constraint forall(i in 1..nPeces, m in 1..nMusics, j in 1..nPeces)( % Per tots els inicis, Per tots els músics  Per totes les peçes
      if s[i] <= s[j] /\ s[i] + d[i] > s[j] /\ i!=j then musicsAssignats[i,m]*musicsAssignats[j,m]=0 endif
);

% Constraint que assegura que es respecta la prioritat
constraint forall(i in 1..nPrecs) (
  s[succ[i]] >= s[pred[i]]+d[pred[i]]
);

solve minimize max([s[i]+d[i]| i in 1..nPeces])*pressupost + preu;

var int: max_value = max([s[i]*5+d[i]*5 | i in 1..nPeces]);

output[
  "Hora d’inici del festival: 10h 0min \nHora d'acabada del festival: " ++ show(10 + max_value div 60)++ "h " ++
  show(max_value mod 60) ++ 
  "min \nCost de contractació: " ++ show(fix(preu)) ++ "\n"
] ++ [
  "Peça " ++ show(p) ++ ":\n" ++ 
  "  Inici: " ++ show(fix(10+s[p]*5 div 60)) ++ "h " ++ show(fix(s[p]*5 mod 60)) ++ " min\n" ++ 
  "  Final: " ++ show(fix(10+((s[p]*5+d[p]*5) div 60))) ++ "h " ++ show(fix((s[p]*5+d[p]*5) mod 60)) ++ " min\n" ++ 
  concat(["  Music " ++ show(m) ++ " toca instrument " ++ show(fix(musicsAssignats[p,m])) ++ "\n" | m in 1..nMusics where fix(musicsAssignats[p,m])!=0]) |  
  p in 1..nPeces
];

/* CÀLCULS DE LOWER BOUNDS I UPPER BOUNDS */
/*array[1..nPeces] of var 1..dummyUB: lb;% = [1 | i in 1..nPeces];  % Lower bounds
array[1..nPeces] of var 1..dummyUB: ub;% = [1 | i in 1..nPeces];  % Upper bounds

constraint forall(i in 1..nPeces) (
    lb[i] = max([s[pred[j]]+d[pred[j]] | j in 1..nPrecs where succ[j]==i]) /\
    ub[i] = min([s[succ[j]]-d[pred[j]] | j in 1..nPrecs where succ[j]==i])
);

constraint forall(i in 1..nPeces) (
    lb[i] <= s[i] /\ s[i] <= ub[i]
);*/









