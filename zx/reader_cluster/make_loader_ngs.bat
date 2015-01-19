@ECHO OFF

..\..\tools\asw\asw -U -L reader_cluster.a80
..\..\tools\asw\p2bin reader_cluster.p reader_cluster.rom -r $-$ -k

..\..\tools\asw\asw -U -L make_hobeta.a80
..\..\tools\asw\p2bin make_hobeta.p RD_CLS.$C -r $-$ -k

pause