;=====================================================================
; proiect.asm  -  Microsistem cu microprocesorul 8086
; Proiect PM - CTI 2025-2026
; Autor: Sebastian-Florin Bor
;---------------------------------------------------------------------
; Toate rutinele cerute de tema sunt scrise ca SUBRUTINE (proc/endp).
; Perifericele se acceseaza prin PORTURI I/O cu instructiunile:
;     OUT DX, AL   ; scrie octetul din AL la portul a carui adresa e in DX
;     IN  AL, DX   ; citeste in AL octetul de la portul a carui adresa e in DX
; (adresa portului > 0FFh => OBLIGATORIU prin DX, nu ca operand imediat)
;---------------------------------------------------------------------
; REGISTRE - ce poti atinge si ce NU:
;   - LIBER de folosit in rutine: AX (AH/AL), BX, CX, DX, SI, DI
;     cu conditia sa salvezi pe stiva (PUSH/POP) ce vrei sa pastrezi.
;   - NU atinge direct: CS, IP (controlate de procesor).
;   - DS il setezi O SINGURA DATA in main (MOV AX,@data / MOV DS,AX).
;   - SS/SP sunt pentru stiva; le gestioneaza PUSH/POP/CALL/RET.
;   - DX e "registrul de port": il folosim mereu pentru adresa de port la IN/OUT.
;---------------------------------------------------------------------
; CONVENTIE DE APEL:
;   - parametri de intrare in AL / BL / CL (documentat la fiecare rutina)
;   - rezultatul se intoarce in AL (sau prin Carry Flag)
;   - fiecare rutina spune explicit ce registre DISTRUGE
;---------------------------------------------------------------------
; ALOCAREA PINILOR (decizie de proiect, detaliata in sistem.inc):
;   Port A -> segmente afisaj 7-seg
;   Port B -> coloane tastatura (intrare)
;   Port C -> PC0..PC2 selectie rang/linie (via 74LS138), PC3..PC7 LED-uri
;---------------------------------------------------------------------
; NOTE DE VERIFICAT PE SCHEMA REALA (nu sunt erori de cod):
;   TODO 1 - valorile de config (SER_MOD, SER_CMD, PAR_CFG) din sistem.inc
;   TODO 2 - tabela seg7: segmente active pe 1 sau pe 0 (vezi mai jos)
;=====================================================================

dosseg
.model small
.stack 100h

include sistem.inc

.data
    ; Tabela de conversie cifra hexa (0..F) -> cod 7 segmente.
    ; Ordinea bitilor:  dp g f e d c b a  (PA7..PA0)
    ; TODO 2: valorile sunt pentru segmente active pe 1. Daca la tine
    ;   segmentele se aprind pe 0, complementeaza fiecare octet (NOT).
    seg7 db 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h   ; 0 1 2 3 4 5 6 7
         db 7Fh,6Fh,77h,7Ch,39h,5Eh,79h,71h   ; 8 9 A b C d E F

    ; Oglinda software a Port C (8255 nu permite citirea sigura a unui port
    ; de iesire). Tinem aici ce am scris ultima data pe Port C, ca sa putem
    ; modifica doar unii biti (LED-uri vs selectie rang) fara sa-i stricam
    ; pe ceilalti.
    portc_stare db 00h

.code

;=====================================================================
; main  -  punct de intrare / program demonstrativ
;=====================================================================
main proc
    MOV AX, @data
    MOV DS, AX

    CALL init_8255        ; programeaza interfata paralela
    CALL init_8251        ; programeaza interfata seriala

    ; --- scenariu de test demonstrativ ---
    MOV BL, 0             ; LED 0
    MOV CL, 1             ; actiune = aprinde
    CALL led

    MOV AL, 0Ah           ; cifra hexa 'A'
    MOV BL, 0             ; rangul 0
    CALL afis_hexa

    MOV AL, 'X'           ; trimite caracterul 'X' pe serial
    CALL ser_emisie

    MOV AX, 4C00h         ; iesire DOS (doar pentru rulare in emulator)
    INT 21h
main endp


