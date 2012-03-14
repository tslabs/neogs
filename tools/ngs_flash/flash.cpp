#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>

#include "flash.h"
#include "ngs_jtag.h"
#include "jtag.h"
#include "bsdl.h"
#include "tap.h"
#include "types.h"





char idcode[21];
char sampre[21];
char extest[21];

char idcode_reply[34];
char idcode_stub[34];




int do_flash(int mode, char * filename, int start_address, int length)
{
	int return_value;
	return_value=1;


	int filesize;

	FILE * infile,* outfile;
	infile = NULL;
	outfile = NULL;

	unsigned char * fileinmem;
	fileinmem = NULL;


	// files handling
	if( mode==PROGRAM )
	{
		infile=fopen(filename,"rb");
		if( infile==NULL )
		{
			printf("cant open %s!\n",filename);
			return 0;
		}

		fseek(infile,0,SEEK_END);
		filesize=ftell(infile);
		fseek(infile,0,SEEK_SET);

		if( (filesize<=0) || ((filesize+start_address)>MAX_SIZE) )
		{
			printf("wrong file size %x at address %x\n",filesize,start_address);
			return 0;
		}
	

		fileinmem=(unsigned char *)malloc(filesize);
		if(fileinmem==NULL)
		{
			printf("cant allocate mem for file!\n");
			return 0;
		}

		if( filesize!=(int)fread(fileinmem,1,filesize,infile) )
		{
			printf("cant read all file into buffer!\n");
			return 0;
		}
	}
	else if( mode==READ )
	{
		outfile=fopen(filename,"wb");
		if( outfile==NULL )
		{
			printf("cant create %s!\n",filename);
			return -1;
		}
	
		fileinmem=(unsigned char *)malloc(MAX_SIZE);
		if(fileinmem==NULL)
		{
			printf("cant allocate mem for reading data!\n");
			return 0;
		}
	}



	//jtag init
	JTAG jtag(0x378,256*(BSbegin->DRlen));

	jtag.RESET();
	jtag.IDLE();


	// create commands for FPGA only, CPLD in bypass
	strcpy(idcode,BSbegin->IDCODE);
	strcat(idcode,BSbegin->BYPASS);

	strcpy(sampre,BSbegin->SAMPLE);
	strcat(sampre,BSbegin->BYPASS);

	strcpy(extest,BSbegin->EXTEST);
	strcat(extest,BSbegin->BYPASS);



	//check presence of FPGA

	jtag._IRSCAN(idcode);

	memset(idcode_stub,'0',33);
	idcode_stub[33]=0;
	strcpy(idcode_reply,idcode_stub);

	jtag.DRSCAN(idcode_stub,idcode_reply);

	if( idcode_reply==strstr(idcode_reply,BSbegin->ID) )
	{
		printf("ep1k30tc144 found!\n");
	}
	else
	{
		printf("ep1k30tc144 not found!\n");
		return 0;
	}
	

	
	// assing aliases to the pins
	addPINalias("IO72","nramcs0");
	addPINalias("IO70","nramcs1");
	addPINalias("IO69","nramcs2");
	addPINalias("IO68","nramcs3");
	addPINalias("IO67","nromcs");

	addPINalias("IO65","nmemoe");
	addPINalias("IO64","nmemwe");

	addPINalias("IO49","nz80res");

	addPINalias("IO117","d0");
	addPINalias("IO112","d1");
	addPINalias("IO109","d2");
	addPINalias("IO111","d3");
	addPINalias("IO116","d4");
	addPINalias("IO110","d5");
	addPINalias("IO114","d6");
	addPINalias("IO113","d7");

	addPINalias("IO102","a0");
	addPINalias("IO101","a1");
	addPINalias("IO100","a2");
	addPINalias("IO99","a3");
	addPINalias("IO98","a4");
	addPINalias("IO97","a5");
	addPINalias("IO96","a6");
	addPINalias("IO95","a7");
	addPINalias("IO92","a8");
	addPINalias("IO91","a9");
	addPINalias("IO90","a10");
	addPINalias("IO89","a11");
	addPINalias("IO88","a12");
	addPINalias("IO87","a13");
	addPINalias("IO82","mema14");
	addPINalias("IO81","mema15");
	addPINalias("IO80","mema16");
	addPINalias("IO79","mema17");
	addPINalias("IO78","mema18");



	//create busses
	struct bus * databus=NULL;
	struct bus * addrbus=NULL;

	databus=add_bus_pin(databus,"d7");
	databus=add_bus_pin(databus,"d6");
	databus=add_bus_pin(databus,"d5");
	databus=add_bus_pin(databus,"d4");
	databus=add_bus_pin(databus,"d3");
	databus=add_bus_pin(databus,"d2");
	databus=add_bus_pin(databus,"d1");
	databus=add_bus_pin(databus,"d0");

	addrbus=add_bus_pin(addrbus,"mema18");
	addrbus=add_bus_pin(addrbus,"mema17");
	addrbus=add_bus_pin(addrbus,"mema16");
	addrbus=add_bus_pin(addrbus,"mema15");
	addrbus=add_bus_pin(addrbus,"mema14");
	addrbus=add_bus_pin(addrbus,"a13");
	addrbus=add_bus_pin(addrbus,"a12");
	addrbus=add_bus_pin(addrbus,"a11");
	addrbus=add_bus_pin(addrbus,"a10");
	addrbus=add_bus_pin(addrbus,"a9");
	addrbus=add_bus_pin(addrbus,"a8");
	addrbus=add_bus_pin(addrbus,"a7");
	addrbus=add_bus_pin(addrbus,"a6");
	addrbus=add_bus_pin(addrbus,"a5");
	addrbus=add_bus_pin(addrbus,"a4");
	addrbus=add_bus_pin(addrbus,"a3");
	addrbus=add_bus_pin(addrbus,"a2");
	addrbus=add_bus_pin(addrbus,"a1");
	addrbus=add_bus_pin(addrbus,"a0");




	// init bscan_state register
	
	char * bscan_state=new char[2+BSbegin->DRlen];
	char * bscan_tmp=new char[2+BSbegin->DRlen];

	memset(bscan_tmp,'0',1+BSbegin->DRlen);
	bscan_tmp[1+BSbegin->DRlen]=0;
	strcpy(bscan_state,bscan_tmp);

	jtag._IRSCAN(sampre);
	jtag.DRSCAN(bscan_tmp,bscan_state); //read base state of boundary register


	// set reset of Z80 to 0, set initial values for CS and OE/WE signals

	set_pin_dir(bscan_state,"nz80res",OUTPUT);
	set_pin_out(bscan_state,"nz80res",0);

	set_pin_dir(bscan_state,"nramcs0",OUTPUT);
	set_pin_dir(bscan_state,"nramcs1",OUTPUT);
	set_pin_dir(bscan_state,"nramcs2",OUTPUT);
	set_pin_dir(bscan_state,"nramcs3",OUTPUT);
	set_pin_dir(bscan_state,"nromcs",OUTPUT);
	set_pin_dir(bscan_state,"nmemoe",OUTPUT);
	set_pin_dir(bscan_state,"nmemwe",OUTPUT);

	set_pin_out(bscan_state,"nramcs0",1);
	set_pin_out(bscan_state,"nramcs1",1);
	set_pin_out(bscan_state,"nramcs2",1);
	set_pin_out(bscan_state,"nramcs3",1);
	set_pin_out(bscan_state,"nromcs",1);
	set_pin_out(bscan_state,"nmemoe",1);
	set_pin_out(bscan_state,"nmemwe",1);

	jtag._IRSCAN(sampre);
	jtag._DRSCAN(bscan_state);
	jtag._IRSCAN(extest);
	jtag._DRSCAN(bscan_state);







	if( mode==READ )
	{
		unsigned char byte;
		unsigned int max_addr;
		unsigned int addr;

		if( start_address>=0 )
			addr = start_address;
		else
			addr = 0;

		if( length>=0 )
			max_addr = start_address+length;
		else
			max_addr = MAX_SIZE;


		set_pin_out(bscan_state,"nmemoe",0);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",0);
		
		set_bus_dir(bscan_state,addrbus,OUTPUT);
		set_bus_dir(bscan_state,databus,INPUT);

		set_bus_out(bscan_state,addrbus,addr);
		addr=addr+1;


		jtag._IRSCAN(sampre);
		jtag._DRSCAN(bscan_state);


		do
		{
			set_bus_out(bscan_state,addrbus,addr);

			jtag._IRSCAN(extest);
			jtag.DRSCAN(bscan_state,bscan_tmp);

			byte=(unsigned char)get_bus_in(bscan_tmp,databus);

			fileinmem[addr-1] = byte;

			print_cur_addr("read address=%x\n",addr-1);

			addr=addr+1;

		} while( addr<=max_addr );

	}
	else if( mode==PROGRAM )
	{
		unsigned char byte;
		unsigned int addr;
		unsigned char * curr;

		unsigned char toggle,oldtoggle;

		int counter;
		
		counter = filesize;
		curr = &fileinmem[0];
		addr = start_address;


		set_pin_out(bscan_state,"nmemoe",1);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",0);

		set_bus_dir(bscan_state,addrbus,OUTPUT);
		set_bus_dir(bscan_state,databus,OUTPUT);


		jtag._IRSCAN(sampre); // prepare 1st data
		jtag._DRSCAN(bscan_state);

		do
		{
			byte = *(curr++);
			
			//write byte
			set_bus_out(bscan_state,addrbus,0x0555);
			set_bus_out(bscan_state,databus,0x00AA);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",1);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);

			set_bus_out(bscan_state,addrbus,0x02AA);
			set_bus_out(bscan_state,databus,0x0055);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",1);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);

			set_bus_out(bscan_state,addrbus,0x0555);
			set_bus_out(bscan_state,databus,0x00A0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",1);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);

			set_bus_out(bscan_state,addrbus,addr);
			set_bus_out(bscan_state,databus,byte);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",1);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);


			set_pin_out(bscan_state,"nmemoe",0);
			set_bus_dir(bscan_state,databus,INPUT);
			jtag._IRSCAN(extest); // complete last write
			jtag._DRSCAN(bscan_state);

			set_pin_out(bscan_state,"nmemoe",1);
			jtag._IRSCAN(extest);
			jtag.DRSCAN(bscan_state,bscan_tmp);
			toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

			do
			{
				oldtoggle = toggle;
				
				set_pin_out(bscan_state,"nmemoe",0);
				jtag._IRSCAN(extest);
				jtag._DRSCAN(bscan_state);
				set_pin_out(bscan_state,"nmemoe",1);
				jtag._IRSCAN(extest);
				jtag.DRSCAN(bscan_state,bscan_tmp);
				toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

			} while ( ((toggle&0x40)!=(oldtoggle&0x40)) && !(toggle&0x20) );

			if( (toggle&0x20) && ((toggle&0x40)!=(oldtoggle&0x40)) )
			{
				printf("program failed!\n");
				return_value=0;
			}


			set_pin_out(bscan_state,"nmemwe",0);
			set_bus_dir(bscan_state,databus,OUTPUT);
			set_bus_out(bscan_state,databus,0x00F0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemwe",1);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);

			print_cur_addr("write address=%x\n",addr++);


		} while(--counter);




		


	}
	else if( mode==ERASE_ALL )
	{
		unsigned char toggle,oldtoggle;

		set_pin_out(bscan_state,"nmemoe",1);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",0);
		
		set_bus_dir(bscan_state,addrbus,OUTPUT);
		set_bus_dir(bscan_state,databus,OUTPUT);


		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x00AA);
		jtag._IRSCAN(sampre); // prepare 1st data
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x02AA);
		set_bus_out(bscan_state,databus,0x0055);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x0080);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x00AA);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x02AA);
		set_bus_out(bscan_state,databus,0x0055);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x0010);
		jtag._IRSCAN(extest);	
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);


		set_pin_out(bscan_state,"nmemoe",0);
		set_bus_dir(bscan_state,databus,INPUT);
		jtag._IRSCAN(extest); // complete last write
		jtag._DRSCAN(bscan_state);

		set_pin_out(bscan_state,"nmemoe",1);
		jtag._IRSCAN(extest);
		jtag.DRSCAN(bscan_state,bscan_tmp);
		toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

		do
		{
			oldtoggle = toggle;
			
			set_pin_out(bscan_state,"nmemoe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemoe",1);
			jtag._IRSCAN(extest);
			jtag.DRSCAN(bscan_state,bscan_tmp);
			toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

		} while ( ((toggle&0x40)!=(oldtoggle&0x40)) && !(toggle&0x20) );

		if( (toggle&0x20) && ((toggle&0x40)!=(oldtoggle&0x40)) )
		{
			printf("erase all failed!\n");
			return_value=0;
		}


		set_pin_out(bscan_state,"nmemwe",0);
		set_bus_dir(bscan_state,databus,OUTPUT);
		set_bus_out(bscan_state,databus,0x00F0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
	}
	else if( mode==ERASE_BLOCK )
	{
		unsigned char toggle,oldtoggle;

		set_pin_out(bscan_state,"nmemoe",1);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",0);
		
		set_bus_dir(bscan_state,addrbus,OUTPUT);
		set_bus_dir(bscan_state,databus,OUTPUT);


		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x00AA);
		jtag._IRSCAN(sampre); // prepare 1st data
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x02AA);
		set_bus_out(bscan_state,databus,0x0055);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x0080);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x0555);
		set_bus_out(bscan_state,databus,0x00AA);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,0x02AA);
		set_bus_out(bscan_state,databus,0x0055);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);

		set_bus_out(bscan_state,addrbus,start_address);
		set_bus_out(bscan_state,databus,0x0030);
		jtag._IRSCAN(extest);	
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);


		set_pin_out(bscan_state,"nmemoe",0);
		set_bus_dir(bscan_state,databus,INPUT);
		jtag._IRSCAN(extest); // complete last write
		jtag._DRSCAN(bscan_state);

		set_pin_out(bscan_state,"nmemoe",1);
		jtag._IRSCAN(extest);
		jtag.DRSCAN(bscan_state,bscan_tmp);
		toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

		do
		{
			oldtoggle = toggle;
			
			set_pin_out(bscan_state,"nmemoe",0);
			jtag._IRSCAN(extest);
			jtag._DRSCAN(bscan_state);
			set_pin_out(bscan_state,"nmemoe",1);
			jtag._IRSCAN(extest);
			jtag.DRSCAN(bscan_state,bscan_tmp);
			toggle=(unsigned char)get_bus_in(bscan_tmp,databus);

		} while ( ((toggle&0x40)!=(oldtoggle&0x40)) && !(toggle&0x20) );

		if( (toggle&0x20) && ((toggle&0x40)!=(oldtoggle&0x40)) )
		{
			printf("erase block failed!\n");
			return_value=0;
		}


		set_pin_out(bscan_state,"nmemwe",0);
		set_bus_dir(bscan_state,databus,OUTPUT);
		set_bus_out(bscan_state,databus,0x00F0);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		set_pin_out(bscan_state,"nmemwe",1);
		set_pin_out(bscan_state,"nromcs",1);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
		jtag._IRSCAN(extest);
		jtag._DRSCAN(bscan_state);
	}













	//jtag shutdown
	jtag.RESET();

	// some deallocations
	del_bus(addrbus);
	del_bus(databus);

	delete[] bscan_state;
	delete[] bscan_tmp;


	
	//writeback read data from flash
	if( mode==READ )
	{
		unsigned int addr,size;

		addr=0;
		size=MAX_SIZE;

		if( start_address>=0 ) addr=start_address;
		if( length>=0 ) size=length;
		
		if( size!=(int)fwrite(&fileinmem[addr],1,size,outfile) )
		{
			printf("cant writeback read file!\n");
			return 0;
		}
	}

	//close shit
	if(fileinmem) free(fileinmem);
	if(infile) fclose(infile);
	if(outfile) fclose(outfile);




	return return_value;
}



void print_cur_addr(char * format_string, unsigned int cur_addr)
{
	static unsigned int old_addr = 0;

	if( (cur_addr-old_addr)>=ADDR_DELTA )
	{
		old_addr = cur_addr;

		printf(format_string,cur_addr);
	}
}
