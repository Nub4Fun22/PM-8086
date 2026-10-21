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

## Istoric decizii (jurnal pe zile)

- **(start)** Setup repo GitHub, structură foldere, mediu VS Code. Fixat
  adresele S1=0BF0h, S2=0C70h. Citit laboratoarele 1–6 pentru convenții.
- **(boilerplate)** Creat sistem.inc + proiect.asm cu cele 8 subrutine,
  doc/hardware.md (conexiuni + hartă memorie + decodificare), doc/ghid.md,
  doc/PLAN.md, doc/TODO.md. Marcat toate TODO-urile în cod.
- **(următorul pas)** TODO 0: decid alocarea biților pe Port C.
