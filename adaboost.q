\c 20 100
\l funq.q
\l pima.q

/ https://cseweb.ucsd.edu/~yfreund/papers/adaboost.ps

-1 .ml.ptree[0] tree:.ml.q45[2;3;::] t;
avg t.class=.ml.dtc[tree] each t / accuracy
-1 "a stump is a single branch tree";
-1 .ml.ptree[0] .ml.stump[::] t;
t:update -1 1 class from t
r:20 .ml.adaboost[.ml.stump;.ml.dtc;t]\(0f;2 1#1;n#1f%n:count t)
avg t.class=signum sum r[;0] * signum r[;1] .ml.dtc/:\: t

show t:`Play xcols (" SSSSS";1#",") 0: `:weather.csv
t:update -1 1 `Yes=Play from t
r:20 .ml.adaboost[.ml.stump;.ml.dtc;t]\(0f;2 1#1;n#1f%n:count t)
avg t.Play=signum sum r[;0] * signum r[;1] .ml.dtc/:\: t
