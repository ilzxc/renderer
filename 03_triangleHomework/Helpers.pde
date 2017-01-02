/// Bounding Box:
/// Stores the top left & the bottom-right corners of contained primitive
/// (in this case it will apply only to triangles)
class BBox
{
  public Vector topLeft, botRight;
  BBox(Vector tl, Vector br) { topLeft = tl; botRight = br; }
}

/// Helper method for computing BoundingBox of a triangle.
BBox BoundingBox(Triangle t) {
  return new BBox(
    new Vector(min(min(t.p0.x, t.p1.x), t.p2.x), min(min(t.p0.y, t.p1.y), t.p2.y)),
    new Vector(max(max(t.p0.x, t.p1.x), t.p2.x), max(max(t.p0.y, t.p1.y), t.p2.y))
  );
}


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

/// Helper class for holding three indices of our vertex array that
/// define a single triangle (a single face). Used for obj files.
class Face
{
  public int[] indices;
  Face(int a, int b, int c) {
    indices = new int[3];
    indices[0] = a;
    indices[1] = b;
    indices[2] = c;
  }
}

/// Triangle -- three corrdinates to be passed in a single container.
class Triangle
{
  Vector p0, p1, p2;
  Triangle(Vector pt0, Vector pt1, Vector pt2) {
    p0 = new Vector(pt0.x, pt0.y);
    p1 = new Vector(pt1.x, pt1.y);
    p2 = new Vector(pt2.x, pt2.y);
  }
}

/// Helper class for .obj file loading.
/// Notice that Processing has its own helpful library for this sort of a thing,
/// but we are limiting ourselves here a little bit, mostly to remind ourselves
/// that vertices are stored separately from face-defining index-triples.
/// (We do use Processing's loadStrings() method for dealing with text files, though
/// this approach will fail if we're trying to load big .obj files).
class ObjLoader
{
  public ArrayList<Vector> points;
  public ArrayList<Face> faces;
  ObjLoader(String[] lines)
  {
    points = new ArrayList<Vector>();
    faces = new ArrayList<Face>();
    
    for (String line : lines)
    {
      String[] tokens = split(line, ' ');
      if (tokens[0].equals("v")) {
        float[] pts = new float[tokens.length - 1];
        for (int i = 1; i < tokens.length; ++i)
          pts[i - 1] = float(tokens[i]);
        points.add(new Vector(pts[0], pts[1], pts[2]));
      } else if (tokens[0].equals("f")) {
        int[] face = new int[3];
        for (int i = 1; i < tokens.length; ++i) {
          if (i < 4) {
            String[] subtokens = split(tokens[i], '/');
            face[i - 1] = int(subtokens[0]);
          }
        }
        faces.add(new Face(face[0], face[1], face[2]));
      }      
    }
  }
}