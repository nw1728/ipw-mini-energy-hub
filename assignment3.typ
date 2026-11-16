#import "style.typ": *

#show: doc => setup("Project brief", doc)

#let authors = "Tila Muhammad and Ethan Bastian"
#let group = "Research group SES"

#set page(
  header: grid(
    columns: (auto, 1fr),
    align: (left + horizon, right + horizon),
    image("saxion-logo.jpg", height: 7.5mm),
    text(size: 8.5pt, fill: luma(110))[Mini Energy Hub #sym.dot.c Project brief],
  ),
  footer: context {
    set text(size: 8pt, fill: luma(125))
    grid(
      columns: (1fr, auto),
      align: (left + horizon, right + horizon),
      [#authors #sym.dot.c #group #sym.dot.c Saxion Hogeschool],
      counter(page).display(),
    )
  },
)

#v(0.5em)

#align(center)[
  #text(size: 9pt, weight: "bold", fill: luma(120), tracking: 1.5pt)[
    INTERNATIONAL PROJECT WEEK #sym.dot.c STUDENT PROJECT BRIEF
  ]

  #v(0.4em)
  #text(2.6 * font_size)[*Build a Portable Mini Energy Hub*]

  #v(0.2em)
  An interactive demonstrator for secondary education

  #v(0.9em)
  #block(width: 100%, stroke: (top: 0.5pt + luma(180), bottom: 0.5pt + luma(180)), inset: (y: 7pt))[
    #set text(size: 9pt)
    *Responsible authors:* #authors \
    #group #sym.dot.c Saxion Hogeschool
  ]

  #v(0.7em)
  #text(size: 9pt, fill: luma(90))[
    16 November 2026 #sym.dot.c firmware and wiring reference:
    #link(repo_url)[#repo_url]
  ]
]

#v(1em)

= Project overview

Energy hubs help integrate renewable energy, flexible demand, local energy
storage and the grid. During this one-week challenge, student teams will design
and build a portable Mini Energy Hub demonstrator for secondary-school
classrooms, open days and outreach activities. The system should make the
interactions between energy generation, consumption, storage and grid
constraints easy to see and understand.

= The challenge

Design and build a transportable tabletop system that demonstrates grid
congestion and the value of flexibility. The demonstrator must include energy
producers, energy consumers, a flexible load and an energy management
controller. All components should fit on a compact board and be suitable for
repeated educational demonstrations.

= Intended learning outcomes

- Explain the role of energy hubs in renewable-energy integration.
- Demonstrate grid congestion, demand response and congestion management.
- Apply sensors, microcontrollers and basic energy management logic in a
  working prototype.
- Translate a technical system into engaging educational activities and clear
  communication.

= Suggested system architecture <briefarch>

Use potentiometers and LDR or any other idea to emulate solar and realize PV
system. For wind generation use DC motors to emulate and realize the wind
generation. Represent household consumption with LEDs or small low-voltage DC
loads. Include a flexible asset such as battery and a controllable DC load or a
battery-charging demonstration. An ESP32 microcontroller acts as the energy
management system (EMS) and indicates normal operation, congestion and
flexibility actions.

*Design note:* Clearly distinguish simulated energy values from measured
electrical power. The team should define and test the congestion threshold and
show how the EMS responds when the limit is approached or exceeded.

= Required project deliverables

- A fully operational hardware Mini Energy Hub demonstrator (simulation is an
  optional bonus).
- An assembly manual.
- A teacher guide suitable for secondary education.
- Three student exercises linked to the demonstrator.
- A demonstration video lasting 3–5 minutes.
- An A3 educational poster.

= Secondary-school learning activity

Develop an engaging, practical lesson lasting approximately 60–90 minutes. The
lesson must include a hands-on demonstration and student activities that
connect observable system behaviour to the underlying energy concepts.

