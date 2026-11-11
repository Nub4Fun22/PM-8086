# Jurnal de proiect

Rezumatul deciziilor și al contextului de lucru, ca să pot relua proiectul
de pe orice calculator (sau după o pauză) fără să pierd firul. Actualizez pe
măsură ce avansez.

---

## Despre ce e proiectul

Proiect la disciplina **Proiectarea cu Microprocesoare** (CTI, 2025–2026).
Temă: proiectarea unui microsistem cu microprocesorul **8086**, cu memorii,
interfețe serială/paralelă și periferice. Se predă ca document editabil pe
Campus Virtual, cu scheme în CAD ca anexe.

Repo GitHub (public): https://github.com/Nub4Fun22/PM-8086

---

## Decizii luate (și de ce)

### Adresele interfețelor (microcomutatoare)
- **Serială (8251): `0BF0h – 0BF2h`** — am ales poziția S1 pe varianta `0Bxx`
  (cealaltă variantă din enunț era `0AF0h`).
- **Paralelă (8255): `0C70h – 0C76h`** — am ales poziția S2 pe varianta `0Cxx`
  (cealaltă variantă din enunț era `0D70h`).
- Nu contează tehnic care variantă, important e să fiu consecvent peste tot
  (cod + schemă + document). În document justific prin poziția microcomutatorului.

### Mod de acces la periferice
- Perifericele (8251, 8255) stau în spațiul **I/O** al lui 8086 și se accesează
  cu instrucțiunile **`IN` / `OUT`** (prin registrul DX), NU cu `INT 21h`.
- `INT 21h` din laboratoare e doar pentru DOS/emulare. Proiectul e un sistem
  real, deci folosim porturi I/O directe.

### Laborator vs. temă (observație importantă)
- Laboratoarele predau assembly x86 în mediu **DOS emulat** și folosesc placa
  Modulo Z3 cu circuitul **8250**. Tema cere **8251** + **8255** proiectate de
  la zero. Laboratoarele rămân referință pentru **structură** (proc/endp,
  registre, salturi, comentarii), nu pentru accesul la periferice.

### Mediu de lucru
- Assembly: **VS Code + extensia MASM/TASM** (ca în Lab 1).
- Sintaxă: x86 pe **16 biți (8086 real mode)** — `.model small`, `dosseg`, etc.
- Simulare cu periferice: eventual **Proteus** (și pentru schemă).
- CAD scheme: Proteus sau EasyEDA (de decis la etapa de schemă).

### Sandbox Kiro
- A trebuit dezactivat (`~/.kiro/settings/sandbox.json` -> `"enabled": false`)
  ca git să poată citi `~/.gitconfig`. Cu sandbox activ, comenzile git eșuează.

---

## Structura repo

```
PM/
├── doc/
│   ├── hardware.md   # cum se leaga 8086 de memorii si interfete
│   ├── ghid.md       # pas cu pas, ce registre atingi
│   ├── PLAN.md       # planul general pe etape
│   ├── TODO.md       # checklist complet (cod + schema + document)
│   └── JURNAL.md     # acest fisier
├── schematic/        # schema CAD (inca gol)
├── src/
│   ├── proiect.asm   # main + cele 8 subrutine, cu TODO-uri marcate
│   └── sistem.inc    # adrese porturi, masti, cuvinte de control
└── README.md
```

NU sunt pe GitHub (în .gitignore): folderul `curs/` cu laboratoarele și PDF-ul
enunțului. Dacă lucrez de pe alt calculator, le copiez separat (stick/cloud).

---

## Starea codului (src/proiect.asm)

Cele 8 subrutine cerute de enunț:
1. `init_8251`      — scrisă (de verificat valorile) — TODO 1
2. `init_8255`      — scrisă (de verificat valorile) — TODO 1
3. `ser_emisie`     — scrisă
4. `ser_receptie`   — scrisă
5. `par_emisie`     — scrisă — TODO 1 (se suprapune cu Port A al afișajului)
6. `scan_tastatura` — **DE SCRIS DE LA ZERO** — TODO 6
7. `led`            — scrisă — TODO 0 (Port C se suprapune cu afișajul)
8. `afis_hexa`      — parțial, lipsește selecția rangului — TODO 8

