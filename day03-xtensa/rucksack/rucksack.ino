extern "C" {
  uint64_t solve(void);
}

void setup() {
  Serial.begin(38400);

  Serial.println("\nおはよう世界");

  uint64_t solution = solve();

  Serial.print("Part 1: ");
  Serial.println(solution >> 32);
  Serial.print("Part 2: ");
  Serial.println(solution & 0xFFFFFFFF);
}

void loop() {
  delay(100);
}
