//Rain Wang, Art22, S19, Final Project: Bamboo
//Borrowed smoke particle system from Daniel Shiffman
//https://processing.org/examples/smokeparticlesystem.html

import processing.pdf.*; // ->> beginRecord endRecord
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
float waveHeight; // shakiness of the leaves
PShape leaf1;
PShape leaf2;
PShape leaf3;
PShape leaf4;
PShape leaf5;
PShape[] leaf;
int[] leafOrder_1 = new int[]{0,2,3,1,4};
int[] leafOrder_2 = new int[]{4,3,1,0,2};
int[] leafOrder_3 = new int[]{3,1,2,4,0};
int[] leafOrder_4 = new int[]{2,4,0,3,1};
int[] leafOrder_5 = new int[]{1,0,4,2,3};
int[][] leafOrder = new int[][]{leafOrder_1,leafOrder_2,leafOrder_3,leafOrder_4,leafOrder_5};
ArrayList<Bamboo> allBamboo = new ArrayList<Bamboo>();
int numberOfBamboos;
ArrayList bambooDegree = new ArrayList();
ParticleSystem ps;

void setup() {
  size(1200,800);
  //size(displayWidth, displayHeight);
  minim = new Minim(this);
  song = minim.loadFile("data/GreenDestiny.mp3",1024);
  song.loop();
  leaf1 = loadShape("data/leaf1.svg");
  leaf1.scale(1);
  leaf2 = loadShape("data/leaf2.svg");
  leaf2.scale(1.0);
  leaf3 = loadShape("data/leaf3.svg");
  leaf3.scale(1);
  leaf4 = loadShape("data/leaf4.svg");
  leaf4.scale(1);
  leaf5 = loadShape("data/leaf5.svg");
  leaf5.scale(1);
  leaf = new PShape[5];
  leaf[0] = leaf1;
  leaf[1] = leaf2;
  leaf[2] = leaf3;
  leaf[3] = leaf4;
  leaf[4] = leaf5;
  numberOfBamboos = 16; //Changable
  for(int i = 0; i < numberOfBamboos; i++){
    Bamboo bambooi = new Bamboo(10+random(-2,13),map((i*width/numberOfBamboos),0,width,50,width-50)+random(-50,50));
    allBamboo.add(bambooi);
    bambooDegree.add(random(-15,15)); //Changable
  }
  filter(BLUR,2);
  PImage img = loadImage("texture.png");
  ps = new ParticleSystem(0, new PVector(width/2, height), img);
  String filename = ""+year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  beginRecord(PDF, "Captures/Bamboo"+filename+".pdf");
}

void draw() {
  background(180);
  waveHeight = map(song.left.get(0),-1,1,0,2);
  for(int i = 0; i < numberOfBamboos; i++){
    pushMatrix();
    rotate(radians((float)bambooDegree.get(i)));
    allBamboo.get(i).display();
    popMatrix();
  }
  
  // Calculate a "wind" force based on mouse horizontal position
  
  float dx = map(mouseX, 0, width, -0.7, 0.7);
  PVector wind = new PVector(dx, 0);
  ps.applyForce(wind);
  ps.run();
  for (int i = 0; i < 3; i++) {
    ps.addParticle();
  }
  
}

void mousePressed() {
  endRecord();
  exit();
}

class Bamboo {
  float stemWidth;
  float stemHeight;
  float x;
  int stemNum;
  float [] theAngles;
  int [] leafNums;
  Bamboo(float stemWidth, float x) {
    this.stemWidth = stemWidth;
    this.x = x;
    stemHeight = stemWidth*10;
    stemNum = (int)(height/stemHeight)+7;
    theAngles =  new float[stemNum];
    leafNums = new int[stemNum];
    //leftrights = new float[stemNum];
    for (int i=0; i<stemNum; i++) {
      theAngles[i] = random(random(10, 80),random(100,170));
      leafNums[i] = 1+(int)random(4);
    }
  }

  void display() {
    // Drawing a single bamboo
    noStroke();
    fill(0);
    for (int i = 0; i<stemNum; i++) {
      fill(5*i);
      pushMatrix();
      translate(-50, -(stemHeight+(stemWidth/2))*i);
      rect(x, height+2*stemHeight, stemWidth, stemHeight);
      // Drawing the leaf on each stem section
      leaves leaves_1 = new leaves(leafNums[i], theAngles[i]);
      leaves_1.display(x+stemWidth/2, height-stemHeight+3);
      popMatrix();
    } //end of for loop
  } //end of display
} //end of bamboo class

class leaves {
  int leafNum;
  int left; //left is 1 and right is -1, multiply it to the angle
  float leavesRotate;
  leaves(int ln, float lAngle) {
    this.leavesRotate = lAngle;
    this.leafNum = ln;
    //this.leftright = leftright;
    if (lAngle<90) {
      left = 1;
    } 
    else {
      left = -1;
    }
  }

  void display(float x, float y) {
      pushMatrix();
      translate(x, y);
      rotate(radians(leavesRotate));
      for (int i = 0; i < leafNum; i++) {
        if(this.left == 1){
          rotate(radians(20*i + random(-waveHeight,waveHeight)));
        }
        else{
          rotate(radians(-20*i + random(-waveHeight,waveHeight)));
        }
        //int randomNum = (int)random(4);
        shape(leaf[leafOrder[i][(7*i)%4]]);
        //leavesRotate += (15);
      }
      popMatrix();
  }
}

// ------------- Below are particle system -------------------
// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;

  ParticleSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.copy();                                   // Store the origin point
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img));         // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p : particles) {
      p.applyForce(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle(origin, img));
  }
}



// A simple Particle class, renders the particle as an image

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l, PImage img_) {
    acc = new PVector(0, 0);
    float vx = randomGaussian()*0.5;
    float vy = randomGaussian()*4.5 - 1.0;
    vel = new PVector(vx, vy);
    loc = l.copy();
    lifespan = 100.0;
    img = img_;
  }

  void run() {
    update();
    render();
  }

  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update position
  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 2.0;
    acc.mult(0); // clear Acceleration
  }

  // Method to display
  void render() {
    //imageMode(CENTER);
    //tint(255, lifespan);
    //image(img, loc.x, loc.y);
    // Drawing a circle instead
     fill(255,lifespan);
     noStroke();
     ellipse(loc.x,loc.y,23,23);
     smooth(2);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
