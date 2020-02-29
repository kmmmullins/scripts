#!/bin/sh

export ORACLE_HOME=/oracle/product/middleware/forms
export PATH=/oracle/product/middleware/formshome/bin:/oracle/product/middleware/forms/bin:${PATH}
export JAVA_HOME=/oracle/product/middleware/forms/jdk/bin/java
export CLASSPATH=/oracle/product/middleware/forms/jlib/frmxmltools.jar:/oracle/product/middleware/forms/jlib/frmjdapi.jar:/oracle/product/middleware/forms/lib/xmlparserv2.jar:/oracle/product/middleware/forms/lib/xschema.jar
export TNS_ADMIN=/oracle/product/middleware/forms/network/admin/
export XMLTOOL=oracle.forms.util.xmltools.Forms2XML




