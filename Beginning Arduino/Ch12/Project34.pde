// Project 34

#include <LiquidCrystal.h>

LiquidCrystal lcd(2, 3, 4, 5, 6, 7); // create an lcd object and assign the pins

// Power connections
#define Left 8     // Left (X1) to digital pin 8
#define Bottom 9   // Bottom (Y2) to digital pin 9
#define Right 10   // Right (X2) to digital pin 10
#define Top 11     // Top (Y1) to digital pin 11
// Analog connections 
#define topInput 0   // Top (Y1) to analog pin 0
#define rightInput 1 // Right (X2) to analog pin 1 

int coordX = 0, coordY = 0;
char buffer[16];

void setup()
{
  lcd.begin(16, 2); // Set the display to 16 columns and 2 rows
  lcd.clear();
}

void loop()
{    
  if (touch())  
  {
    if ((coordX>110 && coordX<300) && (coordY>170 && coordY<360)) {lcd.print("3");}
    if ((coordX>110 && coordX<300) && (coordY>410 && coordY<610)) {lcd.print("2");}
    if ((coordX>110 && coordX<300) && (coordY>640 && coordY<860)) {lcd.print("1");}
    if ((coordX>330 && coordX<470) && (coordY>170 && coordY<360)) {lcd.print("6");}
    if ((coordX>330 && coordX<470) && (coordY>410 && coordY<610)) {lcd.print("5");}
    if ((coordX>330 && coordX<470) && (coordY>640 && coordY<860)) {lcd.print("4");}
    if ((coordX>490 && coordX<710) && (coordY>170 && coordY<360)) {lcd.print("9");}
    if ((coordX>490 && coordX<710) && (coordY>410 && coordY<610)) {lcd.print("8");}
    if ((coordX>490 && coordX<710) && (coordY>640 && coordY<860)) {lcd.print("7");}
    if ((coordX>760 && coordX<940) && (coordY>170 && coordY<360)) {scrollLCD();}
    if ((coordX>760 && coordX<940) && (coordY>410 && coordY<610)) {lcd.print("0");}
    if ((coordX>760 && coordX<940) && (coordY>640 && coordY<860)) {lcd.clear();}  
    delay(250); 
  }
}
 
// return TRUE if touched, and set coordinates to touchX and touchY
boolean touch()
{
  boolean touch = false;

  // get horizontal co-ordinates
  pinMode(Left, OUTPUT); 
  digitalWrite(Left, LOW); // Set Left to Gnd

  pinMode(Right, OUTPUT); // Set right to +5v
  digitalWrite(Right, HIGH);

  pinMode(Top, INPUT); // Top and Bottom to high impedence
  pinMode(Bottom, INPUT);

  delay(3); // short delay
  coordX = analogRead(topInput);

  // get vertical co-ordinates
  pinMode(Bottom, OUTPUT); // set Bottom to Gnd
  digitalWrite(Bottom, LOW);

  pinMode(Top, OUTPUT); // set Top to +5v
  digitalWrite(Top, HIGH);

  pinMode(Right, INPUT); // left and right to high impedence
  pinMode(Left, INPUT);

  delay(3); // short delay
  coordY = analogRead(rightInput);

  // if co-ordinates read are less than 1000 and greater than 0 then the screen has
 been touched
  if(coordX < 1000 && coordX > 0 && coordY < 1000 && coordY > 0) {touch = true;}

    return touch;
}

void scrollLCD() {
  for (int scrollNum=0; scrollNum<16; scrollNum++) {
    lcd.scrollDisplayLeft();
    delay(100);
  }
  lcd.clear();
}

