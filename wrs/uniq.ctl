:logfile uniq.log
:parameters file recl=81
run trim; \file\=\file\
run sort; \file\=\file\/RECLEN:\recl\
run trim; \file\=\file\
run uniq; \file\=\file\
 