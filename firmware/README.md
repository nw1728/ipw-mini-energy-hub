# Mini Energy Hub - firmware

Reference firmware for the Mini Energy Hub demonstrator, the IPW project
assignment. It runs the Energy Management System (EMS) on an ESP32: it
reads simulated solar (a light sensor) and wind (a knob) generation,
switches house loads, decides how fast the "EV" charges (an RGB LED, and
optionally a fan on a MOSFET), and shows whether the grid connection is
congested.

Board: **Joy-IT SBC-NodeMCU-ESP32-C** (classic ESP32, USB-C; Conrad
article 3344407). Any classic ESP32 DevKit works. The ESP32-C3 and -C6
do **not**: different pins, different ADC, different PlatformIO board.

This is a **reference implementation**. It works, but it is deliberately
plain. Improving it is part of the assignment.

## Build and flash

Requires [PlatformIO](https://platformio.org/install) (the VS Code
extension, or `pio` on the command line).

```bash
pio run              # compile
pio run -t upload    # flash the ESP32
pio device monitor   # serial output, 115200 baud
```

The first build downloads about 500 MB of toolchain. Do that **before**
the project week, not during it, and not on the school wifi with six
laptops at once.

Use a USB **data** cable. Many USB-C cables are charge-only, and an ESP32
on a charge-only cable looks exactly like a dead ESP32.

In the classroom the box runs from a 5V 2A USB-C charger plugged into the
ESP32. No separate supply is needed unless you fit the optional fan.

### Why the versions are pinned

`platformio.ini` pins `espressif32@8.0.0`. That release (2026-10-19) is
the first official PlatformIO platform carrying Arduino-ESP32 core 3.x,
and the firmware calls `ledcAttach()`, which is a core 3.x API. On
platform 7.1.3 or older you get core 2.0.17 and a compile error. Library
versions are pinned for the same reason: same binary on every laptop.

## Hardware

Pin map, wiring notes and the bill of materials are in the project
assignment (`assignment.pdf`, appendices A and B). Two things that are
easy to get wrong and expensive to get wrong:

- **The LDR divider and the wind potentiometer run from 3.3V, never 5V.**
  The ESP32 ADC inputs are 3.3V maximum. 5V on GPIO34/35 damages the chip.
- **Green and blue need smaller resistors than red.** On 3.3V a green or
  blue LED on 220 Ω is barely lit. Start at 150 Ω for red and 68 Ω for
  green and blue, then adjust by eye.
- **If you fit the optional fan, it needs a flyback diode** (1N5819 or
  1N4007) across its terminals, cathode to +5V. Without it, switching the
  motor off produces a voltage spike that kills the MOSFET and can take the
  ESP32 with it.

## The EMS logic

`computeEms()` in `src/main.cpp` is a pure function: generation, base load
and the smart/dumb switch in, EV power and net grid flow out. Net grid
flow is signed: **positive = import** from the grid, **negative = export**
to the grid. Congestion is `abs(grid) > GRID_LIMIT` in either direction.

In **DUMB** mode the EV charges at `EV_NORMAL` regardless of the grid. In
**SMART** mode it charges fast on a renewable surplus and throttles back
when the grid connection would otherwise overload. Flipping that switch in
front of a class is the whole point of the demonstrator.

### Checking the numbers

`tools/check_ems_logic.sh` pulls `computeEms()` straight out of
`src/main.cpp`, compiles it on your own machine and prints the scenario
table from the assignment:

```bash
./tools/check_ems_logic.sh
```

Run it after changing any constant (`GRID_LIMIT`, `EV_NORMAL`, `EV_MAX`,
`HOUSE1_W`, `HOUSE2_W`). If the output stops matching section 5 of the
assignment, either the code or the lesson plan is wrong - find out which
before the demonstration.

It needs only `g++`; no ESP32 and no PlatformIO.

## The two lights

| Light | Colour | Meaning |
|---|---|---|
| Grid | green | OK, within the limit |
| Grid | red | import congestion |
| Grid | blue | export congestion |
| EV | off | not charging |
| EV | yellow | throttled by the EMS |
| EV | white | normal charging |
| EV | green | fast charging on local surplus |

The OLED shows the numbers, plus bars for generation (0–200) and EV
power (0–50).

## Two things to set before you build

Both sit in the *hardware settings* block at the top of `src/main.cpp`.

1. **`RGB_COMMON_ANODE`**: `false` for common-cathode RGB LEDs (long leg
   to GND), `true` for common-anode (long leg to 3.3V). Wrong value = all
   colours inverted: OK shows magenta instead of green.
2. **`LDR_DARK` and `LDR_BRIGHT`**: open `pio device monitor`, which
   prints `LDR raw ...` once a second. Cup a hand over the LDR and write
   down the number; hold the desk lamp right above it and write that down.
   Do this in the room you will teach in, because classroom light changes
   everything.
