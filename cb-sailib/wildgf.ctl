; WILDGF.CTL 14-Feb-79
; Compile and add module WILDGF.
;
.path sai:
.com/com wildgf
.r maklib
*libary=libary/master:wildgf,wildgf/replace:wildgf
*libary=libary/index

; Now for high-segment version.
.com/com wildgh=wildgf(h)
.r maklib
*libarh=libarh/master:wildgh,wildgh/replace:wildgh
*libarh=libarh/index
   