#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>
#include <ESP32Servo.h>

// =====================================
// PINES DE ENERGIA EXTRA POR CODIGO
// =====================================
#define PIN_3V3_SUELO 1
#define PIN_3V3_DHT 2
#define PIN_GND_DHT 7

// =====================================
// PINES DE SENSORES Y ACTUADORES
// =====================================
#define PIN_DHT 4
#define TIPO_DHT DHT11
#define PIN_BOMBA 5
#define PIN_SUELO 6
#define SDA_PIN 8
#define SCL_PIN 9
#define PIN_SERVO 13

// =====================================
// CONFIGURACION WIFI Y MQTT (INTERNET)
// =====================================
const char* ssid = "Gregory";
const char* password = "0967673422";

const char* mqtt_server = "broker.hivemq.com";
const char* mqtt_topic = "utmach/raizsmart/datos";

// =====================================
// CONTROL PARA SERVO CONTINUO (360°)
// =====================================
const int SERVO_GIRAR_ABRIR = 130; // Gira para abrir/desplegar
const int SERVO_GIRAR_CERRAR = 50; // Gira para cerrar/recoger
const unsigned long TIEMPO_GIRO_TECHO = 800; // Milisegundos de recorrido

// =====================================
// OBJETOS Y CLIENTE MQTT
// =====================================
DHT dht(PIN_DHT, TIPO_DHT);
LiquidCrystal_I2C lcd(0x27, 16, 2);
WiFiClient espClient;
PubSubClient client(espClient);
Servo techoServo;

int humedadSuelo = 0;
float temperatura = 28.0;
float humedadAmbiente = 60.0;

bool bombaEncendida = false;
bool techoAbierto = false;
unsigned long inicioRiego = 0;
const unsigned long DURACION_RIEGO = 5000;
unsigned long ultimoEnvioMQTT = 0;

byte iconoGota[] = {0b00100,0b00100,0b01010,0b01010,0b10001,0b10001,0b10001,0b01110};
byte iconoTermometro[] = {0b00100,0b01010,0b01010,0b01110,0b01110,0b11111,0b11111,0b01110};
byte iconoPlanta[] = {0b00100,0b10101,0b01110,0b00100,0b00100,0b11111,0b01110,0b01110};
byte iconoNube[] = {0b00000,0b00000,0b01110,0b11111,0b11111,0b00000,0b01010,0b00101};

void detenerServoTotal() {
  techoServo.detach();
  pinMode(PIN_SERVO, OUTPUT);
  digitalWrite(PIN_SERVO, LOW); // Frena el motor poniendo 0V reales
}

void moverTecho(int direccionGiro) {
  techoServo.attach(PIN_SERVO, 500, 2400);
  techoServo.write(direccionGiro);
  delay(TIEMPO_GIRO_TECHO);
  detenerServoTotal();
}

void publicarDatosMQTT() {
  if (!client.connected()) return;

  String estadoTecho = techoAbierto ? "ABIERTO" : "CERRADO";

  String json = "{";
  json += "\"humedad_suelo\":" + String(humedadSuelo) + ",";
  json += "\"temperatura\":" + String(temperatura, 1) + ",";
  json += "\"humedad_amb\":" + String((int)humedadAmbiente) + ",";
  json += "\"bomba\":" + String(bombaEncendida ? "true" : "false") + ",";
  json += "\"techo\":\"" + estadoTecho + "\"";
  json += "}";

  client.publish(mqtt_topic, json.c_str());
  Serial.println("MQTT enviado -> " + json);
}

void reconectarMQTT() {
  if (!client.connected()) {
    String clientId = "ESP32_RaizSmart_" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("Conectado a MQTT!");
    } else {
      Serial.print("Fallo MQTT, rc=");
      Serial.println(client.state());
    }
  }
}

void animacionInicial() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("SISTEMA DE RIEGO");
  for (int i = 0; i != 16; i++) {
    lcd.setCursor(i, 1);
    lcd.write(byte(255));
    delay(100);
  }
  delay(200);
  lcd.clear();
}

