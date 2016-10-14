// Project 37 - Part 2

#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas
 temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);
// arrays to hold device addresses – replace with your sensors addresses
DeviceAddress insideThermometer = { 0x28, 0xCA, 0x90, 0xC2, 0x2, 0x00, 0x00, 0x88 };
DeviceAddress outsideThermometer = { 0x28, 0x3B, 0x40, 0xC2, 0x02, 0x00, 0x00, 0x93 };

void setup()
{
  // start serial port
  Serial.begin(9600);

  // Start up the library
  sensors.begin();

  Serial.println("Initialising...");
  Serial.println();

// set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);
  sensors.setResolution(outsideThermometer, TEMPERATURE_PRECISION);
}

// function to print the temperature for a device
void printTemperature(DeviceAddress deviceAddress)
{
  float tempC = sensors.getTempC(deviceAddress);
  Serial.print(" Temp C: ");
  Serial.print(tempC);
  Serial.print("  Temp F: ");
  Serial.println(DallasTemperature::toFahrenheit(tempC));
}

void loop()
{ 
  // print the temperatures
  Serial.print("Inside Temp:");
  printTemperature(insideThermometer);
  Serial.print("Outside Temp:");
  printTemperature(outsideThermometer);
  Serial.println();
  delay(3000);
}

