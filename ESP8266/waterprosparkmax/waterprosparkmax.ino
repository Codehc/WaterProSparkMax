#include <FirebaseArduino.h>
#include <ESP8266WiFi.h>

#include "keys.h"

#define SIZE 4

const int AirValue = 615;
const int WaterValue = 230;
int soilMoistureValue = 0;
int smPercent = 0;
int smBuffer[SIZE] = {0, 0, 0, 0};

const char* PROFILE = "DCAFCBA7-7C2E-40B7-8E75-8A026E9B6EBE";

const int SENSOR_PIN = A0;
const int RELAY_PIN = D5;

struct Config {
  bool enabled;

  bool usingPurelyInterval;
  int interval; // ms

  int wateringThreshold; // %

  int wateringTime; // ms
} config;

void setup() {
  Serial.begin(115200);

  Serial.println("Initializing");

  pinMode(SENSOR_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);

  Serial.println("Pins configured");

  Serial.print("Connecting to ");
  Serial.print(SSID_);
  Serial.print(" ");

  WiFi.mode(WIFI_STA);

  WiFi.begin(SSID_, PSWRD); 

  int i = 0;
  while (WiFi.status() != WL_CONNECTED) { // Wait for the Wi-Fi to connect
    delay(1000);
    i++;
    Serial.print(".");
  }
  Serial.print("\nSuccessfully connected to ");
  Serial.print(SSID_);
  Serial.print(" with IP ");
  Serial.print(WiFi.localIP());
  Serial.println(" (took ");
  Serial.print(i);
  Serial.println(" seconds)");

  firebaseReconnect();
}

long int endWaterTime = millis();
bool lastOn = false;
void loop() {
  long int time = millis();

  // Query Firebase and update local config
  FirebaseObject remoteConfigGet = Firebase.get(String("/profiles/") + PROFILE);
  if (Firebase.failed()) {
      Serial.println("Firebase get failed");
      Serial.println(Firebase.error());
  } else {
    config.enabled = remoteConfigGet.getBool("enabled");
    config.usingPurelyInterval = remoteConfigGet.getBool("usingPurelyInterval");
    config.interval = remoteConfigGet.getInt("interval");
    config.wateringThreshold = remoteConfigGet.getInt("wateringThreshold");
    config.wateringTime = remoteConfigGet.getInt("wateringTime");
  }

  // Smooth out sensor value using the moving average filter
  soilMoistureValue = analogRead(SENSOR_PIN);
  smPercent = map(soilMoistureValue, AirValue, WaterValue, 0, 100);

  push(smBuffer, SIZE, smPercent);

  int avgSmPercent = avg(smBuffer, SIZE);

  //Serial.println(avgSmPercent);
  
  // Millis to seconds
  if (config.usingPurelyInterval) {
    if (time - endWaterTime >= config.interval) {
      endWaterTime = time + config.wateringTime;
    }
  } else {
    if (time - endWaterTime >= config.interval && avgSmPercent >= config.wateringThreshold) {
      endWaterTime = time + config.wateringTime;
    }
  }

  if (!config.enabled || time > endWaterTime) {
    digitalWrite(RELAY_PIN, LOW);
    lastOn = false;
  } else if (time <= endWaterTime) {
    digitalWrite(RELAY_PIN, HIGH);
    lastOn = true;
  }
  
  delay(250);
}

// Function to take the average value of an array of integers
// used in our moving average filter
int avg(int *array, int size) {
    int total = 0;
    for (int i = 0; i < size; i++) {
        total += array[i];
    }
    return total / size;
}

// Function to shift contents of array 1 to the "left"
void shift(int *array, int size) {
    int tmp[5];
    for (int i = size - 1; i > 0; i--) {
        tmp[i - 1] = array[i];
    }

    for (int i = 0; i < size; i++) {
        array[i] = tmp[i];
    }
}

// Shifts array to the left and then adds a value to the end
void push(int *array, int size, int value) {
    shift(array, size);

    array[size - 1] = value;
}

void printArray(int * array, int size) {
    for (int i = 0; i < size; i++) {
        printf("%i, ", array[i]);
    }
    printf("\n");
}

void firebaseReconnect() {
  Serial.println("Initializing Firebase connection");
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Serial.println("Firebase done initializing");
}

void printConfig(Config *config) {
  Serial.println("Config:");
  Serial.println(" - Using Purely Interval: " + String(config->usingPurelyInterval));
  Serial.println(" - Interval: " + String(config->interval));
  Serial.println(" - Watering Threshold: " + String(config->wateringThreshold));
  Serial.println(" - Watering Time: " + String(config->wateringTime));
}