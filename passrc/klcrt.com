;klcrt.com, last modified 5/31/83, zw
;create TYM-Pascal system on a KL10
:
:time 300
:
copy PKLINI.ENV, P10INI.ENV 
copy MKLDLP.LOW, MDLPRO.LOW 
copy MKLDLP.SHR, MDLPRO.SHR 
copy MKLDLP.EXE, MDLPRO.EXE 
copy NKLCRT.COM, NLBCRT.COM 
copy IKLCRT.COM, ILBCRT.COM 
copy RKLCRT.COM, RDNCRT.COM 
copy MKLDLS.PAS, MMMDLS.PAS 
copy OKLMAC.COM, ODMMAC.COM 
copy OKLMAC.CMD, ODMMAC.CMD 
copy OKLBLD.COM, ODMBLD.COM 
copy OKLLSD.COM, ODMLSD.COM 
copy PKLCAL.BLD, PASCAL.BLD 
copy PKLINI.PAS, PASINI.PAS 
copy KLCRT.OLD, PASCRT.OLD
copy KLRES, PASRES
:
:com nlbcrt.com
:
:com ilbcrt.com
:
:com rdncrt.com
:
:com odmcrt.com
:
:com pmfcrt.com
:
:com cmlcrt.com
    