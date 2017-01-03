/// Vector class!
/// Can be used for 2D and 3D points (my use is not very Java-like, but that's
/// not really the point of this exercise -- think of my classes as C-like structs!)
///
/// We support only the most minimal operations necessary for this exercise:
/// dot & cross products, vector subtraction, and normalization.
class Vector
{
  public float x, y, z;
  Vector(int x, int y) { this.x = float(x); this.y = float(y); }
  Vector(float x, float y) { this.x = x; this.y = y; }
  Vector(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  Vector cross(Vector other) {
    return new Vector(
      this.y * other.z - this.z * other.y,
      this.z * other.x - this.x * other.z,
      this.x * other.y - this.y * other.x
    );
  }
  Vector sub(Vector other) {
    return new Vector(
      this.x - other.x,
      this.y - other.y,
      this.z - other.z
    );
  }
  Vector normalize() {
    float mag = sqrt(x * x + y * y + z * z);
    return new Vector(x / mag, y / mag, z / mag);
  }
  float dot(Vector other) {
    return x * other.x + y * other.y + z * other.z;
  }
}

void segment(Vector p0, Vector p1, color col) 
{
  boolean steep = false;
  if (abs(p0.x - p1.x) < abs(p0.y - p1.y)) {
    // if the line is steep, we transpose:
    p0.x -= p0.y;
    p0.y += p0.x;
    p0.x = p0.y - p0.x;
    p1.x -= p1.y;
    p1.y += p1.x;
    p1.x = p1.y - p1.x;
    steep = true;
  }
  if (p0.x > p1.x) {
    // make it left-to-right:
    p0.x -= p1.x;
    p1.x += p0.x;
    p0.x = p1.x - p0.x;
    p0.y -= p1.y;
    p1.y += p0.y;
    p0.y = p1.y - p0.y;
  }
  int dx = int(p1.x - p0.x);
  int dy = int(p1.y - p0.y);
  int derror = abs(dy) * 2;
  int error = 0;
  int y = int(p0.y);
  int yinc = (p1.y > p0.y) ? 1 : -1;
  for (int x = int(p0.x); x <= p1.x; ++x) {
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