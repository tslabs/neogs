How to install driver (WinNT, Win2K, WinXP):
--------------------------------------------

1.  Go to "Control Panel"
2.  Select "Add/Remove Hardware"
3.  Press twice button "Next" in Harware Wizard
4.  Select "Add a new device" and press "Next"
5.  Select "No, I want to select the hardware from a list" and
    press "Next"
6.  Select "Other devices" and press "Next"
7.  Press button "Have Disk"
8.  In dialog "Install From Disk" press "Browse" and point to the 
    file GIVEIO.INF which is delivered with JTAG Flasher
9.  Press "Open" then press OK
10. Select "giveio Driver" in Models list and press "Next" twice
11. Press "Finish"


How to use driver:
------------------

1. Insert this code into your program.


HANDLE h; 
h=CreateFile("\\\\.\\giveio", GENERIC_READ, 0, NULL, 
             OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL); 
if (h==INVALID_HANDLE_VALUE) {
   puts("Error: Unable to open driver!\n");
   return -1;
}
 else puts("Driver was successfully opened.");
CloseHandle(h);


2. After that you can use usual I/O ports read/write operations.