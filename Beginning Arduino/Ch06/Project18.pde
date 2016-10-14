// Project 18

int latchPin = 8;  //Pin connected to Pin 12 of 74HC595 (Latch)
int clockPin = 12; //Pin connected to Pin 11 of 74HC595 (Clock)
int dataPin = 11;  //Pin connected to Pin 14 of 74HC595 (Data)

void setup() {
  	//set pins to output 
pinMode(latchPin, OUTPUT);
  	pinMode(clockPin, OUTPUT);
  	pinMode(dataPin, OUTPUT);
}

void loop() {
for (int i = 0; i < 256; i++) {     //count from 0 to 255
digitalWrite(latchPin, LOW); //set latchPin low to allow data flow
shiftOut(i);  
  		shiftOut(255-i);  
//set latchPin to high to lock and send data
digitalWrite(latchPin, HIGH); 
    		delay(250 );
  	}
}

void shiftOut(byte dataOut) {
	boolean pinState; // Shift out 8 bits LSB first, on rising edge of clock

  	digitalWrite(dataPin, LOW); //clear shift register ready for sending data
  	digitalWrite(clockPin, LOW);

for (int i=0; i<=7; i++)  {  // for each bit in dataOut send out a bit
digitalWrite(clockPin, LOW); //set clockPin to LOW prior to sending bit

// if value of DataOut and (logical AND) a bitmask are true, set pinState to 1 (HIGH)
    		if ( dataOut & (1<<i) ) {
      		pinState = HIGH;
    		}
    		else {	
      			pinState = LOW;
    		}

//sets dataPin to HIGH or LOW depending on pinState
digitalWrite(dataPin, pinState); 

digitalWrite(clockPin, HIGH); //send bit out on rising edge of clock 
    		digitalWrite(dataPin, LOW);
  	}

digitalWrite(clockPin, LOW); //stop shifting
}

