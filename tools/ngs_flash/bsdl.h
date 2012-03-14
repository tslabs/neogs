#ifndef __BSDL_H__
#define __BSDL_H__

/*
 *  INFO:
 *     bsdl.cpp (C) 2002  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.3 - 12.10.2002
 *  
 *  
 *  DESCRIPTION:
 *     Contains definitions of functions and data structures for BSDL parser
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

#include <stdio.h>

#define DWORD unsigned long

//----------------------------------------------------------
struct PINS {
     char * name;    // pin name
	 char * altname;// alternative name
     DWORD id_pins; // pin number
     int   input;   // bit for pin input    -\ 
     int   output;  // bit for pin output    |- absent if -1 
     int   control; // bit for pin control  -/
     int   vOUT;    // value for output
     char  prev_i;  // previous value of input 
     char  prev_o;  // previous value of output value
     char  prev_c;  // previous value of control
     PINS* next;
};

struct BS {
     char* name;    // the name of JTAG-device
     DWORD id_bs;   // device id (for interconnect)
     char* file;    // file name with device description
     int   IRlen;   // the length of Instruction Register
     int   DRlen;   // the length of Boundary Scan Register
     int   IDlen;   // the length of Device ID  Register
     char* BYPASS;
	 char* EXTEST;
     char* SAMPLE;  // the code of command SAMPLE
     char* IDCODE;  // the code of command IDCODE
     char* ID;      // device ID Code
     int   PINnum;  // the number of devices pins
     PINS* pins;    // pointer to the pins structure
     BS*   next;    // pointer to the next device structure
};


extern struct PINS* Pbegin;
extern struct BS*   BSbegin;

//----------------------------------------------------------

// extern word;
extern void  printBS(FILE *);
extern DWORD pins2id(DWORD, char *);
extern int   getfwdint(char *, char);

extern PINS* addPIN(char *);
extern PINS* findPIN(char *);
extern PINS* findPINx(char *);
extern void  delPINSitem(PINS *);
extern void  addBSitem();
extern void  delBSitem(BS *);
extern void  delBSall();
extern void  PINanalysis(char *);

extern void addPINalias(char *,char *);
extern PINS * findPINalias(char *);

extern BS*   readBSD(char *, int, DWORD);

#endif