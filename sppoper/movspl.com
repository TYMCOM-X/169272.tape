cop (spool)spool.gdf,same
cop (spool)spool.fdf,same
cop (spool)spool.map,same
cop (spool)splcnt,same
cop (spool)remcnt,same
cop (spool)nodpri,same
cop (spool)priadr,same
cop (*1batch)parchg.dat,same
cop (*1batch)splchg.dat,same
cop (*1batch)reqnum.dat,same
;the following files are system and/or date dependent
cop (*1batch)bat039.feb,same
cop (*1batch)batcan.feb,same
cop (*1batch)splcan.feb,same

 