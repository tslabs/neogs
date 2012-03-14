#ifndef _TAP_H
#define _TAP_H

/*
 *  INFO:
 *     tap.h (C) 2004  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.2 - 04.01.2004
 *  
 *  
 *  DESCRIPTION:
 *     Contains definitions for TAP class
 *
 *
 *  NOTES:
 *     1. Additional operations (update() and realize()) were added to increase 
 *        the speed of communication with parallel port. You should setup global 
 *        buffer size for these operations during the invoking of class constructor
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
#include <conio.h>
#include "t_tap.h"
#include "types.h"

class TAP {

  BYTE  oldv;         // current state of data register of parallel port (for pins: TDI,TCK,TMS)
  int   FD;           // FILE descriptor to open driver as a file
  BYTE  MODE;         // access method (reserved for Linux and non-standard JTAG cables)
  BYTE* g_buf;        // global buffer: stores the sequence of signals for JTAG port
  DWORD g_pos;        // current position in global buffer
  int   status;       // the status of last operation with class TAP (see defs TAP_ ...)

  void set_bit(int bit, int val);  // sets specified BIT in data port to specified in DATA value
  BYTE get_bit(int bit);           // returns the current status of specified bit of STATUS reg.

public:

  TAP(int port,int g_size);        // opens the specified driver to get access to parallel port
  ~TAP();                          // closes previously opened driver, delete allocated memory

  int  GetStatus()                 // returns the status of last operation (see defs TAP_ ...)
       {return status;}  
  
  void update();                   // adds to global buffer curretn state of DATA register (oldv)
  void realize();                  // realize burst-write of all stored in g_buf data to driver
  
  BYTE TDO() {                     // returns current state of TDO signal (either '0' or '1')
       return get_bit(_TDO_);
  }
  
  void TCK(BYTE val) {             // sets TCK to specified in 'val' value (either '0' or '1')
       set_bit(_TCK_,val);
  }
  
  void TMS(BYTE val) {             // sets TMS to specified in 'val' value (either '0' or '1')
       set_bit(_TMS_,val);
  }

  void TDI(BYTE val) {             // sets TDI to specified in 'val' value (either '0' or '1')
       set_bit(_TDI_,val);
  }

  void TCK_CLOCK(int NUM=1);

};

#endif