/*
Cassie Mullins
5/19/2022

Generates random colors and rulesets and then one static each frame
Used to generate random color palettes to be currated and then used in higher rez images
*/


int rows = 0;
int cols = 100;

int numColors = 10;

int square;
float w = 0;

int[] ruleSet;

int frame = 0;

int[][] colors;
int[][] startColors;
color[] colorList;

int time = 0;

int numFrames = 0;
int version = 0;

int baseRed = -1;
int baseGreen = -1;
int baseBlue = -1;
boolean randomColors = false;

PrintWriter output;


void setup() {
  output = createWriter("Rules.txt"); 
  size(800,800);

  square = (int)(width/(cols-1));
  rows = (int)(height/square) + 1;
  noStroke();
  
  //generateNewColors();
  color[] allColors = {#31232b, #756a74, #513c3f, #556b75, #6a422c, #7d5758, #4f2325, #665847, #708aa2};
  //{#7f5e41, #436186, #9b663d, #3a3738, #63605e, #180f12, #5e4958};
  //{#31232b, #756a74, #513c3f, #556b75, #6a422c, #7d5758, #4f2325, #665847, #708aa2};
  colorList = new color[allColors.length];
  for (int i = 0; i < allColors.length; i++) {
    colorList[i] = allColors[i];
  }
  numColors = allColors.length;

  ruleSet = generateRules();
  generateNewSetup();
}

void keyPressed() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  exit(); // Stops the program
}

void draw() {
  generateNewSetup();
  findNewRules();
  String setString = frame + ":";
  for (int i = 0; i < numColors; i++) {
    color c = colorList[i];
    setString += red(c) + "," + green(c) + "," + blue(c);
     if (i < numColors - 1) {
       setString += " "; 
     }
  }
  output.println(setString);
  save(frame + ".png");
  frame++;
}

void drawSquares() {
   for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
         int currColor = colors[i][j];
         fill(colorList[currColor]);
         
         float x = i*square;
         float y = j*square;
         rect(x,y,square,square);
     }
   }
   int[][] nextIter = new int[cols][rows];
   for (int i = 1; i < cols; i++) {
     nextIter[i] = colors[i-1]; 
   }
   nextIter[0] = getNextCol(nextIter[1]);
   colors = nextIter;
}

int[] getNextCol(int[] prev) {
   int[] next = new int[rows];
   for (int i = 0; i < rows; i++) {
     int prevI = i == 0 ? rows - 1 : i - 1; 
     int nextI = i == rows - 1 ? 0 : i + 1;
     
     int l = prev[prevI];
     int m = prev[i];
     int r = prev[nextI];
     
     int valL = l - m;
     int valR = r - m;
     
     int val = m;
     if (valL == 0 && valR == 0) {
        val += ruleSet[0];
     } else if (valL > 0 && valR > 0) {
       val += ruleSet[1];
     } else if (valL < 0 && valR < 0) {
       val += ruleSet[2];
     } else if (valL == 0 && valR < 0) {
       val += ruleSet[3];
     } else if (valL > 0 && valR == 0) {
       val += ruleSet[4];
     } else if (valL < 0 && valR == 0) {
       val += ruleSet[5];
     } else if (valL == 0 && valR > 0) {
       val += ruleSet[6];
     }  else if (valL >= 0 && valR < 0) {
       val += ruleSet[7];
     } else if (valL > 0 && valR <= 0) {
       val += ruleSet[8];
     } else if (valL < 0 && valR >= 0) {
       val += ruleSet[9];
     } else if (valL <= 0 && valR > 0) {
       val += ruleSet[10];
     }
     if (l == numColors - 1 && m == 0) {
       val = numColors - 1; 
     }
     val = val > numColors - 1 ? numColors - 1 : val < 0 ? 0 : val;
     
     next[i] = val;
   }
   return next;
}

int[] generateRules() {
  int[] rules = new int[11];
  for (int i = 0; i < 11; i++) {
    int rule = (int)random(-numColors + 1, numColors);
    rules[i] = rule;
  }
  return rules;
}

boolean calculateValue() {
  boolean[] checkList = new boolean[numColors];
  for (int i = 0; i < numColors; i++) {
    checkList[i] = false; 
  }
  
  for (int x = 1; x < 960-1; x++) {
    for (int y = 0; y < height; y++) {
      color col = get(x,y);
      float r = red(col);
      float g = green(col);
      float b = blue(col);
      
      color col0 = get(x-1,y);
      float r0 = red(col0);
      float g0 = green(col0);
      float b0 = blue(col0);
      
      color col2 = get(x+1,y);
      float r2 = red(col2);
      float g2 = green(col2);
      float b2 = blue(col2);
      if (!(r == r0 && r == r2 && g == g0 && g == g2 && b == b0 && b == b2)) {
         for (int i = 0; i < numColors; i++) {
            color col1 = colorList[i];
            float r1 = red(col1);
            float g1 = green(col1);
            float b1 = blue(col1);
            
            if (r == r1 && g == g1 && b == b1) {
              checkList[i] = true; 
            }
         }
      }
    }
  }
  boolean check = true;
  for (int i = 0; i < numColors; i++) {
     check &= checkList[i]; 
  }
  return check;
}

void findNewRules() {
  boolean check = false;
  while (!check) {
    resetColors();
    ruleSet = generateRules();
    
    for (int i = 0; i < cols*3; i++) {
      drawSquares(); 
    }
  
    check = calculateValue();
  }
}

void resetColors() {
  for (int i = 0; i < cols; i++) {
       for (int j = 0; j < rows; j++) {
          colors[i][j] = startColors[i][j];
       }
    }
}

void generateNewColors() {
  numColors = (int)random(5, 20);
  
  colorList = new color[numColors];
  for (int i = 0; i < numColors; i++) {
    int red = baseRed == -1 ? (int)random(256) : baseRed;
    int green = baseGreen == -1 ? (int)random(256) : baseGreen;
    int blue = baseBlue == -1 ? (int)random(256) : baseBlue;
    if (baseRed == -2 && baseGreen == -2 && baseBlue == -2) {
      red = (int)random(256);
      green = red;
      blue = red;
    }
    colorList[i] = color(red, green, blue); 
  }
}

void generateNewSetup() {
  generateNewColors();
  
  colors = new int[cols][rows];
  startColors = new int[cols][rows];
  for (int i = 0; i < cols; i++) {
     for (int j = 0; j < rows; j++) {
        int randomColor = (int)random(numColors);
        colors[i][j] = randomColor;
        startColors[i][j] = randomColor;
     }
  }
}
