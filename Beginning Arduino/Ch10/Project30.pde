// Project 30 - Line Following Robot

#define lights 9
int LDR1, LDR2, LDR3; // sensor values

// calibration offsets
int leftOffset = 0, rightOffset = 0, centre = 0;
// pins for motor speed and direction
int speed1 = 3, speed2 = 11, direction1 = 12, direction2 = 13;
// starting speed and rotation offset
int startSpeed = 70, rotate = 30;
// sensor threshold
int threshhold = 5;
// initial speeds of left and right motors
int left = startSpeed, right = startSpeed;

// Sensor calibration routine
void calibrate() {

  for (int x=0; x<10; x++) { // run this 10 times to obtain average
  digitalWrite(lights, HIGH); // lights on
  delay(100);
  LDR1 = analogRead(0); // read the 3 sensors
  LDR2 = analogRead(1);
  LDR3 = analogRead(2);
  leftOffset = leftOffset + LDR1; // add value of left sensor to total
  centre = centre + LDR2; // add value of centre sensor to total
  rightOffset = rightOffset + LDR3; // add value of right sensor to total
  
  delay(100);
  digitalWrite(lights, LOW); // lights off
  delay(100);
  }
  // obtain average for each sensor
  leftOffset = leftOffset / 10; 
  rightOffset = rightOffset / 10;
  centre = centre /10;  
  // calculate offsets for left and right sensors
  leftOffset = centre - leftOffset;
  rightOffset = centre - rightOffset;
  }

void setup()
{
    // set the motor pins to outputs
    pinMode(lights, OUTPUT); // lights
    pinMode(speed1, OUTPUT); 
    pinMode(speed2, OUTPUT);
    pinMode(direction1, OUTPUT);
    pinMode(direction2, OUTPUT);
    // calibrate the sensors
    calibrate();
    delay(3000);
    
    digitalWrite(lights, HIGH); // lights on
    delay(100);
    
    // set motor direction to forward
    digitalWrite(direction1, HIGH);  
    digitalWrite(direction2, HIGH); 
    // set speed of both motors
    analogWrite(speed1,left); 
    analogWrite(speed2,right);
}

void loop() {
  
  // make both motors same speed
  left = startSpeed;
  right = startSpeed;

  // read the sensors and add the offsets
  LDR1 = analogRead(0) + leftOffset;
  LDR2 = analogRead(1);
  LDR3 = analogRead(2) + rightOffset;
  
  // if LDR1 is greater than the centre sensor + threshold turn right
  if (LDR1 > (LDR2+threshhold)) {
    left = startSpeed + rotate;
    right = startSpeed - rotate; 
  } 
  
  // if LDR3 is greater than the centre sensor + threshold turn left
  if (LDR3 > (LDR2+threshhold)) {
    left = startSpeed - rotate;
    right = startSpeed + rotate; 
  }
    // send the speed values to the motors
    analogWrite(speed1,left); 
    analogWrite(speed2,right);
}

