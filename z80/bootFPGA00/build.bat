cp ../../fpga/current/quartus/main.rbf ./

..\..\tools\mhmt\mhmt main.rbf main.mlz

call mk.bat bootFPGA

..\..\tools\addcrc\addcrc -n bootFPGA.bin bootFPGA.crc


