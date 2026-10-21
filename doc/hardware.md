# Descrierea hardware a microsistemului cu 8086

Acest document descrie structura fizică a microsistemului și modul în care
microprocesorul 8086 se conectează la memorii și la interfețele periferice.
Acoperă cerința din enunț: „Descrierea hardware-ului (3–5 pagini)".

---

## 1. Schema bloc

```
                    +---------------------+
                    |      8086 (CPU)     |
                    |                     |
     AD0..AD15 <--->| multiplexat adr/date|
     A16..A19  ---->|                     |
        ALE   ----->|  (latch adrese)     |
   RD, WR, M/IO ---->|                     |
                    +----------+----------+
                               |
            +------------------+------------------+
            | magistrala adrese/date demultiplexata|
            +--+-------+---------+---------+-------+
               |       |         |         |
          +----v--+ +--v---+ +---v----+ +--v-----+
          | EPROM | | SRAM | |  8251  | |  8255  |
          |128 KB | |64 KB | |(serial)| |(paralel)|
          |27C2048| |62512 | | 0BF0h  | | 0C70h  |
          +-------+ +------+ +--------+ +--------+
                                 |          |
                              RS232     tastatura,
                                        LED-uri,
                                        afisaj 7seg
```

Notă: 8086 are magistrala **AD0–AD15 multiplexată** (adrese și date pe
aceleași linii). Semnalul **ALE** comandă un latch (de ex. 74LS373) care
„prinde" partea de adresă la începutul ciclului. Pe partea de sus,
**A16–A19** dau adresa completă pe 20 de biți (1 MB spațiu de memorie).

---

## 2. Separarea memorie / intrare-ieșire

8086 are **două spații de adresare distincte**:

- **Memorie**: 1 MB (adrese pe 20 de biți) — aici stau EPROM și SRAM.
- **I/O (porturi)**: 64 KB (adrese pe 16 biți) — aici stau 8251 și 8255.

Semnalul **M/IO#** al lui 8086 spune magistralei despre ce e vorba:
- `M/IO# = 1` → acces la memorie (EPROM / SRAM)
- `M/IO# = 0` → acces la porturi I/O (8251 / 8255)

