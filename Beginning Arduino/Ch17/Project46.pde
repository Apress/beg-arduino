// Project 46 – Based on the Arduino Webserver example by David A. Mellis and Tom Igoe

#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

float tempC, tempF;
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress insideThermometer = { 0x10, 0x7A, 0x3B, 0xA9, 0x01, 0x08, 0x00, 0xBF };
DeviceAddress outsideThermometer = { 0x10, 0xCD, 0x39, 0xA9, 0x01, 0x08, 0x00, 0xBE};

byte mac[] = { 0x48, 0xC2, 0xA1, 0xF3, 0x8D, 0xB7 };
byte ip[] = { 192,168,0, 104 };

// Start the server on port 80
Server server(80);

void setup()
{
  // Begin ethernet and server
  Ethernet.begin(mac, ip);
  server.begin();
    // Start up the sensors library
  sensors.begin();
    // set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);
  sensors.setResolution(outsideThermometer, TEMPERATURE_PRECISION);
}

// function to get the temperature for a device
void getTemperature(DeviceAddress deviceAddress)
{
  tempC = sensors.getTempC(deviceAddress);
  tempF = DallasTemperature::toFahrenheit(tempC);
} 
void loop()
{
  sensors.requestTemperatures();

  // listen for incoming clients
  Client client = server.available();
  if (client) {
    // an http request ends with a blank line
    boolean BlankLine = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        // If line is blank and end of line is newline character '\n' = end of HTTP request
        if (c == '\n' && BlankLine) {
          getTemperature(insideThermometer);
  client.println("HTTP/1.1 200 OK"); // Standard HTTP response
          client.println("Content-Type: text/html\n");
          client.println("<html><head><META HTTP-EQUIV=""refresh""CONTENT=""5"">\n");
          client.println("<title>Arduino Web Server</title></head>");
          client.println("<body>\n");
          client.println("<h1>Arduino Web Server</h1>");
          client.println("<h3>Internal Temperature</h3>");
          client.println("Temp C:");
          client.println(tempC);
          client.println("<br/>");
          client.println("Temp F:");
          client.println(tempF);
          client.println("<br/>");
          getTemperature(outsideThermometer);
          client.println("<h3>External Temperature</h3>");
          client.println("Temp C:");
          client.println(tempC);
          client.println("<br/>");
          client.println("Temp F:");
          client.println(tempF);
          client.println("<br/>");
          
          break;
      }
        if (c == '\n') {
          // Starting a new line
          BlankLine = true;
        } 
        else if (c != '\r') {
          // Current line has a character in it
          BlankLine = false;
        }
      }
    }
    // Allow time for the browser to receive data
    delay(10);
    // Close connection
    client.stop();
  }
}

