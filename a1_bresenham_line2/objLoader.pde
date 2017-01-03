class Vec2f
{
  public float x, y;
  Vec2f(int x, int y) { this.x = float(x); this.y = float(y); }
  Vec2f(float x, float y) { this.x = x; this.y = y; }
  void show() { println("[" + x + ", " + y + "]"); }
}

class Triangle
{
  public int[] indices;
  Triangle(int a, int b, int c) {
    indices = new int[3];
    indices[0] = a;
    indices[1] = b;
    indices[2] = c;
  }
}

class ObjLoader
{
  public ArrayList<Vec2f> points;
  public ArrayList<Triangle> faces;
  ObjLoader(String[] lines)
  {
    points = new ArrayList<Vec2f>();
    faces = new ArrayList<Triangle>();
    
    for (String line : lines)
    {
      //println(line);
      String[] tokens = split(line, ' ');
      println(tokens[0]);
      if (tokens[0].equals("v")) {
        println("processing line : " + line + "\n(as vertex)");
        float[] pts = new float[tokens.length - 1];
        for (int i = 1; i < tokens.length; ++i)
          pts[i - 1] = float(tokens[i]);
        points.add(new Vec2f(pts[0], pts[1]));
      } else if (tokens[0].equals("f")) {
        println("processing line : " + line + "\n(as faces)");
        int[] face = new int[3];
        for (int i = 1; i < tokens.length; ++i) {
          if (i < 4) {
            String[] subtokens = split(tokens[i], '/');
            face[i - 1] = int(subtokens[0]);
          }
        }
        faces.add(new Triangle(face[0], face[1], face[2]));
      }      
    }
  }
}