# zLinux perf scripts

## Description

zLinux perf scripts are a set of scripts used to collect performance data for
futher analysis.

## Deployment

Copy the binary of nmon_zLinux_rhel8 to /usr/bin, give permission to execute
and create a symbolic link.
```
# chmod +x /usr/bin/nmon_zLinux_rhel8
# ln -s /usr/bin/nmon_zLinux_rhel8 /usr/bin/nmon
```

Create the directory /usr/local/scripts and copy scripts and give execute
permission
```
# mkdir -p /usr/local/scripts
# chmod +x /usr/local/scripts/*.sh
```

Add the following entries in root's crontab
```
# zLinux perf scripts
0,10,20,30,40,50 * * * * /usr/local/scripts/monitor_col_nmon.sh > /var/log/monitor_col_nmon.log 2>&1
0,10,20,30,40,50 * * * * /usr/local/scripts/monitor_col_dasdstat.sh > /var/log/monitor_col_dasdstat.log 2>&1
0,10,20,30,40,50 * * * * /usr/local/scripts/monitor_col_iostat.sh > /var/log/monitor_col_iostat.log 2>&1
```

Every 10 minutes the monitoring scripts are executed from crontab, they check
if data collection is already in execution. If not they execute the script that
actually does the data collection. Usually is expected to have one file per day
unless the servers are restarted or something else happens.

All data is generated at /var/perf

Once in execution, this is supposed to be seeing.
```
# ps -ef | grep stat
  root      231737       1  0 01:50 ?        00:00:00 /bin/bash /usr/local/scripts/col_iostat.sh
  root      231754  231737  0 01:50 ?        00:00:00 iostat -cdkNtx 60 1329
  root      233310       1  0 02:12 ?        00:00:00 /bin/bash /usr/local/scripts/col_dstat.sh
  root      233377  233310  0 02:12 ?        00:00:02 python3 /usr/bin/dstat -t -afvr --nocolor --output=/var/perf/dstat/dstat_teste.ibm.com_20210326_021254.dst 60 1307
  root      236919       1  0 02:40 ?        00:00:01 /bin/bash /usr/local/scripts/col_dasdstat.sh
  root      302969  302942  0 09:15 pts/0    00:00:00 grep --color=auto stat
```

If you are going to run I/O tests with Spectrum Scale (former GPFS), check if
Spectrum Scale's Perfmon counters are enabled:
```
# mmperfmon config show | egrep -B1 "period = 0"
```

If the following performance counters are disabled, please enable it:
- Diskstat
- GPFSDisk
- GPFSPoolIO
- GPFSIOC
- GPFSvFLUSH
- GPFSMutex
- GPFSCondvar  

```
# mmperfmon config update Diskstat.period=1
# mmperfmon config update GPFSDisk.period=1
# mmperfmon config update GPFSPoolIO.period=1
# mmperfmon config update GPFSIOC.period=1
# mmperfmon config update GPFSvFLUSH.period=1
# mmperfmon config update GPFSMutex.period=1
# mmperfmon config update GPFSCondvar.period=1
```

We use fio as I/O load tool to simulate I/O workload. For you install:
```
# yum install -y fio
```

Here are some workload tests that we run for initial evaluation
- Write sequential, 4kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/write-4kb-16thr-256dep.fio   
[write-4kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=write   
bs=4k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/write-4kb-16thr-256dep.fio
```

- Write random, 4kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/readrand_4kb_16thr_256dep.fio   
[writerand-4kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=writeread   
bs=4k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/readrand_4kb_16thr_256dep.fio
```

- Read sequential, 4kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/read-4kb-16thr-256dep.fio   
[read-4kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=read   
bs=4k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/read-4kb-16thr-256dep.fio
```

- Read random, 4kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/readrand_4kb_16thr_256dep.fio   
[readrand-4kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=4k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/readrand_4kb_16thr_256dep.fio
```

- Write sequential, 128kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/write_128kb_16thr_256dep.fio   
[write-128kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=write   
bs=128k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/write-128kb-16thr-256dep.fio
```

- Write random, 128kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/writerand_128kb_16thr_256dep.fio   
[writerand-128kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randwrite   
bs=128k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/writerand-128kb-16thr-256dep.fio
```

- Read sequential, 128kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/read_128kb_16thr_256dep.fio   
[read-128kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=read   
bs=128k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/read_128kb_16thr_256dep.fio
```

- Read random, 128kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/readrand_128kb_16thr_256dep.fio   
[readrand-128kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=128k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/readrand_128kb_16thr_256dep.fio
```

- Write sequential, 1024kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/write_1024kb_16thr_256dep.fio   
[write-1024kb-16thr-256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=1024k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date

# fio --directory=/ibm/gpfs01 /tmp/write-1024kb-16thr-256dep.fio
```

- Write random, 1024kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/writerand_1024kb_16thr_256dep.fio   
[writerand_1024kb_16thr_256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=1024k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date  

# fio --directory=/ibm/gpfs01 /tmp/writerand_1024kb_16thr_256dep.fio
```

- Read sequential, 1024kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/read_1024kb_16thr_256dep.fio   
[read_1024kb_16thr_256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=1024k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date
 

# fio --directory=/ibm/gpfs01 /tmp/read_1024kb_16thr_256dep.fio
```

- Read random, 1024kb, 16 threads, depth 256   
```
# cat <<EOF > /tmp/readrand_1024kb_16thr_256dep.fio   
[readrand_1024kb_16thr_256dep]   
filename=f50G   
size=50g   
ioengine=libaio   
direct=1   
rw=randread   
bs=1024k   
numjobs=16   
iodepth=256   
end_fsync=1   
EOF  

# date  

# fio --directory=/ibm/gpfs01 /tmp/readrand_1024kb_16thr_256dep.fio
```

To send data collected during performance tests, tar /var/perf directory and
send via IBM Box for further analysis.
```
# cd /var/perf
# tar -zcvf /tmp/zLinux_data_col.tgz *
```

To collect perf data from Scale:
```
# mmdumpperfdata --removetree 7200
```

Obs.: This value is in seconds. In case of period of tests takes more than two
hour, please make the right correction.
