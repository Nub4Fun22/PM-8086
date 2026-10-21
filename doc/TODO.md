# TODO — ce trebuie să fac EU

Checklist personal, verificat față de cerințele din enunțul proiectului.
Bifezi pe măsură ce termini. Legenda: [ ] de făcut, [x] gata, [~] parțial.

---

## A. COD ASSEMBLY (src/proiect.asm)

Enunțul cere 8 subrutine. Starea lor acum:

- [x] 1. `init_8251` — programare serială (scrisă, de verificat valorile)
- [x] 2. `init_8255` — programare paralelă (scrisă, de verificat valorile)
- [x] 3. `ser_emisie` — emisie serial (scrisă)
- [x] 4. `ser_receptie` — recepție serial (scrisă)
- [x] 5. `par_emisie` — emisie paralelă (scrisă)
- [ ] 6. `scan_tastatura` — **DE SCRIS DE LA ZERO** (acum doar returnează 0FFh)
- [x] 7. `led` — aprindere/stingere LED (scrisă)
- [~] 8. `afis_hexa` — **DE COMPLETAT**: lipsește selecția rangului prin Port C

### TODO cod — ce scriu efectiv:

- [ ] **TODO 6**: implementez bucla de scanare a tastaturii (matrice 4x3):
      activez pe rând fiecare linie pe Port C, citesc coloanele pe Port B,
      calculez codul tastei = linie*3 + coloana. Pseudocodul e deja în fișier.

- [ ] **TODO 8**: adaug selecția rangului (0..5) prin Port C în `afis_hexa`,
      fără să stric biții LED-urilor.

- [ ] **TODO decizie**: aloc clar biții pe Port C — care biți sunt LED-uri,
      care sunt selecție rang, care sunt linii tastatură. Acum `led` și
      `afis_hexa` folosesc amândouă Port C și se suprapun. Trebuie împărțit.

- [ ] **TODO verificare valori** (după ce am schema): confirm că sunt corecte
      - tabela `seg7` (segmente active pe 1 sau pe 0?)
      - cuvintele `SER_MOD`, `SER_CMD`, `PAR_CFG` din sistem.inc
      - măștile LED și pozițiile biților

- [ ] **TODO scenariu test** în `main`: pun câteva apeluri demonstrative
      (aprind un LED, afișez o cifră, trimit un caracter serial).

---

## B. HARDWARE / SCHEMĂ (schematic/)

Enunțul cere descriere hardware + scheme în CAD (A4/A3).

- [ ] **TODO datasheet**: verific organizarea exactă a circuitelor și câte
      bucăți îmi trebuie:
      - 27C2048 (EPROM) — câți biți date/adresă? câte circuite pt. 128 KB?
      - 62512 (SRAM) — câte circuite pt. 64 KB?
      (am lăsat semn de întrebare în doc/hardware.md)

- [ ] **TODO schemă CAD**: desenez schema completă (Proteus / EasyEDA):
      - [ ] 8086 + latch adrese (74LS373) + demultiplexare
      - [ ] EPROM cu chip-select corect
      - [ ] SRAM cu chip-select corect
      - [ ] logica de decodificare (74LS138 sau porți)
      - [ ] 8251 + conector RS232 + microcomutator S1
      - [ ] 8255 + tastatură + LED-uri + afișaj 7seg + microcomutator S2
      - [ ] export schemă în format A4 sau A3

---

## C. DOCUMENT DE PREDARE (doc/)

Enunțul cere o structură fixă de pagini. De pregătit:

- [ ] **Pagina 1** (titlu): numele universității, facultății, disciplinei
      (în extenso), numele proiectului, numele meu, anul universitar
- [ ] **Pagina 2**: tema proiectului (copiez din enunț)
- [ ] **Pagini 3–5**: descrierea hardware (am baza în doc/hardware.md,
      o extind și adaug schema bloc)
- [ ] **Pagini 3–7**: programele cu delimitări și comentarii (copiez din
      src/proiect.asm după ce îl termin)
- [ ] **Ultima pagină**: bibliografia (cărți, datasheet-uri, link-uri)
- [ ] **Anexe**: schemele în A4/A3
- [ ] Salvez ca document editabil (Word/PDF) și îl încarc pe Campus Virtual

---

## D. TERMENE (din enunț)

- [ ] **Săptămâna 8**: prezint stadiul intermediar
- [ ] **Săptămâna 12**: susținere finală

---

## Ordinea recomandată (ce fac primul)

1. [ ] TODO 8 (afis_hexa — selecție rang) — scurt, bun de început
2. [ ] TODO decizie biți Port C — fără asta, 6 și 8 se bat cap în cap
3. [ ] TODO 6 (scan_tastatura) — cel mai greu
4. [ ] TODO datasheet + schemă CAD
5. [ ] Document de predare (asamblez la final)
