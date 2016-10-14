// Project 19
#include <TimerOne.h>

int latchPin = 8; //Pin connected to Pin 12 of 74HC595 (Latch)
int clockPin = 12; //Pin connected to Pin 11 of 74HC595 (Clock)
int dataPin = 11; //Pin connected to Pin 14 of 74HC595 (Data)

byte led[8];  // 8 element unsigned integer array to store the sprite

void setup() {
        pinMode(latchPin, OUTPUT);  // set the 3 digital pins to outputs
        pinMode(clockPin, OUTPUT);
        pinMode(dataPin, OUTPUT);
        led[0] = B11111111;  // enter the binary representation of the image
        led[1] = B10000001;  // into the array
        led[2] = B10111101;
        led[3] = B10100101;
        led[4] = B10100101;
        led[5] = B10111101;
        led[6] = B10000001;
        led[7] = B11111111;
        // set a timer of length 10000 microseconds (1/100th of a second)
        Timer1.initialize(10000); 
        // attach the screenUpdate function to the interrupt timer
        Timer1.attachInterrupt(screenUpdate); 
}

void loop() {
        for (int i=0; i<8; i++) {
                led[i]= ~led[i]; // invert each row of the binary image
        }
        delay(500);
}

void screenUpdate() { // function to display image
        byte row = B10000000; // row 1
        for (byte k = 0; k < 9; k++) {
                digitalWrite(latchPin, LOW); // open latch ready to receive data
        shiftIt(~led[k] ); // shift out the LED array (inverted)
        shiftIt(row ); // shift out row binary number 

        // Close the latch, sending the data in the registers out to the matrix
        digitalWrite(latchPin, HIGH);     
        row = row << 1; // bitshift left
        }
}

void shiftIt(byte dataOut) {    // Shift out 8 bits LSB first, on rising edge of clock

        boolean pinState; 
        digitalWrite(dataPin, LOW); //clear shift register read for sending data

        for (int i=0; i<8; i++)  {    // for each bit in dataOut send out a bit
                digitalWrite(clockPin, LOW); //set clockPin to LOW prior to sending bit

                // if the value of DataOut and (logical AND) a bitmask
                // are true, set pinState to 1 (HIGH)
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
