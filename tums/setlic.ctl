;Set required protection
declare all run run (mail)mailer.sav,(mail)rdmail.sav
declare all run run (mail)sendma.sav,(mail)tums.sav
;Set required license
r setlic
(MAIL)EXEC.SAV,OP SY WF
start
(MAIL)MAILER.SAV,WC OP SY JL WF
start
(MAIL)MCAUTO.SAV,WC OP SY AC WF
start
(MAIL)ONTMTP.SAV,OP SY AC WF
start
(MAIL)ONTYME.SAV,OP SY AC WF
start
(MAIL)RDMAIL.SAV,OP SY WF
start
(MAIL)SENDMA.SAV,OP SY WF
start
(MAIL)SIGNUP.SAV,OP SY WF
start
(MAIL)SMTP.SAV,WC OP SY JL AC WF
start
(MAIL)SMTPX.SAV,OP SY AC WF
start
(MAIL)TMS.SAV,WC OP SY AC WF
start
(MAIL)TUMS.SAV,OP SY WF
 