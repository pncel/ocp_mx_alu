#pwsh

$output_vvp="simv"
$design_dir="../../src/v"
$tb_dir="."
$high_tb_dir=".."

iverilog -g2012 -o $output_vvp `
    -I $design_dir `
    "$high_tb_dir/transection.sv" `
    "$tb_dir/mx_int8_bd_mon.sv" `
    "$tb_dir/mx_int8_bd_drv.sv" `
    "$tb_dir/mx_int8_bd_ref.sv"
    "$tb_dir/tb_mxint8_bd.sv"

vvp -n $output_vvp > test.log

