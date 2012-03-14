#ifndef _JTAG_H
#define _JTAG_H

/*
 *  INFO:
 *     jtag.h (C) 2003  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.5 - 23.11.2003
 *  
 *  
 *  DESCRIPTION:
 *     Contains definitions for JTAG class
 *     Allows to execute the following commands:
 *        - RESET   - move TAP-controller from any state to RESET
 *        - IDLE    - move TAP-controller from RESET state to Run/Idle state
 *        - IRSCAN  - scan-in specified JTAG-command
 *        - DRSCAN  - scan-in specified JTAG-data
 *
 *
 *  NOTES: 
 *     1. _IRSCAN and _DRSCAN are the fast versions of IRSCAN and DRSCAN which
 *        do not capture data from pin TDO
 *     2. All data are shifted from the first byte to TDI
 *     3. 0 and 1 in all data are represented as an ASCIIZ string of '1' and '0'
 *     4. Use line '#define JTAG_LOG' for switching to verbose mode
 *
 *
 *  DEPENDS: 
 *     1. Class TAP
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

//#define JTAG_LOG
#include "tap.h"

class JTAG {

  // private properties of class JTAG
  TAP* tap;      // pointer to instance of TAP class to get access to TAP controller
  int  status;   // the status of last operation with class TAP (see defs TAP_ ...)

  // private methods of class JTAG
  void TCK_CLOCK(int NUM=1);

public:
  // public methods of class JTAG                                   
  JTAG(int mode,int g_size);          // these parameters just translated to the constructor of TAP
  ~JTAG();                            // delete objects and allocated memory

  int  GetStatus()                    // returns the status of last operation (see defs TAP_ ...)
       {return status;}  

  void RESET();                       // move TAP-controller from any state to RESET
  void IDLE();                        // move TAP-controller from RESET state to Run/Idle state
  void IRSCAN(char * cmd1,char * out1); // scan-in specified in 'cmd1' JTAG-command, output data
                                      // is stored in the 'out1'
  void _IRSCAN(char * cmd1);           // scan-in specified in 'cmd1' JTAG-command 
  void DRSCAN(char * in1,char * out1);  // scan-in specified in 'in1' data, output data 
                                      // is stored in the 'out1'
  void _DRSCAN(char * in1);            // scan-in specified in 'in1' data

};

#endif