#tbl(
  columns: (auto, 1fr),
  align: (left + top, left + top),
  table.header(th[Scenario], th[Suggested classroom investigation]),
  [1. Grid congestion],
  [Increase demand or reduce available generation to demonstrate the effect of
  a grid.],
  [2. Flexibility reduces congestion],
  [Activate EMS control and observe how a flexible load can be reduced or
  shifted.],
  [3. Smart renewable-energy use],
  [Change simulated solar and wind generation and explore how demand or storage
  can respond.],
)

For each exercise, provide a learning objective, student instructions, expected
observations and questions for reflection.

= Team organisation

Suggested division of responsibilities for IPW team:

#tbl(
  columns: (1fr),
  align: (left + top),
  table.header(th[Primary responsibility]),
  [Hardware assembly, electrical connections and board design],
  [ESP32 software development],
  [Energy management logic and test scenarios],
  [Teacher guide and student learning materials],
  [Video production and project documentation],
)

All team members share responsibility for integration, testing, critical review
and the final demonstration.

= One-week project plan

#tbl(
  columns: (auto, auto, 1fr),
  align: (center + top, left + top, left + top),
  table.header(th[Day], th[Main focus], th[Suggested milestone]),
  [1], [Concept development and system design],
  [Agreed architecture, responsibilities and component plan],
  [2], [Hardware construction], [Assembled tabletop prototype],
  [3], [ESP32 programming and testing],
  [Working control logic and observable scenarios],
  [4], [Educational materials],
  [Draft teacher guide and three student exercises],
  [5], [Video and final presentation],
  [Demonstration, poster and completed handover],
)

= Working principles

- Connect and test electronics using appropriate low-voltage safety practices.
- Design a robust, portable board and protective casing where needed.
- Program, test and critically evaluate the energy-hub logic.
- Use AI tools responsibly as support; verify all technical outputs.
- Create accessible educational materials and an engaging demonstration video.

= Assessment criteria

#tbl(
  columns: (1fr, auto),
  align: (left + top, right + top),
  table.header(th[Assessment component], th[Weight]),
  [Technical functionality], [30%],
  [Educational value], [25%],
  [Documentation quality], [20%],
  [Demonstration video], [15%],
  [Teamwork and project management], [10%],
  [*Total*], [*100%*],
)

= Supporting materials

Teams should document any assumptions, selected components and design decisions
in their assembly manual. The parts, connections and reference code below are
suggestions, not requirements.

== Suggested bill of materials

One kit per team, indicative prices, orderable from Conrad.

