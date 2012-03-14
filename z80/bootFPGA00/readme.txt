... everything here must fit into 32k totally!
... requires ASL asm to be in this dir (.exe, .dll, .msg), addcrc.exe

 bootFPGA - начальный загрузчик прошивки FPGA.

Как слепить загрузчик и прошивку:

1. запаковать main.rbf (длиной 59215 байт) MegaLZом: megalz main.rbf main.mlz
2. скомпилять bootFPGA asl'ом: mk bootFPGA
3. посчитать CRC: addcrc -n bootFPGA.bin bootFPGA.crc
4. полученный файл bootFPGA.crc прошить в начало последних 64кб флешки (по адресу flashsize-65536)



