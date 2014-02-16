import processing.serial.*;

Serial port;
char val;
float xPos;
int nGraph = 4;
int bkgColor = #000000;
int fgdColor = #FFFFFF;
int white = #FFFFFF;
int green = #7FFF00;
int red = #D9210D;
int blue = #00BFFF;
int yellow = #ffff00;
int lightGray = #EEEEEE;
int mediumGray = #CCCCCC;
int darkGray = #888888;

final static int gapx = 25;
final static int gapx2 = gapx*2;
final static int gapy = 15;
final static int gapy2 = gapy*2;

final static int w_width = 1200 + gapx;
final static int w_height = 800 + gapy;
final static int g_width = 1200;
final static int g_height = 800 - gapy2;

SData[] ios;

SData[] init_IOs() {
  SData[] ios = new SData[20];
  for (int i=0; i<ios.length; i++) {
    if (i<=5) {
      ios[i] = new SData("Analog-" + i, 1023);
    }
    else
      ios[i] = new SData("Digital-" + (i-6), 1);
  }
  return ios;
}

class SData {
  public String name;
  public String mode = "In";
  public String msg = "";
  public int lineColor = fgdColor;
  public float lineWidth = 2;
  private int[] data;
  public int head = -1;
  public int maxVal = 1023;
  public final int defaultMaxVal;
  public final static int maxLength = 500;

  public final static int signalPeriod = 10;//ms
  public final static int nXAxis = 40;
  public final static int period = signalPeriod*maxLength/nXAxis;

  public SData(String name, int defaultMaxVal) {
    this.name = name;
    this.defaultMaxVal = defaultMaxVal;
    data = new int[maxLength];
  }

  public void push(int new_data) {
    head ++;
    if (head == maxLength) head = 0;
    data[head] = new_data;
  }

  public int top() {
    return data[head];
  }

  public int get(int i) {
    return data[i];
  }
}

int look_for_port(String portName) {
  int portIndex = -1;
  for (int i=0; i<Serial.list().length; i++) {
    println(Serial.list()[i]);
    if (Serial.list()[i].compareTo(portName) == 0)
      portIndex = i;
  }
  return portIndex;
}

void setup()
{
  size(w_width, w_height);
  background(bkgColor);
  //frameRate(200);
  smooth();
  frame.setTitle("Serial Port Visualization for Arduino - Fan Du @ University of Maryland, 2014");
  xPos = width;
  ios = init_IOs();

  int portIndex = look_for_port("/dev/tty.usbmodem1421");
  if (portIndex == -1) {
    println("Serial port not found");
    exit();
  }
  else {
    println("Connecting to " + Serial.list()[portIndex]);
    port = new Serial(this, Serial.list()[portIndex], 9600);
  }

  new DataThread().start();
}

int[] strings_to_ingeters(String[] strings) {
  int[] integers = new int[strings.length];
  for (int i=0; i<strings.length; i++) {
    String[] splits = strings[i].split("@");
    integers[i] = Integer.parseInt(splits[0]);
    if (splits.length == 2)
      ios[i].msg = splits[1];
    else
      ios[i].msg = "";
  }
  return integers;
}

void draw_text(String s, float x, float y, int fontSize, int fontColor, int leftJustified) {
  fill(fontColor);
  textSize(fontSize);
  if (leftJustified == 0)
    textAlign(LEFT, TOP);
  else if (leftJustified == 1)
    textAlign(RIGHT, TOP);
  else if (leftJustified == 2)
    textAlign(CENTER, TOP);
  text(s, x, y);
}

//, float v0, float v1, int n
void draw_x_axis(float x0, float x1, float y0, float y1) {
  int n = 4;
  int nd = SData.nXAxis;
  float step = (y1-y0)/n;
  float yy=y0;
  for (int i=0; i<=n; i++) {
    if (i==n/2)
      dottedLine(x0, yy, x1, yy, nd, 1, lightGray);
    else
      dottedLine(x0, yy, x1, yy, nd, 0.5, mediumGray);

    yy+=step;
  }
}

void draw_y_axis(float x0, float x1, float y0, float y1) {
  int n = SData.nXAxis;
  int nd = 4;
  float step = (x1-x0)/n;
  float xx=x0;
  for (int i=0; i<=n; i++) {
    if (i==0 || i==n || i==n/2)
      dottedLine(xx, y0, xx, y1, nd, 1, lightGray);
    else
      dottedLine(xx, y0, xx, y1, nd, 0.5, mediumGray);

    xx+=step;
  }
}

void dottedLine(float x1, float y1, float x2, float y2, float steps, float weight, int dotColor) {
  noStroke();
  fill(dotColor);
  for (int i=0; i<=steps; i++) {
    float x = lerp(x1, x2, i/steps);
    float y = lerp(y1, y2, i/steps);
    ellipse(x, y, weight, weight);
  }
}

