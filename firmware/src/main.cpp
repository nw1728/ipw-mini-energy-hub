// ---------------------------------------------------------------------
// Mini Energy Hub - reference EMS implementation
// Board: Joy-IT SBC-NodeMCU-ESP32-C (classic ESP32, USB-C).
// Build with PlatformIO:  pio run -t upload && pio device monitor
// Toolchain and library versions are pinned in platformio.ini. Do not
// build this with the Arduino IDE: ledcAttach() needs core 3.x, and the
// IDE will happily hand you core 2.x instead.
//
// The LDR divider and the wind potentiometer run from 3.3V, NEVER from
// 5V: the ESP32 ADC inputs are 3.3V maximum.
// The fan is optional (O1). If you fit it, it needs a logic-level MOSFET
// module and a flyback diode (1N5819 / 1N4007) across its terminals.
// ---------------------------------------------------------------------

#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// ---------- pin map (see Appendix B) ----------
#define SOLAR_PIN     34   // ADC1, input-only: LDR divider
#define WIND_PIN      35   // ADC1, input-only: 10k potentiometer
#define PIN_SDA       21   // I2C to OLED
#define PIN_SCL       22
#define HOUSE1_LED    25
#define HOUSE2_LED    26
#define GRID_R        27   // grid status RGB LED
#define GRID_G        14
#define GRID_B        33
#define EV_R          18   // EV charging RGB LED
#define EV_G          19
#define EV_B          23
#define SW_HOUSE1     16   // INPUT_PULLUP, closed = house ON
#define SW_HOUSE2      4
#define SW_SMART      13   // INPUT_PULLUP, closed = SMART (EMS on)
#define FAN_PWM       17   // optional fan (O1): MOSFET gate. Harmless if unused.

// ---------- hardware settings: set these to match YOUR box ----------
// Common-anode RGB LEDs have their long leg on 3.3V and light up when the
// pin goes LOW, so the duty cycle must be inverted. Common-cathode LEDs
// have their long leg on GND. Check the datasheet of the LEDs you bought.
const bool RGB_COMMON_ANODE = false;

// Raw ADC readings (0..4095) of the LDR divider. Read them off the serial
// monitor in the room where you will teach:
//   LDR_DARK   = reading with a hand cupped over the LDR  -> solar 0
//   LDR_BRIGHT = reading with the desk lamp right above it -> solar 100
const int LDR_DARK   = 400;
const int LDR_BRIGHT = 3500;

// ---------- EMS constants ----------
const int GRID_LIMIT = 60;   // cable capacity, both directions
const int EV_NORMAL  = 25;   // normal charging power
const int EV_MAX     = 50;   // fast charging power
const int HOUSE1_W   = 30;
const int HOUSE2_W   = 25;

#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT  64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

enum Status { GRID_OK, IMPORT_CONGESTION, EXPORT_CONGESTION };

struct Ems {
  int ev;        // flexible load actually drawn
  int grid;      // + = import from grid, - = export to grid
  Status status;
};

// Forward declarations: a .cpp file does not get the .ino's automatic
// prototypes, so every function used before its definition is declared here.
void setRgb(int pinR, int pinG, int pinB, uint8_t r, uint8_t g, uint8_t b);
void showLights(Ems e);
void showDisplay(int solar, int wind, int baseLoad, bool smart, Ems e);

// Pure function: easy to reason about and to test on paper.
Ems computeEms(int generation, int baseLoad, bool smart) {
  Ems r;
  if (!smart) {
    r.ev = EV_NORMAL;                 // DUMB: charge regardless of the grid
  } else if (generation > baseLoad) {
    r.ev = EV_MAX;                    // surplus: soak up local renewables
  } else {
    // throttle so that import stays within the grid limit
    int room = GRID_LIMIT + generation - baseLoad;
    r.ev = constrain(room, 0, EV_NORMAL);
  }
  r.grid = baseLoad + r.ev - generation;
  if (r.grid > GRID_LIMIT)       r.status = IMPORT_CONGESTION;
  else if (r.grid < -GRID_LIMIT) r.status = EXPORT_CONGESTION;
  else                           r.status = GRID_OK;
  return r;
}

void setup() {
  Serial.begin(115200);

  pinMode(HOUSE1_LED, OUTPUT);
  pinMode(HOUSE2_LED, OUTPUT);
  pinMode(SW_HOUSE1, INPUT_PULLUP);
  pinMode(SW_HOUSE2, INPUT_PULLUP);
  pinMode(SW_SMART, INPUT_PULLUP);

  analogReadResolution(12);           // 0..4095

  // RGB LEDs: 5 kHz, 8-bit. Core 3.x picks the LEDC channels itself.
  const int rgbPins[] = {GRID_R, GRID_G, GRID_B, EV_R, EV_G, EV_B};
  for (int pin : rgbPins) ledcAttach(pin, 5000, 8);
  ledcAttach(FAN_PWM, 20000, 8);      // 20 kHz: above hearing, 8-bit duty

  Wire.begin(PIN_SDA, PIN_SCL);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("SSD1306 not found at 0x3C");
  }
  display.clearDisplay();
  display.display();
}

