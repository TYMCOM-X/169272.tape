"/Discreminate between WAKE UUO and EXIT/
400<excflg:
picon:
config 40/	pat0:
.!setz t2,
.+1!tlne t1,hibwku
.+1!tro t2,wakflg
.+1!tlne t1,hibfex
.+1!tro t2,excflg
.+1!jrst hibnty+4
.+1!pat1:
hibnty+3/jrst pat0
errcon:
hlttrp+3/q+2/movei t1,excflg
clock1:
jsclr/q+excflg
config+40/(q)+pat1-q,,pat1
./
pat1k
7tcnftbl 2/((q)+20)
    