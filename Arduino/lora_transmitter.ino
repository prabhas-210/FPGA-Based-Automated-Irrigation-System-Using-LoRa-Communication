#include <SoftwareSerial.h>

SoftwareSerial lora(3, 2); // RX, TX

int number = 125;  // Your numeric data

void setup() {
  Serial.begin(9600);
  lora.begin(9600);

  delay(1000);
  Serial.println("Transmitter Ready");
}

void loop() {

  String data = String(number);   // Convert number to string

  String command = "AT+SEND=2," + String(data.length()) + "," + data;

  lora.println(command);

  Serial.println("Sent: " + data);

  delay(3000);
}
