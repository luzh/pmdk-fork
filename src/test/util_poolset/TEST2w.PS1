#
# Copyright 2015-2019, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# src/test/util_poolset/TEST2w -- unit test for util_pool_open()
#

. ..\unittest\unittest.ps1

require_test_type medium
require_fs_type non-pmem

setup

$Env:TEST_LOG_LEVEL = "4"
$Env:TEST_LOG_FILE = "test$Env:UNITTEST_NUM.log"

$MIN_POOL = 4 * 1024 * 1024 # 4MiB
$MIN_POOL_STR = ${MIN_POOL}.toString() + "B" # 4MiB

# prepare pool sets
create_poolset $DIR\testset1 ${MIN_POOL_STR}:$DIR\testfile11:x ${MIN_POOL_STR}:$DIR\testfile12:x
create_poolset $DIR\testset2 ${MIN_POOL_STR}:$DIR\testfile21:x ${MIN_POOL_STR}:$DIR\testfile22:x
create_poolset $DIR\testset3 ${MIN_POOL_STR}:$DIR\testfile31:x ${MIN_POOL_STR}:$DIR\testfile32:x
create_poolset $DIR\testset4 ${MIN_POOL_STR}:$DIR\testfile41:x ${MIN_POOL_STR}:$DIR\testfile42:x
create_poolset $DIR\testset5 ${MIN_POOL_STR}:$DIR\testfile51:x ${MIN_POOL_STR}:$DIR\testfile52:x
create_poolset $DIR\testset6 ${MIN_POOL_STR}:$DIR\testfile61:x ${MIN_POOL_STR}:$DIR\testfile62:x
create_poolset $DIR\testset7 ${MIN_POOL_STR}:$DIR\testfile71:x ${MIN_POOL_STR}:$DIR\testfile72:x
create_poolset $DIR\testset8 ${MIN_POOL_STR}:$DIR\testfile81:x ${MIN_POOL_STR}:$DIR\testfile82:x
create_poolset $DIR\testset9 ${MIN_POOL_STR}:$DIR\testfile91:x ${MIN_POOL_STR}:$DIR\testfile92:x
create_poolset $DIR\testset10 ${MIN_POOL_STR}:$DIR\testfile101:x ${MIN_POOL_STR}:$DIR\testfile102:x
create_poolset $DIR\testset11 ${MIN_POOL_STR}:$DIR\testfile111:x ${MIN_POOL_STR}:$DIR\testfile112:x
create_poolset $DIR\testset12 ${MIN_POOL_STR}:$DIR\testfile121:x ${MIN_POOL_STR}:$DIR\testfile122:x

# create pool sets
expect_normal_exit $Env:EXE_DIR\util_poolset$Env:EXESUFFIX c $MIN_POOL `
    $DIR\testset1 $DIR\testset2 `
    $DIR\testset3 $DIR\testset4 `
    $DIR\testset5 $DIR\testset6 `
    $DIR\testset7 $DIR\testset8 `
    $DIR\testset9 $DIR\testset10 `
    $DIR\testset11 $DIR\testset12

# inject some errors
&$PMEMSPOIL $DIR\testfile22 pool_hdr.checksum=0
&$PMEMSPOIL $DIR\testfile32 pool_hdr.signature="ERROR" "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile42 pool_hdr.major=99 "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile52 pool_hdr.arch_flags="0000000000000000" "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile62 pool_hdr.features.compat=0x12345678 "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile72 pool_hdr.features.compat=0x12345678 "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile82 pool_hdr.features.compat=0x12345678 "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile91 pool_hdr.poolset_uuid="0123456789012345" "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile101 pool_hdr.next_part_uuid="0123456789012345" "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile111 pool_hdr.prev_part_uuid="0123456789012345" `
    pool_hdr.next_part_uuid="0123456789012345" "pool_hdr.checksum_gen()"
&$PMEMSPOIL $DIR\testfile121 pool_hdr.next_repl_uuid="0123456789012345" "pool_hdr.checksum_gen()"

# now check if pool sets may be opened
expect_normal_exit $Env:EXE_DIR\util_poolset$Env:EXESUFFIX o $MIN_POOL `
    $DIR\testset1 $DIR\testset2 `
    $DIR\testset3 $DIR\testset4 `
    $DIR\testset5 $DIR\testset6 `
    $DIR\testset7 $DIR\testset8 `
    $DIR\testset9 $DIR\testset10 `
    $DIR\testset11 $DIR\testset12

sls -Path $Env:TEST_LOG_FILE -Pattern "<1>" | `
    %{[string]$_ -replace '^.* len ',"" -replace '^.*][ ]*',''} `
    > grep$Env:UNITTEST_NUM.log

check

pass