TODO-uri marcate în cod (caută "TODO" cu Ctrl+F):
- **TODO 0** — decizie alocare biți pe Port C (LED vs rang afișaj vs tastatură).
  Blochează 6 și 8 până e luată. ACESTA E URMĂTORUL PAS.
- **TODO 1** — verific valorile de config din sistem.inc după ce am schema.
- **TODO 2** — verific tabela seg7 (segmente active pe 1 sau pe 0).
- **TODO 6** — scriu scanarea tastaturii.
- **TODO 8** — completez selecția rangului în afis_hexa.
- **TODO T** — scenariu de test în main.

---

## Ce rămâne de făcut (pe scurt)

Detaliat în `doc/TODO.md`. Pe secțiuni:
- **A. Cod**: TODO 0, 6, 8 (de scris) + verificările 1, 2 (după schemă).
- **B. Hardware**: verificat datasheet-uri (27C2048, 62512) + schema CAD.
- **C. Document de predare**: structura fixă de pagini (titlu, temă, hardware,
  programe, bibliografie, scheme ca anexe).
- **D. Termene**: săptămâna 8 (stadiu intermediar), săptămâna 12 (final).

---

## Cum reiau de pe alt calculator

1. `git clone https://github.com/Nub4Fun22/PM-8086.git`
2. Copiez separat folderul `curs/` și PDF-ul enunțului (nu sunt pe GitHub).
3. Instalez VS Code + extensia MASM/TASM.
4. Deschid acest `doc/JURNAL.md` + `doc/TODO.md` ca să văd unde am rămas.
5. Workflow: `git pull` înainte să încep, `git push` după ce termin.

---

## Alocarea pinilor 8255 (decizie finală)

- **Port A** (PA0..PA7) iesire -> segmentele afisajului 7-seg (a..g, dp)
- **Port B** (PB0..PB3) intrare -> cele 4 coloane ale tastaturii
- **Port C** iesire, impartit:
  - PC0..PC2 -> cod binar (0..5) intr-un decodificator 74LS138 care face
    si selectia celor 6 ranguri afisaj, si cele 3 linii de scanare tastatura
  - PC3..PC7 -> 5 LED-uri (LED0..LED4); LED5 pe o iesire ramasa de la 74LS138
- Oglinda `portc_stare` (RAM) tine ultima valoare scrisa pe Port C, ca sa
  modificam LED-urile fara sa stricam bitii de selectie si invers.

## Schema in EasyEDA (prin MCP easyeda-copilot)

Conectare: MCP `easyeda-copilot-mcp` (npx) + extensia .eext in EasyEDA Pro Desktop
(External Interactions / "Allow interactive with external" ON). Proiect: Proiect_PM.

### Componente alese (part_uuid real din LCSC)

| Rol | Cip folosit | Part / MPN | Nota |
|-----|-------------|-----------|------|
| CPU | 8086 | P8086 (AMD, DIP-40) | exact din tema |
| Tact/reset | 8284A | MD8284A/B (DIP-18) | exact din tema |
| Latch adrese x3 | 74LS373 | SN74LS373N (DIP-20) | |
| Transceiver date x2 | 74LS245 | SN74LS245N (DIP-20) | |
| Decodor x2 | 74LS138 | SN74LS138N (DIP-16) | memorii + porturi I/O |
| EPROM | 27C2048 | AT27C2048-12PC (DIP-40) | exact din tema; 128K x16 |
| SRAM | 62256 x2 | CY62256NL-70PC (DIP-28) | ALTERNATIVA (vezi mai jos) |
| Serial | 8251 | LD8251A (DIP-28) | exact din tema |
| Paralel | 8255 | P8255A-5 (DIP-40) | exact din tema |

### Alternativa documentata (de scris in documentatia finala)
- Tema cere SRAM **62512** (64K x8). Acesta NU exista in biblioteca EasyEDA/LCSC
  sub niciun nume uzual (62512, 628512, HM628512, LH628512 - inexistente).
  S-a folosit echivalentul **62256** (SRAM 32K x8), cate **2 circuite** pentru
  a acoperi 64KB, organizate pe bancuri par/impar (ca la referinta Daria).
- 27C2048 EXISTA si e folosit exact din tema (EPROM, 128K x16 pe DIP-40).

