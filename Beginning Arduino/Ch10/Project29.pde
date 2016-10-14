// Project 29 - Using a motor shield

// Set the pins for speed and direction of each motor
int speed1 = 3;  
int speed2 = 11;  
int direction1 = 12; 
int direction2 = 13;

void stopMotor() {
  // turn both motors off
  analogWrite(speed1, 0);  
  analogWrite(speed2, 0);
}

void setup()
{
  // set all the pins to outputs
  pinMode(speed1, OUTPUT);  
  pinMode(speed2, OUTPUT);
  pinMode(direction1, OUTPUT);
  pinMode(direction2, OUTPUT);
}

void loop()
{
  // Both motors forwaard at 50% speed for 2 seconds
  digitalWrite(direction1, HIGH); 
  digitalWrite(direction2, HIGH);  
  analogWrite(speed1,128);  
  analogWrite(speed2,128);
  delay(2000);
  
  stopMotor(); delay(1000); // stop
  
  // Left turn for 1 second
  digitalWrite(direction1, LOW); 
  digitalWrite(direction2, HIGH);  
  analogWrite(speed1, 128);  
  analogWrite(speed2, 128);
  delay(1000);
  
  stopMotor(); delay(1000); // stop
  
  // Both motors forward at 50% speed for 2 seconds
  digitalWrite(direction1, HIGH);  
  digitalWrite(direction2, HIGH);  
  analogWrite(speed1,128);  
  analogWrite(speed2,128);
  delay(2000);
  
  stopMotor(); delay(1000); // stop
  
  // rotate right at 25% speed
  digitalWrite(direction1, HIGH); 
  digitalWrite(direction2, LOW);  
  analogWrite(speed1, 64);  
  analogWrite(speed2, 64);
  delay(2000);

  stopMotor(); delay(1000); // stop

}

