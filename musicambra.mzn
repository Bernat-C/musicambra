include "globals.mzn";

int: nPeces;         % Nombre de peces a tocar
int: nInst;          % Nombre d'instruments a tocar
int: nMusics;        % Nombre de musics

array[1..nPeces] of int: d;                    % Durada de les peces.
array[1..nPeces,1..nInst] of int: requereix;   % Instruments requerits per cada peça
array[1..nMusics,1..nInst] of bool: saptocar;  % True si el music sap tocar l'instrument en qüestió

int: pressupost;      
array[1..nMusics] of int: salari;

int: nPrecs;
array[1..nPrecs] of 1..nPeces: pred;
array[1..nPrecs] of 1..nPeces: succ;

int: dummyUB = sum(i in 1..nPeces)(d[i]);

array [1..nPeces] of var 1..dummyUB: s;  % Temps d'inici de cada peça
var 1..pressupost+1: preu;               % Pressupost

array[1..nInst] of int: poolInstruments = [sum(j in 1..nMusics)(saptocar[j,i])| i in 1..nInst]; % Number of each instrument we have.
array[1..nPeces,1..nMusics] of var 0..nInst: musicsAssignats;

% Que un music toqui un instrument que li toca.
constraint forall(i in 1..nPeces)(
    forall(j in 1..nMusics)(
      if musicsAssignats[i,j]!=0 then saptocar[j,musicsAssignats[i,j]] endif
    )
);

% Que cada peça tingui els instruments que necessita durant l'execució
constraint forall(i in 1..nPeces)(
    forall(j in 1..nInst)(
      exactly(requereix[i,j], [musicsAssignats[i,k]|k in 1..nMusics], j)
    )
);

% Constraint que assegura que un músic no hagi de tocar dos peces simultàniament
constraint forall(i in 1..nPeces)( % Per tots els inicis
    forall(m in 1..nMusics)(       % Per tots els músics
      forall(j in 1..nPeces)(      % Per totes les peçes
        if s[i] <= s[j] /\ s[j] + d[j] > s[i] /\ i!=j then musicsAssignats[i,m] != musicsAssignats[j,m] endif
      )
    )
);

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