#tbl(
  columns: (1.55fr, auto, auto, 1.2fr),
  align: (left + top, center + top, right + top, left + top),
  table.header(th[Component], th[Qty], th[Cost], th[Note]),

  table.cell(colspan: 4, fill: luma(242))[*Controller*],
  [Joy-IT SBC-NodeMCU-ESP32-C], [1], [€12], [Conrad 3344407. Classic ESP32,
  USB-C. Not a C3 or C6.],
  [Spare ESP32 board], [1], [€12], [],
  [USB-C *data* cable], [1], [€5], [Not a charge-only cable.],
  [5V 2A USB-C charger], [1], [€10], [],

  table.cell(colspan: 4, fill: luma(242))[*Generation and consumption*],
  [LDR (GL5528) + 10k resistor], [1], [€1], [],
  [10k potentiometer], [2], [€2], [Wire to 3.3V.],
  [DC motor, 3–6V, with propeller], [1], [€6], [Wind generator.],
  [LEDs, yellow or warm white], [4], [€2], [],
  [RGB LED, 5 mm, diffused], [2], [€2], [Note cathode or anode type.],
  [Switches], [4], [€5], [],
  [220 / 150 / 68 Ω resistors], [10 / 5 / 10], [€2], [],

  table.cell(colspan: 4, fill: luma(242))[*Measurement*],
  [INA219 current and voltage sensor], [2], [€12], [I#super[2]C, address 0x40.],
  [Panel DC voltmeter and ammeter], [1], [€8], [Optional, needs no code.],
  [Multimeter], [1], [], [Borrow one.],

  table.cell(colspan: 4, fill: luma(242))[*Storage*],
  [18650 Li-ion cell, protected], [2], [€12], [Protected cells only.],
  [18650 battery holder with leads], [2], [€4], [],
  [TP4056 charger module with protection], [1], [€4], [],
  [Boost or buck converter module], [1], [€5], [],

  table.cell(colspan: 4, fill: luma(242))[*Display, switching and board*],
  [OLED I#super[2]C display], [1], [€5], [SSD1306, 128×64, 0x3C.],
  [Breadboard], [2], [€10], [],
  [Jumper wire kit], [1], [€5], [],
  [Logic-level MOSFET module], [2], [€8], [AO3400 or IRLZ44N. Not an IRF520.],
  [Flyback diode 1N5819 or 1N4007], [4], [€2], [Across any motor.],
  [Board, standoffs, connectors, heat-shrink], [set], [€8], [],
  [Desk lamp or bright torch], [1], [], [Borrow one.],
)

== Suggested connections

ESP32 pins that work. These avoid the strapping pins (GPIO0, 2, 5, 12, 15) and
the ADC2 pins, which stop working once Wi-Fi is on.

#tbl(
  columns: (auto, auto, 1fr),
  align: (left + top, center + top, left + top),
  table.header(th[Use], th[GPIO], th[Notes]),
  [Analogue input 1], [34], [ADC1, input-only.],
  [Analogue input 2], [35], [ADC1, input-only.],
  [I#super[2]C SDA / SCL], [21 / 22], [Display and INA219 share this bus.],
  [Plain LED outputs], [25 / 26], [220 Ω each.],
  [RGB output 1 (R / G / B)], [27 / 14 / 33], [150 Ω on R, 68 Ω on G and B.],
  [RGB output 2 (R / G / B)], [18 / 19 / 23], [150 Ω on R, 68 Ω on G and B.],
  [Switch inputs], [16 / 4 / 13], [`INPUT_PULLUP`, switch to GND.],
  [PWM output for a MOSFET gate], [17], [Flyback diode across the load.],
)

- Analogue inputs go on 3.3V, never 5V. Check with a multimeter before first
  power-up.
- Green and blue LEDs need smaller resistors than red.
- Join every ground to the ESP32 GND.
- Use protected 18650 cells and a charger with protection. Never leave a cell
  charging unattended.

== Reference code

A working reference firmware is at #link(repo_url)[#repo_url]. Clone it rather
than copying out of this PDF.

#tbl(
  columns: (auto, 1fr),
  align: (left + top, left + top),
  table.header(th[Path], th[What it is]),
  [`firmware/platformio.ini`],
  [Pinned build: `espressif32@8.0.0`, board `esp32dev`, pinned libraries.],
  [`firmware/src/main.cpp`],
  [The firmware, 225 lines. Pin map at lines 20–36, hardware settings 38–49,
  controller constants 51–56, decision function at line 77.],
  [`firmware/tools/check_ems_logic.sh`],
  [Compiles the decision function with `g++` and prints a scenario table, on a
  laptop, without an ESP32.],
  [`firmware/README.md`], [Build instructions and the pin map in text form.],
)

```bash
pio run -t upload      # build and flash (needs a USB DATA cable)
pio device monitor     # serial output at 115200 baud
```

Download the toolchain before the project week: the first build fetches roughly
500 MB.

#heading(numbering: none)[Final presentation checklist]

- Demonstrate normal operation, congestion and an EMS flexibility response.
- Explain what the indicators and controls represent.
- Show that the system is portable and suitable for a classroom setting.
- Present the teacher guide, three exercises, assembly manual, video and A3
  poster.
- Reflect on limitations, safety and possible future improvements.

#briefnote[
  *Project scope note:* The brief describes a demonstrator rather than a
  grid-connected energy system. Keep the classroom setup low-voltage and do not
  connect it directly to mains electricity except the power supply.
]
