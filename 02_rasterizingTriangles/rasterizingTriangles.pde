class Vec2i
{
  public int x, y;
  Vec2i(int x, int y) { this.x = x; this.y = y; }
  void show() { println("[" + x + ", " + y + "]"); }
}

void swap(Vec2i a, Vec2i b) {
  int dummy = a.x;
  a.x = b.x;
  b.x = dummy;
  dummy = a.y;
  a.y = b.y;
  b.y = dummy;
}

/// Simplified Draw Line for fills:
void drawHorizontalLine(int x0, int x1, int y, color col) {
  println("line : [" + x0 + ", " + x1 + "] @ " + y);
  if (x0 > x1) {
    int dummy = x0;
    x0 = x1;
    x1 = dummy;
  }
  for (int x = x0; x <= x1; ++x)
    set(x, y, col);
}

void drawVerticalLine(int y0, int y1, int x, color col) {
  if (y0 > y1) {
    int dummy = y0;
    y0 = y1;
    y1 = dummy;
  }
  for (int y = y0; y <= y1; ++y)
    set(x, y, col);
}

void drawTriangle(Vec2i t0, Vec2i t1, Vec2i t2, color col)
{
  /// Drawing the stroked triangle, so we can see what's up...
  segmentFinal(t0.x, t0.y, t1.x, t1.y, color(255, 0, 0));
  segmentFinal(t1.x, t1.y, t2.x, t2.y, color(255, 0, 0));
  segmentFinal(t2.x, t2.y, t0.x, t0.y, color(255, 0, 0));
  
  /// use horizontal lines
  /// enumerate points top-to-bottom
  if (t0.y > t1.y) swap(t0, t1);
  if (t0.y > t2.y) swap(t0, t2);
  if (t1.y > t2.y) swap(t1, t2);
  t0.show(); t1.show(); t2.show();
  
  /// draw top-to-middle
  for(int y = t0.y; y < t1.y; ++y) {
    // get x-coordinate for t0 -> t1
    float t = (y - t0.y) / float(t1.y - t0.y);
    int x0 = int(t0.x * (1.0f - t) + t1.x * t);
    // get x-coordinate for t0 -> t2
    t = (y - t0.y) / float(t2.y - t0.y);
    int x1 = int(t0.x * (1.0f - t) + t2.x * t);
    // draw horizontal line using two points above
    drawHorizontalLine(x0, x1, y, col);
  }

  /// draw middle-to-bottom
  for (int y = t1.y; y <= t2.y; ++y) {
    float t = abs((y - t1.y) / float(t2.y - t1.y));
    int x0 = int(t1.x * (1.0 - t) + t2.x * t);
    t = (y - t0.y) / float(t2.y - t0.y);
    int x1 = int(t0.x * (1.0f - t) + t2.x * t);
    drawHorizontalLine(x0, x1, y, col);
  }
}

void setup()
{
  size(100, 100);
  background(0);
  drawTriangle(new Vec2i(10, 10), new Vec2i(90, 80), new Vec2i(10, 90), color(200, 200, 255));
  noLoop();
}