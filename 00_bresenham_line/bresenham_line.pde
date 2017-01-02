/// First approach:
///
/// Given a pair of points, we define t to traverse the line,
/// and compute x, y along the line that we will set using a
/// given color.
///
/// Note that this approach has some problems. First off, we
/// use a number for increment, which means that we may be 
/// setting some points multiple times and some points may not
/// be set at all (if t "skips" them).
///
/// However, this is a good beginning, as the main formula is
/// going to be useful in our improvements.
void segmentNaive(int x0, int y0, int x1, int y1, color col) 
{
  float increment = 0.1f;
  for (float t = 0.0f; t < 1.0f; t += increment) {
    int x = int(x0 * (1.0f - t) + x1 * t);
    int y = int(y0 * (1.0f - t) + y1 * t);
    set(x, y, col);
  }
}

/// First improvement:
///
/// Let's use the x-values to ensure that we set only the points
/// that are necessary. In this case, instead of simply incrementing
/// the line segment, we need to compute the traversal point t by
/// hand, by dividing the x-offset (x - x0) by the total length of
/// the line (x1 - x0).
/// 
/// However, notice that in the case of x0 > x1, our line won't draw
/// at all (x <= x1 predicate in our loop will skip over our code!)
/// And even if x0 < x1, if the segment height is greater than
/// the segment width, we will still end up with some holes.
/// So we need to do a little more work for our code to work correctly.
/// (And once it does, we can think about optimization, as well!)
void segmentWrong(int x0, int y0, int x1, int y1, color col) 
{
  for (int x = x0; x <= x1; ++x) {
    float t = (x - x0) / float(x1 - x0);
    int y = int(y0 * (1.0f - t) + y1 * t);
    set(x, y, col);
  }
}

/// Getting it correct:
///
/// To make things work correctly, we need to:
/// 1. figure out if the width of the segment is greater than height,
///    this will be the "x" value that we will use to walk our line;
/// 2. ensure that x0 < x1, and reverse the line if it isn't;
///
/// To achieve 1, we simply need to compare x-length against the y-length
/// of the line. If the y-length is greater than x-length, we will swap
/// x0 with y0 and x1 with y1. However, that will result in the wrong
/// drawing -- if this occurs, we will need to set pixels with (y, x)
/// coordinates rather than (x, y) coordinates.
///
/// To achieve 2, we only need to check that x0 < x1. Because 2 will be
/// evaluated after 1, x0 and x1 will hold x values if x-length is greater
/// than y-length and y values otherwise.
///
/// The rest of the code should be identical to what we had before.
void segmentBetter(int x0, int y0, int x1, int y1, color col) 
{
  boolean steep = false;
  if (abs(x0 - x1) < abs(y0 - y1)) {
    // if the line is steep, we swap x0 with y0 and x1 with y1:
    // (I'm using in-place swap here)
    // swap(x0, y0):
    x0 -= y0;
    y0 += x0;
    x0 = y0 - x0;
    // swap(x1, y1):
    x1 -= y1;
    y1 += x1;
    x1 = y1 - x1;
    // let our drawing code know that we swapped x & y:
    steep = true;
  }
  if (x0 > x1) {
    // make it left-to-right:
    // swap(x0, x1)
    x0 -= x1;
    x1 += x0;
    x0 = x1 - x0;
    // swap(y0, y1):
    y0 -= y1;
    y1 += y0;
    y0 = y1 - y0;
  }
  for (int x = x0; x <= x1; ++x) {
    float t = (x - x0) / float(x1 - x0);
    int y = int(y0 * (1.0f - t) + y1 * t);
    if (steep) {
      set(y, x, col);
    } else {
      set(x, y, col);
    }
  }
}

/// Optimization:
///
/// We will need to draw a lot of these lines, so let us try to see
/// how we can optimize the segment drawing routine. One costly operation
/// is our division: and notice that every iteration of the above loop
/// always divides by the same denominator: float(x1 - x0).
///
/// What is the purpose of this division? We're computing traversal (t):
/// that we can then use to compute our y-coordinate. First, let us
/// compute the change in x and the change in y, dx and dy, respectively.
/// Then, we can compute the ratio of dy / dx (ensure it is positive by
/// taking the absolute value.
///
/// If we accumulate this error in our loop (adding it to a variable error)
/// we can make an informed decision as to whether we increment or decrement
/// our y-value. We do this by "rounding" the pixel-value to the next pixel
/// by checking if error > 0.5. If it is, we increment the y value and
/// reset our error by subtracting 1.0 from it. 
void segmentFirstOptimization(int x0, int y0, int x1, int y1, color col) 
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
  float derror = abs(dy / float(dx));
  float error = 0;
  int y = y0;
  int yinc = (y1 > y0) ? 1 : -1;
  for (int x = x0; x <= x1; ++x) {
    if (steep) {
      set(y, x, col);
    } else {
      set(x, y, col);
    }
    error += derror;
    if (error > 0.5) {
      y += yinc;
      error -= 1.0f;
    }
  }
}

/// An even better optimization:
///
/// Do we need floating point numbers at all? The answer is no.
/// But we need to be clever: we are trying to round up from 0.5.
/// Since we do not have enough resolution for our values to
/// account for "half-way" between y-coordinates, we need to do
/// something to increase our resolution appropriately.
///
/// First, let us define derror as being twice the y-distance. Then,
/// as we accumulate the error, we will check it against the x-distance.
/// If the error exceeds dx, we increment the y appropriately, and 
/// correct our error by subtracting twice the dx. Thus, we now account
/// for the half-way points by accumulating the error at twice the
/// resolution that we have.
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

void setup()
{  
  size(100, 100);
  background(0);
  segmentFinal(13, 20, 13, 40, color(255));
  segmentFinal(13, 40, 80, 40, color(255));
  segmentFinal(23, 13, 40, 80, color(255, 0, 0));
  segmentFinal(80, 40, 13, 20, color(255, 0, 0));
}