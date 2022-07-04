#! /bin/bash

if [ "$1" ]; then
    number_test=$1
else
    number_test=10
fi

main_dir=$(pwd)
echo > tmp.txt
array_of_dir=""
for i in `seq 1 $number_test`
do
    DATE=$(date +%s_%N)
    dir_name="dir-$DATE"
    array_of_dir="$array_of_dir $dir_name"
    mkdir $dir_name
    seed=$RANDOM
    echo "Using seed: $seed"
    # xsim control_tb_top --stats -tclbatch /home/developer/code/common/utils/xsim.tcl --testplusarg UVM_TESTNAME=control_test -sv_seed $seed  
    echo "Running: cd $dir_name && ln -s ../xsim.dir . && xsim control_tb_top --stats -tclbatch /home/developer/code/common/utils/xsim.tcl --testplusarg UVM_TESTNAME=control_test  -sv_seed $seed  > run_$dir_name.log " 
    cd $dir_name && ln -s ../xsim.dir . && xsim control_tb_top --stats -tclbatch /home/developer/code/common/utils/xsim.tcl --testplusarg UVM_TESTNAME=control_test  -sv_seed $seed  > run_$dir_name.log
    cd ../
done

#Test para correr en paralelo, todas corren con la misma semilla :(
# echo "Waiting for jobs to finish :)"
# cat tmp.txt | xargs -I CMD --max-procs=3 bash -c CMD
# rm tmp.txt
# echo $array_of_dir


echo "Post processing"
for carp in $array_of_dir
do
    echo $carp
    cd $carp && python3 /home/developer/code/common/utils/test_status.py && cd $main_dir
done
echo all Tests are done!
