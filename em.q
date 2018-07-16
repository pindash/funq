\c 40 100
\l funq.q

/ expectation maximization (EM)

/ binomial example
/ http://www.nature.com/nbt/journal/v26/n8/full/nbt1406.html
n:10
x:"f"$sum each (1000110101b;1111011111b;1011111011b;1010001100b;0111011101b)
theta:.6 .5        / initial coefficients
lf:.ml.binla[n]    / likelihood function
mf:.ml.wbinmle[n]  / parameter maximization function
phi:2#1f%2f        / coins are picked with equal probability
.ml.em[lf;mf;x] pt:(phi;flip enlist theta)
.ml.em[lf;mf;x] over pt  / call until convergence
/ which flips came from which theta? pick maximum log likelkhood
.util.assert[1 0 0 1 0] .ml.f2nd[.ml.imax] (@[;x] .ml.binll[n] .) peach last .ml.em[lf;mf;x] over pt

/ gaussian mixtures
/ http://mccormickml.com/2014/08/04/gaussian-mixture-models-tutorial-and-matlab-code/
/ 1d gauss
mu0:10 20 30                    / distribution's mu
s20:s0*s0:1 3 2                 / distribution's variance
m0:100 200 150                  / number of points per distribution
X:raze X0:mu0+s0*(.util.bm ?[;1f]@) each m0 / build dataset
show .util.plt raze each (X0;0f*X0),'(X0;.ml.gauss'[mu0;s20;X0]) / plot 1d data and guassian curves
k:count mu0
phi:k#1f%k;      / guess that distributions occur with equal frequency
mu:neg[k]?X;     / pick k random points as centers
s2:k#var X;      / use the whole datasets variance
lf:.ml.gauss     / likelihood function
mf:.ml.wgaussmle / maximum likelihood estimator function
.ml.em[lf;mf;X] over pt:(phi;flip (mu;s2)) / returns best guess for (phi;mu;s)
group .ml.f2nd[.ml.imax] (@[;X] .ml.gaussll .) peach last .ml.em[lf;mf;X] over pt

/ 2d gauss
mu0:(10 20;-10 -20;0 0)
S20:((30 -20;-20 30);(20 0; 0 50);(10 2; 5 10)) / SIGMA (covariance matrix)
m0:1000 2000 1000

R0:.qml.mchol each S20          / sqrt(SIGMA)
X:(,') over X0:mu0+R0$'(.util.bm (?).)''[flip each flip (m0;3 2#1f)]
show .util.plt X

k:count mu0
phi:k#1f%k                      / equal probability
mu:X@\:/:neg[k]?count X 0       / pick k random points for mu
S:k#enlist X cov\:/: X          / full covariance matrix

lf:.ml.gaussmv
mf:.ml.wgaussmvmle
.ml.em[lf;mf;X] over (phi;flip (mu;S))

/ lets try the iris data again for >2d

\l iris.q
`X`y set' iris`X`y;
k:count distinct y              / 3 clusters
phi:k#1f%k                      / equal prior probability
mu:X@\:/:neg[k]?count y         / pick k random points for mu
S:k#enlist X cov\:/: X          / sample covariance
lf:.ml.gaussmv
mf:.ml.wgaussmvmle
pt:.ml.em[lf;mf;X] over (phi;flip (mu;S))
/ how well did it cluster the data?
g:0 1 2!value group .ml.f2nd[.ml.imax] (@[;X].ml.gaussmvll .) peach pt 1
show m:.ml.mode each y g
avg y=m .ml.ugrp g
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .ml.cm[y;m .ml.ugrp g]

-1"let's cluster hand written numbers into groups";
-1"assuming each pixel of a black/white image is a bernoulli distribution,";
-1"we can model each picture as a bernoulli mixture model";
\l mnist.q
`X`y set' mnist`X`y;
-1"convert the grayscale image into black/white";
X>:128
plt:value .util.plot[28;14;.util.c10] .util.hmap flip 28 cut
k:40
-1"lets use ",string[k]," clusters";
-1"we first initialize phi to be equal weight across all clusters";
phi:k#1f%k                      / equal prior probability
-1"then we use the hamming distance to pick different prototypes";
mu:flip last k .ml.kpp[.ml.hdist;X]/ () / pick k distant proto
-1"and finally we add a bit of noise without 'pathological' extreme values";
mu:.5*mu+.15+count[X]?/:k#.7            / randomly disturb around .5
-1"display a few initial prototypes";
-1 (,'/) plt each 4#mu;
lf:.ml.bmml
mf:.ml.wbmmmle[1e-8]
pt:(phi;flip enlist mu)
\s 0 / prevent wsfull in peach
-1"0-values in phi or mu will create null values.";
-1"to prevent this, we need to use dirichlet smoothing";
pt:.ml.em[lf;mf;X] pt
-1"after the first em round, the numbers are prototypes are much clearer";
-1 (,'/) (plt first @) each  pt 1;
-1"lets run 10 more em steps";
pt:10 .ml.em[lf;mf;X]/ pt
-1"grouping the data and finding the mode identifies the clusters";
g:group .ml.f2nd[.ml.imax] (@[;X].ml.bmmll .) peach pt 1
show m:.ml.mode each y g
avg y=m .ml.ugrp g
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .ml.cm[y;m .ml.ugrp g]
