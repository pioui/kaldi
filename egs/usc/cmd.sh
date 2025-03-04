# you can change cmd.sh depending on what type of queue you are using.
# If you have no queueing system and want to run on a local machine, you
# can change all instances 'run.pl' to run.pl (but be careful and run
# commands one by one: most recipes will exhaust the memory on your
# machine).  run.pl works with GridEngine (qsub).  slurm.pl works
# with slurm.  Different queues are configured differently, with different
# queue names and different ways of specifying things like memory;
# to account for these differences you can create and edit the file
# conf/queue.conf to match your queue's configuration.  Search for
# conf/queue.conf in http://kaldi-asr.org/doc/queue.html for more information,
# or search for the string 'default_config' in utils/run.pl or utils/slurm.pl.

export cuda_cmd=run.pl
export cuda_cmd="run.pl --mem 2G"
# the use of cuda_cmd is deprecated, used only in 'nnet1',
export cuda_cmd="run.pl --gpu 1"

if [ "$(hostname -d)" == "fit.vutbr.cz" ]; then
  queue_conf=$HOME/queue_conf/default.conf # see example /homes/kazi/iveselyk/queue_conf/default.conf,
  export cuda_cmd="run.pl --config $queue_conf --mem 2G --matylda 0.2"
  export cuda_cmd="run.pl --config $queue_conf --mem 3G --matylda 0.1"
  export cuda_cmd="run.pl --config $queue_conf --gpu 1 --mem 10G --tmp 40G"
fi
