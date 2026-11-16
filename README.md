# IPW Mini Energy Hub

Reference firmware and project brief for the International Project Week
assignment *Build a Portable Mini Energy Hub*: a transportable tabletop
demonstrator of grid congestion and flexibility, built around an ESP32.

- **[assignment3.pdf](assignment3.pdf)** is the project brief, including the
  suggested bill of materials, pin map and the pointers into this repository.
- **[firmware/](firmware/)** is a working reference implementation. It is a
  reference, not an answer key: read it, test it, and take responsibility for
  what you flash.

## Build and flash

Requires [PlatformIO](https://platformio.org/). The build is pinned to
`espressif32@8.0.0`; see `firmware/platformio.ini` for why.

```bash
cd firmware
pio run -t upload      # build and flash (needs a USB DATA cable)
pio device monitor     # serial output at 115200 baud
```

Download the toolchain before the project week: the first build fetches
roughly 500 MB.

## Checking the control logic

`firmware/tools/check_ems_logic.sh` extracts the decision function from
`firmware/src/main.cpp`, compiles it with `g++` and prints a table of test
scenarios. It runs on a laptop and needs no ESP32.

```bash
cd firmware && ./tools/check_ems_logic.sh
```

Run it after changing any constant. If the script and your documentation
disagree, one of them is wrong.

## Hardware notes

Before first power-up, check with a multimeter that no ESP32 analogue input
sees more than 3.3V. Join every ground to the ESP32 GND. Fit a flyback diode
across any motor. Use protected 18650 cells and a charger module with
protection, and never leave a cell charging unattended.

## Rebuilding the brief

```bash
typst compile assignment3.typ
```

Needs `style.typ` and `saxion-logo.jpg` beside it, plus the Zed Sans Extended
and JetBrainsMono NF fonts.
