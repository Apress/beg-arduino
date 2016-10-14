// Project 20
#include <TimerOne.h>

int latchPin = 8; //Pin connected to Pin 12 of 74HC595 (Latch)
int clockPin = 12; //Pin connected to Pin 11 of 74HC595 (Clock)
int dataPin = 11; //Pin connected to Pin 14 of 74HC595 (Data)
byte frame = 0;  // variable to store the current frame being displayed

byte led[8][8] = { {0, 56, 92, 158, 158, 130, 68, 56}, // 8 frames of an animation
                      {0, 56, 124, 186, 146, 130, 68, 56},
                      {0, 56, 116, 242, 242, 130, 68, 56},
                      {0, 56, 68, 226, 242, 226, 68, 56},
                      {0, 56, 68, 130, 242, 242, 116, 56},
                      {0, 56, 68, 130, 146, 186, 124, 56},
                      {0, 56, 68, 130, 158, 158, 92, 56},
                      {0, 56, 68, 142, 158, 142, 68, 56} };

void setup() {
        pinMode(latchPin, OUTPUT);  // set the 3 digital pins to outputs
        pinMode(clockPin, OUTPUT);
        pinMode(dataPin, OUTPUT);

        Timer1.initialize(10000); // set a timer of length 10000 microseconds 
        Timer1.attachInterrupt(screenUpdate); // attach the screenUpdate function
}

void loop() {
        for (int i=0; i<8; i++) { // loop through all 8 frames of the animation
                for (int j=0; j<8; j++) { // loop through the 8 rows per frame
                        led[i][j]= led[i][j] << 1 | led[i][j] >> 7; // bitwise rotation
                }
        }
        frame++; // go to the next frame in the animation
        if (frame>7) { frame =0;} // make sure we go back to frame 0 once past 7
        delay(100); // wait a bit between frames
}

void screenUpdate() { // function to display image
        byte row = B10000000; // row 1
        for (byte k = 0; k < 9; k++) {
          digitalWrite(latchPin, LOW); // open latch ready to receive data

                shiftIt(~led[frame][k] ); // LED array (inverted)
                shiftIt(row); // row binary number

                // Close the latch, sending the data in the registers out to the matrix
                digitalWrite(latchPin, HIGH);
                row = row >> 1; // bitshift right
        }
}

void shiftIt(byte dataOut) {
        // Shift out 8 bits LSB first, on rising edge of clock

        boolean pinState; 

        //clear shift register read for sending data
        digitalWrite(dataPin, LOW);

        // for each bit in dataOut send out a bit
        for (int i=0; i<8; i++)  {
                //set clockPin to LOW prior to sending bit
                digitalWrite(clockPin, LOW);

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
                //send bit out on rising edge of clock 
                digitalWrite(clockPin, HIGH);
                digitalWrite(dataPin, LOW);
        }

digitalWrite(clockPin, LOW); //stop shifting
}
