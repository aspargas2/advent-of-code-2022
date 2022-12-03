#include <LiquidCrystal.h>

const int rs = 12, en = 11, d4 = 2, d5 = 3, d6 = 4, d7 = 5;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

extern "C" {
  uint32_t solve(void);
}

void setup() {
  lcd.begin(16, 2);

  uint32_t solution = solve();

  lcd.print("Part 1: ");
  lcd.print(solution >> 16);
  lcd.setCursor(0, 1);
  lcd.print("Part 2: ");
  lcd.print(solution & 0xFFFF);
}

void loop() {
  delay(100);
}
