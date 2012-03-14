#ifndef __NGS_JTAG_H__
#define __NGS_JTAG_H__



#define INPUT 1
#define OUTPUT 0

struct bus {
	struct bus * next;
	char * pin_name;
};

void set_bus_dir(char * bscan_state,struct bus * mybus, int dir);
void set_bus_out(char * bscan_state,struct bus * mybus, int value);
int get_bus_in(char * bscan_state,struct bus * mybus);

struct bus * add_bus_pin(struct bus * mybus, char * pin_name);
void del_bus(struct bus * mybus);


void set_pin_out(char * bscan_state,char * pin_alias, int value);
void set_pin_dir(char * bscan_state,char * pin_alias, int dir);
int get_pin_out(char * bscan_state,char * pin_alias);
int get_pin_dir(char * bscan_state,char * pin_alias);
int get_pin_in(char * bscan_state,char * pin_alias); // input value on the pin





#endif
