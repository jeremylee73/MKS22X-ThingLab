import java.util.Random;

interface Displayable {
  void display();
}

interface Moveable {
  void move();
}

interface Collideable {
  boolean isTouching(Thing other);
}

PImage[] rocks;

abstract class Thing implements Displayable, Collideable {
  float x, y, radius; //Position of the Thing, radius of intersection

  Thing(float x, float y, float radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }
  abstract void display();

  boolean isTouching(Thing other) {
    return Math.sqrt(Math.pow(x-other.x, 2)+Math.pow(y-other.y, 2)) < radius+other.radius;
  }
}

class Rock extends Thing {

  PImage rock;

  Rock(float x, float y) {
    super(x, y, 40);
    rock = rocks[(int) Math.floor(Math.random() * 2)];
  }

  void display() {
    image(rock, x-50, y-50, 100, 100);
  }
}

class LivingRock extends Rock implements Moveable {

  int[] eyecolor;
  float vx;
  float vy;

  LivingRock(float x, float y) {
    super(x, y);

    float theta = random(0., (float)(2*Math.PI));
    vx = 5*(float)Math.cos(theta);
    vy = 5*(float)Math.sin(theta);

    double rng = Math.random();

    if (rng < 0.25)
      eyecolor = new int[] {40, 26, 13}; //brown

    else if (rng >= 0.25 && rng < 0.5)
      eyecolor = new int[] {85, 56, 0}; //hazel

    else if (rng >= 0.5 && rng < 0.75)
      eyecolor = new int[] {0, 96, 255}; //blue, kinda

    else if (rng >= 0.75 && rng < 1)
      eyecolor = new int[] {0, 179, 44}; //green, kinda

  }

  void move() {

    x += vx;
    y += vy;

    if (x >= width){
      vx = -Math.abs(vx);
    } else if (x < 0) {
      vx = Math.abs(vx);
    } else if (y >= height){
      vy = -Math.abs(vy);
    } else if (y < 0) {
      vy = Math.abs(vy);
    }

    for (Thing c : thingsToCollide) {
      if (this != c && isTouching(c)) {
        float v = (float)Math.sqrt(Math.pow(vx, 2)+Math.pow(vy, 2));
        float dx = x-c.x;
        float dy = y-c.y;
        float s = v/(float)Math.sqrt(Math.pow(dx, 2)+Math.pow(dy, 2));
        vx = dx*s;
        vy = dy*s;
      }
    }
  }

  int randgen(int min, int max) {
    Random r = new Random();
    return r.nextInt((max - min) + 1) + min;
      // super.y += random(-10, 10);
  }

  void display() {
    super.display();
    fill(255);
    ellipse(this.x-15, this.y-10, 20, 20);
    ellipse(this.x+15, this.y-10, 20, 20);
    fill(eyecolor[0], eyecolor[1], eyecolor[2]);
    ellipse(this.x-15, this.y-10, 10, 10);
    ellipse(this.x+15, this.y-10, 10, 10);
  }
}

//Since 3 styles of movement are required
class LivingRock2 extends LivingRock {
  float deg = (float)Math.random() * 360;
  
  LivingRock2(float x, float y) {
    super(x, y);

    double rng = Math.random();

    if (rng < 0.25)
      eyecolor = new int[] {40, 26, 13}; //brown

    else if (rng >= 0.25 && rng < 0.5)
      eyecolor = new int[] {85, 56, 0}; //hazel

    else if (rng >= 0.5 && rng < 0.75)
      eyecolor = new int[] {0, 96, 255}; //blue, kinda

    else if (rng >= 0.75 && rng < 1)
      eyecolor = new int[] {0, 179, 44}; //green, kinda
  }
  
  void move() {
    //Commented out: circular movement
    //this.x = super.x + 10 * (float)Math.cos(deg);
    //this.y = super.y + 10 * (float)Math.sin(deg);
    
    //Active code: polar graph curve
    this.x = super.x + 20 * (float)(Math.cos(2 * deg) * Math.cos(deg));
    this.y = super.y + 20 * (float)(Math.sin(2 * deg) * Math.sin(deg));
    deg += 0.05;
  }
}

class Ball extends Thing implements Moveable {

  float vx, vy;
  float r, g, b;

  Ball(float x, float y) {
    super(x, y, 10);
    vy = 0;
    vx = random(-10, 10);
    r = random(0, 255);
    g = random(0, 255);
    b = random(0, 255);
  }

  void display() {
    fill(r, g, b);
    ellipse(x, y, 20, 20);
  }

  void move() {
    y += vy;
    x += vx;

    // floor collision
    if (y > height) {
      y = height;
      vy = -vy*0.9;
    } else {
      vy += 2;
    }

    // wall collision
    if (x > width || x < 0) vx = -vx;

    // object collision
    for (Thing c : thingsToCollide) {
      if (this != c && isTouching(c)) {
        float v = (float)Math.sqrt(Math.pow(vx, 2)+Math.pow(vy, 2));
        float dx = x-c.x;
        float dy = y-c.y;
        float s = v/(float)Math.sqrt(Math.pow(dx, 2)+Math.pow(dy, 2));
        vx = dx*s;
        vy = dy*s;
      }
    }
  }
}

ArrayList<Displayable> thingsToDisplay;
ArrayList<Moveable> thingsToMove;
ArrayList<Thing> thingsToCollide;

void setup() {
  size(1000, 800);
  rocks = new PImage[2];
  rocks[0] = loadImage("rock.png");
  rocks[1] = loadImage("rock2.png");

  thingsToDisplay = new ArrayList<Displayable>();
  thingsToMove = new ArrayList<Moveable>();
  thingsToCollide = new ArrayList<Thing>();

  for (int i = 0; i < 10; i++) {
    Ball b = new Ball(50+random(width-100), 50+random(height-100));
    thingsToDisplay.add(b);
    thingsToMove.add(b);
    thingsToCollide.add(b);
    Rock r = new Rock(50+random(width-100), 50+random(height-100));
    thingsToDisplay.add(r);
    thingsToCollide.add(r);
  }
  for (int i = 0; i < 3; i++) {
    LivingRock m = new LivingRock(50+random(width-100), 50+random(height-100));
    thingsToDisplay.add(m);
    thingsToMove.add(m);
    thingsToCollide.add(m);
  }
  
  for (int i = 0; i < 3; i++) {
    LivingRock m = new LivingRock2(50+random(width-100), 50+random(height-100));
    thingsToDisplay.add(m);
    thingsToMove.add(m);
    thingsToCollide.add(m);
  }
}
void draw() {
  background(255);

  for (Displayable thing : thingsToDisplay) {
    thing.display();
  }
  for (Moveable thing : thingsToMove) {
    thing.move();
  }
}
