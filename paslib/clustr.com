do pascal
clustr,clustr=clustr/deb/stat/enable:trace

do link
clustr
build
print
cost
optim
dispos
/g
ssave clustr
do clustr
  