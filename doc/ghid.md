# Ghid de lucru: de unde începi și ce ai de făcut

Acesta e planul tău pas cu pas. Pentru fiecare pas: ce faci, în ce fișier,
ce registre atingi și de unde înveți.

---

## Ordinea recomandată de implementare

Mergi de la cel mai simplu la cel mai complex. Fiecare subrutină o testezi
înainte să treci la următoarea.

1. `init_8255` și `init_8251` (sunt cele mai simple — doar scriu config)
2. `par_emisie` (un singur OUT)
3. `ser_emisie` și `ser_receptie` (bucla de așteptare pe status)
4. `led` (lucru pe biți + oglindă)
5. `afis_hexa` (tabelă de conversie + multiplexare)
6. `scan_tastatura` (cea mai grea — matrice linii/coloane)

---

## Unde scrii

- **Codul**: `src/proiect.asm` — completezi corpul subrutinelor unde scrie `TODO`.
- **Constantele** (adrese, măști): `src/sistem.inc` — deja completat, ajustezi
  doar dacă schimbi cablajul.
- **Nu modifica** structura `main`/`proc`/`endp` decât dacă adaugi o rutină nouă.

---

## Registre: ce atingi, ce NU

| Registru | Poți folosi? | Observație |
|----------|-------------|------------|
| AX (AH/AL) | DA | registrul de lucru principal; AL e operandul pt. IN/OUT |
| BX, CX, DX | DA | DX îl folosim mereu ca adresă de port pt. IN/OUT |
| SI, DI | DA | indecși pt. parcurgere tabele/șiruri |
| DS | setat 1x în main | nu-l mai schimba după `MOV DS, AX` |
| CS, IP | NU | controlate de procesor (cod + pointer instrucțiune) |
| SS, SP | NU direct | stiva; le gestionează PUSH/POP/CALL/RET |
| FLAGS | indirect | se setează automat; le testezi cu JZ/JC/TEST etc. |

Regula de aur: dacă o rutină strică un registru de care are nevoie
apelantul, salvează-l cu `PUSH` la intrare și `POP` la ieșire.

---

## Pas cu pas pe fiecare subrutină

### `init_8255` / `init_8251` — programarea interfețelor
- **Ce face**: scrie cuvântul de configurare în registrul de control.
- **Atingi**: AL (valoarea), DX (adresa portului de control).
- **De învățat**: cuvântul de control al lui 8255 (mod 0) și cuvintele de
  mod+comandă ale lui 8251. Vezi comentariile din `sistem.inc`.
- **E deja scris** — citește-l și înțelege fiecare linie.

### `par_emisie` — un caracter pe paralelă
- **Ce face**: `OUT` octetul din AL pe Port A.
- **Atingi**: DX. AL rămâne neatins.
- **E deja scris** — cel mai simplu exemplu de referință.

### `ser_emisie` / `ser_receptie` — serial
- **Ce face**: așteaptă bitul de status (TxRDY la emisie, RxRDY la recepție),
  apoi scrie/citește registrul de date.
- **Atingi**: AL, DX. La emisie salvăm AL pe stivă cât testăm status-ul.
- **De învățat**: Lab 2 (TEST, JZ, bucle), plus biții de status din 8251.
- **E deja scris** — modelul „poll pe status" e tipic.

### `led` — aprinde/stinge un LED
- **Intrare**: BL = nr. LED (0..5), CL = acțiune (0 stinge / 1 aprinde).
- **Ce face**: construiește masca `1 << BL`, modifică `led_stare`, scoate pe port.
- **De învățat**: Lab 2 (SHL, OR, AND, NOT), lucru pe biți.
- **E deja scris** — bun exemplu de folosire a variabilei-oglindă.

### `afis_hexa` — cifră hexa pe un rang
- **Intrare**: AL = cifra (0..0Fh), BL = rangul (0..5).
- **Ce face**: `seg7[AL]` → cod segmente → Port A; apoi selectează rangul BL.
- **De completat**: partea de selecție a rangului prin Port C (vezi TODO).
- **De învățat**: Lab 3 (tabele, OFFSET, indexare cu SI).

### `scan_tastatura` — matrice 4x3
- **Ieșire**: AL = codul tastei (0..11) sau 0FFh dacă niciuna.
- **Ce face**: pentru fiecare linie o activează prin Port C, citește coloanele
  prin Port B, calculează `cod = linie*3 + coloana`.
- **De completat**: toată bucla (vezi pseudocodul din TODO).
- **De învățat**: Lab 2 (bucle LOOP, salturi), lucru pe biți pentru a izola
  coloana activă.

---

## Cum testezi

Codul e scris în stilul din laboratoare (`.model small`, `INT 21h` pentru
ieșire), ca să poți rula/asambla cu extensia MASM/TASM din VS Code.

ATENȚIE: perifericele reale (8251/8255 la porturi) NU există într-un emulator
DOS obișnuit. Pentru verificare ai două opțiuni:
1. **Logica în sine** (măști, bucle, tabele) o poți testa separat, pe valori
   în registre, fără hardware.
2. **Comportamentul cu periferice** se verifică cel mai bine într-un simulator
   care modelează 8086 + 8255/8251 (ex. Proteus, dacă îl folosești și pentru
   schemă). Acolo vezi efectiv LED-urile, afișajul și tastatura.

---

## Legătura cu documentul de predare (cerut de enunț)

Pe măsură ce completezi, vei avea gata materialul pentru documentul final:
- **Descriere hardware (3–5 pag)**: din `doc/hardware.md`.
- **Programele (3–7 pag)**: din `src/proiect.asm`, cu comentariile deja puse.
- **Schemele (anexe, A4/A3)**: le desenezi în CAD pe baza lui `doc/hardware.md`.
