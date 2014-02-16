int brightness = 0;
int fadeAmount = 15;

//0 - in active
//1 - analog in
//2 - digital in
//3 - analog out
//4 - digital out

int DM[14];
int AM[6];
String DS[14];
String AS[6];
int A[6];
int D[14];
void monitor_setup(){
  for(int i=0; i<6; i++){
    AM[i] = 0;
    AS[i] = "";
  }
  for(int i=0; i<14; i++){
    DM[i] = 0;
    DS[i] = "";
  }
  //modes
  AM[1] = 1;
  DM[5] = 3;
  DM[6] = 2;
  DM[13] = 3;
  DM[7] = 4;
}

void setup()  {
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(5, OUTPUT);

  monitor_setup();
}

void loop()  {
  monitor_start();
  //--------------------------
  //Operations
  int analog_in = analogRead(1);
  int percent = analog_in / 1023.0 * 100;
  AS[1] += " (" + String(percent) + "%)";
  //
  int analog_in_value_mapped = map(analog_in, 0, 1023, 0, 255);
  analogWrite(5, analog_in_value_mapped);
  D[5] = analog_in_value_mapped;
  DS[5] += " (" + String(percent) + "%)";

  if(analog_in == 0){
    analogWrite(13, 0);
    D[13] = 0;
    DS[13] += " (Off)";

    digitalWrite(7, LOW);
    DS[7] += " (Low)";
    DS[6] += " (Low)";
  }
  else{
    brightness = brightness + fadeAmount;
    if (brightness <= 0 || brightness >= 255) {
      fadeAmount = -fadeAmount;
    }
    analogWrite(13, brightness);
    D[13] = brightness;
    DS[13] += " (" +String(fadeAmount)+ ")";

    digitalWrite(7, HIGH);
    DS[7] += " High";
    DS[6] += " (High)";
  }
  //--------------------------
  monitor_end();
}

void monitor_start(){
  DS[5] = "Blue LED Indicating A1";
  DS[13] = "Red LED Fading";
  DS[7] = "Indicating D13";
  AS[1] = "Potentiometer";
  DS[6] = "Connected with D7";
  //analog in 0-1023
  for (int i=0; i<6; i++)
    A[i] = analogRead(i);

  //digital in 0 / 1
  for (int i=0; i<14; i++)
    D[i] = digitalRead(i);
}

void monitor_end(){
  String serial_print_string = "";
  //analog in 0-1023
  for (int i=0; i<6; i++){
    serial_print_string += String(A[i])+String(AM[i])+"@"+String(AS[i]) + ",";
  }

  //digital in 0 / 1
  for (int i=0; i<14; i++){
    serial_print_string += String(D[i])+String(DM[i])+"@"+String(DS[i]);
    if(i != 13) serial_print_string += ",";
    else serial_print_string += ";";
  }

  Serial.print(serial_print_string); 
  delay(10);
}






