#ifndef KB_H
#define KB_H

#include "screen.h"
#include "system.h"
#include "types.h"

string readStr()
{
    char buff;
    string buffstr;
    uint8 i = 0;
    uint8 reading = 1;
    while(reading)
    {
        if(inportb(0x64) & 0x1)                 
        {
            switch(inportb(0x60))
            { 
      /*case 1:
                printCh('(char)27);           Escape button
                buffstr[i] = (char)27;
                i++;
                break;*/
        case 2:
                printCh('1');
                buffstr[i] = '1';
                i++;
                break;
        case 3:
                printCh('2');
                buffstr[i] = '2';
                i++;
                break;
        case 4:
                printCh('3');
                buffstr[i] = '3';
                i++;
                break;
        case 5:
                printCh('4');
                buffstr[i] = '4';
                i++;
                break;
        case 6:
                printCh('5');
                buffstr[i] = '5';
                i++;
                break;
        case 7:
                printCh('6');
                buffstr[i] = '6';
                i++;
                break;
        case 8:
                printCh('7');
                buffstr[i] = '7';
                i++;
                break;
        case 9:
                printCh('8');
                buffstr[i] = '8';
                i++;
                break;
        case 10:
                printCh('9');
                buffstr[i] = '9';
                i++;
                break;
        case 11:
                printCh('0');
                buffstr[i] = '0';
                i++;
                break;
        case 12:
                printCh('-');
                buffstr[i] = '-';
                i++;
                break;
        case 13:
                printCh('=');
                buffstr[i] = '=';
                i++;
                break;
        case 14:
                printCh('\b');
                i--;
                buffstr[i] = 0;
                break;
       /* case 15:
                printCh('\t');          Tab button
                buffstr[i] = '\t';
                i++;
                break;*/
        case 16:
                printCh('q');
                buffstr[i] = 'q';
                i++;
                break;
        case 17:
                printCh('w');
                buffstr[i] = 'w';
                i++;
                break;
        case 18:
                printCh('e');
                buffstr[i] = 'e';
                i++;
                break;
        case 19:
                printCh('r');
                buffstr[i] = 'r';
                i++;
                break;
        case 20:
                printCh('t');
                buffstr[i] = 't';
                i++;
                break;
        case 21:
                printCh('y');
                buffstr[i] = 'y';
                i++;
                break;
        case 22:
                printCh('u');
                buffstr[i] = 'u';
                i++;
                break;
        case 23:
                printCh('i');
                buffstr[i] = 'i';
                i++;
                break;
        case 24:
                printCh('o');
                buffstr[i] = 'o';
                i++;
                break;
        case 25:
                printCh('p');
                buffstr[i] = 'p';
                i++;
                break;
        case 26:
                printCh('[');
                buffstr[i] = '[';
                i++;
                break;
        case 27:
                printCh(']');
                buffstr[i] = ']';
                i++;
                break;
        case 28:
               // printCh('\n');
               // buffstr[i] = '\n';
                  i++;
               reading = 0;
                break;
      /*  case 29:
                printCh('q');           Left Control
                buffstr[i] = 'q';
                i++;
                break;*/
        case 30:
                printCh('a');
                buffstr[i] = 'a';
                i++;
                break;
        case 31:
                printCh('s');
                buffstr[i] = 's';
                i++;
                break;
        case 32:
                printCh('d');
                buffstr[i] = 'd';
                i++;
                break;
        case 33:
                printCh('f');
                buffstr[i] = 'f';
                i++;
                break;
        case 34:
                printCh('g');
                buffstr[i] = 'g';
                i++;
                break;
        case 35:
                printCh('h');
                buffstr[i] = 'h';
                i++;
                break;
        case 36:
                printCh('j');
                buffstr[i] = 'j';
                i++;
                break;
        case 37:
                printCh('k');
                buffstr[i] = 'k';
                i++;
                break;
        case 38:
                printCh('l');
                buffstr[i] = 'l';
                i++;
                break;
        case 39:
                printCh(';');
                buffstr[i] = ';';
                i++;
                break;
        case 40:
                printCh((char)44);               //   Single quote (')
                buffstr[i] = (char)44;
                i++;
                break;
        case 41:
                printCh((char)44);               // Back tick (`)
                buffstr[i] = (char)44;
                i++;
                break;
     /* case 42:                                 Left shift 
                printCh('q');
                buffstr[i] = 'q';
                i++;
                break;
        case 43:                                 \ (< for somekeyboards)   
                printCh((char)92);
                buffstr[i] = 'q';
                i++;
                break;*/
        case 44:
                printCh('z');
                buffstr[i] = 'z';
                i++;
                break;
        case 45:
                printCh('x');
                buffstr[i] = 'x';
                i++;
                break;
        case 46:
                printCh('c');
                buffstr[i] = 'c';
                i++;
                break;
        case 47:
                printCh('v');
                buffstr[i] = 'v';
                i++;
                break;                
        case 48:
                printCh('b');
                buffstr[i] = 'b';
                i++;
                break;               
        case 49:
                printCh('n');
                buffstr[i] = 'n';
                i++;
                break;                
        case 50:
                printCh('m');
                buffstr[i] = 'm';
                i++;
                break;               
        case 51:
                printCh(',');
                buffstr[i] = ',';
                i++;
                break;                
        case 52:
                printCh('.');
                buffstr[i] = '.';
                i++;
                break;            
        case 53:
                printCh('/');
                buffstr[i] = '/';
                i++;
                break;            
        case 54:
                printCh('.');
                buffstr[i] = '.';
                i++;
                break;            
        case 55:
                printCh('/');
                buffstr[i] = '/';
                i++;
                break;            
      /*case 56:
                printCh(' ');           Right shift
                buffstr[i] = ' ';
                i++;
                break;*/           
        case 57:
                printCh(' ');
                buffstr[i] = ' ';
                i++;
                break;
            }
        }
    }
    buffstr[i] = 0;                   
    return buffstr;
}

#endif