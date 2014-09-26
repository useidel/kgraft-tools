#!/bin/bash

PATH=/bin:/usr/bin:/usr/local/bin
export PATH

if test -z "$1"; then
    echo "usage: $0 [list of symbols]"
fi

cat <<EOF
/*
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 */


#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kgraft.h>
#include <linux/sched.h>
#include <linux/types.h>
#include <linux/capability.h>
#include <linux/ptrace.h>

EOF

for i in $@; do
	echo 
	echo "/* "
	echo " * Place your changed function here "
	echo " * The name should kgr_new_$i "
	echo " */ "
	echo 
done

cat <<EOF

static struct kgr_patch patch = {
        .name = "my_sample_patcher",
        .owner = THIS_MODULE,
        .patches = {
EOF


for i in $@; do
    echo "		KGR_PATCH($i, kgr_new_$i, true),"
done

cat <<EOF
                KGR_PATCH_END
        }
};

static int __init kgr_patcher_init(void)
{
        return kgr_patch_kernel(&patch);
}

static void __exit kgr_patcher_cleanup(void)
{
        kgr_patch_remove(&patch);
}

module_init(kgr_patcher_init);
module_exit(kgr_patcher_cleanup);

MODULE_LICENSE("GPL");

EOF
