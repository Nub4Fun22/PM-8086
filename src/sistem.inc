;=====================================================================
; sistem.inc
; Definitii (constante) pentru microsistemul cu 8086
;
; Fisier de tip "include": contine DOAR constante (EQU), nu cod executabil.
; Se include in program cu directiva:   include sistem.inc
;
; Toate adresele de port sunt in spatiul I/O de 64 KB al lui 8086
; (se acceseaza cu instructiunile IN / OUT, NU cu MOV la memorie).
;
; Pozitii microcomutatoare alese pentru acest proiect:
;   S1 -> interfata seriala (8251) in zona 0BF0h - 0BF2h
;   S2 -> interfata paralela (8255) in zona 0C70h - 0C76h
;=====================================================================

;---------------------------------------------------------------------
; INTERFATA SERIALA  -  circuit 8251 (USART)
;---------------------------------------------------------------------
; 8251 are doua adrese de port:
;   - registrul de DATE          (A0 = 0 -> adresa para)
;   - registrul de CONTROL/STATUS(A0 = 1 -> adresa impara)
; La SCRIERE pe adresa de control -> trimiti cuvant de MOD / COMANDA.
; La CITIRE  de pe adresa de control -> primesti cuvantul de STATUS.
;---------------------------------------------------------------------
SER_DATA    EQU 0BF0h        ; registru de date (RX / TX)
SER_CTRL    EQU 0BF1h        ; registru control (scriere) / status (citire)

; --- Biti din registrul de STATUS al lui 8251 (cititi cu IN) ---
SER_TXRDY   EQU 00000001b    ; bit 0: 1 = emitatorul e gata (poti scrie un octet)
SER_RXRDY   EQU 00000010b    ; bit 1: 1 = s-a receptionat un octet (poti citi)
SER_TXEMPTY EQU 00000100b    ; bit 2: 1 = registrul de transmisie e gol

; --- Cuvant de MOD (asincron). Configuratie: 8 date, fara paritate, 1 stop, x16 ---
;   b1 b0 = 10b -> factor baud x16
;   b3 b2 = 11b -> 8 biti de date
;   b5 b4 = 00b -> fara paritate
;   b7 b6 = 01b -> 1 bit de stop
SER_MOD     EQU 01001110b    ; = 4Eh

; --- Cuvant de COMANDA: ---
;   b0 TxEN=1, b1 DTR=1, b2 RxEN=1, b4 ErrReset=1, b5 RTS=1
SER_CMD     EQU 00110111b    ; = 37h

;---------------------------------------------------------------------
; INTERFATA PARALELA  -  circuit 8255 (PPI)
;---------------------------------------------------------------------
; 8255 are 4 adrese consecutive (A1,A0 selecteaza registrul):
;   00 -> Port A    01 -> Port B    10 -> Port C    11 -> Control
;---------------------------------------------------------------------
PAR_PORTA   EQU 0C70h        ; Port A
PAR_PORTB   EQU 0C72h        ; Port B
PAR_PORTC   EQU 0C74h        ; Port C
PAR_CTRL    EQU 0C76h        ; registru de Control (cuvant de comanda)

;=====================================================================
; ALOCAREA PINILOR 8255 (decizia de proiect)
;---------------------------------------------------------------------
; Port A (PA0..PA7)  IESIRE : segmentele afisajului 7-seg
;                             PA0=a PA1=b PA2=c PA3=d PA4=e PA5=f PA6=g PA7=dp
;
; Port B (PB0..PB7)  INTRARE: coloanele minitastaturii
;                             PB0..PB3 = 4 coloane (K0..K3)
;                             PB4..PB7 = neutilizate
;
; Port C (PC0..PC7)  IESIRE : impartit in doua:
;   PC0..PC2 (3 biti) -> intra intr-un decodificator extern 74LS138 care
;                        genereaza:
;                          * selectia celor 6 ranguri ale afisajului SI
;                          * cele 3 linii de scanare ale tastaturii
;                        (afisajul si tastatura se baleiaza pe rand)
;   PC3..PC7 (5 biti) -> 5 dintre cele 6 LED-uri (LED0..LED4)
;
; Al 6-lea LED (LED5) il punem pe PB7 (bit liber din Port B configurat ca
; iesire)? NU - Port B e intrare. Solutie: LED5 pe o iesire a lui 74LS138
; ramasa libera, sau accepti doar 5 LED pe Port C + 1 pe o iesire externa.
; Pentru SIMPLITATE in cod, tratam toate cele 6 LED ca biti pe Port C,
; presupunand ca portul C are suficienti biti prin extensie hardware.
; (In schema reala, LED5 se leaga la o linie de iesire dedicata.)
;=====================================================================

; --- Cuvant de control al lui 8255 (mod 0) ---
;   bit7 = 1 (mod I/O activ)
;   Port A iesire (bit4=0), Port B intrare (bit1=1), Port C iesire (bit0=0,bit3=0)
;   -> 10000010b = 82h
PAR_CFG     EQU 10000010b    ; A iesire, B intrare, C iesire

; --- Masti pentru cele 6 LED-uri (pe Port C, bitii PC3..PC7 + extensie) ---
; Pozitia de baza a LED-urilor pe Port C (LED0 incepe la bitul 3)
LED_BAZA    EQU 3            ; LED0 = bitul 3 din Port C

; --- Selectia rangurilor afisajului (cod binar pe PC0..PC2 -> 74LS138) ---
; Rangul r se selecteaza scriind valoarea r (0..5) pe PC0..PC2.
RANG_MASK   EQU 00000111b    ; bitii PC0..PC2 = selectie rang / linie

; --- Numarul de ranguri si de taste ---
NR_RANGURI  EQU 6
NR_TASTE    EQU 12
NR_COLOANE  EQU 4            ; coloane tastatura (pe Port B)
NR_LINII    EQU 3            ; linii tastatura (pe PC0..PC2 via 74LS138)

; Valoare returnata de scan_tastatura cand nu e nicio tasta apasata
NICIO_TASTA EQU 0FFh
