#! /bin/bash
# Copyright (C) 2014 Red Hat, Inc.
# This file is part of elfutils.
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# elfutils is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. $srcdir/backtrace-subr.sh

tempfiles deleted deleted-lib.so
cp -p ${abs_builddir}/deleted ${abs_builddir}/deleted-lib.so .

# We don't want to run the deleted process under valgrind then
# stack will see the valgrind process backtrace.
OLD_VALGRIND_CMD="$VALGRIND_CMD"
unset VALGRIND_CMD

pid=$(testrun ${abs_builddir}/deleted)
sleep 1
rm -f deleted deleted-lib.so
tempfiles bt bt.err

set VALGRIND_CMD="$OLD_VALGRIND_CMD"
# It may have non-zero exit code with:
# .../elfutils/src/stack: dwfl_thread_getframes tid 26376 at 0x4006c8 in .../elfutils/tests/deleted: no matching address range
testrun ${abs_top_builddir}/src/stack -p $pid 1>bt 2>bt.err || true
cat bt bt.err
kill -9 $pid
wait
check_native_unsupported bt.err deleted
grep -qw libfunc bt
grep -qw main bt
