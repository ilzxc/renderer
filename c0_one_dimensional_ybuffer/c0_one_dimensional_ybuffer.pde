void rasterize(Vector p0, Vector p1, color c, int[] ybuffer, color[] buffer)
{
  // flip points (std::swap in C++) if necessary:
  if (p0.x > p1.x) {
    Vector temp = p0;
    p0 = p1;
    p1 = temp;
  }
  
  // walk across the line, writing to ybuffer as necessary, testing
  // the y-value against the y-buffer value to see if we need to be drawing.
  for (int x = int(p0.x); x <= int(p1.x); ++x) {
    float t = (x - p0.x) / (p1.x - p0.x);
    int y = int(p0.y * (1.0f - t) + p1.y * t);
    if (ybuffer[x] < y) {
      ybuffer[x] = y;
      buffer[x] = c; // note we only set this if ybuffer[x] < y!
    }
  }
}

void setup()
{
  size(800, 550, P2D);
  background(0);
  
  // scene "2d mesh" -- for now, different coordinates due to the up-down flip
  segment(new Vector(20, 466), new Vector(744, 100), color(255, 0, 0));
  segment(new Vector(120, 66), new Vector(444, 100), color(0, 255, 0));
  segment(new Vector(330, 36), new Vector(594, 300), color(0, 0, 255));
  
  // screen line
  segment(new Vector(10, 490), new Vector(790, 490), color(255, 255, 255));
  
  // visual cruft (not really renderer-based)
  stroke(128);
  strokeWeight(4);
  line(0, 500, width, 500);
  
  // one-dimensional rendering using our y-buffer:
  int[] ybuffer = new int[width];
  for (int i = 0; i < width; ++i) {
    ybuffer[i] = Integer.MIN_VALUE; // std::numeric_limits<int>::min()
  }
  
  // create a pixel buffer for our rasterizer:
  color[] buffer = new color[width];
  
  rasterize(new Vector(20,   34), new Vector(744, 400), color(255, 0, 0), ybuffer, buffer);
  rasterize(new Vector(120, 434), new Vector(444, 400), color(0, 255, 0), ybuffer, buffer);
  rasterize(new Vector(330, 463), new Vector(594, 200), color(0, 0, 255), ybuffer, buffer);
  
  for (int i = 0; i < width; ++i) {
    for (int j = 0; j < 16; ++j) {
      set(i, 516 + j, buffer[i]);
    }
  }
  
  noLoop();
}