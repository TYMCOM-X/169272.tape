INF LOG JOB

;Files required to build product
COPY FROM-SOURCE:C.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:C.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:C.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:UUOSYM.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:MACTEN.MAC TO-SOURCE:*.*.-1
COPY FROM-SOURCE:CHEAD.MAC TO-SOURCE:*.*.-1

;Library files used for symbols
COPY FROM-SUBSYS:UUOSYM.UNV TO-SUBSYS:*.*.-1
COPY FROM-SUBSYS:MACTEN.UNV TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SUBSYS:C.UNV TO-SUBSYS:*.*.-1

   