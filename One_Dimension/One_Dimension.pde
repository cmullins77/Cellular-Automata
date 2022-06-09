/*
Cassie Mullins
5/19/2022

This version of my cellular automata code is primarily for rendering out animated versions of the 1D automata.
By defualt it is setup for Youtube aspect ratio, but was also used to render instagram videos.
*/

//Change number of columns to update how many squares are in automata
int rows = 0;
int cols = 210;

//Number of colors is by default 10, but is randomly changed with each iteration
int numColors = 10;

//Square is the square size, ie how many pixels each cell in the grid is
int square;

//The current set of rules, always 11 int values
int[] ruleSet;

//Frame number used for saving images and knowing when to reset
int frame = 0;

//Colors is 2d array of all current pixel color indexes, start colors is the random colors the animation starts with
int[][] colors;
int[][] startColors;
//The colors used in the automata, related to indexes saved in above 2d arrays
color[] colorList;

//Num frames is how long the animation uses current ruleset & colors, and version is a count of different setups (rulesets and colors)
int numFrames = 0;
int version = 0;

//Some color variables which can give more control over random colors
//with a -1 a random value will be generated
//if set to anything else that value will be used instead
int baseRed = -1;
int baseGreen = -1;
int baseBlue = -1;

void setup() {
  size(1050,672);

  //Figure out square size and then how many rows
  square = (int)(width/(cols-1));
  rows = (int)(height/square) + 1;
  
  //Don't show stroke on cells
  noStroke();
}

void draw() {
  //When number of frames is hit, generate a new ruleset and setup - runs at start because numFrames is 0 to begin with
  if (frame == numFrames) {
     frame = 0;
     //numFrames = (int)random(300, 1000);
     numFrames = 1;
     //Setup new colors and rules
     generateNewSetup();
     findNewRules();
     version++;
  }
  //Draws the next iteration of squares
  drawSquares();
  
  //Save the current image in a folder of all images of current version
  save(version + ".png");
  frame++;
}

//Draws current iteration of squares
void drawSquares() {
  //First loops through all columns and rows and draws a rect for each cell of appropriate color
   for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
         int currColor = colors[i][j];
         fill(colorList[currColor]);
         
         float x = i*square;
         float y = j*square;
         rect(x,y,square,square);
     }
   }
   
   //Create a new 2D array to be next frame's colors
   int[][] nextIter = new int[cols][rows];
   
   //Fill most of the array with current cells, shifted over one
   for (int i = 1; i < cols; i++) {
     nextIter[i] = colors[i-1]; 
   }
   
   //Get the new row of cells and replace current with new
   nextIter[0] = getNextCol(nextIter[1]);
   colors = nextIter;
}

//Function that gets the next column using cellular automata rules
int[] getNextCol(int[] prev) {
  
  //Create new column
   int[] next = new int[rows];
   for (int i = 0; i < rows; i++) {
     
     //Get the index of the previous and next cell, wraps around at ends
     int prevI = i == 0 ? rows - 1 : i - 1; 
     int nextI = i == rows - 1 ? 0 : i + 1;
     
     //Get value of current cell and previous and next cell
     int l = prev[prevI];
     int m = prev[i];
     int r = prev[nextI];
     
     //Get values to use with rules by comparing previous and next cell value to current
     int valL = l - m;
     int valR = r - m;
     
     // rules are positive and negative numbers, depending on whether adjacent 
     // cells are greater or less than the current cell determines which rule is 
     // used, ie which random number is added to the current cell
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
     
     //Make sure value is from 0 to number of colors - 1
     val = val > numColors - 1 ? numColors - 1 : val < 0 ? 0 : val;
     
     next[i] = val;
   }
   return next;
}

//Generates a random set of rules
int[] generateRules() {
  int[] rules = new int[11];
  for (int i = 0; i < 11; i++) {
    int rule = (int)random(-numColors + 1, numColors);
    rules[i] = rule;
  }
  return rules;
}

//Checks to see if current ruleset has produced a "good" image
//For me a good image is an image that has all the colors and isn't just horizontal stripes
boolean calculateValue() {
  
  //Create a boolean list, one bool for each color so we can determine if all the colors are present
  boolean[] checkList = new boolean[numColors];
  for (int i = 0; i < numColors; i++) {
    checkList[i] = false; 
  }
  
  //Loop through all the pixels
  for (int x = 1; x < width-1; x++) {
    for (int y = 0; y < height; y++) {
      
      //Get the current pixel's color
      color col = get(x,y);
      float r = red(col);
      float g = green(col);
      float b = blue(col);
      
      //Get the previous and next pixel's colors
      color col0 = get(x-1,y);
      float r0 = red(col0);
      float g0 = green(col0);
      float b0 = blue(col0);
      
      color col2 = get(x+1,y);
      float r2 = red(col2);
      float g2 = green(col2);
      float b2 = blue(col2);
      
      //Check to see if adjacent pixels are the same color, don't count if they are to avoid images that are only horizontal stripes
      //Can remove or adjust this check depending on desired results, sometimes horizontal stripe patterns are cool
      if (!(r == r0 && r == r2 && g == g0 && g == g2 && b == b0 && b == b2)) {
          //Loop throuhg list of colors, once color is found, set boolean in list to true
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
  //Combine all booleans in list to determine if ruleset "worked"
  boolean check = true;
  for (int i = 0; i < numColors; i++) {
     check &= checkList[i]; 
  }
  return check;
}

//Function that finds a new valid ruleset
void findNewRules() {
  
  //Run loop  until a ruleset is generated that satisfies the check
  boolean check = false;
  while (!check) {
    //Resets color to the starting configuration
    resetColors();
    
    //Generate the new random set of rules
    ruleSet = generateRules();
    
    //Run the automata for a while
    for (int i = 0; i < cols*3; i++) {
      drawSquares(); 
    }
  
    //check to see if ruleset created a good automata  
    check = calculateValue();
  }
}

//Reset colors to starting configuration
void resetColors() {
  for (int i = 0; i < cols; i++) {
       for (int j = 0; j < rows; j++) {
          colors[i][j] = startColors[i][j];
       }
    }
}

//Setup for new automata
void generateNewSetup() {
  //Pick random number of colors for new setup
  numColors = (int)random(5, 20);
  
  //Create a new color list and randomly generate colors
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
  
  //Create a random starting configuration
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
