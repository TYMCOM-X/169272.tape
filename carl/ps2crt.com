:
:time 300
:
cop PKLINI.ENV,P10INI.ENV 
cop MKLDLP.LOW,MDLPRO.LOW 
cop MKLDLP.SHR,MDLPRO.SHR 
cop MKLDLP.EXE,MDLPRO.EXE 
cop NKLCRT.COM,NLBCRT.COM 
cop IKLCRT.COM,ILBCRT.COM 
cop RKLCRT.COM,RDNCRT.COM 
cop MKLDLS.PAS,MMMDLS.PAS 
cop OKLMAC.COM,ODMMAC.COM 
cop OKLMAC.CMD,ODMMAC.CMD 
cop OKLBLD.COM,ODMBLD.COM 
cop OKLLSD.COM,ODMLSD.COM 
cop PKLCAL.BLD,PASCAL.BLD 
cop PKLINI.PAS,PASINI.PAS 
cop 2KLRES,PS2RES
:
:com nlbcrt.com
:
:com ilbcrt.com
:
:com rdncrt.com
:
:com odmcrt.com
:
:com cmlcrt.com
:
    