;=====================================================================
; 1) init_8251  -  programarea interfetei seriale (8251)
;---------------------------------------------------------------------
; INTRARI : niciuna (foloseste SER_MOD / SER_CMD din .inc)
; IESIRI  : niciuna
; DISTRUGE: AL, DX
; OBS: dupa reset, 8251 asteapta intai cuvantul de MOD, apoi COMANDA.
;=====================================================================
init_8251 proc
    MOV DX, SER_CTRL
    MOV AL, SER_MOD      ; cuvant de mod: asincron 8N1, factor x16
    OUT DX, AL
    MOV AL, SER_CMD      ; cuvant de comanda: TxEN, RxEN, DTR, RTS, ErrReset
    OUT DX, AL
    RET
init_8251 endp


;=====================================================================
; 2) init_8255  -  programarea interfetei paralele (8255)
;---------------------------------------------------------------------
; INTRARI : niciuna (foloseste PAR_CFG din .inc)
; IESIRI  : niciuna
; DISTRUGE: AL, DX
;=====================================================================
init_8255 proc
    MOV DX, PAR_CTRL
    MOV AL, PAR_CFG      ; A iesire, B intrare, C iesire (mod 0)
    OUT DX, AL
    RET
init_8255 endp


;=====================================================================
; 3) ser_emisie  -  emisie (transmitere) caracter pe interfata seriala
;---------------------------------------------------------------------
; INTRARI : AL = octetul de transmis
; IESIRI  : niciuna
; DISTRUGE: DX (AL se pastreaza)
; ALGORITM: asteapta TxRDY=1 in status, apoi scrie octetul in reg. de date.
;=====================================================================
ser_emisie proc
    PUSH AX              ; salvam octetul (AL) cat testam status-ul
asteapta_tx:
    MOV DX, SER_CTRL
    IN  AL, DX           ; citeste registrul de status
    TEST AL, SER_TXRDY   ; emitatorul e gata?
    JZ  asteapta_tx      ; nu -> mai asteapta
    POP AX               ; recuperam octetul in AL
    MOV DX, SER_DATA
    OUT DX, AL           ; scrie octetul pe linia seriala
    RET
ser_emisie endp


;=====================================================================
; 4) ser_receptie  -  receptie caracter de pe interfata seriala
;---------------------------------------------------------------------
; INTRARI : niciuna
; IESIRI  : AL = octetul receptionat
; DISTRUGE: DX
; ALGORITM: asteapta RxRDY=1 in status, apoi citeste reg. de date.
;=====================================================================
ser_receptie proc
asteapta_rx:
    MOV DX, SER_CTRL
    IN  AL, DX           ; citeste registrul de status
    TEST AL, SER_RXRDY   ; a sosit un octet?
    JZ  asteapta_rx      ; nu -> mai asteapta
    MOV DX, SER_DATA
    IN  AL, DX           ; citeste octetul receptionat
    RET
ser_receptie endp


;=====================================================================
; 5) par_emisie  -  emisie caracter pe interfata paralela (8255, Port A)
;---------------------------------------------------------------------
; INTRARI : AL = octetul de scos pe Port A
; IESIRI  : niciuna
; DISTRUGE: DX (AL se pastreaza)
; OBS: scoate direct un octet pe Port A (cele 8 linii paralele).
;=====================================================================
par_emisie proc
    MOV DX, PAR_PORTA
    OUT DX, AL           ; scoate octetul pe Port A
    RET
par_emisie endp


;=====================================================================
; 6) scan_tastatura  -  scanarea minitastaturii (12 contacte)
;---------------------------------------------------------------------
; INTRARI : niciuna
; IESIRI  : AL = codul tastei apasate (0..11), sau NICIO_TASTA (0FFh)
; DISTRUGE: AX, BX, CX, DX
; MODEL: matrice 3 linii x 4 coloane = 12 taste.
;   - liniile se activeaza pe rand prin PC0..PC2 (valoare 0,1,2)
;   - coloanele se citesc pe Port B (PB0..PB3)
;   - o tasta apasata aduce bitul coloanei sale pe 1 cand linia ei e activa
;   - cod tasta = linie * NR_COLOANE + coloana
; ATENTIE: activarea liniei pe PC0..PC2 nu trebuie sa strice bitii LED
;   (PC3..PC7). De aceea pastram LED-urile din oglinda si doar inlocuim
;   bitii de selectie (PC0..PC2).
;=====================================================================
scan_tastatura proc
    XOR BH, BH           ; BH = numarul liniei curente (0..2)
