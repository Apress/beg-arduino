// Project 42
// Based on the SD Fat examples by Bill Greiman from sdfatlib

#include <SdFat.h>
#include <SdFatUtil.h>

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))

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

// Write a Carriage Return and Line Feed to the file
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

void setup() {
  Serial.begin(9600);
  Serial.println();
  Serial.println("Type any character to start");
  while (!Serial.available());
  
  // initialize the SD card at SPI_HALF_SPEED to avoid bus errors with breadboards. 
  // Use SPI_FULL_SPEED for better performance if your card an take it.
  if (!card.init(SPI_HALF_SPEED)) error("card.init failed");
  
  // initialize a FAT volume
  if (!volume.init(&card)) error("volume.init failed");
  
  // open the root directory
  if (!root.openRoot(&volume)) error("openRoot failed");

  // create a new file
  char name[] = "TESTFILE.TXT";
  
  file.open(&root, name, O_CREAT | O_EXCL | O_WRITE);
  // Put todays date and time here
  file.timestamp(2, 2010, 12, 25, 12, 34, 56);
 
 // write 10 lines to the file
  for (uint8_t i = 0; i < 10; i++) {
    writeString(file, "Line: ");
    writeNumber(file, i);
    writeString(file, " Write test.");
    writeCRLF(file);
  }
  // close file and force write of all data to the SD card
  file.close();
  Serial.println("File Created");  
  
  // open a file
  if (file.open(&root, name, O_READ)) {
    Serial.println(name);
  }
  else{
    error("file.open failed");
  }
  Serial.println();

  int16_t character;
  while ((character = file.read()) > 0) Serial.print((char)character);

  Serial.println("\nDone");
}

void loop() { }