De aceea, în cod:
- memoriile se accesează implicit prin `MOV` (instrucțiunile normale),
- perifericele se accesează cu `IN` / `OUT` (care generează automat M/IO#=0).

---

## 3. Harta de memorie (spațiul de 1 MB)

| Zonă        | Circuit  | Dimensiune | Interval adrese     |
|-------------|----------|------------|---------------------|
| SRAM (date) | 62512 x? | 64 KB      | `00000h – 0FFFFh`   |
| ...liber... |          |            | `10000h – EFFFFh`   |
| EPROM (cod) | 27C2048  | 128 KB     | `E0000h – FFFFFh`   |

Motivație:
- **EPROM sus**, lângă `FFFFFh`, pentru că după RESET procesorul 8086
  pornește execuția de la adresa `FFFF0h` (vectorul de reset). Acolo trebuie
  să fie o instrucțiune de salt către programul principal din EPROM.
- **SRAM jos**, de la `00000h`, pentru că acolo stau tabela de vectori de
  întrerupere și stiva.

### Calculul numărului de circuite

- **EPROM 27C2048**: este un circuit de 128 Kbit? Nu — `27C2048` este
  2 Mbit = **256 KB x? ** atenție la foaia de catalog. Dacă circuitul este
  organizat 128K x 8 = 128 KB, atunci **1 singur circuit** acoperă cei 128 KB
  ceruți. VERIFICĂ organizarea exactă în datasheet și documentează alegerea.
- **SRAM 62512**: organizat tipic 64K x 8 = **64 KB**, deci **1 circuit**
  acoperă cei 64 KB ceruți. (Numele seamănă cu 62256 = 32K x 8; verifică.)

> TODO (de confirmat din datasheet-uri): organizarea exactă (câți biți de
> date, câți de adresă) a lui 27C2048 și 62512, ca să justifici numărul de
> circuite și liniile de adresă folosite.

---

## 4. Decodificarea adreselor (chip-select)

Fiecare circuit de memorie are un pin **CE#/CS#** (chip enable). Trebuie
generat un semnal care îl activează DOAR când adresa pe magistrală cade în
intervalul circuitului. Asta face **logica de decodificare** (un
decodificator 74LS138 sau porți logice simple).

### Pentru EPROM (`E0000h – FFFFFh`)

Biții de adresă mari A19..A17 = `111b` pentru tot intervalul E0000–FFFFF.
Deci `CS_EPROM# = NOT(A19 AND A18 AND A17)` (activ pe 0).

### Pentru SRAM (`00000h – 0FFFFh`)

Biții A19..A16 = `0000b`. Deci `CS_SRAM# = NOT(NOT A19 AND NOT A18 AND
NOT A17 AND NOT A16)`.

Un **74LS138** (decodificator 3-la-8) ia A19,A18,A17 pe intrări și scoate
8 semnale de selecție, câte unul pentru fiecare bloc de 128 KB. Alegi
ieșirea potrivită pentru fiecare circuit.

---

## 5. Decodificarea porturilor I/O (8251 și 8255)

Perifericele stau în spațiul I/O (adrese pe 16 biți). Fiecare are un
**CS#** generat prin compararea adresei de pe magistrală cu adresa fixată
de microcomutator.

### 8251 – interfața serială (S1 → `0BF0h – 0BF2h`)

- `0BF0h` → registrul de **date** (A0 = 0)
- `0BF1h` → registrul de **control/status** (A0 = 1)
- `CS_8251#` activ când A15..A1 corespund lui `0BF0h` (comparator de adresă).
- Pinul **C/D#** (control/data) al lui 8251 se leagă de **A0**.

### 8255 – interfața paralelă (S2 → `0C70h – 0C76h`)

- `0C70h` → Port A, `0C72h` → Port B, `0C74h` → Port C, `0C76h` → Control
- Pinii **A1, A0** ai lui 8255 selectează registrul; în harta noastră sunt
  legați de A2,A1 de pe magistrală (de aceea adresele merg din 2 în 2).
- `CS_8255#` activ când restul biților de adresă corespund lui `0C70h`.

### Rolul microcomutatoarelor S1 și S2

Enunțul cere ca adresa să poată fi comutată:
- **S1**: serial la `0AF0h` SAU `0BF0h` → S1 comandă un bit din comparatorul
  de adresă (bitul care diferă între 0A.. și 0B..). Noi am ales **0BF0h**.
- **S2**: paralel la `0D70h` SAU `0C70h` → S2 comandă bitul care diferă
  între 0D.. și 0C... Noi am ales **0C70h**.

Practic, microcomutatorul injectează un `0` sau `1` pe o intrare a
comparatorului de adresă, mutând astfel fereastra de adrese a perifericului.

---

## 6. Perifericele conectate la 8255

| Port 8255 | Direcție | Periferic                              |
|-----------|----------|----------------------------------------|
| Port A    | ieșire   | segmentele afișajului 7-seg (a..g, dp) |
| Port B    | intrare  | coloanele minitastaturii (citire)      |
| Port C    | ieșire   | selecție rang afișaj + cele 6 LED-uri  |

- **Afișaj 7 segmente, 6 ranguri**: multiplexat. Scoți codul de segmente pe
  Port A, apoi activezi pe rând câte un rang prin Port C. Reîmprospătezi
  rapid toate rangurile ca ochiul să le vadă aprinse simultan.
- **Minitastatură 12 contacte**: matrice 4x3. Activezi o linie prin Port C,
  citești coloanele prin Port B.
- **6 LED-uri**: pe biți din Port C. Ca să aprinzi/stingi un singur LED fără
  să le afectezi pe celelalte, ții starea într-o variabilă-oglindă în RAM
  (vezi `led_stare` în cod).

---

## 7. Perifericul conectat la 8251

- **Interfață serială RS232**: liniile TxD (transmisie), RxD (recepție) și
  semnalele de control (DTR, DSR, RTS, CTS). Un cuarț extern dă tactul de
  bază, divizat intern pentru rata baud aleasă.
- Configurația software (vezi `init_8251`): asincron, 8 biți de date, fără
  paritate, 1 bit de stop, factor x16.