void loop() {
  // ---------- inputs ----------
  int ldrRaw = analogRead(SOLAR_PIN);
  int solar  = constrain(map(ldrRaw, LDR_DARK, LDR_BRIGHT, 0, 100), 0, 100);
  int wind   = map(analogRead(WIND_PIN), 0, 4095, 0, 100);
  int generation = solar + wind;                 // 0..200

  // pull-ups: LOW = switch closed = on
  bool house1 = (digitalRead(SW_HOUSE1) == LOW);
  bool house2 = (digitalRead(SW_HOUSE2) == LOW);
  bool smart  = (digitalRead(SW_SMART)  == LOW);

  int baseLoad = (house1 ? HOUSE1_W : 0) + (house2 ? HOUSE2_W : 0);

  // ---------- EMS ----------
  Ems e = computeEms(generation, baseLoad, smart);

  // ---------- outputs ----------
  digitalWrite(HOUSE1_LED, house1);
  digitalWrite(HOUSE2_LED, house2);

  ledcWrite(FAN_PWM, map(e.ev, 0, EV_MAX, 0, 255));

  showLights(e);
  showDisplay(solar, wind, baseLoad, smart, e);

  // Raw LDR reading once a second, for setting LDR_DARK / LDR_BRIGHT.
  static unsigned long lastPrint = 0;
  if (millis() - lastPrint >= 1000) {
    lastPrint = millis();
    Serial.printf("LDR raw %4d -> solar %3d | wind %3d | gen %3d | grid %+4d\n",
                  ldrRaw, solar, wind, generation, e.grid);
  }

  delay(200);
}

void setRgb(int pinR, int pinG, int pinB, uint8_t r, uint8_t g, uint8_t b) {
  if (RGB_COMMON_ANODE) { r = 255 - r; g = 255 - g; b = 255 - b; }
  ledcWrite(pinR, r);
  ledcWrite(pinG, g);
  ledcWrite(pinB, b);
}

// Grid light:  green = OK, red = import congestion, blue = export congestion.
// EV light:    off = not charging, yellow = throttled, white = normal,
//              green = fast (charging on local sunshine and wind).
// If one colour looks much brighter than the others, change its resistor
// (Appendix B) or scale its value down here.
void showLights(Ems e) {
  switch (e.status) {
    case GRID_OK:                setRgb(GRID_R, GRID_G, GRID_B,   0, 255,   0); break;
    case IMPORT_CONGESTION: setRgb(GRID_R, GRID_G, GRID_B, 255,   0,   0); break;
    case EXPORT_CONGESTION: setRgb(GRID_R, GRID_G, GRID_B,   0,   0, 255); break;
  }

  if (e.ev <= 0)             setRgb(EV_R, EV_G, EV_B,   0,   0,   0);
  else if (e.ev < EV_NORMAL) setRgb(EV_R, EV_G, EV_B, 255, 160,   0);
  else if (e.ev == EV_NORMAL) setRgb(EV_R, EV_G, EV_B, 255, 255, 255);
  else                       setRgb(EV_R, EV_G, EV_B,   0, 255,   0);
}

// Horizontal bar, full display width = full scale.
void drawBar(int y, int value, int fullScale) {
  int w = map(constrain(value, 0, fullScale), 0, fullScale, 0, SCREEN_WIDTH);
  display.drawRect(0, y, SCREEN_WIDTH, 4, SSD1306_WHITE);
  display.fillRect(0, y, w, 4, SSD1306_WHITE);
}

void showDisplay(int solar, int wind, int baseLoad, bool smart, Ems e) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  display.setCursor(0, 0);
  display.print(smart ? "MODE: SMART" : "MODE: DUMB");

  display.setCursor(0, 10);
  display.print("Gen  ");  display.print(solar + wind);
  display.print(" (S"); display.print(solar);
  display.print(" W");  display.print(wind); display.print(")");
  drawBar(19, solar + wind, 200);

  display.setCursor(0, 25);
  display.print("Load "); display.print(baseLoad);
  display.print("  EV "); display.print(e.ev);
  drawBar(34, e.ev, EV_MAX);

  display.setCursor(0, 40);
  display.print("Grid ");
  if (e.grid > 0) {
    display.print("+"); display.print(e.grid); display.print(" imp");
  } else if (e.grid < 0) {
    display.print(e.grid); display.print(" exp");
  } else {
    display.print("0");
  }

  display.setCursor(0, 48);
  display.setTextSize(2);
  switch (e.status) {
    case GRID_OK:                 display.print("OK");        break;
    case IMPORT_CONGESTION:  display.print("IMPORT!");   break;
    case EXPORT_CONGESTION:  display.print("EXPORT!");   break;
  }
  display.display();
}
