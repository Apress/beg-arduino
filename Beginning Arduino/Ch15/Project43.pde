// Project 43
// Based on the SD Fat examples by Bill Greiman from sdfatlib
// DS1307 library by Matt Joyce with enhancements by D. Sjunnesson

#include <SdFat.h>
#include <SdFatUtil.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <WProgram.h>
#include <Wire.h>
#include <DS1307.h> // written by  mattt on the Arduino forum and modified by D. Sjunnesson

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))
// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas
 temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
  DeviceAddress insideThermometer = { 0x10, 0x20, 0x2C, 0xA9, 0x01, 0x08, 0x00, 0x73 };
  DeviceAddress outsideThermometer = { 0x10, 0x22, 0x5B, 0xA9, 0x01, 0x08, 0x00, 0x21 };
  
  float tempC, tempF;
  int hour, minute, seconds, day, month, year;

// create a new file name
char name[] = "TEMPLOG.TXT";
void error_P(const char* str) {
  PgmPrint("error: ");
  SerialPrintln_P(str);
  if (card.errorCode()) {
    PgmPrint("SD error: ");
    Serial.print(card.errorCode(), HEX);
    Serial.print(',');
    Serial.println(card.errorData(), HEX);
  }
  while(1);
}

void writeCRLF(SdFile& f) {
  f.write((uint8_t*)"\r\n", 2);
}

// Write an unsigned number to file
void writeNumber(SdFile& f, uint32_t n) {
  uint8_t buf[10];
  uint8_t i = 0;
  do {
    i++;
    buf[sizeof(buf) - i] = n%10 + '0';
    n /= 10;
  } while (n);
  f.write(&buf[sizeof(buf) - i], i);
}

// Write a string to file
void writeString(SdFile& f, char *str) {
  uint8_t n;
  for (n = 0; str[n]; n++);
  f.write((uint8_t *)str, n);
}

void getTemperature(DeviceAddress deviceAddress)
{
  sensors.requestTemperatures();
  tempC = sensors.getTempC(deviceAddress);
  tempF = DallasTemperature::toFahrenheit(tempC);
}

void getTimeDate() {
  hour = RTC.get(DS1307_HR,true); //read the hour and also update all the values by
 pushing in true
  minute = RTC.get(DS1307_MIN,false);//read minutes without update (false)
  seconds = RTC.get(DS1307_SEC,false);//read seconds
  day = RTC.get(DS1307_DATE,false);//read date
  month = RTC.get(DS1307_MTH,false);//read month
  year = RTC.get(DS1307_YR,false); //read year 
}

void setup() {
  Serial.begin(9600);
  Serial.println("Type any character to start");
  while (!Serial.available());
  Serial.println();
  
  // Start up the sensors library
  sensors.begin(); 
  Serial.println("Initialising Sensors.");

  // set the resolution
  sensors.setResolution(insideThermometer, TEMPERATURE_PRECISION);
  sensors.setResolution(outsideThermometer, TEMPERATURE_PRECISION);
  delay(100);
  
  // Set the time on the RTC.
  // Comment out this section if you have already set the time and have a battery backup
  RTC.stop();
  RTC.set(DS1307_SEC,0);        //set the seconds
  RTC.set(DS1307_MIN,15);     //set the minutes
  RTC.set(DS1307_HR,14);       //set the hours
  RTC.set(DS1307_DOW,7);       //set the day of the week
  RTC.set(DS1307_DATE,3);       //set the date
  RTC.set(DS1307_MTH,10);        //set the month
  RTC.set(DS1307_YR,10);         //set the year
  RTC.start();

  Serial.println("Initialising SD Card...");
  
  // initialize the SD card at SPI_HALF_SPEED to avoid bus errors with breadboards. 
  // Use SPI_FULL_SPEED for better performance if your card an take it.
  if (!card.init(SPI_HALF_SPEED)) error("card.init failed");
  
  // initialize a FAT volume
  if (!volume.init(&card)) error("volume.init failed");
  
  // open the root directory
  if (!root.openRoot(&volume)) error("openRoot failed");
  Serial.println("SD Card initialised successfully.");
  Serial.println();
}
void loop() {
   
  Serial.println("File Opened.");
  file.open(&root, name, O_CREAT | O_APPEND | O_WRITE);
  getTimeDate();
  file.timestamp(7, year, month, day, hour, minute, seconds);
 
   getTemperature(insideThermometer);
    Serial.print("Inside: ");
    Serial.print(tempC);
    Serial.print(" C  ");
    Serial.print(tempF);
    Serial.println(" F");
    writeNumber(file, year);
    writeString(file, "/");
    writeNumber(file, month);
    writeString(file, "/");
    writeNumber(file, day);
    writeString(file, "  ");
    writeNumber(file, hour);
    writeString(file, ":");
    writeNumber(file, minute);
    writeString(file, ":");
    writeNumber(file, seconds);  
    writeCRLF(file); 
    writeString(file, "Internal Sensor: ");
    writeNumber(file, tempC);
    writeString(file, " C   ");
    writeNumber(file, tempF);
    writeString(file, " F");
    writeCRLF(file);
    
    getTemperature(outsideThermometer);
    Serial.print("Outside: ");
    Serial.print(tempC);
    Serial.print(" C  ");
    Serial.print(tempF);
    Serial.println(" F");
    writeString(file, "External Sensor: ");
    writeNumber(file, tempC);
    writeString(file, " C   ");
    writeNumber(file, tempF);
    writeString(file, " F");
    writeCRLF(file);
    writeCRLF(file);
     Serial.println("Data written.");
  // close file and force write of all data to the SD card
  file.close(); 
  Serial.println("File Closed."); 
  Serial.println();
  delay(10000);
}

