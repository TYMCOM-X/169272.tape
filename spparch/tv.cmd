
;Files required to build product
COPY FROM-SOURCE:TV.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:TV.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:TV.MAC TO-SOURCE:*.*.-1

;Documentation for product

;Library files used for symbols
;COPY FROM-SUBSYS:MACREL.REL TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MACSYM.UNV TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MONSYM.UNV TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SOURCE:TV.EXE TO-SUBSYS:*.*.-1
  