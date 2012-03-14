// addcrc.cpp : Defines the entry point for the console application.
//

#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>



unsigned int calc_crc(unsigned char *,unsigned int,unsigned int init_crc=0x0000FFFF);


int main(int argc, char* argv[])
{
	int retval=0;
	
	unsigned int filesize;
	unsigned char byte;
	unsigned int crc16;

	FILE * infile,* outfile;
	infile = NULL;
	outfile = NULL;

	char * inname, * outname;
	inname  = NULL;
	outname = NULL;

	unsigned char * indata;
	indata = NULL;

	int nolen=0;


//	printf("test crc: %X\n",calc_crc((unsigned char *)"123456789",9) );
//	return 0;


//	if( (argc>=2)&&(argc<=4) )
//	{
//	}


	if( argc==2 && strcmp(argv[1],"-n") )
	{
		inname = argv[1];
		outname = (char*)malloc( strlen(inname)+5 );
		strcpy(outname,inname);
		strcat(outname,".crc");
	}
	else if( argc==3 && strcmp(argv[1],"-n") )
	{
		inname  = argv[1];
		outname = (char*)malloc( strlen(argv[2])+1 );
		strcpy(outname,argv[2]);
	}
	else if( argc==3 && !strcmp(argv[1],"-n") )
	{
		inname = argv[2];
		outname = (char*)malloc( strlen(inname)+5 );
		strcpy(outname,inname);
		strcat(outname,".crc");
		nolen=1;
	}
	else if( argc==4 && !strcmp(argv[1],"-n") )
	{
		inname  = argv[2];
		outname = (char*)malloc( strlen(argv[3])+1 );
		strcpy(outname,argv[3]);
		nolen=1;
	}
	else
	{
		printf("error in arguments!\nuse: addcrc [-n] <infilename> [outfilename]\n");
		printf("if -n is used, the length of block won't be added to the beginning\n");
		retval=-1;
	}


	if( !retval )
	{
		infile=fopen(inname,"rb");
		if( infile==NULL )
		{
			printf("cant open %s!\n",inname);
			retval=-1;
		}

		outfile=fopen(outname,"wb");
		if( outfile==NULL )
		{
			printf("cant open %s!\n",outname);
			retval=-1;
		}
	}


	if( !retval )
	{
		// get length of input file
		fseek(infile,0,SEEK_END);
		filesize=ftell(infile);
		fseek(infile,0,SEEK_SET);
	}


	if( !retval )
	{
		// write length to the output file
		if( filesize>0x0000fffc )
		{
			printf("file too long: %d bytes\n",filesize);
			retval=-1;
		}
	}

	
	if( !retval )
	{
		// write length of packed block to the output file
		if( !nolen )
		{
			byte = (filesize>>8) & 0x000000FF;
			fwrite(&byte,1,1,outfile); // high byte
			byte = filesize & 0x000000FF;
			fwrite(&byte,1,1,outfile); // low byte
		}
	}

	if( !retval )
	{
		// load file in mem

		indata=(unsigned char*)malloc(filesize);
		if(!indata)
		{
			printf("can't allocate memory for input file!\n");\
			retval=-1;
		}
	}

	if( !retval )
	{
		if(filesize!=fread(indata,1,filesize,infile))
		{
			printf("can't load input file in mem!\n");
			retval=-1;
		}
	}

	if( !retval )
	{
		//save into output file
		if(filesize!=fwrite(indata,1,filesize,outfile))
		{
			printf("can't write to output file from mem!\n");
			retval=-1;
		}
	}

	
	if( !retval )
	{
		// calc and write crc

		crc16=0x0000FFFF;
		
		if( !nolen )
		{
			byte = (filesize>>8) & 0x000000FF;
			crc16 = calc_crc(&byte,1,crc16);
			byte = filesize & 0x000000FF;
			crc16 = calc_crc(&byte,1,crc16);
		}

		crc16 = calc_crc(indata,filesize,crc16);

		printf("crc16_ccitt is 0x%X\n",crc16);

		byte = (crc16>>8) & 0x000000FF;
		fwrite(&byte,1,1,outfile); // high byte
		byte = crc16 & 0x000000FF;
		fwrite(&byte,1,1,outfile); // low byte
	}

	
	
	if(indata) free(indata);

	if(outfile) fclose(outfile);
	if(infile) fclose(infile);

	if(outname) free(outname);

	return retval;
}



unsigned int calc_crc(unsigned char * data,unsigned int size,unsigned int init_crc)
{

	unsigned int i,ctr,crc;

	unsigned char * ptr;

	crc = init_crc;

	ptr=data;
	ctr=0;
	while( (ctr++) <size)
	{
		crc ^= (*ptr++) << 8;
		
		for(i=8;i!=0;i--)
			crc = (crc&0x00008000) ? ( (crc<<1)^0x1021 ) : (crc<<1);
	}

	return crc&0x0000FFFF;
}
