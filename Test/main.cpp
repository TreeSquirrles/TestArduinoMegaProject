#include <Arduino.h>

#define PIN 49
#define O 8

void setup()
{
  Serial.begin(9600);
  pinMode(PIN, INPUT_PULLUP);
  pinMode(O, OUTPUT);
}

int pressed = 0;

void loop()
{
  pressed = !digitalRead(PIN);

  pressed ? digitalWrite(O, HIGH) : digitalWrite(O, LOW);
  delay(100);
}
