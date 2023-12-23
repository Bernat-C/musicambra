include "globals.mzn";

int: nPeces;         % Nombre de peces a tocar
int: nInstruments;   % Nombre d'instruments a tocar
int: nMusics;        % Nombre de musics

array[1..nPeces] of int: durada;                    % Durada de les peces.
%array[1..nPeces] of int: d = [durada[i] div 5 | i in 1..nPeces];
array[1..nPeces,1..nInstruments] of int: requereix;   % Instruments requerits per cada peça
array[1..nMusics,1..nInstruments] of bool: saptocar;  % True si el music sap tocar l'instrument en qüestió

int: pressupost;      
array[1..nMusics] of int: salari;

int: nPrecs;
array[1..nPrecs] of 1..nPeces: pred;
array[1..nPrecs] of 1..nPeces: succ;

int: dummyUB = sum(i in 1..nPeces)(durada[i]);

array [1..nPeces] of var 0..dummyUB: s;  % Temps d'inici de cada peça
var 0..pressupost: preu = sum([durada[i]*salari[j] div 5 | j in 1..nMusics, i in 1..nPeces where musicsAssignats[i,j]!=0]);               % Pressupost

array[1..nInstruments] of int: poolInstruments = [sum(j in 1..nMusics)(saptocar[j,i])| i in 1..nInstruments]; % Number of each instrument we have.
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
      if s[i] <= s[j] /\ s[i] + durada[i] > s[j] /\ i!=j then musicsAssignats[i,m] != musicsAssignats[j,m] endif
);

solve minimize max([s[i]+durada[i]| i in 1..nPeces]);

output["Hora d’inici del festival: 10h 0min \nHora d'acabada del festival: 10h " ++ show(max([s[i]+durada[i]| i in 1..nPeces])) ++ "min \nCost de contractació: " ++ show(preu) ++ "\n"] ++ [ "Peça " ++ show(p) ++ ":\n" ++ "  Inici: 10h " ++ show(s[p]) ++ " min\n" ++ "  Final: 10h " ++  show(s[p]+durada[p]) ++ " min\n" |  p in 1..nPeces ];

/* CÀLCULS DE LOWER BOUNDS I UPPER BOUNDS */
/*array[1..nPeces] of var int: lb = [1 | i in 1..nPeces];  % Lower bounds
array[1..nPeces] of var int: ub = [1 | i in 1..nPeces];  % Upper bounds

constraint forall(i in 1..nPeces) (
    lb[i] = max([lb[pred[j]]+d[pred[j]] | j in 1..nPrecs where succ[j]==i]) /\
    ub[i] = max([ub[pred[j]]+d[pred[j]] | j in 1..nPrecs where succ[j]==i])
);

constraint forall(i in 1..nPeces) (
    lb[i] <= s[i] /\ s[i] <= ub[i]
);*/

% Constraint que assegura que no assignem més instruments dels que tenim.
/*constraint forall(i in 1..nPeces)(
    forall(j in 1..nInst)(
      poolInstruments[j] - sum([]) > 0
    )
);*/