void setup() {
  Serial.begin(115200);

  pinMode(PIN_3V3_SUELO, OUTPUT);
  digitalWrite(PIN_3V3_SUELO, HIGH);
  pinMode(PIN_3V3_DHT, OUTPUT);
  digitalWrite(PIN_3V3_DHT, HIGH);
  pinMode(PIN_GND_DHT, OUTPUT);
  digitalWrite(PIN_GND_DHT, LOW);

  pinMode(PIN_BOMBA, OUTPUT);
  digitalWrite(PIN_BOMBA, HIGH);

  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  techoServo.setPeriodHertz(50);
  detenerServoTotal();

  delay(500);
  dht.begin();

  Wire.begin(SDA_PIN, SCL_PIN);
  lcd.init();
  lcd.backlight();
  lcd.createChar(0, iconoGota);
  lcd.createChar(1, iconoTermometro);
  lcd.createChar(2, iconoPlanta);
  lcd.createChar(3, iconoNube);

  animacionInicial();

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  lcd.setCursor(0, 0);
  lcd.print("Conectando WiFi");
  unsigned long inicioWiFi = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - inicioWiFi < 15000) {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  lcd.setCursor(0, 0);
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi conectado!");
    lcd.print("WIFI CONECTADO");
    lcd.setCursor(0, 1);
    lcd.print("MQTT LISTO");
  } else {
    Serial.println("\nNo se pudo conectar al WiFi");
    lcd.print("SIN WIFI/INTERNET");
  }
  delay(2500);
  lcd.clear();

  client.setServer(mqtt_server, 1883);
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    if (!client.connected()) {
      reconectarMQTT();
    }
    client.loop();
  }

  int lectura = analogRead(PIN_SUELO);
  humedadSuelo = constrain(map(lectura, 4095, 1500, 0, 100), 0, 100);

  float t = dht.readTemperature();
  float h = dht.readHumidity();
  if (!isnan(t)) temperatura = t;
  if (!isnan(h)) humedadAmbiente = h;

  // Control automático de bomba
  if (humedadSuelo >= 40) {
    if (bombaEncendida) {
      digitalWrite(PIN_BOMBA, HIGH);
      bombaEncendida = false;
    }
  } else {
    if (!bombaEncendida) {
      digitalWrite(PIN_BOMBA, LOW);
      bombaEncendida = true;
      inicioRiego = millis();
    }
    if (bombaEncendida && millis() - inicioRiego >= DURACION_RIEGO) {
      digitalWrite(PIN_BOMBA, HIGH);
      bombaEncendida = false;
    }
  }

  // Lógica del techo: >= 30.0°C -> ABIERTO y quieto en 0V | <= 29.0°C -> CERRADO y quieto en 0V
  if (temperatura >= 30.0) {
    if (!techoAbierto) {
      moverTecho(SERVO_GIRAR_ABRIR);
      techoAbierto = true;
    }
  } else if (temperatura <= 29.0) {
    if (techoAbierto) {
      moverTecho(SERVO_GIRAR_CERRAR);
      techoAbierto = false;
    }
  }

  // Publicar datos cada 25 segundos hacia tu pagina web
  if (millis() - ultimoEnvioMQTT >= 25000) {
    ultimoEnvioMQTT = millis();
    publicarDatosMQTT();
  }

  lcd.setCursor(0, 0);
  lcd.write(byte(0));
  lcd.print("H:");
  lcd.print(humedadSuelo);
  lcd.print("% ");
  lcd.write(byte(1));
  lcd.print(temperatura, 1);
  lcd.print("C  ");

  lcd.setCursor(0, 1);
  if (bombaEncendida) {
    lcd.write(byte(2));
    lcd.print(" REGANDO PLANTA");
  } else if (techoAbierto) {
    lcd.write(byte(3));
    lcd.print(" TECHO ABIERTO  ");
  } else {
    lcd.write(byte(3));
    lcd.print(" HUM. AMB: ");
    lcd.print((int)humedadAmbiente);
    lcd.print("%  ");
  }

  delay(200);
}