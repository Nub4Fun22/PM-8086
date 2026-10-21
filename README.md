# Microsistem cu microprocesorul 8086

Proiect la disciplina **Proiectarea cu Microprocesoare** (CTI), anul universitar 2025–2026.

## Tema

Proiectarea unui microsistem bazat pe microprocesorul 8086, cu:

- unitate centrala cu 8086;
- 128 KB memorie EPROM (circuite 27C2048);
- 64 KB memorie SRAM (circuite 62512);
- interfata seriala cu 8251, la `0BF0H–0BF2H` (microcomutator S1);
- interfata paralela cu 8255, la `0C70H–0C76H` (microcomutator S2);
- minitastatura cu 12 contacte;
- 6 led-uri;
- modul de afisare 7 segmente, 6 ranguri.

## Structura repository-ului

```
PM/
├── doc/
│   ├── hardware.md   # descrierea hardware (memorie, decodificare, periferice)
│   └── ghid.md       # ghid pas cu pas de implementare
├── schematic/        # schema hardware (CAD)
├── src/
│   ├── proiect.asm   # programul principal + cele 8 subrutine
│   └── sistem.inc    # definitii (adrese porturi, masti, cuvinte de control)
└── README.md
```

## De unde incepi

Citeste `doc/ghid.md` — are ordinea de implementare, ce registre poti folosi
si de unde inveti fiecare parte. Descrierea conexiunilor hardware (cum se
leaga 8086 de memorii si interfete) e in `doc/hardware.md`.

## Subrutine (assembly 8086)

1. Programare 8251
2. Programare 8255
3. Emisie caracter pe seriala (8251)
4. Receptie caracter pe seriala (8251)
5. Emisie caracter pe paralela (8255)
6. Scanare minitastatura (12 taste)
7. Aprindere / stingere LED
8. Afisare caracter hexa pe un rang cu 7 segmente

## Mediu de lucru

- Visual Studio Code + extensia MASM/TASM
- (optional) emu8086 / DOSBox pentru simulare
- CAD pentru scheme: Proteus / EasyEDA

## Autor

Sebastian-Florin Bor
