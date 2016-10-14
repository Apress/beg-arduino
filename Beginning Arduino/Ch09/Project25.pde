// Project 25
#include <Servo.h> 
 
Servo servo1;  // Create a servo object 
 
void setup() 
{ 
  	servo1.attach(5);  // attaches the servo on pin 5 to the servo object 
} 
 
void loop() 
{ 
    	int angle = analogRead(0); // read the pot value
    	angle=map(angle, 0, 1023, 0, 180); // map the values from 0 to 180 degrees
    	servo1.write(angle); // write the angle to the servo
    	delay(15); // delay of 15ms to allow servo to reach position 
} 

