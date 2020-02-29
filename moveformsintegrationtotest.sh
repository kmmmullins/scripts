#!/bin/bash
#
#
#

##################
#
# TAS Forms
#
##################


for form  in  TSABADET.fmx TSABAHDR.fmx TSABALTR.fmx TSABAREV.fmx TSADCDEF.fmx TSAMASS.fmx TSAPPPCT.fmx TSIBAMEM.fmx TSRBASCF.fmx TSRSTGRP.fmx

do
echo $form;


#scp oracle@forms-test-app-1:/sis/mitsis/applications/forms/TAS/$form /sis/mitsis/applications/forms/TAS/
scp oracle@forms-dev-app-1:/sis/integration/mitsis/forms/TAS/$form /sis/mitsis/applications/forms/TAS/

done

echo " moved TAS forms"


##################
#
# GENForms
#
##################


for form  in GTAGPADM.fmx

do
echo $form;

#scp oracle@forms-test-app-1:/sis/mitsis/applications/forms/GEN/$form /sis/mitsis/applications/forms/GEN/
scp oracle@forms-dev-app-1:/sis/integration/mitsis/forms/GEN/$form /sis/mitsis/applications/forms/GEN/


done


echo " moved GEN forms"

#################
#
# RES Forms
#
##################

for form  in  RFRMGMT.fmx ROAFAINT.fmx ROAINST.fmx ROASTAT.fmx RORDILLT.fmx RPAAWRD.fmx RPADISUM.fmx RPIDIRES.fmx RPIOSREC.fmx RPIPAELG.fmx RPIPARES.fmx RPRGASTI.fmx RPRLOPT.fmx RPROPTS.fmx RRAAREQ.fmx RRAMLPNR.fmx

do
echo $form;


#scp oracle@forms-test-app-1:/sis/mitsis/applications/forms/RES/$form /sis/mitsis/applications/forms/RES/
scp oracle@forms-dev-app-1:/sis/integration/mitsis/forms/RES/$form /sis/mitsis/applications/forms/RES/

done


echo " moved RES forms"
##################
#
# SAT Forms
#
##################

for form  in  SCASUBJB.fmx SCASUBJI.fmx SDAAUNSA.fmx SDAAUNSR.fmx SDAAUPRF.fmx SDAAUSRQ.fmx SDAAUSUB.fmx SFAREADM.fmx SFARECOU.fmx SFAREDET.fmx SFAREGIS.fmx SFAREPRE.fmx SFASTINF.fmx SFATUITN.fmx SFRRELOD.fmx SFRREMSG.fmx SFRRETIM.fmx SFRSDRLS.fmx SFRTUADJ.fmx SFRTUBCD.fmx SFRTUBCR.fmx SFRTUCAL.fmx SGASTDAC.fmx SGASTINT.fmx SGTGPTRM.fmx SHACRREQ.fmx SHADEGAW.fmx SHADEGRE.fmx SHAGRDEF.fmx SHAGREXP.fmx SHASTMIN.fmx SHASTNSE.fmx SHRDETRN.fmx  SLABLDG.fmx SLAEVNT.fmx SLAHMBLD.fmx SLAHMRMS.fmx SLARDEF.fmx SLARMAP.fmx SLARMAT.fmx SLIEVAVR.fmx SLIRAUTL.fmx SMAIASPP.fmx SORRCCSR.fmx SORRCGRP.fmx SPAPEACD.fmx SPAPEADR.fmx SPAPEAPC.fmx SPIPEADS.fmx SPRMLRUL.fmx SSASUSUB.fmx STVDEGRE.fmx STVPEADC.fmx STVPEADT.fmx


do
echo $form;

#scp oracle@forms-test-app-1:/sis/mitsis/applications/forms/SAT/$form /sis/mitsis/applications/forms/SAT/
scp oracle@forms-dev-app-1:/sis/integration/mitsis/forms/SAT/$form /sis/mitsis/applications/forms/SAT/



done


echo " moved SAT forms"


exit

