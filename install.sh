#!/usr/bin/env bash

ENABLETEST=true
for arg in "$@"
do
	case "$arg" in
	        noTest)
	            ENABLETEST=false
	            ;;
	        *)
	            echo $"Usage: $0 {noTest}"
	            exit 1
	 
	esac
done

echo "test:$ENABLETEST"

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "building ... $SCRIPTPATH"


# get current dir name
DIRNAME=${SCRIPTPATH##*/}
SRCDIR="$SCRIPTPATH""/src"
BINPATH="$SCRIPTPATH""/bin/$DIRNAME"
CURDIR="$SCRIPTPATH"
OLDGOPATH="$GOPATH"
export GOPATH="$CURDIR"

echo "gofmt ..."
gofmt -w "$SRCDIR"
if [[ $? -ne 0 ]]; then
	echo "Error: cant fmt <$SRCDIR> !"
	exit 1
fi
echo "install ..."
go install "$DIRNAME"
if [[ $? -ne 0 ]]; then
	echo "Error: cant install <$DIRNAME> !"
	exit 1
fi

 
if $ENABLETEST ; then
	cd $SRCDIR
	ALLTESTS=`find . -name "*_test.go"`
	for f in $ALLTESTS  
	do  
		TESTNAME="$( dirname ${f})"
	    echo $TESTNAME  
	    go test $TESTNAME
	done 
fi

export GOPATH="$OLDGOPATH"

echo 'Install success.'
echo `ls -l $BINPATH`