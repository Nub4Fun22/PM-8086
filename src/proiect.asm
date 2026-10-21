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
;   - DS il setezi O SINGURA DATA in main (MOV AX,@data / MOV DS,AX)
;     ca sa poti accesa variabilele din .data; dupa aceea nu-l mai schimba.
;   - SS si SP sunt pentru stiva; nu-i modifica manual decat daca stii
;     exact ce faci. PUSH/POP/CALL/RET ii gestioneaza automat.
;   - DX e "registrul de port": il folosim mereu ca sa tinem adresa de
;     port pentru IN/OUT. De aceea multe rutine il distrug.
;---------------------------------------------------------------------
; CONVENTIE DE APEL folosita in tot fisierul:
;   - parametri de intrare in AL / BL / CL (documentat la fiecare rutina)
;   - rezultatul se intoarce in AL (sau prin Carry Flag)
;   - fiecare rutina spune explicit ce registre DISTRUGE
;=====================================================================
; !!! CITESTE: toate punctele de lucru sunt marcate cu "TODO" in cod.
;     Cauta "TODO" (Ctrl+F) ca sa le vezi pe toate. Rezumat:
;       TODO 0  - decizie alocare biti pe Port C (LED vs rang vs tastatura)
;       TODO 1  - verifica valorile de config din sistem.inc
;       TODO 2  - verifica tabela seg7 (segmente active pe 1 sau pe 0)
;       TODO 6  - de SCRIS: scanarea minitastaturii
;       TODO 8  - de COMPLETAT: selectia rangului in afis_hexa
;       TODO T  - scenariu de test in main
;=====================================================================

dosseg
.model small
.stack 100h

include sistem.inc

.data
    ; Tabela de conversie cifra hexa (0..F) -> cod 7 segmente.
    ; Ordinea bitilor presupusa:  dp g f e d c b a
    ; TODO 2: verifica cu schema ta daca segmentele sunt active pe 1 sau pe 0.
    ;   Valorile de mai jos sunt pentru segmente active pe 1 (anod comun invers).
    ;   Daca la tine sunt active pe 0, trebuie sa COMPLEMENTEZI fiecare octet
    ;   (ex: in loc de 3Fh pui NOT 3Fh = 0C0h), altfel afisajul va fi inversat.
    seg7 db 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h   ; 0 1 2 3 4 5 6 7
         db 7Fh,6Fh,77h,7Ch,39h,5Eh,79h,71h   ; 8 9 A b C d E F

    ; "Oglinda" software a starii LED-urilor (8255 nu permite citirea
    ; sigura a unui port de iesire). Aici tinem ce am scos pe portul LED.
    led_stare db 00h

    ; TODO 0: daca selectia rangului afisajului e tot pe Port C, tine si
    ;   pentru ea o oglinda separata (ex: rang_stare db 00h) ca sa nu te bati
    ;   cu bitii LED-urilor. Vezi nota de la "TODO 0" de mai jos.

.code

;=====================================================================
; TODO 0 - DECIZIE IMPORTANTA: alocarea bitilor pe Port C
;---------------------------------------------------------------------
; Acum DOUA rutine folosesc Port C si se SUPRAPUN:
;   - led          scoate starea LED-urilor pe Port C
;   - afis_hexa    vrea sa selecteze rangul (0..5) tot pe Port C
; Trebuie sa imparti bitii Port C (8 biti) intre functii, de exemplu:
;   PC0..PC2 -> selectie coloane/linii tastatura
;   PC3..PC7 -> ... etc
; SAU muti LED-urile pe Port B (daca nu-l folosesti la tastatura) etc.
; Pana nu iei aceasta decizie, 6 si 8 nu pot fi corecte simultan.
; Dupa ce decizi, actualizeaza mastile din sistem.inc si rutinele de mai jos.
;=====================================================================

;=====================================================================
; main  -  punct de intrare / program demonstrativ
;=====================================================================
main proc
    MOV AX, @data
    MOV DS, AX

    CALL init_8255        ; programeaza interfata paralela
    CALL init_8251        ; programeaza interfata seriala

    ; TODO T: scenariu de test. Decomenteaza / completeaza exemple ca sa
    ;   demonstrezi ca rutinele functioneaza. Exemple:
    ;     MOV BL, 0          ; LED 0
    ;     MOV CL, 1         ; actiune = aprinde
    ;     CALL led
    ;     MOV AL, 0Ah       ; cifra 'A'
    ;     MOV BL, 0         ; rangul 0
    ;     CALL afis_hexa
    ;     MOV AL, 'X'
    ;     CALL ser_emisie

    MOV AX, 4C00h        ; iesire DOS (doar pentru rulare in emulator)
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
    ; TODO 1: verifica SER_MOD si SER_CMD in sistem.inc. Valorile actuale
    ;   inseamna: asincron, 8 biti date, fara paritate, 1 stop, factor x16.
    ;   Daca tema/schema cere alta configuratie (ex: paritate, 2 biti stop),
    ;   schimba constantele acolo si justifica alegerea in document.
    ; TODO 1: unele montaje cer un mic delay sau cateva scrieri de 0 pe reg.
    ;   de control inainte de resetare (pentru resincronizare 8251). Verifica
    ;   la laborator daca e nevoie.
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
    ; TODO 1: verifica PAR_CFG in sistem.inc. Valoarea actuala (82h) =
    ;   Port A iesire, Port B intrare, Port C iesire, mod 0.
    ;   Daca iti schimbi alocarea perifericelor (ex: pui LED-uri pe Port B),
    ;   recalculeaza cuvantul de control si actualizeaza constanta.
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
;=====================================================================
par_emisie proc
    ; TODO 1: Port A e folosit si de afis_hexa (pentru segmente). Daca vrei ca
    ;   "emisie pe paralela" sa insemne alt port sau alt scop, decide clar ce
    ;   reprezinta octetul scos aici si pe ce pini ajunge in schema.
    MOV DX, PAR_PORTA
    OUT DX, AL           ; scoate octetul pe Port A
    RET
