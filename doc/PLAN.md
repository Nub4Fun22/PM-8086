# Plan proiect: Microsistem cu microprocesorul 8086

## Decizii fixate

| Element | Alegere | Observatii |
|---|---|---|
| Microcomutator S1 (seriala 8251) | zona `0BF0H – 0BF2H` | adresele portului serial |
| Microcomutator S2 (paralela 8255) | zona `0C70H – 0C76H` | adresele portului paralel |
| Mediu assembly | VS Code + extensia MASM/TASM | ca in laborator |
| Simulare hardware | emu8086 (optional, port I/O) | laboratoarele folosesc DOS/INT 21h |
| CAD scheme | Proteus sau EasyEDA | de ales la etapa de schema |

## Observatie cheie: laborator vs. tema proiect

Laboratoarele predau assembly x86 in mediu **DOS emulat** (`INT 21h`) si folosesc
placa Modulo Z3 cu circuitul **8250**. Tema proiectului cere insa un microsistem
proiectat de la zero, cu interfete **8251** si **8255**, accesate prin **porturi I/O**
(`IN` / `OUT`), nu prin `INT 21h`.

Concluzie: subrutinele proiectului acceseaza direct porturile la adresele fixate mai
sus. Laboratoarele raman referinta pentru structura (proceduri `proc/endp`, registre,
salturi, comentarii), nu pentru modul de acces la periferice.

## Harta de memorie (de calculat la Etapa 1)

- Spatiu total 8086: 1 MB (adrese 00000H – FFFFFH)
- 128 KB EPROM cu 27C2048
- 64 KB SRAM cu 62512
- Decodificare chip-select pentru fiecare circuit
- Decodificare porturi I/O: 8251 la 0BF0H, 8255 la 0C70H

## Subrutine de implementat (assembly 8086)

Toate ca proceduri (`proc`/`endp`), cu intrari/iesiri definite clar.

1. `INIT_8251`  – programarea circuitului serial (mod + comanda)
2. `INIT_8255`  – programarea circuitului paralel (cuvant de control)
3. `TX_SERIAL`  – emisie caracter pe seriala (8251)
4. `RX_SERIAL`  – receptie caracter pe seriala (8251)
5. `TX_PARALEL` – emisie caracter pe paralela (8255)
6. `SCAN_TASTA` – scanare minitastatura (12 contacte)
7. `LED_ON_OFF` – aprindere / stingere LED
8. `AFIS_HEXA`  – afisare caracter hexa pe un rang cu 7 segmente

## Etape de lucru

- [ ] **Etapa 0 – Setup** (in curs): repo GitHub, structura, mediu VS Code
- [ ] **Etapa 1 – Harta de memorie + decodificare adrese** (fundatia)
- [ ] **Etapa 2 – Schema hardware** (CAD)
- [ ] **Etapa 3 – Subrutinele assembly** (cele 8, cu verificare)
- [ ] **Etapa 4 – Documentul de predare** (structura ceruta de regulament)

## Termene (din regulament)

- Saptamana 8: prezentare stadiu intermediar
- Saptamana 12: sustinere finala

## Structura documentului de predare (regulament)

1. Pagina titlu: universitate, facultate, disciplina (in extenso), nume proiect, autor, an
2. Pagina 2: tema proiectului
3. 3–5 pagini: descriere hardware
4. 3–7 pagini: programele, cu delimitari si comentarii
5. Ultima pagina: bibliografie
6. Scheme: anexe A4/A3, realizate in CAD
