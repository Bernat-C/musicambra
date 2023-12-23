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
array[1..nPeces,1..nMusics] of var 0..1: musicsAssignats;


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

array[1..nPeces] of var 0..nPeces: sumAssignats;
constraint forall(i in 1..nPeces)(
    sumAssignats[i] = sum(j in 1..nPeces where s[i] <= s[j] /\ s[j] + d[j] > s[i])(
        musicsAssignats[j]
    )
);
constraint forall(i in 1..nPeces)(sumAssignats[i] <= 1);

constraint sum(j in 1..nPeces where s[i]<=s[j] /\ s[i]+d[i]>=s[j])(k) <= 1;

constraint forall(i in 1..nPeces)(
    poolInstruments - sum(Requeriments de instruments de musics cançons que es toquen ara mateix) > 0
);