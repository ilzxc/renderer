void seg(int x0, int y0, int x1, int y1, color col) 
{
  boolean steep = false;
  if (abs(x0 - x1) < abs(y0 - y1)) {
    // if the line is steep, we transpose:
    x0 -= y0;
    y0 += x0;
    x0 = y0 - x0;
    x1 -= y1;
    y1 += x1;
    x1 = y1 - x1;
    steep = true;
  }
  if (x0 > x1) {
    // make it left-to-right:
    x0 -= x1;
    x1 += x0;
    x0 = x1 - x0;
    y0 -= y1;
    y1 += y0;
    y0 = y1 - y0;
  }
  int dx = x1 - x0;
  int dy = y1 - y0;
  int derror = abs(dy) * 2;
  int error = 0;
  int y = y0;
  int yinc = (y1 > y0) ? 1 : -1;
  for (int x = x0; x <= x1; ++x) {
    if (steep) {
      set(y, x, col);
    } else {
      set(x, y, col);
    }
    error += derror;
    if (error > dx) {
      y += yinc;
      error -= dx * 2;
    }
  }
}

void setup()
{  
  ObjLoader test = new ObjLoader(loadStrings("diablo3_pose.obj"));
  for (Triangle t : test.faces) {
    println(t.indices[0], t.indices[1], t.indices[2]);
  }
  size(800, 800);
  color c = color(255);
  background(0);
  noLoop();
  
  for (Triangle t : test.faces) {
    for (int i = 0; i < 3; ++i) {
      Vec2f v0 = test.points.get(t.indices[i] - 1);
      Vec2f v1 = test.points.get(t.indices[(i + 1) % 3] - 1);
      int x0 = int((v0.x + 1.f) * (width  / 2.f));
      int y0 = height - int((v0.y + 1.f) * (height / 2.f));
      int x1 = int((v1.x + 1.f) * (width  / 2.f));
      int y1 = height - int((v1.y + 1.f) * (height / 2.f));
      seg(x0, y0, x1, y1, c);
    }
  }
}