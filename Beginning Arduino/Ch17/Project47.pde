// Project 47 - Based on the Pachube Arduino examples
#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define SHARE_FEED_ID  10722     // this is your Pachube feed ID
#define UPDATE_INTERVAL  10000    // if the connection is good wait 10 seconds before updating again - should not be less than 5
#define RESET_INTERVAL  10000    // if connection fails/resets wait 10 seconds before trying again - should not be less than 5
#define PACHUBE_API_KEY  "066ed6ea1d1073600e5b44b35e8a399697d66532c3e736c77dc11123dfbfe12f" // fill in your API key 

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress insideThermometer = { 0x10, 0x7A, 0x3B, 0xA9, 0x01, 0x08, 0x00, 0xBF };
DeviceAddress outsideThermometer = { 0x10, 0xCD, 0x39, 0xA9, 0x01, 0x08, 0x00, 0xBE};

byte mac[] = { 0xCC, 0xAC, 0xBE, 0xEF, 0xFE, 0x91 }; // make sure this is unique on your network
byte ip[] = { 192, 168, 0, 104   };                  // no DHCP so we set our own IP address
byte remoteServer[] = { 173, 203, 98, 29 };            // pachube.com

Client localClient(remoteServer, 80);

unsigned int interval;
char buff[64];
int pointer = 0;
char pachube_data[70];
char *found;
boolean ready_to_update = true;
boolean reading_pachube = false;
boolean request_pause = false;
boolean found_content = false;
unsigned long last_connect;
int content_length;
int itempC, itempF, etempC, etempF;

void setupEthernet(){
  resetEthernetShield();
  delay(500);
  interval = UPDATE_INTERVAL;
  Serial.println("setup complete");
}

void clean_buffer() {
  pointer = 0;
  memset(buff,0,sizeof(buff)); 
}

void resetEthernetShield(){
  Serial.println("reset ethernet");
  Ethernet.begin(mac, ip);
}

void pachube_out(){
  getTemperatures();
  if (millis() < last_connect) last_connect = millis();

  if (request_pause){
    if ((millis() - last_connect) > interval){
      ready_to_update = true;
      reading_pachube = false;
      request_pause = false;
    }
  }

  if (ready_to_update){
    Serial.println("Connecting...");
    if (localClient.connect()) {

      sprintf(pachube_data,"%d,%d,%d,%d",itempC, itempF, etempC, etempF);
      Serial.print("Sending: ");
      Serial.println(pachube_data);
      content_length = strlen(pachube_data);

      Serial.println("Updating.");
       localClient.print("PUT /v1/feeds/");
      localClient.print(SHARE_FEED_ID);
      localClient.print(".csv HTTP/1.1\nHost: api.pachube.com\nX-PachubeApiKey: ");
      localClient.print(PACHUBE_API_KEY);
      localClient.print("\nUser-Agent: Beginning Arduino – Project 47");
      localClient.print("\nContent-Type: text/csv\nContent-Length: ");
      localClient.print(content_length);
      localClient.print("\nConnection: close\n\n");
      localClient.print(pachube_data);
      localClient.print("\n");

      ready_to_update = false;
      reading_pachube = true;
      request_pause = false;
      interval = UPDATE_INTERVAL;

    } 
    else {
      Serial.print("connection failed!");
      ready_to_update = false;
      reading_pachube = false;
      request_pause = true;
      last_connect = millis();
      interval = RESET_INTERVAL;
      setupEthernet();
    }
  }

  while (reading_pachube){
      while (localClient.available()) {
        checkForResponse();
      }  
      if (!localClient.connected()) {
        disconnect_pachube();
      }
  }
}

void disconnect_pachube(){
    Serial.println("disconnecting.\n===============\n\n");
    localClient.stop();
    ready_to_update = false;
    reading_pachube = false;
    request_pause = true;
    last_connect = millis();
    resetEthernetShield();
}

void checkForResponse(){  
  char c = localClient.read();
  buff[pointer] = c;
  if (pointer < 64) pointer++;
   if (c == '\n') {
    found = strstr(buff, "200 OK");
    buff[pointer]=0;
    clean_buffer();    
  }
}

// function to get the temperature for a device
void getTemperatures()
{
  sensors.requestTemperatures();
  itempC = sensors.getTempC(insideThermometer);
  itempF = DallasTemperature::toFahrenheit(itempC);
  etempC = sensors.getTempC(outsideThermometer);
  etempF = DallasTemperature::toFahrenheit(etempC);
}

void setup()
{
  Serial.begin(57600); 
  setupEthernet(); 
      // Start up the sensors library
  sensors.begin();
    // set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);
  sensors.setResolution(outsideThermometer, TEMPERATURE_PRECISION);
}

void loop()
{
pachube_out();
}


