"/Terminate exit when parent with interrupt but frame attached/
errcon:
pat!pat0:push p,s
.+1!push p,f
.+1!pushj p,ttyfnd
.+1!pop p,f
.+1!pop p,s
.+1!tdze u,u
.+1!aos (p)
.+1!popj p,
.+1!pat:
hlttrp+11/jrst pat0
pat0k
patsiz/pat
7tcnftbl 2/((q)+20)
  