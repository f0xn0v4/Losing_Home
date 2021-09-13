color[] FIRE_COLORS = {#E5544B, #FAB45A, #612F3A, #0C1B2C};
FireParticles FP1;

PGraphics pg;
int GLOBAL_COUNT;

int LT_MULT = 200;
float TIME_PROG = 0.05;

void setup(){
  pg = createGraphics(800,800);
  FP1 = new FireParticles(375,750,425,750,0.08);
  GLOBAL_COUNT = 0;
  size(800,800);
  smooth();
  background(255);
  pg.beginDraw();
}

void draw(){
 FP1.show_update();
 if (FP1.Particles.size() == 0){
   FP1.repopulate(375,750,425,750,0.08);
   pg.endDraw();
   pg.save("frames/"+str(GLOBAL_COUNT)+".png");
   image(pg,0,0);
   background(255);
   GLOBAL_COUNT +=1;
   pg = createGraphics(800,800);
   pg.beginDraw();
 }
}


class FireParticles {
  ArrayList<Particle> Particles = new ArrayList<Particle>();
  FlowField ff;
  float mx;
  float my;
  
  FireParticles(float X1, float Y1, float X2, float Y2, float rho){
   this.ff = new FlowField(0.01, TIME_PROG);
   this.mx = (X2-X1)/2;
   this.my = (Y2-Y1)/2;
   for (float i = X1; i <= X2; i+=rho){
     for (float j = Y1; j <= Y2; j+=rho){
       int lt = int(abs(random(LT_MULT) + 1));
       this.Particles.add(new Particle(i,j,lt));
     }
   }
  }
  
  void repopulate(float X1, float Y1, float X2, float Y2, float rho){
   this.mx = (X2-X1)/2;
   this.my = (Y2-Y1)/2;
   for (float i = X1; i <= X2; i+=rho){
     for (float j = Y1; j <= Y2; j+=rho){
       int lt = int(abs(random(LT_MULT) + 1));
       this.Particles.add(new Particle(i,j,lt));
     }
   }
   this.ff.update();
  }
  
  void show_update(){
    for (Particle p: this.Particles){
      float lt_frac = (float(p.age)/float(p.lifetime));
      color b = fire_transition(lt_frac);
      p.show(b, int(150*(1-lt_frac)));
      PVector Force = this.ff.F(p.P.x, p.P.y).copy();
      PVector guide = new PVector(this.mx-p.P0.x, this.my-p.P0.y);
      guide.setMag(2*lt_frac);
      Force.add(guide);
      Force.normalize();
      p.update(Force);
    }
    this.prune();
  }
  
  void prune(){
    ArrayList<Particle> k = new ArrayList<Particle>();
    for (Particle p: this.Particles){
      if (p.age >= p.lifetime){
        k.add(p);
      }
    }
    for (Particle p: k){
      this.Particles.remove(p);
    }
  }
}

class Particle{
  
  PVector P;
  PVector P0;
  int age = 0;
  int lifetime;
  float noise_offset = random(-1000,1000);
  color[] C = {#E5544B, #FAB45A, #612F3A, #0C1B2C};
  
  Particle(float X, float Y, int LT){
    this.P = new PVector(X,Y);
    this.P0 = new PVector(X,Y);
    this.lifetime = LT;
  }
  
  void update(PVector F){
    if (this.age >= this.lifetime) return;
    this.P.add(F);
    this.age += 1;
  }
  
  void show(color c, int alpha){
    pg.pushStyle();
    pg.stroke(c, alpha);
    pg.point(P.x, P.y);
    pg.popStyle();
  }
  
}

class FlowField {
  float t;
  float t_inc;
  float noise_detail;
  
  FlowField(float nd, float ti){
    this.t = 0;
    this.noise_detail = nd;
    this.t_inc = ti;
  }
  
  PVector F(float x, float y) {
    float X = this.noise_detail * (x);
    float Y = this.noise_detail * (y);
    return PVector.fromAngle(-PI*noise(X,Y,this.t));
  }
  
  void update(){
    this.t += this.t_inc;
  }
}

color fire_transition(float h){
  float[] transition_states = {0.3, 0.7, 0.9};
  int idx = 0;
  for (float u: transition_states) {
    if (h > u){
      idx += 1;
      continue;
    } else break;
  }
  if (idx == 0) {
    return FIRE_COLORS[0];
  } else {
    return lerpColor(FIRE_COLORS[idx-1], FIRE_COLORS[idx], h/transition_states[idx-1]);
  }
}

float falloff(float k, float l, float x){
  return -k*(exp(-x/l)-1);
}

float gauss(float x){
  return exp(-pow(x,2));
}
