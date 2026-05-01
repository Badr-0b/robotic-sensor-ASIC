# robotic-sensor-ASIC

<img width="1328" height="794" alt="image" src="https://github.com/user-attachments/assets/c75d602c-f521-400b-b263-bf2b92f7fc72" />


Digital Robotic Sensor Processing Unit designed in Verilog HDL,
deployed on FPGA, and extended to physical ASIC layout.

**PDK:** OSU018 (180nm standard cell library)  
**EDA Flow:** Yosys → Magic VLSI → [REDACTED]
**FPGA Target:** Altera Cyclone V DE1-SoC (Quartus 13.1)

---

## Overview

A fully combinational digital circuit that accepts two 3-bit robotic
proximity sensor inputs (front sensor G, side sensor Y) and a 3-bit
operation select (S). Results are decoded and displayed in real-time
on a 7-segment display. An overflow LED flags out-of-range arithmetic
results. No clock. No sequential logic.

The design was first realized on FPGA, then taken through a full
open-source ASIC implementation flow using the OSU018 180nm PDK.

---

## System Architecture

<INSERT THE FLOWCHART HERE>

Two modules:
- `robotic_sensor` — 8-way MUX, each branch K-map derived. 5-bit
  temp register catches arithmetic overflow before 4-bit truncation.
  Default assignments on all outputs prevent inferred latches.
- `seg7_decoder` — Priority chain: blank > overflow > E/U flags >
  numeric digit. Active-LOW encoding for Cyclone V HEX display.

---

## Operation Table

| S[2:0] | Operation        | Expression      | Overflow Condition     |
|--------|-----------------|-----------------|------------------------|
| 000    | Motor speed map  | 2G              | G2 = 1 (G ≥ 4)        |
| 001    | Turning angle    | 3Y              | Y2 + (Y1·Y0)           |
| 010    | Sensor compare   | G == Y → E/U    | Never                  |
| 011    | Forward adjust   | G + 3           | G2·(G1 + G0)           |
| 100    | Clearance check  | 7 − Y           | Never                  |
| 101    | Path average     | (G + Y) / 2     | Never                  |
| 110    | Difference       | G − Y (clamped) | Never                  |
| 111    | System off       | blank display   | Never                  |

Overflow state: result = 0000, OVF LED = 1, display shows '=' (seg[6:0] = 0110111 active-LOW).

---

## K-Map Derived Equations (selected)

**Motor Speed Mapping (2G):**
LED0 = 0
LED1 = G0
LED2 = G1
LED3 = 0
OVF  = G2

**Clearance Check (7−Y):**
LED0 = Y0'
LED1 = Y1'
LED2 = Y2'
LED3 = 0
OVF  = 0

**Forward Adjustment (G+3):**
LED0 = G0'
LED1 = G1 XNOR G0
LED2 = G0 + G1 + G2
LED3 = 0
OVF  = G2 · (G1 + G0)

---

## 7-Segment Encoding (Active-LOW)

| Symbol | seg[6:0] | Segments ON  |
|--------|----------|--------------|
| 0      | 1000000  | a,b,c,d,e,f  |
| 1      | 1111001  | b,c          |
| 2      | 0100100  | a,b,d,e,g    |
| 3      | 0110000  | a,b,c,d,g    |
| 4      | 0011001  | b,c,f,g      |
| 5      | 0010010  | a,c,d,f,g    |
| 6      | 0000010  | a,c,d,e,f,g  |
| 7      | 1111000  | a,b,c        |
| 8      | 0000000  | all          |
| 9      | 0010000  | a,b,c,d,f,g  |
| E      | 0000110  | a,d,e,f,g    |
| U      | 1000001  | b,c,d,e,f    |
| =      | 0110111  | d,g          |

---

## ASIC Implementation

The `robotic_sensor` module was synthesized and laid out using a
fully open-source EDA toolchain:

**Flow:** RTL → Synthesis (Yosys) → Place & Route / Layout (Magic VLSI)  
**PDK:** OSU018 (180nm standard cell library)  
**Pin mapping:**
- Inputs: G[0], G[1], G[2], Y[1], Y[2] routed to chip boundary
- Outputs: seg[0]–seg[6], flow_led mapped to output pins

This extended the project beyond FPGA prototyping into a physical
chip layout, bridging digital logic design with IC implementation.

---

## Tools

| Tool      | Purpose                        |
|-----------|-------------------------------|
| Quartus 13.1 | FPGA synthesis & programming |
| Verilog HDL  | RTL design                   |
| Yosys        | Logic synthesis (ASIC flow)  |
| Magic VLSI   | Layout & place-and-route     |
| OSU018 PDK   | 180nm standard cell library  |
