#! /bin/sh

# Copyright (C) 2001 by Martin Pool <mbp@samba.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version
# 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


# rsync top-level test script -- this invokes all the other more
# detailed tests in order.  This script can either be called by `make
# check' or `make installcheck'.  `check' runs against the copies of
# the program and other files in the build directory, and
# `installcheck' against the installed copy of the program.  

# In either case we need to also be able to find the source directory,
# since we read test scripts and possibly other information from
# there.

# Whenever possible, informational messages are written to stdout and
# error messages to stderr.  They're separated out by the build farm
# display scripts.

# According to the GNU autoconf manual, the only valid place to set up
# directory locations is through Make, since users are allowed to (try
# to) change their mind on the Make command line.  So, Make has to
# pass in all the values we need.

# For other configured settings we read ./config.sh, which tells us
# about shell commands on this machine and similar things.

# rsync_bin gives the location of the rsync binary.  This is either
# builddir/rsync if we're testing an uninstalled copy, or
# install_prefix/bin/rsync if we're testing an installed copy.  On the
# build farm rsync will be installed, but into a scratch /usr.

# srcdir gives the location of the source tree, which lets us find the
# build scripts.  At the moment we assume we are invoked from the
# source directory.

# This script must be invoked from the build directory.  

# A scratch directory, 'testtmp', is created in the build directory to
# hold working files.

# Both this script and the Makefile have to be pretty conservative
# about which Unix features they use.  

# Exit codes: (passed back to build farm):

#    1  tests failed
#    2  error in starting tests


set -e

. "./shconfig"


echo "============================================================"
echo "$0 running in `pwd`"
echo "    rsync_bin=$rsync_bin"
echo "    srcdir=$srcdir"

if ! test -f $rsync_bin
then
    echo "rsync_bin $rsync_bin is not a file" >&2
    exit 2
fi

if ! test -d $srcdir
then
    echo "srcdir $srcdir is not a directory" >&2
    exit 2
fi


export rsync_bin

skipped=0
missing=0
passed=0
failed=0

scratchdir=./testtmp
[ -d "$scratchdir" ] && rm -r "$scratchdir"
mkdir "$scratchdir"

echo "    scratchdir=$scratchdir"
suitedir="$srcdir/testsuite"

for testbase in rsync-hello hands
do
    testscript="$suitedir/$testbase.test"
    if test \! -f "$testscript" 
    then
	echo "$testscript does not exist" >&2
	missing=`expr $missing + 1`
	continue
    fi

    echo "------------------------------------------------------------"
    echo "----- $testbase running"

    if sh "$testscript"
    then
	echo "----- $testbase completed succesfully"
	passed=`expr $passed + 1`
    else
	echo "----- $testbase failed!"
	failed=`expr $failed + 1`
    fi	
done

echo '------------------------------------------------------------'
echo "----- overall results:"
echo "      $passed passed"
echo "      $failed failed"
echo "      $skipped skipped"
echo "      $missing missing"
echo '------------------------------------------------------------'

if test $failed -gt 0
then
    exit 1
else
    exit 0
fi
