// ngs_jtag.cpp : Defines the entry point for the console application.
//

#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>



#include "ngs_jtag.h"
#include "flash.h"
#include "jtag.h"
#include "bsdl.h"
#include "tap.h"
#include "types.h"



void error_help(void);


int main(int argc, char* argv[])
{
	int mode;
	int start_address;
	int length;
	char * filename;

	length=start_address=(-1);


	// get ports control
	HANDLE h;
	h = CreateFile("\\\\.\\giveio", GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (h==INVALID_HANDLE_VALUE) {printf("Error! Unable to open giveio.sys driver!");return -1;}
	CloseHandle(h);


	// load and parse bsdl for ep1k30t144
	if(NULL==readBSD("1k30t144.bsd",1,0))
	{
		printf("1k30t144.bsd failed\n");
		return -1;
	}



	// parse command line
	if( argc==2 )
	{
		if( _stricmp(argv[1],"a")==0 )
		{
			mode = ERASE_ALL;
		}
		else
		{
			error_help();
			return -1;
		}
	}
	else if( argc==3 ) // read all or erase sector
	{
		if( _stricmp(argv[1],"e")==0 )
		{
			mode = ERASE_SECTOR;
			if( sscanf(argv[2],"%x",&start_address)!=1 )
			{
				error_help();
				return -1;
			}
		}
		else if( _stricmp(argv[1],"r")==0 )
		{
			mode = READ;
			filename = argv[2];
		}
		else
		{
			error_help();
			return -1;
		}
	}
	else if( argc==4 ) // program
	{
		if( _stricmp(argv[1],"p")==0 )
		{
			mode = PROGRAM;
			if( sscanf(argv[2],"%x",&start_address)!=1 )
			{
				error_help();
				return -1;
			}
			filename = argv[3];
		}
		else
		{
			error_help();
			return -1;
		}
	}
	else if( argc==5 ) // read with address and length
	{
		if( _stricmp(argv[1],"r")==0 )
		{
			mode = READ;
			if( sscanf(argv[2],"%x",&start_address)!=1 )
			{
				error_help();
				return -1;
			}
			if( sscanf(argv[3],"%x",&length)!=1 )
			{
				error_help();
				return -1;
			}
			filename = argv[4];
		}
		else
		{
			error_help();
			return -1;
		}
	}
	else
	{
		error_help();
		return -1;
	}
	



	if( !do_flash(mode,filename,start_address,length) )
	{
		printf("do_flash() failed!\n");
		return -1;
	}
	



	






/*
	int address=0,oldaddr=0;
	unsigned char byte;

	set_pin_out(bscan_state,"nramcs0",0);

	set_bus_dir(bscan_state,databus,OUTPUT);
	set_bus_dir(bscan_state,addrbus,OUTPUT);

	jtag._IRSCAN(sampre); // prepare 1st data
	jtag._DRSCAN(bscan_state);
	
	while( address<filesize )
	{
		set_bus_out(bscan_state,addrbus,address);
		set_bus_out(bscan_state,databus,(int)loadedfile[address]);

		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		address++;
		if( (address-oldaddr)>=512 )
		{
			printf("wraddr=%d\n",address);
			oldaddr=address;
		}
	}
	// complete last write
	jtag._IRSCAN(extest);
	jtag._DRSCAN(bscan_state);



	set_bus_dir(bscan_state,databus,INPUT);
	set_pin_out(bscan_state,"nmemoe",0);
	set_bus_out(bscan_state,addrbus,0);
	jtag._IRSCAN(sampre);
	jtag._DRSCAN(bscan_state);

	oldaddr=0;
	for(address=1;address<=filesize;address++)
	{
		set_bus_out(bscan_state,addrbus,address);

		jtag._IRSCAN(extest);
		jtag.DRSCAN(bscan_state,bscan_tmp);

		byte=(unsigned char)get_bus_in(bscan_tmp,databus);

		if( ((unsigned char)byte)!=((unsigned char)loadedfile[address-1]) )
		{
			printf("check error at %X: was %X, must be %X\n",address-1,byte,loadedfile[address-1]);
			return -1;
		}
		
		if( (address-oldaddr)>=512 )
		{
			printf("rdaddr=%d\n",address);
			oldaddr=address;
		}
	}
*/	
	
	
	
	

	
	
	return 0;
}



















void set_bus_dir(char * bscan_state,struct bus * mybus, int dir)
{
	while( mybus!=NULL )
	{
		set_pin_dir(bscan_state,mybus->pin_name,dir);

		mybus=mybus->next;
	}
}


void set_bus_out(char * bscan_state,struct bus * mybus, int value)
{
	while( mybus!=NULL )
	{
		set_pin_out(bscan_state,mybus->pin_name,value&1);

		mybus=mybus->next;
		value>>=1;
	}
}


int get_bus_in(char * bscan_state,struct bus * mybus)
{
	int result,shift;

	result=0;shift=1;


	while( mybus!=NULL )
	{
		result |= (get_pin_in(bscan_state,mybus->pin_name)==1)?shift:0 ;

		mybus=mybus->next;
		shift<<=1;
	}

	return result;
}


// add new pin to the bus (add pins from MSB to LSB!)
struct bus * add_bus_pin(struct bus * mybus, char * pin_name)
{
	struct bus * newbus=new struct bus;

	newbus->next = mybus;
	newbus->pin_name = pin_name;

	return newbus;
}


// delete all bus allocations
void del_bus(struct bus * mybus)
{
	struct bus * tmpbus;

	while( mybus!=NULL )
	{
		tmpbus = mybus;
		mybus = mybus->next;
		delete tmpbus;
	}
}














//set output data for the pin
void set_pin_out(char * bscan_state,char * pin_alias, int value)
{
	PINS * pin;
	if( (pin=findPINalias(pin_alias))==NULL )
	{
		if( (pin=findPIN(pin_alias))==NULL )
			exit(0);
	}

	if( (pin->output) != (-1) ) bscan_state[BSbegin->DRlen-1-pin->output]=(value==0)?'0':'1';
}


//set direction for the pin
void set_pin_dir(char * bscan_state,char * pin_alias, int dir)
{
	PINS * pin;
	if( (pin=findPINalias(pin_alias))==NULL )
	{
		if( (pin=findPIN(pin_alias))==NULL )
			exit(0);
	}


	if( (pin->control) != (-1) ) bscan_state[BSbegin->DRlen-1-pin->control]=((dir==OUTPUT)?OUTPUT:INPUT)+((int)'0');
}

//get data set for pin outputting or -1 if pin->output==-1
int get_pin_out(char * bscan_state,char * pin_alias)
{
	PINS * pin;
	if( (pin=findPINalias(pin_alias))==NULL )
	{
		if( (pin=findPIN(pin_alias))==NULL )
			exit(0);
	}

	if( (pin->output)==(-1) )
		return -1;
	else
		return bscan_state[BSbegin->DRlen-1-pin->output]-'0';
}

//get mode set for pin or -1 if pin->control==-1
int get_pin_dir(char * bscan_state,char * pin_alias)
{
	PINS * pin;
	if( (pin=findPINalias(pin_alias))==NULL )
	{
		if( (pin=findPIN(pin_alias))==NULL )
			exit(0);
	}

	if( (pin->control)==(-1) ) 
		return -1;
	else
		return ((int)(bscan_state[(BSbegin->DRlen-1-pin->control)]-'0')==INPUT)?INPUT:OUTPUT;
}


//get input data on the pin or -1 if pin->input==-1
int get_pin_in(char * bscan_state,char * pin_alias)
{
	PINS * pin;
	if( (pin=findPINalias(pin_alias))==NULL )
	{
		if( (pin=findPIN(pin_alias))==NULL )
			exit(0);
	}

	if( (pin->input)==(-1) ) 
		return -1;
	else
		return (int)(bscan_state[BSbegin->DRlen-1-pin->input]-'0');
}




void error_help(void)
{
	printf("ngs_flash a - erase all\n");
	printf("ngs_flash e <hex addr> - erase block within given address\n");
	printf("ngs_flash p <start hex addr> filename - program into flash with checking\n");
	printf("ngs_flash r <filename> or r <start hex> <length hex> <filename> - read all or given range\n");
}
