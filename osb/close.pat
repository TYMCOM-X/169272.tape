"/Patch to restore old F for PC.UIO restore/

iocss:
close3!jrst pat
ucls3!jrst pat 3
pat!push p,f
pushj p,waitio
jrst close3+1
pop p,t1
tlnn t1,14600
jrst ucls3 1
jrst ucls3 2
pat:
patsiz!pat
patmap[q+4
  