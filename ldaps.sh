#!/bin/bash

ldapsearch -h ldap.mit.edu -x -b dc=mit,dc=edu -LLL uid=$1
