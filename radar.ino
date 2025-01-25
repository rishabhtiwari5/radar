#include <Servo.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

const int trigPin = 2;
const int echoPin = 3;
const int buzzerPin = 10;
const int ledPin = 4; // LED connected to pin 4

// defining time and distance
long duration;
int distance;
int lastAngle = -1;  // To store the last valid angle displayed
Servo myServo; // Object servo
LiquidCrystal_I2C lcd(0x27, 16, 2); // Create an LCD object for I2C (adjust address if necessary)

void setup() {
  pinMode(trigPin, OUTPUT); // trigPin as an Output
  pinMode(echoPin, INPUT);  // echoPin as an Input
  pinMode(buzzerPin, OUTPUT); // buzzer as an Output
  pinMode(ledPin, OUTPUT); // LED as an Output

  Serial.begin(9600);
  myServo.attach(9); // Pin Connected To Servo

  lcd.begin(16, 2); // Initialize the LCD with 16 columns and 2 rows
  lcd.setBacklight(true); // Turn on the backlight
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Initializing...");
  delay(2000);
  lcd.clear();
}

void loop() {
  static bool forward = true;  // Tracks the direction of servo movement
  static int angle = 0;        // Tracks the current angle of the servo

  // Move the servo based on the current direction
  if (forward) {
    angle++;  // Increment the angle
    if (angle >= 180) {
      forward = false;  // Change direction to backward when the max angle is reached
    }
  } else {
    angle--;  // Decrement the angle
    if (angle <= 0) {
      forward = true;  // Change direction to forward when the min angle is reached
    }
  }

  myServo.write(angle);       // Move servo to the current angle
  delay(30);                  // Small delay for smooth servo motion

  distance = calculateDistance(); // Measure distance
  
  // Update LCD and Buzzer/LED
  updateLCD(angle, distance);
  handleBuzzerAndLED(distance);

  // Debugging output
  Serial.print(angle);
  Serial.print(",");
  Serial.print(distance);
  Serial.println(".");
}

int calculateDistance() { 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 microseconds
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH); 
  distance = duration * 0.034 / 2;
  return distance;
}

void handleBuzzerAndLED(int distance) {
  if (distance > 0 && distance <= 50) { // Assuming an object is detected within 20 cm
    digitalWrite(buzzerPin, HIGH);
    digitalWrite(ledPin, LOW); // Turn OFF LED
    delay(200);
    digitalWrite(buzzerPin, LOW);
    delay(200);
  } else {
    digitalWrite(buzzerPin, LOW);
    digitalWrite(ledPin, HIGH); // Turn ON LED
  }
}

void updateLCD(int angle, int distance) {
  // Update first row for angle
  lcd.setCursor(0, 0);
  
  if (angle % 15 == 0) {  // Update angle only if it's a multiple of 15
    lcd.print("Angle: ");
    lcd.print(angle);
    lastAngle = angle; // Store the current angle
  } else {
    // If angle is not a multiple of 15, keep the last valid multiple of 15
    lcd.print("Angle:");
    lcd.print(lastAngle);  // Display the last valid angle
  }

  // Clear any leftover characters (in case angle is less than 100)
  lcd.print("   ");  // Clear extra spaces for previous angle digits

  // Update second row for detection status
  lcd.setCursor(0, 1);
  lcd.print("OBJ DETECTED:");  // Fixed part of the second row
  
  // Clear last three cells before updating YES/NO
  lcd.setCursor(13, 1);  // Position the cursor at the last 3 characters
  lcd.print("   ");  // Clear the last three characters

  // Now update with YES or NO based on distance
  if (distance > 0 && distance <= 50) {
    lcd.setCursor(13, 1);
    lcd.print("YES");  // Object detected within 20 cm
  } else {
    lcd.setCursor(13, 1);
    lcd.print("NO ");  // No object detected
  }
}
