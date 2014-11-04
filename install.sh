#!/usr/bin/env bash

ENABLETEST=true
BUILDALL=false
for arg in "$@"
do
	case "$arg" in
	        noTest)
	            ENABLETEST=false
	            ;;
	        all)
	            BUILDALL=true
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
	echo $'\e[0;31mError: cant fmt '"<$DIRNAME> !" $'\e[0m'
	exit 1
fi
echo "install ..."

go install "$DIRNAME"
if [[ $? -ne 0 ]]; then
	echo $'\e[0;31mError: cant install '"<$DIRNAME> !" $'\e[0m'
	exit 1
fi
if $BUILDALL; then
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install "$DIRNAME"
	if [[ $? -ne 0 ]]; then
		echo $'\e[0;31mError: cant install linux amd64 '"<$DIRNAME> !" $'\e[0m'
		exit 1
	fi
	CGO_ENABLED=0 GOOS=linux GOARCH=386 go install "$DIRNAME"
	if [[ $? -ne 0 ]]; then
		echo $'\e[0;31mError: cant install linux 386'"<$DIRNAME> !" $'\e[0m'
		exit 1
	fi
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go install "$DIRNAME"
	if [[ $? -ne 0 ]]; then
		echo $'\e[0;31mError: cant install windows amd64'"<$DIRNAME> !" $'\e[0m'
		exit 1
	fi
	CGO_ENABLED=0 GOOS=windows GOARCH=386 go install "$DIRNAME"
	if [[ $? -ne 0 ]]; then
		echo $'\e[0;31mError: cant install windows 386'"<$DIRNAME> !" $'\e[0m'
		exit 1
	fi
fi


export GOPATH="$OLDGOPATH"

 
if $ENABLETEST ; then
	cd $SRCDIR
	ALLTESTS=`find . -name "*_test.go"`
	for f in $ALLTESTS  
	do  
		TESTNAME="$( dirname ${f})"
	    echo $TESTNAME  
	    go test $TESTNAME
	    if [[ $? -ne 0 ]]; then
		echo $'\e[0;31mTest Failed! \e[0m'
		exit 1
		fi
	done 
fi


export GOPATH="$OLDGOPATH"
echo $'\e[0;32mInstall success. \e[0m'
echo `ls -l $BINPATH`