############################
#
# First Pass
#
############################
#GJAJOBS.fmx GTAGPVMS.fmx GTVGPUSR.fmx GUAMENU.fmx
#RBAABUD.fmx RBIBUDG.fmx RFIBUDG.fmx RFRASCH.fmx RFRBASE.fmx RFRBASE.fmx RFRDEFA.fmx RFRMGMT.fmx RHARQST.fmx RHIAFSH.fmx RHIAFSH.fmx ROAINST.fmx ROAINST.fmx ROASTAT.fmx ROASTAT.fmx RORFFSUB.fmx RORTPRD.fmx RPAAWRD.fmx RPADISUM.fmx RPAFAPMT.fmx RPAOSCHK.fmx RPIATRM.fmx RPIFAREC.fmx RPIGAWRK.fmx RPIOSREC.fmx RPRFAMGT.fmx RPRGACTL.fmx RPRLOPT.fmx RPRLPRD.fmx RPRLPRD.fmx RPRPACLS.fmx RRAAREQ.fmx RRAAREQ.fmx
#SCASUBJI.fmx SCASUBJI.fmx SCRSUMRU.fmx SCRSUMRU.fmx SDAAUNSR.fmx SDAAUPRF.fmx SDAAUREO.fmx SDAAUSRQ.fmx SDAAUSUB.fmx SDIAUARQ.fmx SDRAUPGC.fmx SFAREDET.fmx SFAREGIS.fmx SFASTINF.fmx SFASTINF.fmx SFATUITN.fmx SFRTUBCR.fmx SFRTUBCT.fmx SFRTUPRO.fmx SGASTINT.fmx SHAGRDEF.fmx SHASTNSE.fmx SHRGRAPP.fmx SIAADVIN.fmx SIIADVIN.fmx SLAASCD.fmx SLABLDG.fmx SLABQRY.fmx SLAEVNT.fmx SLALMFE.fmx SLARDEF.fmx SLARDEF.fmx SLIEVAVR.fmx SLIEVRUD.fmx SLIMADRM.fmx SLIMASGS.fmx SLIRAUTL.fmx SOIHOLD.fmx SPAEMRG.fmx SPAEMRG.fmx SPAPEACD.fmx SPAPEACF.fmx SPAPEADR.fmx SPAPEAPC.fmx STVAFOFC.fmx STVCOURS.fmx STVDEPT.fmx STVHLDD.fmx STVPEREL.fmx STVSTMIN.fmx STVSUBJ.fmx STVTERM.fmx STVTUBAS.fmx STVTUTUC.fmx
#TGACREV.fmx TSABAARC.fmx TSABADET.fmx TSABAREV.fmx  TSABASAR.fmx TSADCDEF.fmx TSADCDEF.fmx TSASPDEF.fmx TSASPDEF.fmx TSIBADIS.fmx TSIBAMEM.fmx TSRBAARA.fmx TSRBAREP.fmx TSRBARRR.fmx TSRBASCF.fmx TSRBASCF.fmx TTVBAADJ.fmx TTVBADIS.fmx

############################
#
# Second Pass
#
############################
# RBAABUD.fmx ROAINST.fmx ROASTAT.fmx RORPOST.fmx RORTPRD.fmx RPIDIRES.fmx RPRFAMGT.fmx RPRLOPT.fmx RRAMLOAN.fmx
# SFAREADM.fmx SFARECOU.fmx SFAREDET.fmx SFAREGIS.fmx SFAREGRT.fmx SFATUITN.fmx SFIRECOU.fmx SFRRELOD.fmx SFRTUBCR.fmx  SGTGPTRM.fmx SHAGREXP.fmx SHAGRVER.fmx SPAPEADR.fmx SPAPEAPC.fmx SSASUSUB.fmx STVCOURS.fmx STVDEGRE.fmx STVDETYP.fmx STVDEULT.fmx STVPEADT.fmx STVPEAPD.fmx
# TSABASUS.fmx TSAPPPCT.fmx TSAPPVAR.fmx TSASTMSG.fmx TTVSTTYP.fmx 

#TSABASUS.fmx TSAPPPCT.fmx TSAPPVAR.fmx TSASTMSG.fmx TTVSTTYP.fmx 
#RBAABUD.fmx ROAINST.fmx ROASTAT.fmx RORPOST.fmx RORTPRD.fmx RPIDIRES.fmx RPRFAMGT.fmx RPRLOPT.fmx RRAMLOAN.fmx
#SFAREADM.fmx SFARECOU.fmx SFAREDET.fmx SFAREGIS.fmx SFAREGRT.fmx SFATUITN.fmx SFIRECOU.fmx SFRRELOD.fmx SFRTUBCR.fmx  SGTGPTRM.fmx SHAGREXP.fmx SHAGRVER.fmx SPAPEADR.fmx SPAPEAPC.fmx SSASUSUB.fmx STVCOURS.fmx STVDEGRE.fmx STVDETYP.fmx STVDEULT.fmx STVPEADT.fmx STVPEAPD.fmx

