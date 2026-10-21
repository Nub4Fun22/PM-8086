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

; --- Cuvant de MOD (asincron). Configuratie aleasa: 8N1, factor x16 ---
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
; In harta noastra adresele sunt la pas de 2 (A0 e legat la A1 bus).
;---------------------------------------------------------------------
PAR_PORTA   EQU 0C70h        ; Port A
PAR_PORTB   EQU 0C72h        ; Port B
PAR_PORTC   EQU 0C74h        ; Port C
PAR_CTRL    EQU 0C76h        ; registru de Control (cuvant de comanda)

; --- Cuvant de control al lui 8255 (mod 0). bit7=1 (mod I/O activ) ---
;   Port A iesire, Port B intrare, Port C iesire -> 10000010b = 82h
;   (A = segmente afisaj, B = citire coloane tastatura, C = selectii+led)
PAR_CFG     EQU 10000010b    ; 82h: A ies, B intr, C ies
PAR_CFG_OUT EQU 10000000b    ; 80h: A,B,C toate iesiri (varianta alternativa)

;---------------------------------------------------------------------
; PERIFERICE conectate la 8255 (alocare propusa)
;---------------------------------------------------------------------
;   Port A  -> segmentele afisajului 7-seg (a..g + dp)   : IESIRE
;   Port B  -> coloanele tastaturii (3 coloane)          : INTRARE
;   Port C  -> PC0..PC3: linii tastatura / selectie rang : IESIRE
;              PC4..PC7 + ... : cele 6 LED-uri            : IESIRE
;---------------------------------------------------------------------

; Masti pentru cele 6 LED-uri pe Port C (ajusteaza la cablajul real)
LED0        EQU 00000001b
LED1        EQU 00000010b
LED2        EQU 00000100b
LED3        EQU 00001000b
LED4        EQU 00010000b
LED5        EQU 00100000b
