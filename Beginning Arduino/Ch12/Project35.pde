// Project 35

// Power connections
#define Left 8     // Left (X1) to digital pin 8
#define Bottom 9   // Bottom (Y2) to digital pin 9
#define Right 10   // Right (X2) to digital pin 10
#define Top 11     // Top (Y1) to digital pin 11

// Analog connections 
#define topInput 0   // Top (Y1) to analog pin 0
#define rightInput 1 // Right (X2) to analog pin 1 
// RGB pins
#define pinR 3
#define pinG 5
#define pinB 6

int coordX = 0, coordY = 0;
boolean ledState = true;
int red = 100, green = 100, blue = 100;

void setup()
{
  pinMode(pinR, OUTPUT);
  pinMode(pinG, OUTPUT);
  pinMode(pinB, OUTPUT);
}

void loop()
{    
        if (touch()) {
                if ((coordX>0 && coordX<270) && (coordY>0 && coordY<460)) {ledState =
 true; delay(50);}
                if ((coordX>0 && coordX<270) && (coordY>510 && coordY< 880)) {ledState =
 false; delay(50);}
                if ((coordX>380 && coordX<930) && (coordY>0 && coordY<300)) {red=
map(coordX, 380, 930, 0, 255);}
                if ((coordX>380 && coordX<930) && (coordY>350 && coordY<590))
 {green=map(coordX, 380, 930, 0, 255);} 
                if ((coordX>380 && coordX<930) && (coordY>640 && coordY<880))
 {blue=map(coordX, 380, 930, 0, 255);} 
                delay(10);
}

        if (ledState) {
                analogWrite(pinR, red);
                analogWrite(pinG, green);
                analogWrite(pinB, blue);
        }
        else {
                analogWrite(pinR, 0);
                analogWrite(pinG, 0);
                analogWrite(pinB, 0);
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

