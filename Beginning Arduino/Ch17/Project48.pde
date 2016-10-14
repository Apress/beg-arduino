#include <Ethernet.h>
#include <SPI.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#define time 1000
#define emailInterval 60
#define HighThreshold 40 // Highest temperature allowed
#define LowThreshold 10 // Lowest temperature

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

float tempC, tempF;
char message1[35], message2[35];
char subject[] = "ARDUINO: TEMPERATURE ALERT!!\0";
unsigned long lastMessage;

// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress insideThermometer = { 0x10, 0x7A, 0x3B, 0xA9, 0x01, 0x08, 0x00, 0xBF };

byte mac[] = { 0x64, 0xB9, 0xE8, 0xC3, 0xC7, 0xE2 };
byte ip[] = { 192,168,0, 105 };
byte server[] = { 62, 234, 219, 95 };  // Mail server address. Change this to your own mail servers IP.

Client client(server, 25);

void sendEmail(char subject[], char message1[], char message2[], float temp) {
  Serial.println("connecting...");
 
 if (client.connect()) {
   Serial.println("connected");
   client.println("EHLO MYSERVER");  delay(time); // log in
   client.println("AUTH LOGIN"); delay(time); // authorise
   // enter your username here
   client.println("caFzLmNvbQaWNZXGluZWVsZWN0cm9uNAZW2FsydGhzd3");  delay(time);
   // and password here
   client.println("ZnZJh4TYZ2ds");  delay(time);
   client.println("MAIL FROM:<alert@bobsmith.org>");      delay(time);
   client.println("RCPT TO:<fred@bloggs.com>");      delay(time);
   client.println("DATA");       delay(time);
   client.println("From: <alert@bobsmith.org>");       delay(time);
   client.println("To: <fred@bloggs.com>");       delay(time);
   client.print("SUBJECT: ");
     client.println(subject);       delay(time);
   client.println();      delay(time);
   client.println(message1);      delay(time);
   client.println(message2);      delay(time);
   client.print("Temperature: ");
   client.println(temp);   delay(time);
   client.println(".");      delay(time);
   client.println("QUIT");      delay(time);
   Serial.println("Email sent.");
   lastMessage=millis();
 } else {
   Serial.println("connection failed");
 }

}

void checkEmail() { // see if any data is available from client
  while (client.available()) {
   char c = client.read();
   Serial.print(c);
 }
 
 if (!client.connected()) {
   Serial.println();
   Serial.println("disconnecting.");
   client.stop();
 } 
}

// function to get the temperature for a device
void getTemperature(DeviceAddress deviceAddress)
{
  tempC = sensors.getTempC(deviceAddress);
  tempF = DallasTemperature::toFahrenheit(tempC);
} 

void setup()
{
 lastMessage = 0;
 Ethernet.begin(mac, ip);
 Serial.begin(9600);
 
     // Start up the sensors library
  sensors.begin();
    // set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);

delay(1000);
}

void loop()
{
  sensors.requestTemperatures();
  getTemperature(insideThermometer);
  Serial.println(tempC);
  // Is it too hot?
if (tempC >= HighThreshold && (millis()>(lastMessage+(emailInterval*1000)))) {
    Serial.println("High Threshhold Exceeded");
    char message1[] = "Temperature Sensor\0";
    char message2[] = "High Threshold Exceeded\0";
    sendEmail(subject, message1, message2, tempC);
  } // too cold?
else if (tempC<= LowThreshold && (millis()>(lastMessage+(emailInterval*1000))))
    Serial.println("Low Threshhold Exceeded");
    char message1[] = "Temperature Sensor\0";
    char message2[] = "Low Threshold Exceeded\0";
    sendEmail(subject, message1, message2, tempC);
  }
       
    if (client.available()) {checkEmail();}
}

