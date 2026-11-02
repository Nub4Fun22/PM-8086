# Specificația schemei (conexiuni pin-cu-pin)

Document de lucru pentru desenarea schemei în Proteus (sau alt CAD).
Fiecare secțiune listează ce pin se leagă de ce. Diagrama-bloc generală e
în discuția din chat / se poate reface ca figură în document.

Legenda semnalelor:
- `A0..A19` = magistrala de adrese (după latch-uri)
- `D0..D15` = magistrala de date
- `RD#`, `WR#` = citire / scriere (active pe 0)
- `M/IO#` = 1 memorie, 0 intrare/ieșire
- `CS#` = chip select (activ pe 0)

---

## 1. Microprocesorul 8086 (minimal mode)

| Pin 8086 | Se leagă la |
|----------|-------------|
| AD0..AD15 | intrările latch-urilor 74LS373 (adresă) ȘI magistrala de date D0..D15 |
| A16..A19 | al treilea latch 74LS373 |
| ALE | intrarea de clock (LE) a latch-urilor 74LS373 |
| RD# | RD# la memorii și la 8251/8255 (prin RD#) |
| WR# | WR# la memorii și la 8251/8255 |
| M/IO# | logica de selecție: alege între memorie și I/O |
| CLK | ieșirea CLK a generatorului de tact 8284 |
| RESET | ieșirea RESET a lui 8284 |
| MN/MX# | la +5V (mod minimal) |

Notă: în mod minimal, 8086 generează direct RD#, WR#, M/IO#, ALE.
Tactul vine de la circuitul generator **8284**.

---

## 2. Latch-uri adrese — 74LS373 (x3)

8086 are AD0..AD15 multiplexate (adresă + date pe aceleași linii). ALE
„prinde" adresa la începutul ciclului.

| 74LS373 | Intrări (D) | Ieșiri (Q) → magistrala adrese |
|---------|-------------|-------------------------------|
| U1 | AD0..AD7 | A0..A7 |
| U2 | AD8..AD15 | A8..A15 |
| U3 | A16..A19 (+ 4 neutilizate) | A16..A19 |

- Pinul LE (Latch Enable) al tuturor = **ALE** de la 8086
- Pinul OE# (Output Enable) = masă (mereu activ)

---

## 3. EPROM 27C2048 — 128 KB (E0000h–FFFFFh)

> TODO: confirmă din datasheet organizarea (nr. linii adresă = A0..A16
> pentru 128K, 8 linii date). Ajustează mai jos dacă diferă.

| Pin EPROM | Se leagă la |
|-----------|-------------|
| A0..A16 | A0..A16 de pe magistrala de adrese |
| D0..D7 | D0..D7 de pe magistrala de date |
| CE# (chip enable) | ieșirea decodificatorului pentru zona EPROM |
| OE# (output enable) | RD# |
| VPP, VCC | +5V |

Chip-select EPROM: activ când A19,A18,A17 = 1,1,1 (zona E0000h–FFFFFh).

---

## 4. SRAM 62512 — 64 KB (00000h–0FFFFh)

> TODO: confirmă din datasheet (A0..A15 pentru 64K, 8 linii date).

| Pin SRAM | Se leagă la |
|----------|-------------|
| A0..A15 | A0..A15 de pe magistrala de adrese |
| D0..D7 | D0..D7 de pe magistrala de date |
| CE# | ieșirea decodificatorului pentru zona SRAM |
| OE# | RD# |
| WE# | WR# |
| VCC | +5V |

Chip-select SRAM: activ când A19..A16 = 0,0,0,0 (zona 00000h–0FFFFh).

---

## 5. Decodificator memorie — 74LS138

| Pin 74LS138 | Se leagă la |
|-------------|-------------|
| A (intrare) | A17 |
| B (intrare) | A18 |
| C (intrare) | A19 |
| G1 (enable) | M/IO# inversat (=1 pentru memorie) |
| G2A#, G2B# | masă |
| Y0 (ieșire) | CS# SRAM (adrese joase 00000h..) |
| Y7 (ieșire) | CS# EPROM (adrese inalte ..FFFFFh) |

Alege Y0 pentru SRAM (A19-17=000) și Y7 pentru EPROM (A19-17=111).

