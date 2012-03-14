#ifndef _T_TAP_H
#define _T_TAP_H

/*
 *  INFO:
 *     t_tap.h (C) 2002  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.1 - 20.02.2002
 *  
 *  
 *  DESCRIPTION:
 *     Contains different definitions for TAP class (see tap.h and tap.cpp)
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

#define _TDO_ 7         // #BUSY (status port) !!! INVERTED !!!
#define _TDI_ 6         // D6      (data port)
#define _TCK_ 0         // D0      (data port)
#define _TMS_ 1         // D1      (data port)
#define _BBMV_ON_ 1     // D1 (bbmv ON) !!! INVERTED !!!

#define TAP_SUCCESS 0   // previous operation was successfully finished
#define TAP_FAILED  1   // previous operation is failed
#define TAP_DENIED  2   // access to device is denied
#define TAP_UNSUPP  3   // unsupported operation
#define TAP_MEMERR  4   // there is not enough memory

#endif