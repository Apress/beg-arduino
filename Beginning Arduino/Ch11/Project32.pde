/*
SCP1000             Mega
DRDY                N/A
CSB                 53 via Logic Level Convertor
MISO                50 (straight through)
MOSI                51 via Logic Level Convertor
SCK                 52 via Logic Level Convertor
3.3v                3.3v
GND                 GND
TRIG                GND
PD                  GND
*/

#include <glcd.h>

#include "fonts/allFonts.h"

// SPI PINS
#define SLAVESELECT 53
#define SPICLOCK 52
#define DATAOUT 51      //MOSI
#define DATAIN 50       //MISO
#define UBLB(a,b)  ( ( (a) << 8) | (b) )
#define UBLB19(a,b) ( ( (a) << 16 ) | (b) )

//Addresses
#define PRESSURE 0x1F   //Pressure 3 MSB
#define PRESSURE_LSB 0x20 //Pressure 16 LSB
#define TEMP 0x21       //16 bit temp
#define INTERVAL 900  // Time interval in seconds (approx.)

int dots[124], dotCursor = 0, counter = 0;;
char rev_in_byte;
int temp_in;
float hPa;
unsigned long pressure_lsb;
unsigned long pressure_msb;
unsigned long temp_pressure;
unsigned long pressure;

void setup()
{
  GLCD.Init();   // initialise the library
  GLCD.ClearScreen();
  GLCD.SelectFont(System5x7, BLACK); // load the font

  byte clr;
  pinMode(DATAOUT, OUTPUT);
  pinMode(DATAIN, INPUT);
  pinMode(SPICLOCK,OUTPUT);
  pinMode(SLAVESELECT,OUTPUT);
  digitalWrite(SLAVESELECT,HIGH); //disable device

  SPCR = B01010011; // SPi Control Register
  //MPIE=0, SPE=1 (on), DORD=0 (MSB first), MSTR=1 (master), CPOL=0 (clock idle when low),
 CPHA=0 (samples MOSI on rising edge), SPR1=1 & SPR0=1 (250kHz)
  clr=SPSR;// SPi Status Register
  clr=SPDR; // SPi Data Register
  delay(10);

  write_register(0x03,0x09); // High Speed Read Mode
  write_register(0x03,0x0A); // High Resolution Measurement Mode

  GLCD.DrawRect(1,1,125,44); // Draw a rectangle
  for (int x=0; x<46; x+=11) { // Draw vertical scale
    GLCD.SetDot(0,1+x, BLACK);
    GLCD.SetDot(127,1+x, BLACK);
  }
    for (int x=0; x<128; x+=5) { // Draw horizontal scale
    GLCD.SetDot(1+x,0, BLACK);
  }

  for (int x; x<124; x++) {dots[x]=1023;} // clear the array
  getPressure();
  drawPoints(dotCursor);
}

void loop()
{
  getPressure();

  GLCD.CursorToXY(0, 49); // print pressure
  GLCD.print("hPa:");
  GLCD.CursorToXY(24,49);
  GLCD.print(hPa);

  temp_in = read_register16(TEMP);
  float tempC = float(temp_in)/20.0;
  float tempF = (tempC*1.8) + 32;

  GLCD.CursorToXY(0,57); // print temperature
  GLCD.print("Temp:");
  GLCD.CursorToXY(28, 57);
  GLCD.print(tempC); // change to tempF for Fahrenheit

  delay(1000);

  GLCD.CursorToXY(84,49); // print trend
  GLCD.print("TREND:");
  GLCD.CursorToXY(84,57);
  printTrend();

   counter++;
  if (counter==INTERVAL) {drawPoints(dotCursor);}

}

void drawPoints(int position) {
  counter=0;
  dots[dotCursor] = int(hPa);
  GLCD.FillRect(2, 2, 123, 40, WHITE); // clear graph area
  for (int x=0; x<124; x++) {
    GLCD.SetDot(125-x,44-((dots[position]-980)), BLACK);
    position--;
    if (position<0) {position=123;}
     }
  dotCursor++;
  if (dotCursor>123) {dotCursor=0;}
  }

void getPressure() {
  pressure_msb = read_register(PRESSURE);
  pressure_msb &= B00000111;
  pressure_lsb = read_register16(PRESSURE_LSB);
  pressure_lsb &= 0x0000FFFF;
  pressure = UBLB19(pressure_msb, pressure_lsb);
  pressure /= 4;
  hPa = float(pressure)/100;
}

void printTrend() { // calculate trend since last data point and print
  int dotCursor2=dotCursor-1;
  if (dotCursor2<0) {dotCursor2=123;}
  int val1=dots[dotCursor2];
  int dotCursor3=dotCursor2-1;
  if (dotCursor3<0) {dotCursor3=123;}
  int val2=dots[dotCursor3];
  if (val1>val2) {GLCD.print("RISING ");}
  if (val1==val2) {GLCD.print("STEADY ");}
  if (val1<val2) {GLCD.print("FALLING");}
}

char spi_transfer(char data)
{
  SPDR = data;                    // Start the transmission
  while (!(SPSR & (1<<SPIF)))     // Wait for the end of the transmission
  {
  };
  return SPDR;   // return the received byte
}

char read_register(char register_name)
{
    char in_byte;
    register_name <<= 2;

    digitalWrite(SLAVESELECT,LOW); //Enable SPI Device
    spi_transfer(register_name); //Write byte to device
    in_byte = spi_transfer(0x00); //Send nothing but get back register value
    digitalWrite(SLAVESELECT,HIGH); // Disable SPI Device
    delay(10);
    return(in_byte); // return value
    }

unsigned long read_register16(char register_name)
{
    byte in_byte1;
    byte in_byte2;
    float in_word;

    register_name <<= 2;

    digitalWrite(SLAVESELECT,LOW); //Enable SPI Device
    spi_transfer(register_name); //Write byte to device
    in_byte1 = spi_transfer(0x00);
    in_byte2 = spi_transfer(0x00);
    digitalWrite(SLAVESELECT,HIGH); // Disable SPI Device
    in_word = UBLB(in_byte1,in_byte2);
    return(in_word); // return value
}

void write_register(char register_name, char register_value)
{
    register_name <<= 2;
    register_name |= B00000010; //Write command

    digitalWrite(SLAVESELECT,LOW); //Select SPI device
    spi_transfer(register_name); //Send register location
    spi_transfer(register_value); //Send value to record into register
    digitalWrite(SLAVESELECT,HIGH);
}

