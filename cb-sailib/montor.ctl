; MONTOR.CTL 14-Feb-79
; Compile and add module MONTOR.
;
.path sai:
.com/com montor
.r maklib
*libary=libary/master:montor,montor/replace:montor
*libary=libary/index

; Now for high-segment version.
.com/com montoh=montor(h)
.r maklib
*libarh=libarh/master:montoh,montoh/replace:montoh
*libarh=libarh/index
   