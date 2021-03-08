#include <stdio.h>
#include <string.h>
#include <math.h>
#include <Wire.h> 
 
String sentPH;
String sentRPM;
String sentTemp;
 
volatile unsigned long rpmcount = 0.0;
double rpm = 0;
double timeold = 0;
   
int val;
double temp;
double pH = 7.0;

int p_pressed = 0;
double userPH;
int s_pressed = 0;
int userRPM;
int t_pressed = 0;
double userTemp;

   
const byte lightgatePin  = 2;
const byte stirrerPin    = 5;
const byte heaterPin     = 6;
const byte thermistorPin = A0;
const byte pHPin         = A1;
   
void rpm_fun(){
   rpmcount++;
}


void setup(){
  Serial.begin(9600);
  Wire.begin();
  Wire.beginTransmission(0x40);
  Wire.write(0x00);
  Wire.write(0x21);
  Wire.endTransmission();
  
  attachInterrupt(digitalPinToInterrupt(lightgatePin), rpm_fun, FALLING);
   
  pinMode(lightgatePin,  INPUT);
  pinMode(stirrerPin,    OUTPUT);
  pinMode(heaterPin,     OUTPUT);
  pinMode(thermistorPin, INPUT);
  pinMode(pHPin,         INPUT);
  
 }
 
void pH_Function(double x){
 pH = analogRead(pHPin);
 pH = pH/75;
 
 if (pH > x){ //ENTER USER VALUE HERE INSTEAD OF 5
  int ontime = 2;
  int offtime = 4095;
  Wire.beginTransmission(0x40);
  Wire.write(0x06);
  Wire.write((ontime)&(0xFF));
  Wire.write((ontime >> 8)&(0x0F));
  Wire.write((offtime)&(0xFF));
  Wire.write((offtime >> 8)&(0x0F));
  Wire.endTransmission();
  
  ontime = 1;
  offtime = 4095;
  Wire.beginTransmission(0x40);
  Wire.write(0x0A);
  Wire.write((ontime)&(0xFF));
  Wire.write((ontime >> 8)&(0x0F));
  Wire.write((offtime)&(0xFF));
  Wire.write((offtime >> 8)&(0x0F));
  Wire.endTransmission();
}
 else{
  int ontime = 1;
  int offtime = 4095;
  Wire.beginTransmission(0x40);
  Wire.write(0x06);
  Wire.write((ontime)&(0xFF));
  Wire.write((ontime >> 8)&(0x0F));
  Wire.write((offtime)&(0xFF));
  Wire.write((offtime >> 8)&(0x0F));
  Wire.endTransmission();
  
  ontime = 2;
  offtime = 4095;
  Wire.beginTransmission(0x40);
  Wire.write(0x0A);
  Wire.write((ontime)&(0xFF));
  Wire.write((ontime >> 8)&(0x0F));
  Wire.write((offtime)&(0xFF));
  Wire.write((offtime >> 8)&(0x0F));
  Wire.endTransmission();
  }
}
  
void Stirring_Function(){
   //41
   //120
   analogWrite(stirrerPin, 120);
   detachInterrupt(0);

   rpm = 30*1000/(millis() - timeold)*rpmcount;
   timeold = millis();
   rpmcount = 0;
   
   attachInterrupt(digitalPinToInterrupt(lightgatePin), rpm_fun, FALLING);
}

double Thermistor_Function(int RawADC){
   double a1 = 5*(RawADC/1023.0);
   double a2 = (10000*a1)/(5-a1);
   
   double A = -0.006319899698;
   double B = 0.001477078921;
   double C = -0.000005015991922;

   double b1 = (B*log(a2));
   double b2 = (C*pow(log(a2), 3));
   double temp1 = 1/(A+b1+b2);
   return temp1;
}
   
void Heating_Function(double x){
 val = analogRead(thermistorPin);
 temp = Thermistor_Function(val);
   
 if ((temp+1) < x){ //ENTER USER VALUE HERE INSTEAD OF 307
    analogWrite(heaterPin, 255);
 }
 else{
   analogWrite(heaterPin, 0);
 }
} 

void loop(){

   if(p_pressed == 0){
  sentPH = String(pH);
  Serial.println("p" + sentPH);
}
if(p_pressed == 1){
  pH_Function(userPH);
  sentPH = String(pH);
  Serial.println("p" + sentPH);
  Serial.println("P");
}
if(s_pressed == 0){
  sentRPM = String(rpm);
  Serial.println("s" + sentRPM);
}
if(s_pressed == 1){
  Stirring_Function();
  sentRPM = String(rpm);
  Serial.println("s" + sentRPM);
  Serial.println("S");
 } 
 if(t_pressed == 0){
   val = analogRead(thermistorPin);
   temp = Thermistor_Function(val);
   sentTemp = String(temp);
   Serial.println("t" + sentTemp);
 }
  if(t_pressed == 1){
   Heating_Function(userTemp);
   sentTemp = String(temp);
   Serial.println("t" + sentTemp);
   Serial.println("T");
 }

delay(100); 

if(Serial.available() > 0){
  String serialMessage = Serial.readString();
  char first = serialMessage[0];
  
  if(first == 'p'){
    String phString = serialMessage.substring(1);
    int ph_str_len = phString.length() + 1;
    char phCharArray[ph_str_len];
    phString.toCharArray(phCharArray, ph_str_len);
    userPH = atoi(phCharArray);
    p_pressed = 1;
    delay(100);
  } else if(first == 's'){
    String speedString = serialMessage.substring(1);
    int speed_str_len = speedString.length() + 1;
    char speedCharArray[speed_str_len];
    speedString.toCharArray(speedCharArray, speed_str_len);
    userRPM = atoi(speedCharArray);
    s_pressed = 1;
    delay(100);
  } else if (first == 't'){
    String tempString = serialMessage.substring(1);
    int temp_str_len = tempString.length() + 1;
    char tempCharArray[temp_str_len];
    tempString.toCharArray(tempCharArray, temp_str_len);
    userTemp = atoi(tempCharArray);
    t_pressed = 1;
    delay(100);
  }



//Serial.print("K,");
//Serial.println(temp);
//Serial.print(" RPM: ");
//Serial.print(rpm);
//Serial.print(",");
//Serial.print(" pH: ");
//Serial.println(pH);
 }

}
