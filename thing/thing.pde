import java.util.Random;

interface Displayable {
  void display();
}

interface Moveable {
  void move();
}

interface Collidable {
  boolean isTouching(Thing other);
}

PImage[] rocks;

abstract class Thing implements Displayable, Collidable {
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
    super(x, y, 50);
    rock = rocks[(int) Math.floor(Math.random() * 2)];
  }

  void display() {
    image(rock, x, y, 100, 100);
  }
}

class LivingRock extends Rock implements Moveable {
  LivingRock(float x, float y) {
    super(x, y);
  }

  void move() {
    /* ONE PERSON WRITE THIS - Kevin Li */
    super.x += randgen(-20, 20);
    super.y += randgen(-20, 20);
  }

  int randgen(int min, int max) {
    Random r = new Random();
    return r.nextInt((max - min) + 1) + min;
  }
}

class Ball extends Thing implements Moveable {
  
  float vx, vy;
  float r, g, b;

  Ball(float x, float y) {
    super(x, y, 20);
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
  }
  for (int i = 0; i < 3; i++) {
    LivingRock m = new LivingRock(50+random(width-100), 50+random(height-100));
    thingsToDisplay.add(m);
    thingsToMove.add(m);
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
