#include <AFMotor.h>
#include <SPI.h>
#include "Adafruit_MAX31855.h"

#define MAXDO   A5
#define MAXCS   A4
#define MAXCLK  A3

// initialize the thermocouple
Adafruit_MAX31855 thermocouple(MAXCLK, MAXCS, MAXDO);

// initialize the motor
AF_DCMotor motor(2);

void setup() 
{
  Serial.begin(9600);
  while (!Serial) delay(1); 
  Serial.println("MAX31855 test");
  // wait for MAX chip to stabilize
  delay(500);
  Serial.print("Initializing sensor...");
  if (!thermocouple.begin()) {
    Serial.println("ERROR.");
    while (1) delay(10);
  }
  Serial.println("DONE.");
  
  //Set initial speed of the motor & stop
  motor.setSpeed(200);
  motor.run(RELEASE);
}

void loop() 
{
  motor.run(FORWARD);

  double ext_temp = thermocouple.readInternal();
  double int_temp = thermocouple.readCelsius(); //thermocouple.readFahrenheit()

  if (isnan(c)) {
    Serial.print(0); // Something wrong with thermocouple!
    Serial.print(",");
    Serial.print(-1);
    Serial.print(",");
    Serial.println(-1);
  } else {
    Serial.print(1); //Nominal.
    Serial.print(",");
    Serial.print(ext_temp);
    Serial.print(",");
    Serial.println(int_temp);
  } 
  delay(1000); // 1 Hz
}
