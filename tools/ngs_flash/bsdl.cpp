/*
 *  INFO:
 *     bsdl.cpp (C) 2002  Dr. Yuri Klimets (www.jtag.tk, jtagtools.sf.net)  
 *     E-mail: klimets@jtag.tk
 *     Rev. 1.3 - 12.10.2002
 *  
 *  
 *  DESCRIPTION:
 *     Defines functions to parse BSDL-files
 * 
 *     Data structures:
 *     ----------------
 *     PINS - stores information about JTAG devices pins
 *     BS   - stores information about JTAG devices
 *
 *     Main functions:
 *     ---------------
 *     readBSD - reads JTAG DEVICE description from specified BSDL-file and 
 *               stores it in the structures PINS and BS
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

#include "bsdl.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

DWORD CUR_ID=800;
DWORD CUR_PINS;

struct PINS* Pbegin;
struct BS*   BSbegin;

//----------------------------------------------------------
// GETS: stream CHAR* STR, SYM is an end symbol of stream STR   
// RETURNS: INT from stream CHAR* STR (current pointer is on the end of INT)
int getbackint(char *str,char sym) {                                   
 char ch=*str;                      
 *str=0;
 for (int i=1;*(str-i)!=sym;i++);
 i=atoi(str-i+1);
 *str=ch;
 return i;
}
//----------------------------------------------------------
// GETS: stream CHAR* STR, SYM is an end symbol of stream STR   
// RETURNS: INT from stream CHAR* STR (current pointer is on the begin of INT)
int getfwdint(char *str,char sym) {                                   
 char *s=strchr(str,sym);           
 if (s==NULL) return -1;            
 char ch=*s;
 *s=0;
 for (DWORD j=0;j<strlen(str);j++)
    if (*(str+j)<'0'||*(str+j)>'9') return -1;
 int i=atoi(str);
 *s=ch;
 return i;
}
//----------------------------------------------------------
// copy JTAG COMMAND code from SRC to DEST
int getCMDcode(char *src,char *dest) {
 for (;(*src=='0')||(*src=='1');*dest=*src,src++,dest++);
 if (*src!=')') return -1;
 *dest=0;
 return 0;
}
//----------------------------------------------------------
// copy JTAG DEVICE ID code from SRC to DEST
int getIDcode(char *src,char *dest) {
 for (;;src++) {
     if (*src=='0'||*src=='1') {*dest=*src;dest++;continue;}
     if (*src=='\"'||*src=='&') continue;
     break;
 }
 if (*src!=0) return -1;
 *dest=0;
 return 0;
}
//----------------------------------------------------------
// adds pin with name NAME to the structure PINS
// RETURNS: pointer to the new pin  
PINS *addPIN(char *name) {                        
 if (*name=='*') return NULL;
 PINS *tmp=new PINS;
 tmp->next=NULL;
 if (Pbegin==NULL) Pbegin=tmp;
   else {
     PINS *x=Pbegin;
     for (;x->next!=NULL;x=x->next);
     x->next=tmp;
   }
 tmp->name=new char[strlen(name)+1];
 tmp->altname="";
 strcpy(tmp->name,strupr(name));
 tmp->control=-1;
 tmp->input=-1;
 tmp->output=-1;
 tmp->vOUT=-1;
 tmp->prev_i='0';
 tmp->prev_o='0';
 tmp->prev_c='0';
 tmp->id_pins=CUR_PINS;
 CUR_PINS++;
 return tmp;
}
//----------------------------------------------------------
void addPINalias(char * pin_name,char * pin_alias)
{
	PINS * pin;

	pin=findPIN(pin_name);

	if(pin!=NULL)
	{
		pin->altname = pin_alias;
	}

}
//----------------------------------------------------------
// RETURNS: the pointer to the pin with name NAME
PINS *findPINalias(char *name) {
 PINS *item=Pbegin;
 for (;item!=NULL;item=item->next)
    if (strcmp(name,item->altname)==0) return item;
 return NULL;
}
//----------------------------------------------------------
// RETURNS: the pointer to the pin with name NAME
PINS *findPIN(char *name) {
 PINS *item=Pbegin;
 for (;item!=NULL;item=item->next)
    if (strcmp(name,item->name)==0) return item;
 return NULL;
}
//----------------------------------------------------------
// the same, but if pin not found it will create pin with this name
PINS *findPINx(char *name) {                           
 PINS *item=Pbegin;
 strupr(name);
 for (;item!=NULL;item=item->next)
    if (strcmp(name,item->name)==0) return item;
 return addPIN(name);
}
//----------------------------------------------------------
// delete the pin with pointer ITEM
void delPINSitem(PINS *item) {
 if (item==NULL) return;
 PINS *tmp=Pbegin;
 if (item==Pbegin) {
    if (item->name!=NULL) {
       delete[] item->name;
       item->name=NULL;
    }
    Pbegin=Pbegin->next;
    delete tmp;
    tmp=NULL;
    return;
 }
 for (;tmp->next!=NULL;tmp=tmp->next)
    if (tmp->next==item) {
       tmp->next=item->next;
       if (item->name!=NULL) {
          delete[] item->name;
          item->name=NULL;
        }
       delete item;
       item=NULL;
       return;
    }
}
//----------------------------------------------------------
// delete all pins in structure PINS
void delPINSall(PINS *item) {
 for (PINS *tmp=item;tmp!=NULL;) {
     PINS *x=tmp->next;
     if (tmp->name!=NULL) {
        delete[] tmp->name;
        tmp->name=NULL;
     }
     delete tmp;tmp=NULL;
     tmp=x;
 }
}
//-----------------------------------------------------------
// add new device to the list of jtag devices BS
void addBSitem() {
 BS *BStmp=new BS;
 BStmp->next=BSbegin;
 BSbegin=BStmp;
 BStmp->name=NULL;
 BStmp->file=NULL;
 BStmp->BYPASS=NULL;
 BStmp->EXTEST=NULL;
 BStmp->SAMPLE=NULL;
 BStmp->IDCODE=NULL;
 BStmp->ID=NULL;
 BStmp->pins=NULL;
 BStmp->DRlen=0;
 BStmp->IRlen=0;
 BStmp->DRlen=0;
 BStmp->IDlen=0;
 BStmp->PINnum=0;
 BStmp->id_bs=CUR_ID;
 CUR_ID++;
}
//-----------------------------------------------------------
// delete JTAG DEVICE with pointer item from the list
void delBSitem(BS *item) {
 if (item->name!=NULL) {delete[] item->name;item->name=NULL;}
 if (item->file!=NULL) {delete[] item->file;item->file=NULL;}
 if (item->SAMPLE!=NULL) {delete[] item->SAMPLE;item->SAMPLE=NULL;}
 if (item->IDCODE!=NULL) {delete[] item->IDCODE;item->IDCODE=NULL;}
 if (item->ID!=NULL) {delete[] item->ID;item->ID=NULL;}
 delPINSall(item->pins);
 if (item==BSbegin) BSbegin=item->next;
   else
     for (BS *tmp=BSbegin;tmp!=NULL;tmp=tmp->next)
        if (tmp->next==item) {tmp->next=item->next;break;}
 delete item;item=NULL;
}
//-----------------------------------------------------------
// RETURNS: ID of pin with name PINNAME which belongs to JTAG DEVICE with ID=id
DWORD pins2id(DWORD id,char *pinname) {                                     
 for (BS *tmp=BSbegin;tmp!=NULL;tmp=tmp->next)
     if (tmp->id_bs==id) {
        PINS *item=tmp->pins;
        for (;item!=NULL;item=item->next)
          if (strcmp(pinname,item->name)==0) return item->id_pins;
     }
 return -1;
}
//-----------------------------------------------------------
// delete whole list of JTAG DEVICES
void delBSall() {
 for (;BSbegin!=NULL;) {
     if (BSbegin->name!=NULL) {delete[] BSbegin->name;BSbegin->name=NULL;}
     if (BSbegin->file!=NULL) {delete[] BSbegin->file;BSbegin->file=NULL;}
     if (BSbegin->SAMPLE!=NULL) {delete[] BSbegin->SAMPLE;BSbegin->SAMPLE=NULL;}
     if (BSbegin->IDCODE!=NULL) {delete[] BSbegin->IDCODE;BSbegin->IDCODE=NULL;}
     if (BSbegin->ID!=NULL) {delete[] BSbegin->ID;BSbegin->ID=NULL;}
     delPINSall(BSbegin->pins);
     BS *tmp=BSbegin->next;
     delete BSbegin;BSbegin=NULL;
     BSbegin=tmp;
 }
}
//----------------------------------------------------------------
// start analysis of BSDL-file for DEVICE PINS
// STR is a pointer to the stream with BSDL-file
void PINanalysis(char *str) {                           
 char *s;
 char *buf1=new char[strlen(str)+1];
 s=buf1;
 int j=0;
 for (DWORD i=0;i<strlen(str);i++) {
     if (*(str+i)=='&'||*(str+i)=='\"'||*(str+i)==' '||*(str+i)==9) continue;
     *(s+j)=*(str+i);j++;
 }
 *(s+j)=0;
 char* prev_name=NULL;
 for (;;) {
     char* _str=NULL;
     int bracket=0;
     for (unsigned int i=0;i<strlen(s);i++) {
         if (s[i]=='(') bracket++;
         if (s[i]==')') 
             if (bracket==1) break;
                else bracket--;
     }
     if (i!=strlen(s)) _str=s+i;
     if (_str==NULL) {delete[] buf1;buf1=NULL;return;}
     *_str=0;
     j=getfwdint(s,'(');
     if (j==-1) {s=_str+1;if (*s==',') s++;continue;}
     s=strchr(s,',')+1;
     char *_s=strchr(s,',');
     if (_s==NULL) {s=_str+1;if (*s==',') s++;continue;}
     *_s=0;
     char *name=s;
     if (*name=='*') name=prev_name;
        else prev_name=name;
     s=_s+1;
     _s=strchr(s,',');
     if (_s==NULL) {s=_str+1;if (*s==',') s++;continue;}
     *_s=0;
     int type,ctrl,vout;
     if (strstr(s,"input")!=NULL) type=1;
      else if (strstr(s,"output")!=NULL) type=2;
       else type=0;
     if (type==0) {s=_str+1;if (*s==',') s++;continue;}
     s=_s+1;
     if (type==2) {
         _s=strchr(s,',');
         if (_s==NULL) {s=_str+1;if (*s==',') s++;continue;}
         s=_s+1;
         _s=strchr(s,',');
         if (_s==NULL) {s=_str+1;if (*s==',') s++;continue;}
         ctrl=getfwdint(s,',');
         if (ctrl==-1) {s=_str+1;if (*s==',') s++;continue;}
         s=_s+1;
         _s=strchr(s,',');
         if (_s==NULL) {s=_str+1;if (*s==',') s++;continue;}
         vout=getfwdint(s,',');
         if (vout==-1||(vout!=0&&vout!=1)) {s=_str+1;if (*s==',') s++;continue;}
         vout=1-vout;
     }
     PINS *x=findPINx(name);
     if (x==NULL) {s=_str+1;if (*s==',') s++;continue;}
     switch (type) {
        case 1 : x->input=j;break;
        case 2 : x->output=j;x->control=ctrl;x->vOUT=vout;break;
     }
     s=_str+1;
     if (*s==',') s++;
 }
}

//-------------------------------------------------------------------
// reads JTAG DEVICE description from the file FL. CURDEV - is a current DEVICE ID
// mode=1(read with pins), mode=0(read without pins) - to optimize on speed
BS* readBSD(char* fl,int mode,DWORD curdev) {
 CUR_ID=curdev;
 CUR_PINS=0;
 if (fl==NULL) return NULL;
 FILE *in=fopen(fl,"rt");
 if (in==NULL) return NULL;
 fseek(in,0,SEEK_END);
 int filelen=ftell(in);
 rewind(in);
 char _lex[256];
 char  lex[256];
 char *buf,*_buf,*bufbegin;
 bufbegin=buf=_buf=new char[filelen];
 for (;!feof(in);) {
     if (fgets(_lex,255,in)==NULL) break;
     strlwr(_lex);
     int ind=0;
     for (DWORD i=0;i<strlen(_lex);i++)
        if (_lex[i]>=32 && _lex[i]<127) {lex[ind]=_lex[i];ind++;};
     lex[ind]=0;
     for (i=0;i<strlen(lex);i++)
        if (lex[i]!=' ') break;
     strcpy(_lex,lex+i);
     ind=0;
     for (i=0;i<strlen(_lex);i++) {
         if (ind && lex[ind-1]==' ' && (_lex[i]==',' || _lex[i]==':' || _lex[i]==' ' ||
             _lex[i]==';' || _lex[i]=='\"' || _lex[i]=='(' || _lex[i]==')' || 
             _lex[i]=='&' || _lex[i]=='[' || _lex[i]==']')) ind--;
         if (ind && _lex[i]==' ' && (lex[ind-1]==',' || lex[ind-1]==':' || lex[ind-1]==';' || 
             lex[ind-1]=='\"' || lex[ind-1]=='(' || lex[ind-1]==')' || lex[ind-1]=='&' || 
             lex[ind-1]=='[' || lex[ind-1]==']' || lex[ind-1]==' ')) continue; 
         lex[ind]=_lex[i];ind++;
        }
     lex[ind]=0;
     for (i=1;i<strlen(lex);i++)
         if (lex[i]=='-' && lex[i-1]=='-') {lex[i-1]=0;break;} 
     if (!strlen(lex)) continue;
     if (lex[0]=='-' && lex[1]=='-') continue;
     strcpy(_buf,lex);
     _buf+=strlen(lex);
    }
 // At this point all lexems are represented as a one long string with pointer "char *buf"
 for (;;) {
     int i;
     char *Ctmp1,*Ctmp2,*Ctmp3;
     int curpin=0;
     int flag1=0;
     int flag2=0;
     if (*buf==0) break;            // if it's an end of lexems?
     _buf=strstr(buf,";end ");
     if (_buf==NULL) break;       // there is no new entities
     _buf+=5;
     Ctmp1=strstr(_buf,";");
     if (Ctmp1==NULL) break;
     *Ctmp1=0;                     // now Ctmp points to the name of current entity
     sprintf(lex,"entity %s is",_buf);
     buf=strstr(buf,lex);
     if (buf==NULL) {buf=lex+1;continue;}
     buf+=strlen(lex);
     addBSitem();
     BSbegin->name=new char[strlen(_buf)+1];
     strcpy(BSbegin->name,strupr(_buf));
     BSbegin->file=new char[strlen(fl)+1];
     strcpy(BSbegin->file,fl);
     // looking for IR length
     _buf=strstr(buf," instruction_length ");
     if (_buf==NULL) goto m1;
     _buf=strstr(_buf,";");
     if (_buf==NULL) goto m1;
     i=getbackint(_buf,' ');
     if (i==0) goto m1;
     BSbegin->IRlen=i;
     // looking for DR length
     _buf=strstr(buf," boundary_length ");
     if (_buf==NULL) goto m1;
     _buf=strstr(_buf,";");
     if (_buf==NULL) goto m1;
     i=getbackint(_buf,' ');
     if (i==0) goto m1;
     BSbegin->DRlen=i;
     // looking for commands SAMPLE and IDCODE
     _buf=strstr(buf," instruction_opcode ");
     if (_buf==NULL) goto m1;
     Ctmp2=strstr(_buf,";");
     if (Ctmp2==NULL) goto m1;
     *Ctmp2=0;

     // BYPASS
     Ctmp3=strstr(_buf,"\"bypass(");
     if (Ctmp3==NULL) {*Ctmp2=';';goto m1;}
     i=strstr(Ctmp3,")")-Ctmp3-7;
     BSbegin->BYPASS=new char[i];
     if (getCMDcode(Ctmp3+8,BSbegin->BYPASS)) {*Ctmp2=';';goto m1;}
     
     // EXTEST
     Ctmp3=strstr(_buf,"\"extest(");
     if (Ctmp3==NULL) {*Ctmp2=';';goto m1;}
     i=strstr(Ctmp3,")")-Ctmp3-7;
     BSbegin->EXTEST=new char[i];
     if (getCMDcode(Ctmp3+8,BSbegin->EXTEST)) {*Ctmp2=';';goto m1;}
     
     // SAMPLE
     Ctmp3=strstr(_buf,"\"sample(");
     if (Ctmp3==NULL) {*Ctmp2=';';goto m1;}
     i=strstr(Ctmp3,")")-Ctmp3-7;
     BSbegin->SAMPLE=new char[i];
     if (getCMDcode(Ctmp3+8,BSbegin->SAMPLE)) {*Ctmp2=';';goto m1;}
     
     // IDCODE
	 Ctmp3=strstr(_buf,"\"idcode(");
     if (Ctmp3==NULL) {*Ctmp2=';';goto m2;}
     i=strstr(Ctmp3,")")-Ctmp3-7;
     BSbegin->IDCODE=new char[i];
     getCMDcode(Ctmp3+8,BSbegin->IDCODE);
     *Ctmp2=';';
     
	 // looking for device ID
     _buf=strstr(buf," idcode_register ");
     if (_buf==NULL) goto m2;
     Ctmp2=strstr(_buf,";");
     if (Ctmp2==NULL) goto m2;
     *Ctmp2=0;
     Ctmp3=strstr(_buf,"\"");
     if (Ctmp3==NULL) {*Ctmp2=';';goto m2;}
     if (getIDcode(Ctmp3+1,lex)) {*Ctmp2=';';goto m2;}
     if (strlen(lex)==0) {*Ctmp2=';';goto m2;}
     BSbegin->ID=new char[strlen(lex)+1];
     strcpy(BSbegin->ID,lex);
     BSbegin->IDlen=strlen(lex);
     *Ctmp2=';';
m2:  
     // looking for device pins
     if (mode==1) {
         _buf=strstr(buf," boundary_register ");
         if (_buf==NULL) goto m1;
         Ctmp2=strstr(_buf,";");
         if (Ctmp2==NULL) goto m1;
         *Ctmp2=0;
         Ctmp3=strstr(_buf,"\"");
         if (Ctmp3==NULL) {*Ctmp2=';';goto m1;}
         Pbegin=NULL;
         PINanalysis(Ctmp3);
         if (Pbegin==NULL) {*Ctmp2=';';goto m1;}
         PINS *x;
         x=Pbegin;
         for (;Pbegin!=NULL;) {
             if (Pbegin->input==-1&&Pbegin->output==-1) 
                {Pbegin=Pbegin->next;delPINSitem(x);x=Pbegin;continue;}
             break;
         }
         if (Pbegin==NULL) goto m1;
         curpin=0;
         for (;x->next!=NULL;x=x->next) {
             if (x->next->input==-1&&x->next->output==-1) {
                 delPINSitem(x->next);
                 if (x->next==NULL) break;
                 continue;
             }
             curpin++;
         }   
         BSbegin->pins=Pbegin;
         BSbegin->PINnum=curpin+1;
         buf=Ctmp1+1;continue;
        }
      else {BSbegin->pins=NULL;BSbegin->PINnum=0;buf=Ctmp1+1;continue;}
m1:  
     buf=Ctmp1+1;
     delBSitem(BSbegin);
     continue;
 }
 delete[] bufbegin;bufbegin=NULL;
 fclose(in);
 return BSbegin;
}