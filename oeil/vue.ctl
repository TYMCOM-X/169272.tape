:LOGFILE vue.log
:Parameters start-address=730000
compile /cross(monitor) @vue.cmd
:com vuelnk.ctl "vue/ssave ="
:com vuelnk.ctl "dvue/map/ssave = /locals dsk:ddt,"
:com vuelnk.ctl "/set:.high.:\start-address XVUE/ssave ="
:escape
r filex
vue.exe=xvue.shr
:escape
delete xvue.shr,xvue.low
cross
   