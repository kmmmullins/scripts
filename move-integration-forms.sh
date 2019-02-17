#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for form  in GJAJOBS.fmx GTAGPVMS.fmx GTVGPUSR.fmx GUAMENU.fmx

do
echo $form;

cd /sis/integration/mitsis/forms/GEN

scp $form  oracle@forms-test-app-1:/sis/mitsis/applications/forms/GEN/;
ssh oracle@forms-test-app-1 "ls -lart /sis/mitsis/applications/forms/GEN/*"


done

#GJAJOBS.fmx GTAGPVMS.fmx GTVGPUSR.fmx GUAMENU.fmx

#RBAABUD.fmx RBIBUDG.fmx RFIBUDG.fmx RFRASCH.fmx RFRBASE.fmx RFRBASE.fmx RFRDEFA.fmx RFRMGMT.fmx RHARQST.fmx RHIAFSH.fmx RHIAFSH.fmx ROAINST.fmx ROAINST.fmx ROASTAT.fmx ROASTAT.fmx RORFFSUB.fmx RORTPRD.fmx RPAAWRD.fmx RPADISUM.fmx RPAFAPMT.fmx RPAOSCHK.fmx RPIATRM.fmx RPIFAREC.fmx RPIGAWRK.fmx RPIOSREC.fmx RPRFAMGT.fmx RPRGACTL.fmx RPRLOPT.fmx RPRLPRD.fmx RPRLPRD.fmx RPRPACLS.fmx RRAAREQ.fmx RRAAREQ.fmx

#SCASUBJI.fmx SCASUBJI.fmx SCRSUMRU.fmx SCRSUMRU.fmx SDAAUNSR.fmx SDAAUPRF.fmx SDAAUREO.fmx SDAAUSRQ.fmx SDAAUSUB.fmx SDIAUARQ.fmx SDRAUPGC.fmx SFAREDET.fmx SFAREGIS.fmx SFASTINF.fmx SFASTINF.fmx SFATUITN.fmx SFRTUBCR.fmx SFRTUBCT.fmx SFRTUPRO.fmx SGASTINT.fmx SHAGRDEF.fmx SHASTNSE.fmx SHRGRAPP.fmx SIAADVIN.fmx SIIADVIN.fmx SLAASCD.fmx SLABLDG.fmx SLABQRY.fmx SLAEVNT.fmx SLALMFE.fmx SLARDEF.fmx SLARDEF.fmx SLIEVAVR.fmx SLIEVRUD.fmx SLIMADRM.fmx SLIMASGS.fmx SLIRAUTL.fmx SOIHOLD.fmx SPAEMRG.fmx SPAEMRG.fmx SPAPEACD.fmx SPAPEACF.fmx SPAPEADR.fmx SPAPEAPC.fmx STVAFOFC.fmx STVCOURS.fmx STVDEPT.fmx STVHLDD.fmx STVPEREL.fmx STVSTMIN.fmx STVSUBJ.fmx STVTERM.fmx STVTUBAS.fmx STVTUTUC.fmx

#TGACREV.fmx TSABAARC.fmx TSABADET.fmx TSABAREV.fmx  TSABASAR.fmx TSADCDEF.fmx TSADCDEF.fmx TSASPDEF.fmx TSASPDEF.fmx TSIBADIS.fmx TSIBAMEM.fmx TSRBAARA.fmx TSRBAREP.fmx TSRBARRR.fmx TSRBASCF.fmx TSRBASCF.fmx TTVBAADJ.fmx TTVBADIS.fmx
