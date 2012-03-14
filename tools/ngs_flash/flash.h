#ifndef _FLASH_H
#define _FLASH_H



//operation modes
#define ERASE_SECTOR (1)
#define ERASE_BLOCK  (1)
#define ERASE_ALL    (2)
#define PROGRAM      (3)
#define READ         (4)

// max flash size
#define MAX_SIZE (524288)

// delta for addr printing
#define ADDR_DELTA (1024)



int do_flash(int mode, char * filename, int start_address, int length);



void print_cur_addr(char * format_string, unsigned int cur_addr);


#endif