void draw_line_graph(SData sData, float xStart, float xSize, float yStart, float ySize) {  
  stroke(sData.lineColor);
  strokeWeight(sData.lineWidth);
  float xStep = xSize / (sData.maxLength-1);

  float curX = xStart+xSize;

  noFill();
  beginShape();
  for (int i=sData.head; ; i--) {
    if (i == -1) i = sData.maxLength-1;
    int i0 = i;
    if (i0 == -1) i0 = sData.maxLength-1;
    int i1 = i0-1;
    if (i1 == -1) i1 = sData.maxLength-1;

    int val0 = sData.get(i0);
    float yPos0 = ySize - (float)val0/sData.maxVal * ySize + yStart;
    float xPos0 = curX;
    curveVertex(xPos0, yPos0);
    if (i0 == sData.head) curveVertex(xPos0, yPos0);
    curX -= xStep;

    if (i1 == sData.head) {
      curveVertex(xPos0, yPos0); 
      break;
    }
  }
  endShape();

  //  stroke(red);
  //  strokeWeight(0.5);
  //  rect(xStart, yStart, xSize, ySize);
  float x0 = xStart, x1 = x0+xSize, y0 = yStart+5, y1 = y0+ySize;
  draw_x_axis(x0, x1, y0, y1);
  draw_y_axis(x0, x1, y0, y1);
  //
  draw_text(sData.name+sData.mode, x0, y1, 12, sData.lineColor, 0);
  draw_text(Integer.toString(SData.period)+" ms", x1, y1, 12, darkGray, 1);
  draw_text(sData.msg, (x0+x1)/2, y1, 12, sData.lineColor, 2);
  //
  float dx = 5, dy = 7;
  int val;

  val = sData.maxVal;
  draw_text(Integer.toString(val), x0-dx, y0-dy, 10, darkGray, 1);

  val = sData.maxVal/2;
  if (val > 0) {
    draw_text(Integer.toString(val), x0-dx, (y0+y1)/2-dy, 10, darkGray, 1);
  }

  val = 0;
  draw_text(Integer.toString(val), x0-dx, y1-dy, 10, darkGray, 1);  
}

void draw_legend(){
  float l = 50, g = 5;
  float x = gapx2;
  float y = w_height - 30, yy = y+7;
  
  strokeWeight(1);
  stroke(darkGray);
  noFill();
  rect(x-5, y-3, 500, 20);
  
  strokeWeight(1);
  stroke(green);
  line(x, yy, x+l, yy);
  draw_text("Analog In", x+l+g, y, 12, darkGray, 0);
  
  x+=l+70;
  
  strokeWeight(4);
  stroke(green);
  line(x, yy, x+l, yy);
  draw_text("Digital In", x+l+g, y, 12, darkGray, 0);
  
  x+=l+70;
  
  strokeWeight(1);
  stroke(blue);
  line(x, yy, x+l, yy);
  draw_text("Analog Out", x+l+g, y, 12, darkGray, 0);
  
  x+=l+80;
  
  strokeWeight(4);
  stroke(blue);
  line(x, yy, x+l, yy);
  draw_text("Digital Out", x+l+g, y, 12, darkGray, 0);
}

void draw()
{
  background(bkgColor);
  draw_legend();
  float h = (float)g_height/ios.length*2;
  float w = (float)g_width/2;
  for (int i=0; i<ios.length; i++) {
    int row = i%10;
    if (i < 10)
      draw_line_graph(ios[i], gapx2, w-gapx2, gapy+row*h, h-gapy2);
    else
      draw_line_graph(ios[i], w+gapx2, w-gapx2, gapy+row*h, h-gapy2);
  }
  delay(0);
}

//-----------------Data-------------------

class DataThread extends Thread {
  public void run() {
    println("data thread running");
    while (true) {
      read_line();
      delay(0);
    }
  }
}

void push_vals(int []vals) {
  for (int i=0; i<vals.length; i++) {
    int val = vals[i]/10;
    int mode = vals[i]%10;
    ios[i].push(val);
    //0 - in active
    //1 - analog in
    //2 - digital in
    //3 - analog out
    //4 - digital out
    ios[i].lineWidth = 1;
    if (mode == 0) {
      ios[i].mode = " (inactive)";
      ios[i].lineColor = lightGray;
      ios[i].lineWidth = 0.2;
      ios[i].maxVal = ios[i].defaultMaxVal;
    }
    else if (mode == 1) {
      ios[i].mode = "-In";
      ios[i].lineColor = green;
      ios[i].maxVal = 1023;
    }
    else if (mode == 2) {
      ios[i].mode = "-In";
      ios[i].lineColor = green;
      ios[i].maxVal = 1;
      ios[i].lineWidth = 4;
    }
    else if (mode == 3) {
      ios[i].mode = "-Out (PWM)";
      ios[i].lineColor = blue;
      ios[i].maxVal = 255;
    }
    else if ( mode ==4) {
      ios[i].mode = "-Out";
      ios[i].lineColor = blue;
      ios[i].maxVal = 1;
      ios[i].lineWidth = 4;
    }
    print(val + " ");
  }
  print("\n");
}

void read_line() {
  while (true) {
    StringBuffer line = get_line();
    boolean error = false;
    int []vals = null;
    try {
      vals = strings_to_ingeters(line.toString().split(","));
      if (vals.length!= ios.length) 
        throw new Exception();
    }
    catch (Exception e) {
      println(line);
      println("protocol error, line skipped");
      continue;
    }
    push_vals(vals);
    break;
  }
}

StringBuffer get_line() {
  StringBuffer line = new StringBuffer();
  while (true) {
    if (port.available() > 0) {
      val = port.readChar();
      //      println("#"+val);
      if (val == ';') {
        break;
      }
      else {
        line.append(val);
      }
    }
    delay(0);
  }

  return line;
}

