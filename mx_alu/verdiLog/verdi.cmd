simSetSimulator "-vcssv" -exec \
           "/home/ohlbur/ee477/ocp_mx_alu/mx_alu/build/sim-rtl-rundir/simv" \
           -args
debImport "-full64" "-dbdir" \
          "/home/ohlbur/ee477/ocp_mx_alu/mx_alu/build/sim-rtl-rundir/simv.daidir"
debLoadSimResult \
           /home/ohlbur/ee477/ocp_mx_alu/mx_alu/build/sim-rtl-rundir/waveform.fsdb
wvCreateWindow
srcHBSelect "testbench.dut.alu" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.dut.alu" -delim "."
srcHBSelect "testbench.dut.alu" -win $_nTrace1
srcSignalView -on
srcSignalViewExpand "testbench.dut.alu.curr_e\[4:0\]"
srcSignalViewCollapse "testbench.dut.alu.curr_e\[4:0\]"
srcSignalViewSelect "testbench.dut.alu.curr_e\[4:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "testbench.dut.alu.curr_m\[1:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "testbench.dut.alu.sign"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetCursor -win $_nWave2 24.991563 -snap {("G2" 0)}
wvZoom -win $_nWave2 54.981027 58.666083
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetRadix -win $_nWave2 -format Bin
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetRadix -win $_nWave2 -format Bin
wvSelectGroup -win $_nWave2 {G2}
verdiWindowResize -win $_Verdi_1 "278" "209" "1135" "700"
srcSignalViewExpand "testbench.dut.alu.curr"
srcSignalViewExpand "testbench.dut.alu.curr.exponent\[4:0\]"
srcSignalViewCollapse "testbench.dut.alu.curr.exponent\[4:0\]"
srcSignalViewExpand "testbench.dut.alu.curr.exponent\[4:0\]"
srcSignalViewSelect "testbench.dut.alu.curr.exponent\[0\]"
srcSignalViewCollapse "testbench.dut.alu.curr.exponent\[4:0\]"
srcSignalViewCollapse "testbench.dut.alu.curr"
srcSignalViewExpand "testbench.dut.alu.curr"
srcSignalViewCollapse "testbench.dut.alu.curr"
srcSignalViewExpand "testbench.dut.alu.inA"
srcSignalViewCollapse "testbench.dut.alu.inA"
srcSignalViewSelect "testbench.dut.alu.inA"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 "testbench/dut/alu/inA"
srcSignalViewSelect "testbench.dut.alu.inA"
srcSignalViewExpand "testbench.dut.alu.inA"
srcSignalViewSelect "testbench.dut.alu.inA.scale\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 "testbench/dut/alu/inA/scale\[7:0\]"
srcSignalViewSelect "testbench.dut.alu.inA.elements\[31:0\]"
wvAddSignal -win $_nWave2 "testbench/dut/alu/inA/elements\[31:0\]"
srcSignalViewSelect "testbench.dut.alu.inA.scale\[7:0\]"
debExit
