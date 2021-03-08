import controlP5.*;
import processing.serial.*;

Serial port;
ControlP5 cp5;   // ControlP5 object
int myColor = color(0,0,0);
float addedTemp;

int buttonPressed = 0;
int underTemp = 0;

Textlabel currentTemp, currentRPM, currentPH;
PrintWriter output;
float Temperature_Slider = 298;
int Speed_Slider = 1500;
float pH_Slider = 5.0;
float phValue;
float rpmValue;
float tempValue;

int tempButtonPressed = 1;
int rpmButtonPressed = 1;
int phButtonPressed = 1;


Chart tempChart, speedChart, phChart;

void setup(){
  size(700,700);
  noStroke();
  cp5 = new ControlP5(this);
  port = new Serial(this, "/tmp/simavr-uart0", 9600);
  
  output = createWriter("file.txt");
  
  cp5.addSlider("Temperature_Slider")
    .setPosition(50,50)
    .setSize(200,50)
    .setRange(298, 308);
    
  cp5.addButton("temperature")
    .setValue(0)
    .setPosition(450,50)
    .setSize(100,50);
    
  
  cp5.addSlider("Speed_Slider")
    .setPosition(50,150)
    .setSize(200,50)
    .setRange(500,1500);
    
  cp5.addButton("speed")
    .setValue(0)
    .setPosition(450,150)
    .setSize(100,50);
    
  cp5.addSlider("pH_Slider")
    .setPosition(50,250)
    .setSize(200,50)
    .setRange(3,7);
    
  cp5.addButton("pH")
    .setValue(0)
    .setPosition(450,250)
    .setSize(100,50);
    
   currentTemp = cp5.addTextlabel("label")
    .setPosition(600,75)
    .setColorValue(0xffffff00);
    
    currentRPM = cp5.addTextlabel("label1")
      .setPosition(600, 175)
      .setColorValue(0xffffff00);
      
    currentPH = cp5.addTextlabel("label2")
      .setPosition(600,275)
      .setColorValue(0xffffff00);
      
    tempChart = cp5.addChart("Temperature (290 - 310 K)")
      .setPosition(50,350)
      .setSize(150,150)
      .setRange(290,320)
      .setView(Chart.LINE);
    tempChart.getColor().setBackground(color(255,100));
    tempChart.addDataSet("tempDataSet");
    tempChart.setColors("tempDataSet", color(255));
    tempChart.setData("tempDataSet", new float[10]);
    tempChart.setStrokeWeight(1.5);
    
    speedChart = cp5.addChart("RPM (0 - 1500 RPM)")
      .setPosition(220, 350)
      .setSize(150,150)
      .setRange(0,1500)
      .setView(Chart.LINE);
    speedChart.getColor().setBackground(color(255,100));
    speedChart.addDataSet("speedDataSet");
    speedChart.setColors("speedDataSet", color(255));
    speedChart.setData("speedDataSet", new float[10]);
    speedChart.setStrokeWeight(1.5);
    
    phChart = cp5.addChart("pH (3 - 7 pH)")
      .setPosition(390,350)
      .setSize(150,150)
      .setRange(3,7)
      .setView(Chart.LINE);
    phChart.getColor().setBackground(color(255,100));
    phChart.addDataSet("phDataSet");
    phChart.setColors("phDataSet", color(255));
    phChart.setData("phDataSet", new float[10]);
    phChart.setStrokeWeight(1.5);  
}

void draw(){
  text("Bioreactor" , 270, 50);
  background(0,0,0);
  
  while(port.available() > 0){
    String s = port.readStringUntil('\n');
    if(s != null){
    //println("String s: " + s);
    char[] ca = s.toCharArray();
    char first = ca[0];
    //println("First: " + first);
    String valueString = s.substring(1);
  //  println("ValueString :" + valueString);
    
    if(first == 't'){
      tempValue = float(valueString);
      if(underTemp == 0){
        currentTemp.setText(valueString + "K");
        tempChart.addData("tempDataSet", tempValue);
      if(tempChart.getDataSet("tempDataSet").size() > 10){
        tempChart.removeData("tempDataSet", 0);
        }
      }
      if(tempValue > Temperature_Slider -1){
        underTemp = 1;
      }
      if(underTemp == 1){
        if(tempValue > Temperature_Slider -1.5 && tempValue < Temperature_Slider+1.5){
          currentTemp.setText(valueString + "K");
          tempChart.addData("tempDataSet", tempValue);
          if(tempChart.getDataSet("tempDataSet").size() > 10){
            tempChart.removeData("tempDataSet", 0);
          }
        }
      }
      //if(buttonPressed == 0){
      //addedTemp = random(291, 293);
      //currentTemp.setText(addedTemp + "K");
      //tempChart.addData("tempDataSet", addedTemp);
      //if(tempChart.getDataSet("tempDataSet").size() > 10){
      //  tempChart.removeData("tempDataSet", 0);
      //}}
      //else if(buttonPressed == 1){
      //  for(int i = 0; i<10; i++){
      //    addedTemp = random(292 + i, 293 + i);
      //    currentTemp.setText(addedTemp + "K");
      //    tempChart.addData("tempDataSet", addedTemp);
      //    if(tempChart.getDataSet("tempDataSet").size() > 10){
      //      tempChart.removeData("tempDataSet", 0);
      //    }
      //    buttonPressed = 2;
      //  }
      //}
      //else if(buttonPressed == 2){
      //  addedTemp = random(302.5, 303.5);
      //  currentTemp.setText(addedTemp + "K");
      //  tempChart.addData("tempDataSet", addedTemp);
      //  if(tempChart.getDataSet("tempDataSet").size() > 10){
      //      tempChart.removeData("tempDataSet", 0);
      //    }
      //}
    }
    else if (first == 's'){
      rpmValue = float(valueString);
      currentRPM.setText(valueString + "RPM");
      speedChart.addData("speedDataSet", rpmValue);
      if(speedChart.getDataSet("speedDataSet").size() > 10){
        speedChart.removeData("speedDataSet", 0);
      }
      //output.print("S: "+ valueString + "RPM  ");
    }
    else if( first == 'p'){
      phValue = float(valueString);
      currentPH.setText(valueString + "pH");
      phChart.addData("phDataSet", phValue);
      if(phChart.getDataSet("phDataSet").size() > 10){
        phChart.removeData("phDataSet", 0);
      }
     // output.println("P: " + valueString + "pH");
    }
    else if(first == 'T' || first == 'P' || first == 'S'){
      println(first);
    }
  }}
  output.println("T: " + tempValue + "K\tS: " + rpmValue + "RPM\tP: " + phValue + "pH");
}

void keyPressed(){
  if(key == 's' || key == 'S'){
  output.flush();
  output.close();
  exit();
  }
  //if(key == 't' || key == 'T'){
  //  buttonPressed = 1;
  //}
}

void temperature(){
  if (tempButtonPressed == 1){
    tempButtonPressed++;
  } else{
  println("Temperature: " + Temperature_Slider);
  port.write("t" + Temperature_Slider);
  }
}

void speed(){
  if(rpmButtonPressed == 1){
    rpmButtonPressed++;
  } else{
  println("RPM: " + Speed_Slider);
  port.write("s" + Speed_Slider);
  }
}

void pH(){
  if(phButtonPressed == 1){
    phButtonPressed++;
  } else{
  println("pH: " + pH_Slider);
  port.write("p" + pH_Slider);
  }
}