---

## 6. Interfața serială 8251 (0BF0h–0BF2h, microcomutator S1)

| Pin 8251 | Se leagă la |
|----------|-------------|
| D0..D7 | D0..D7 (magistrala de date) |
| C/D# | A0 (0=date, 1=control/status) |
| RD# | RD# de la 8086 |
| WR# | WR# de la 8086 |
| CS# | ieșirea comparatorului de adresă I/O (vezi mai jos) |
| CLK | tact de la 8284 |
| TxD | linia RS232 TxD (iesire) |
| RxD | linia RS232 RxD (intrare) |
| DTR#, DSR#, RTS#, CTS# | semnalele de handshake RS232 |
| TxC#, RxC# | tact de transmisie/recepție (de la un divizor/cuart) |

**Microcomutatorul S1**: injectează bitul care diferă între `0Axx` și `0Bxx`
într-o intrare a comparatorului de adresă. Poziția aleasă → `0BF0h`.
Decodificare CS#: adresa de pe A15..A1 = 0BF0h >> 1.

---

## 7. Interfața paralelă 8255 (0C70h–0C76h, microcomutator S2)

| Pin 8255 | Se leagă la |
|----------|-------------|
| D0..D7 | D0..D7 (magistrala de date) |
| A0 | A1 de pe magistrala (selectie registru, pas de 2) |
| A1 | A2 de pe magistrala |
| RD# | RD# de la 8086 |
| WR# | WR# de la 8086 |
| CS# | ieșirea comparatorului de adresă I/O |
| RESET | RESET de la 8284 |
| PA0..PA7 | segmentele afișajului (a,b,c,d,e,f,g,dp) |
| PB0..PB3 | coloanele tastaturii (K0..K3) |
| PB4..PB7 | neutilizate |
| PC0..PC2 | intrările A,B,C ale decodificatorului 74LS138 (ranguri/linii) |
| PC3..PC7 | LED0..LED4 (prin rezistoare) |

**Microcomutatorul S2**: injectează bitul care diferă între `0Cxx` și `0Dxx`.
Poziția aleasă → `0C70h`.

---

## 8. Afișaj 7 segmente, 6 ranguri + decodificator 74LS138

| Semnal | Se leagă la |
|--------|-------------|
| PA0..PA7 (de la 8255) | segmentele a..g, dp ale TUTUROR rangurilor (comune) |
| PC0..PC2 (de la 8255) | intrările A,B,C ale 74LS138 |
| Y0..Y5 (74LS138) | comanda celor 6 ranguri (tranzistor pe anod/catod comun) |

Multiplexare: scrii segmentele pe Port A, selectezi rangul prin codul de pe
PC0..PC2 → 74LS138 activează un singur rang. Baleiezi rapid toate rangurile.

---

## 9. Minitastatura 12 taste (matrice 3x4)

| Semnal | Se leagă la |
|--------|-------------|
| 3 linii (rânduri) | ieșiri Y de la 74LS138 (aceleași care fac și rangurile, sau separate) |
| 4 coloane | PB0..PB3 (intrări pe 8255), cu rezistoare pull-down/up |

Scanare: activezi o linie prin codul pe PC0..PC2, citești coloanele pe Port B.

---

## 10. Cele 6 LED-uri

| LED | Se leagă la |
|-----|-------------|
| LED0..LED4 | PC3..PC7 (prin rezistor ~330Ω spre masă) |
| LED5 | o ieșire liberă (ex: o linie Y nefolosită de la 74LS138, sau un pin liber) |

---

## Ordinea de desenat în Proteus (recomandare)

1. Pune 8086 + 8284 (tact/reset)
2. Adaugă cele 3 latch-uri 74LS373 și leagă AD + ALE
3. Trage magistralele A (adrese) și D (date) ca „bus"
4. Adaugă EPROM + SRAM, leagă-le la A, D, RD#, WR#
5. Adaugă 74LS138 de decodificare → CS# la memorii
6. Adaugă 8251 + conector RS232 + S1
7. Adaugă 8255 + S2
8. Adaugă perifericele: afișaj + 74LS138, tastatură, LED-uri
9. Alimentare (+5V, GND) peste tot
10. Încarci codul asamblat în 8086 și simulezi
