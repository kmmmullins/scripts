#!/bin/sh
#-------------------------------------------------------------------------------
#  svn checkout
#-------------------------------------------------------------------------------

# checkout for forms-dev-app-1 mitsis/forms
# cd $HOME
# kinit
# svn checkout svn+ssh://svn.mit.edu/sais-sis-mitsis/mitsis/trunk/forms  mitsis/forms
# after checkout - just use "svn up mitsis/forms" to keep current


# checkout for eart-app-2 mitsis
# cd $HOME
# kinit
# svn checkout svn+ssh://svn.mit.edu/sais-sis-mitsis/mitsis/trunk  mitsis
# after checkout - just use "svn up mitsis"  to keep current


OPTIND=1
 projectname=
 dirname=
 pathname=

while getopts :p:d:x:   opt
do
    case $opt in
        p) projectname="$OPTARG";;
        d) dirname="$OPTARG";;
        x) pathname="$OPTARG";;
        *) ;;
    esac
done

 repositoryname="sais-sis-${projectname}"
if [[ -n "$pathname" ]]; then
              pathname="/"${pathname}
fi
if [[ -z "$dirname" ]]; then
              dirname=$projectname$pathname
fi

svn checkout svn+ssh://svn.mit.edu/${repositoryname}/${projectname}/trunk${pathname}  ${dirname}

exit