linie_urm:
    CMP BH, NR_LINII
    JAE nicio             ; am parcurs toate liniile fara tasta

    ; --- activeaza linia BH pe PC0..PC2, pastrand bitii LED din oglinda ---
    MOV AL, portc_stare
    AND AL, NOT RANG_MASK ; sterge bitii PC0..PC2 (pastreaza LED-urile)
    OR  AL, BH           ; pune codul liniei pe PC0..PC2
    MOV portc_stare, AL
    MOV DX, PAR_PORTC
    OUT DX, AL

    ; --- citeste coloanele de pe Port B ---
    MOV DX, PAR_PORTB
    IN  AL, DX           ; AL = starea coloanelor (PB0..PB3 utile)

    ; --- testeaza fiecare coloana (0..NR_COLOANE-1) ---
    XOR BL, BL           ; BL = numarul coloanei curente
coloana_urm:
    CMP BL, NR_COLOANE
    JAE linie_gata
    MOV CL, BL
    MOV AH, 1
    SHL AH, CL           ; AH = masca bitului coloanei BL
    TEST AL, AH          ; coloana BL activa?
    JNZ gasit
    INC BL
    JMP coloana_urm

linie_gata:
    INC BH
    JMP linie_urm

gasit:
    ; cod = BH * NR_COLOANE + BL
    MOV AL, BH
    MOV CL, NR_COLOANE
    MUL CL               ; AX = BH * NR_COLOANE (rezultat in AL, e mic)
    ADD AL, BL           ; AL = cod tasta (0..11)
    RET

nicio:
    MOV AL, NICIO_TASTA  ; 0FFh = nicio tasta
    RET
scan_tastatura endp


;=====================================================================
; 7) led  -  aprinde / stinge un LED
;---------------------------------------------------------------------
; INTRARI : BL = numarul LED-ului (0..5)
;           CL = actiune (0 = stinge, 1 = aprinde)
; IESIRI  : niciuna
; DISTRUGE: AX, CX, DX
; METODA: LED-urile sunt pe Port C incepand de la bitul LED_BAZA (PC3).
;   Construim masca bitului, modificam DOAR acel bit in oglinda portc_stare
;   (fara sa atingem bitii de selectie PC0..PC2), apoi scoatem pe Port C.
;=====================================================================
led proc
    MOV AL, 1
    MOV CH, CL           ; pastram actiunea in CH (0 stinge / 1 aprinde)
    MOV CL, BL
    ADD CL, LED_BAZA     ; pozitia reala a bitului = nr_led + LED_BAZA
    SHL AL, CL           ; AL = masca bitului LED-ului cerut
    CMP CH, 0
    JZ  led_stinge
led_aprinde:
    OR  portc_stare, AL  ; pune bitul pe 1
    JMP led_scoate
led_stinge:
    NOT AL               ; masca inversata
    AND portc_stare, AL  ; pune bitul pe 0
led_scoate:
    MOV AL, portc_stare
    MOV DX, PAR_PORTC
    OUT DX, AL
    RET
led endp


;=====================================================================
; 8) afis_hexa  -  afiseaza o cifra hexa pe un rang cu 7 segmente
;---------------------------------------------------------------------
; INTRARI : AL = valoarea de afisat (0..0Fh)
;           BL = rangul pe care se afiseaza (0..5)
; IESIRI  : niciuna
; DISTRUGE: AX, BX, SI, DX
; ALGORITM:
;   1. cauta codul de segmente in tabela seg7[AL]
;   2. il scoate pe Port A (segmentele)
;   3. selecteaza rangul BL pe PC0..PC2 (via 74LS138), pastrand bitii LED
;=====================================================================
afis_hexa proc
    AND AL, 0Fh          ; sigur ramanem in 0..F
    MOV SI, OFFSET seg7
    XOR AH, AH
    ADD SI, AX           ; SI -> seg7[AL]
    MOV AL, [SI]         ; AL = cod 7 segmente
    MOV DX, PAR_PORTA
    OUT DX, AL           ; scoate segmentele pe Port A

    ; --- selecteaza rangul BL pe PC0..PC2, pastrand LED-urile ---
    MOV AL, portc_stare
    AND AL, NOT RANG_MASK ; sterge bitii de selectie (pastreaza LED)
    AND BL, RANG_MASK    ; rangul pe 3 biti (0..5, max 7)
    OR  AL, BL           ; pune codul rangului pe PC0..PC2
    MOV portc_stare, AL
    MOV DX, PAR_PORTC
    OUT DX, AL
    RET
afis_hexa endp

end main
