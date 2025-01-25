import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.IOException;

// Serial communication variables
Serial myPort; 
String distance = "";
String data = "";
String noObject;
String angle = "";
float pixsDistance;
int iAngle, iDistance;
int index1 = 0;
int index2 = 0;

void setup() {
  size(1280, 720); // Set the size of the window
  smooth();
  myPort = new Serial(this, "COM3", 9600); // Initialize serial port (adjust COM port as needed)
  myPort.bufferUntil('.'); // Read data from the serial port up to the character '.'
}

void draw() {
  // Background fade effect for motion blur
  noStroke();
  fill(0, 4); 
  rect(0, 0, width, height - height * 0.065);

  // Green color for radar elements
  fill(98, 245, 31); 

  // Draw the radar system components
  drawRadar();
  drawLine();
  drawObject();
  drawText();
}

// Serial event handler
void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.'); // Read data up to '.'
  if (data != null) {
    data = data.trim(); // Remove whitespace or line endings
    index1 = data.indexOf(','); // Find the ',' delimiter
    if (index1 > 0) {
      angle = data.substring(0, index1); // Extract angle part
      distance = data.substring(index1 + 1); // Extract distance part

      // Convert extracted data to integers
      iAngle = int(angle);
      iDistance = int(distance);
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); // Center radar at the bottom of the screen
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  // Draw concentric arcs
  float[] arcRadii = {
    width - width * 0.0625,
    width - width * 0.27,
    width - width * 0.479,
    width - width * 0.687
  };

  for (float radius : arcRadii) {
    arc(0, 0, radius, radius, PI, TWO_PI);
  }

  // Draw angle lines
  for (int angle = 0; angle <= 150; angle += 30) {
    float x = (-width / 2) * cos(radians(angle));
    float y = (-width / 2) * sin(radians(angle));
    line(0, 0, x, y);
  }
  line(-width / 2, 0, width / 2, 0); // Horizontal line
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); // Center radar
  strokeWeight(9);
  stroke(255, 10, 10); // Red color for objects

  // Convert distance to pixels
  pixsDistance = iDistance * ((height - height * 0.1666) * 0.025); 

  // Draw object line if within range
  if (iDistance < 40) {
    float x1 = pixsDistance * cos(radians(iAngle));
    float y1 = -pixsDistance * sin(radians(iAngle));
    float x2 = (width - width * 0.505) * cos(radians(iAngle));
    float y2 = -(width - width * 0.505) * sin(radians(iAngle));
    line(x1, y1, x2, y2);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60); // Green color for scanning line
  translate(width / 2, height - height * 0.074); // Center radar
  float x = (height - height * 0.12) * cos(radians(iAngle));
  float y = -(height - height * 0.12) * sin(radians(iAngle));
  line(0, 0, x, y);
  popMatrix();
}

void drawText() {
  pushMatrix();

  // Determine object range status
  if (iDistance > 40) {
    noObject = "";
  } else {
    noObject = "";
  }

  // Draw background for text
  fill(0, 0, 0);
  noStroke();
  rect(0, height - height * 0.0648, width, height * 0.0648);

  // Draw range text
  fill(98, 245, 31);
  textSize(25);
  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);

  // Draw angle and distance data
  textSize(40);
  text("Angle: " + iAngle + "°", width - width * 0.48, height - height * 0.0277);
  if (iDistance < 40) {
    text(iDistance + " cm", width - width * 0.225, height - height * 0.0277);
  }
  text(noObject, width - width * 0.75, height - height * 0.0277);

  // Draw angle labels
  textSize(25);
  float[] angles = {30, 60, 90, 120, 150};
  for (float angle : angles) {
    float x = (width / 2) * cos(radians(angle));
    float y = -(width / 2) * sin(radians(angle));
    pushMatrix();
    translate(width - width * 0.5 + x, height - height * 0.08 + y);
    rotate(-radians(angle - 90));
    text((int) angle + "°", 0, 0);
    popMatrix();
  }
  popMatrix();
}
