// Project 49 – Twitterbot

#include <Ethernet.h>
#include <EthernetDHCP.h>
#include <EthernetDNS.h>
#include <Twitter.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

float itempC, itempF, etempC, etempF;
boolean firstTweet = true;
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress insideThermometer = { 0x10, 0x7A, 0x3B, 0xA9, 0x01, 0x08, 0x00, 0xBF };
DeviceAddress outsideThermometer = { 0x10, 0xCD, 0x39, 0xA9, 0x01, 0x08, 0x00, 0xBE};

byte mac[] = { 0x64, 0xB9, 0xE8, 0xC3, 0xC7, 0xE2 };

// Your Token to tweet (get it from http://arduino-tweet.appspot.com/)
Twitter twitter("608048201-CxY1yQi8ezhvjz60ZVfPHVdzIHbMOD1h2gvoaAIx"); 

unsigned long interval = 600000; // 10 minutes
unsigned long lastTime; // time since last tweet

// Message to post
char message[140], serialString[60];

// function to get the temperature for a device
void getTemperatures()
{
  itempC = sensors.getTempC(insideThermometer);
  itempF = DallasTemperature::toFahrenheit(itempC);
  etempC = sensors.getTempC(outsideThermometer);
  etempF = DallasTemperature::toFahrenheit(etempC);
} 

void tweet(char msg[]) {
   Serial.println("connecting ...");
  if (twitter.post(msg)) {
    int status = twitter.wait();
    if (status == 200) {
      Serial.println("OK. Tweet sent.");
      Serial.println();
      lastTime = millis();
      firstTweet = false;
    } else {
      Serial.print("failed : code ");
      Serial.println(status);
    }
  } else {
    Serial.println("connection failed.");
  }
}

void setup()
{
  EthernetDHCP.begin(mac);
  Serial.begin(9600);
   sensors.begin();
    // set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);
  sensors.setResolution(outsideThermometer, TEMPERATURE_PRECISION);

  sensors.requestTemperatures()
  
  getTemperatures();
  // compile the string to be tweeted
while (firstTweet) { 
sprintf(message, "Int. Temp: %d C (%d F) Ext. Temp: %d C (%d F). Tweeted from Arduino. %ld", int(itempC), int(itempF), int(etempC), int(etempF), millis());   tweet(message); 
  }
}

void loop()
{
  EthernetDHCP.maintain();
  sensors.requestTemperatures();
  // compile the string to be printed to the serial monitor
  sprintf(serialString, "Internal Temp: %d C  %d F. External Temp: %d C %d F", int(itempC), int(itempF), int(etempC), int(etempF));
  delay(500);
  Serial.println(serialString);
  Serial.println();
  
  if (millis() >= (lastTime + interval)) {
  // compile the string to be tweeted
sprintf(message, "Int. Temp: %d C (%d F) Ext. Temp: %d C (%d F). Tweeted from Arduino. %ld", int(itempC), int(itempF), int(etempC), int(etempF), millis());   tweet(message); 
    }
delay(10000); // 10 seconds
}


