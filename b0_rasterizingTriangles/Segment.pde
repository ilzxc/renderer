void segmentFinal(int x0, int y0, int x1, int y1, color col) 
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