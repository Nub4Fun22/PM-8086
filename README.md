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
├── doc/        # documentul de predare, notite, harta de memorie
├── schematic/  # schema hardware (CAD)
├── src/        # cod assembly 8086 (subrutinele)
└── README.md
```

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
