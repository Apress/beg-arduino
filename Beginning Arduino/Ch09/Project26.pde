// Project 26
#include <Servo.h> 

char buffer[10]; 
Servo servo1;  // Create a servo object 
Servo servo2;  // Create a second servo object  

void setup() 
{ 
  	servo1.attach(5);  // attaches the servo on pin 5 to the servo1 object 
  	servo2.attach(6);  // attaches the servo on pin 6 to the servo2 object 
  	Serial.begin(9600);
  	Serial.flush();
  	servo1.write(90);  // put servo1 at home position
  	servo2.write(90);  // put servo2 at home postion
	Serial.println("STARTING...");
} 
 
void loop() 
{ 
  	if (Serial.available() > 0) { // check if data has been entered
  		int index=0;
  		delay(100); // let the buffer fill up
  		int numChar = Serial.available(); // find the string length
  		if (numChar>10) {
  		numChar=10;
  		}
  		while (numChar--) {
  			// fill the buffer with the string
buffer[index++] = Serial.read();		
}
  		splitString(buffer); // run splitString function
  	}
}

void splitString(char* data) {
  	Serial.print("Data entered: ");
  	Serial.println(data);
  	char* parameter;
  	parameter = strtok (data, " ,"); //string to token
  while (parameter != NULL) { // if we haven't reached the end of the string...
  		setServo(parameter); // ...run the setServo function
  		parameter = strtok (NULL, " ,"); 
  	}
  	// Clear the text and serial buffers
  	for (int x=0; x<9; x++) {
  		buffer[x]='\0';
  	}
  	Serial.flush();
}


void setServo(char* data) {
  	if ((data[0] == 'L') || (data[0] == 'l')) {
  		int firstVal = strtol(data+1, NULL, 10); // string to long integer
  		firstVal = constrain(firstVal,0,180); // constrain values
  		servo1.write(firstVal);
  		Serial.print("Servo1 is set to: ");
  		Serial.println(firstVal);
  	}
  	if ((data[0] == 'R') || (data[0] == 'r')) {
  		int secondVal = strtol(data+1, NULL, 10); // string to long integer
  		secondVal = constrain(secondVal,0,255); // constrain the values
  		servo2.write(secondVal);
  		Serial.print("Servo2 is set to: ");
  		Serial.println(secondVal);
  	}
}

