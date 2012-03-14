/*
 *  INFO:
 *     tap.cpp (C) 2004  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.2 - 04.01.2004
 *  
 *  
 *  DESCRIPTION:
 *     Contains implementation of TAP class methods.
 *     For more detailed info - see "tap.h"
 *
 *
 *  DISCLAIMER:
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/  

#include "tap.h"

int DP=0x378;           // data port
int SP=0x379;           // status port
int CP=0x37a;           // control port

TAP::TAP(int port, int g_size) {
 status=0;
 DP=port;SP=port+1;CP=port+2;
 oldv=0;
 FD=0;
 g_pos=0;
// SET_CTRL();
 _outp(CP,(1<<_BBMV_ON_));
 g_buf=NULL;
 g_buf=new BYTE[g_size+1];
 if (g_buf==NULL) status=TAP_MEMERR;
}


TAP::~TAP() {
 if (g_buf!=NULL) {delete[] g_buf; g_buf=NULL;}
 _outp(CP,0x00);
}


void TAP::update() {g_buf[g_pos++]=oldv;}

void TAP::realize() {
 DWORD i=0;
 for (i=0;i<g_pos;i++) _outp(DP,g_buf[i]);
 g_pos=0;
}

void TAP::set_bit(int bit, int val) {
 BYTE mask=0x01;
 mask<<=bit;
 oldv=(BYTE)(val)?(oldv|mask):(oldv&(0xff^mask));
}

BYTE TAP::get_bit(int bit) {
 BYTE s=_inp(SP);
 BYTE mask=0x01;
 mask<<=bit;
 return (BYTE)((s&mask)?0:1);
}

void TAP::TCK_CLOCK(int NUM) {
 if (NUM==1) {TCK(1);update();TCK(0);return;}
 for (int i=0;i<(NUM-1);i++) {
     TCK(1);update();TCK(0);update();
 }
 TCK(1);update();TCK(0);    
}