### Arhitectura aleasa (coerenta cu codul assembly)
- Afisaj: MULTIPLEXAT (selectie rang prin 74LS138) - asa e codul afis_hexa.
- Periferice prin PORTURI I/O (IN/OUT), nu INT 21h.
- Adrese: serial 0BF0h (S1), paralel 0C70h (S2) - ca in sistem.inc/proiect.asm.
- 4 planse: 1) unitate centrala, 2) memorii, 3) interfete, 4) periferice.

## Istoric decizii (jurnal pe zile)

- **(start)** Setup repo GitHub, structură foldere, mediu VS Code. Fixat
  adresele S1=0BF0h, S2=0C70h. Citit laboratoarele 1–6 pentru convenții.
- **(boilerplate)** Creat sistem.inc + proiect.asm cu cele 8 subrutine,
  doc/hardware.md, doc/ghid.md, doc/PLAN.md, doc/TODO.md.
- **(cod complet)** Luat decizia de alocare a pinilor (Opțiunea A - decide
  asistentul). Scris COMPLET toate cele 8 subrutine, inclusiv scan_tastatura
  (matrice 3x4) și afis_hexa (segmente + selecție rang). Adăugat oglinda
  portc_stare. Rămân doar verificări ce depind de schema reală (TODO 1, 2) și
  rularea asamblării în VS Code.
- **(asamblare OK)** proiect.asm transformat in fisier UNIC (definitiile fostul
  sistem.inc incluse direct, fara "include", ca sa ruleze in extensia VS Code).
  Rulat cu TASM in DOSBox: "Error messages: None, Warning messages: None" -
  cod asamblat si link-editat corect. Singurul warning benign: "DOSSEG directive
  ignored" (inofensiv). PARTEA DE COD E VERIFICATA.
- **(schema EasyEDA via MCP)** Conectat MCP easyeda-copilot la EasyEDA Pro.
  Confirmat ca toate componentele exista in LCSC (part_uuid reale). SRAM 62512
  nu exista -> folosim 62256 x2 (documentat). PLANSA 1 (Unitate centrala)
  CONSTRUITA COMPLET: 8086 + 8284A + 3x74LS373 + 2x74LS245, cablata fir-cu-fir,
  beautified, 57% spatiu liber. Arata ca modelul Dariei. Checkpoint salvat.
- **(plansa 2 gata)** Plansa 2 (Memorii) construita: EPROM AT27C2048 (U8),
  2x SRAM 62256 (U9 par, U10 impar), decodor 74LS138 (U11), 74LS32 (U13) pt
  logica ~WE par/impar. Chip-select: SRAM=~Y0 (00000-0FFFFh), EPROM=~Y7
  (E0000-FFFFFh). Adaugat si TABELUL de decodificare (grila bit-cu-bit A19..A0,
  stil Daria) in stanga-jos. Title block completat pe pagina.
  NOTA tehnica: in EasyEDA coordonata Y creste IN SUS (important pt plasari text).
- **(plansa 3 gata)** Interfete: 8251 (U14) + 8255 (U15) + 74LS138 decodor porturi
  (U16) + MAX232 (U17) + comutatoare S1/S2 (slide SPDT). Comutatoarele conectate ca
  Daria: decodor genereaza Y0/Y1 (serial) si Y2/Y6 (paralel), iar comutatorul SPDT
  alege care iesire ajunge la CS (poz1/poz2). + tabel decodificare porturi I/O.
- **(plansa 4 gata)** Periferice pe 3 blocuri: Afisaj 7seg 6 ranguri (DS1-DS6 +
  decodor rang U18, multiplexat - segmente comune pe Port A, selectie rang pe PC0-PC2),
  6 LED-uri (LED0-5 + rezistoare 330R, pe PC3-PC7+PB7), minitastatura 12 taste
  (matrice 3x4: linii PC0-PC2, coloane PB0-PB3 + pull-up 10k). Pagina A1.
  TOATE CELE 4 PLANSE SUNT COMPLETE.
- **(următorul pas)** Export PDF toate planele; documentul de predare final
  (structura: titlu, tema, descriere hardware 3-5 pag, programe 3-7 pag, bibliografie).
