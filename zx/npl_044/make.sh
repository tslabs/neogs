#!/bin/bash

wine ~/d/ngs/tools/asw/asw -U -L play4ngs.a80
wine ~/d/ngs/tools/asw/p2bin play4ngs.p play4ngs.rom -r \$-\$ -k

mhmt -mlz play4ngs.rom play4ngs_pack.rom

wine ~/d/ngs/tools/asw/asw -U -L unp_play4ngs.a80
wine ~/d/ngs/tools/asw/p2bin unp_play4ngs.p unp_play4ngs.rom -r \$-\$ -k

wine ~/d/ngs/tools/asw/asw -U -L play_ngs.a80
wine ~/d/ngs/tools/asw/p2bin play_ngs.p play_ngs.rom -r \$-\$ -k

mhmt -mlz play_ngs.rom play_ngs_pack.rom

wine ~/d/ngs/tools/asw/asw -U -L make_scl.a80
wine ~/d/ngs/tools/asw/p2bin make_scl.p npl044.scl -r \$-\$ -k

wine ~/d/ngs/tools/asw/asw -U -L make_hobeta.a80
wine ~/d/ngs/tools/asw/p2bin make_hobeta.p NPL044.\$C -r \$-\$ -k

