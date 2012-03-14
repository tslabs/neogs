/*
 *  INFO:
 *     jtag.cpp (C) 2003  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.5 - 23.11.2003
 *  
 *  
 *  DESCRIPTION:
 *     Contains implementation of JTAG class methods
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

#include "jtag.h"
#include <string.h>

JTAG::JTAG(int mode, int g_size) {
 status=0;
 tap=new TAP(mode,g_size);
 if (tap==NULL) status=TAP_FAILED;
   else status=tap->GetStatus();
}

JTAG::~JTAG() {
 if (tap!=NULL) {delete tap;tap=NULL;}
}

void JTAG::RESET() {
 #ifdef JTAG_LOG
   puts("RESET");
 #endif
 tap->TCK(0);
 tap->TMS(1);
 tap->update();
 tap->TCK_CLOCK(5);
 tap->update();tap->realize();
}


void JTAG::IDLE() {
 #ifdef JTAG_LOG
   puts("IDLE");
 #endif
 tap->TMS(0);tap->update();tap->TCK_CLOCK();
 tap->update();tap->realize();
}

void JTAG::IRSCAN(char * cmd1,char * out1) {
 #ifdef JTAG_LOG
   printf("IRSCAN: %s\n",cmd1);
 #endif
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK(2);
 int i;
// for (i=0;i<strlen((char *)cmd1)-1;i++) {
 for (i=(strlen((char *)cmd1)-1);i>0;i--) {
     tap->update();tap->realize();
     *(out1+i)=tap->TDO()+'0';
     tap->TDI(*(cmd1+i)=='0'?0:1);
     tap->update();tap->TCK_CLOCK();
 }
 tap->update();tap->realize();
 *(out1+i)=tap->TDO()+'0';
 tap->TDI(*(cmd1+i)=='0'?0:1);
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK();
 tap->update();tap->realize();
}

void JTAG::_IRSCAN(char * cmd1) {
 #ifdef JTAG_LOG
   printf("_IRSCAN: %s\n",cmd1);
 #endif
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK(2);
 int i;
// for (i=0;i<strlen((char *)cmd1)-1;i++) {
 for (i=(strlen((char *)cmd1)-1);i>0;i--) {
     tap->TDI(*(cmd1+i)=='0'?0:1);
     tap->update();
     tap->TCK_CLOCK();
 }
 tap->TDI(*(cmd1+i)=='0'?0:1);
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK();
 tap->update();tap->realize();
}

void JTAG::DRSCAN(char * in1,char * out1) {
 #ifdef JTAG_LOG
   printf("DRSCAN: %s\n",in1);
 #endif
 tap->TMS(1);tap->update();tap->TCK_CLOCK();
 tap->TMS(0);tap->update();tap->TCK_CLOCK(2);
 int i;
 int k=strlen((char *)in1)-1;
 for (i=k;i>0;i--) {
     tap->update();tap->realize();
     *(out1+i)=tap->TDO()+'0';
     tap->TDI(*(in1+i)=='0'?0:1);
     tap->update();tap->TCK_CLOCK();
 }
 tap->update();tap->realize();
 *(out1+i)=tap->TDO()+'0';
 tap->TDI(*(in1+i)=='0'?0:1);
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK();
 tap->update();tap->realize();
}

void JTAG::_DRSCAN(char * in1) {
 #ifdef JTAG_LOG
   printf("_DRSCAN: %s\n",in1);
 #endif
 tap->TMS(1);tap->update();tap->TCK_CLOCK();
 tap->TMS(0);tap->update();tap->TCK_CLOCK(2);
 DWORD i;
 DWORD k=strlen((char *)in1)-1;
 for (i=k;i>0;i--) {
     tap->TDI(*(in1+i)=='0'?0:1);
     tap->update();
     tap->TCK_CLOCK();
 }
 tap->TDI(*(in1+i)=='0'?0:1);
 tap->TMS(1);tap->update();tap->TCK_CLOCK(2);
 tap->TMS(0);tap->update();tap->TCK_CLOCK();
 tap->update();tap->realize();
}