par_emisie endp


;=====================================================================
; 6) scan_tastatura  -  scanarea minitastaturii (12 contacte)
;---------------------------------------------------------------------
; INTRARI : niciuna
; IESIRI  : AL = codul tastei apasate (0..11), sau 0FFh daca nicio tasta
; DISTRUGE: BX, CX, DX
; IDEE: matrice 4 linii x 3 coloane = 12 taste.
;       Activezi pe rand cate o linie prin Port C (PC0..PC3),
;       citesti coloanele prin Port B, deduci tasta apasata.
;=====================================================================
scan_tastatura proc
    ; ================= TODO 6: DE SCRIS DE LA ZERO =================
    ; Acum rutina returneaza mereu 0FFh (nicio tasta). Trebuie sa scrii
    ; toata bucla de scanare matriceala.
    ; Schelet orientativ (pseudocod):
    ;   cod = 0
    ;   pentru fiecare linie 0..3:
    ;       activeaza linia pe Port C (ex: OUT PAR_PORTC, masca_linie)
    ;       IN AL, Port B                ; citeste coloanele
    ;       pentru fiecare coloana 0..2:
    ;           daca bitul coloanei e activ -> AL = cod ; RET
    ;           cod = cod + 1
    ;   AL = 0FFh  ; nicio tasta
    MOV AL, 0FFh         ; valoare implicita: nicio tasta
    RET
scan_tastatura endp


;=====================================================================
; 7) led  -  aprinde / stinge un LED
;---------------------------------------------------------------------
; INTRARI : BL = numarul LED-ului (0..5)
;           CL = actiune (0 = stinge, 1 = aprinde)
; IESIRI  : niciuna
; DISTRUGE: AX, CX, DX
; METODA: construim masca bitului (1 shiftat la stanga cu BL), apoi
;         modificam variabila-oglinda led_stare si o scoatem pe port.
;=====================================================================
led proc
    MOV AL, 1
    MOV CH, CL           ; pastram actiunea in CH
    MOV CL, BL           ; nr. de pozitii de shiftat
    SHL AL, CL           ; AL = masca bitului LED-ului cerut
    CMP CH, 0
    JZ  stinge
aprinde:
    OR  led_stare, AL    ; pune bitul pe 1
    JMP scoate
stinge:
    NOT AL               ; masca inversata
    AND led_stare, AL    ; pune bitul pe 0
scoate:
    MOV AL, led_stare
    ; TODO 0: aici scoatem TOATA oglinda pe Port C. Daca Port C e impartit
    ;   intre LED-uri si selectie rang/tastatura, trebuie sa combini (OR)
    ;   doar bitii de LED cu ceilalti biti, nu sa suprascrii tot portul.
    MOV DX, PAR_PORTC    ; LED-urile sunt pe Port C (ajusteaza daca difera)
    OUT DX, AL
    RET
led endp


;=====================================================================
; 8) afis_hexa  -  afiseaza o cifra hexa pe un rang cu 7 segmente
;---------------------------------------------------------------------
; INTRARI : AL = valoarea de afisat (0..0Fh)
;           BL = rangul pe care se afiseaza (0..5)
; IESIRI  : niciuna
; DISTRUGE: AX, SI, DX
; ALGORITM: cauta codul in tabela seg7[AL], il scoate pe Port A, apoi
;           selecteaza rangul BL prin Port C (multiplexare).
;=====================================================================
afis_hexa proc
    AND AL, 0Fh          ; sigur ramanem in 0..F
    MOV SI, OFFSET seg7
    XOR AH, AH
    ADD SI, AX           ; SI -> seg7[AL]
    MOV AL, [SI]         ; AL = cod 7 segmente
    MOV DX, PAR_PORTA
    OUT DX, AL           ; scoate segmentele pe Port A
    ; ================= TODO 8: DE COMPLETAT =================
    ; Partea de sus (segmentele) e gata. Mai lipseste: selecteaza rangul BL.
    ;   Pasi:
    ;     1. construieste masca rangului (ex: 1 shiftat la stanga cu BL)
    ;     2. scoate masca pe liniile de selectie a rangurilor (Port C)
    ;   ATENTIE (vezi TODO 0): daca rangurile si LED-urile sunt pe acelasi
    ;   Port C, nu suprascrie bitii LED-urilor - combina cu OR / foloseste
    ;   o oglinda separata pentru selectia rangului.
    RET
afis_hexa endp

end main
