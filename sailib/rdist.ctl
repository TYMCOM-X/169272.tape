:logfile rdist.log
:define $substitution=$true
sysno
run (xexec)minit
rdist *.*/master:32/check
    