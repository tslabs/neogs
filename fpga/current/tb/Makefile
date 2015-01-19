PORTS_INC=../../../docs/ports.inc




all: timer_test.bin page_test.bin sdmp3_test.bin


ports.inc: $(PORTS_INC)
	cat $(PORTS_INC) | sed s/#/0x/ >ports.inc

timer_test.bin: timer_test.s ports.inc
	asl -U -L timer_test.s
	p2bin timer_test.p timer_test.bin -r \$$-$$ -k
	echo \ binclude \"timer_test.bin\" >tmp.s
	asl -U -L rom_loader.s
	p2bin rom_loader.p timer_test.bin -r \$$-$$ -k

page_test.bin: page_test.s ports.inc
	asl -U -L page_test.s
	p2bin page_test.p page_test.bin -r \$$-$$ -k
	echo \ binclude \"page_test.bin\" >tmp.s
	asl -U -L rom_loader.s
	p2bin rom_loader.p page_test.bin -r \$$-$$ -k

sdmp3_test.bin: sdmp3_test.s ports.inc
	asl -U -L sdmp3_test.s
	p2bin sdmp3_test.p sdmp3_test.bin -r \$$-$$ -k
	echo \ binclude \"sdmp3_test.bin\" >tmp.s
	asl -U -L rom_loader.s
	p2bin rom_loader.p sdmp3_test.bin -r \$$-$$ -k


clean:
	rm tmp.s ports.inc *.bin *.lst

