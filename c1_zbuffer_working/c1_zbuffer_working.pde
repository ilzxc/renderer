boolean inTriangle(Triangle t, Vector p)
{
  /// Compute barycentric coordinates & return false if any of them are negative:
  float alpha = ((t.p1.y - t.p2.y) * (p.x - t.p2.x) + (t.p2.x - t.p1.x) * (p.y - t.p2.y)) /
    ((t.p1.y - t.p2.y) * (t.p0.x - t.p2.x) + (t.p2.x - t.p1.x) * (t.p0.y - t.p2.y));
  if (alpha < 0) 
    return false;
  
  float beta = ((t.p2.y - t.p0.y) * (p.x - t.p2.x) + (t.p0.x - t.p2.x) * (p.y - t.p2.y)) /
    ((t.p1.y - t.p2.y) * (t.p0.x - t.p2.x) + (t.p2.x - t.p1.x) * (t.p0.y - t.p2.y));
  if (beta < 0) 
    return false;
  
  float gamma = 1.0f - alpha - beta;
  if (gamma < 0) 
    return false;
  
  /// If all barycentric coordinates are >= 0, the point lies in our triangle:
  return true;
}

Vector barycentric(Vector A, Vector B, Vector C, Vector P)
{
  Vector v0 = new Vector(B.x - A.x, B.y - A.y, B.z - A.z );
  Vector v1 = new Vector(C.x - A.x, C.y - A.y, C.z - A.z );
  Vector v2 = new Vector(P.x - A.x, P.y - A.y, P.z - A.z );
  float d00 = v0.dot(v0);
  float d01 = v0.dot(v1);
  float d11 = v1.dot(v1);
  float d20 = v2.dot(v0);
  float d21 = v2.dot(v1);
  
  float denom = d00 * d11 - d01 * d01;
  float v = (d11 * d20 - d01 * d21 ) / denom;
  float w = (d00 * d21 - d01 * d20 ) / denom;
  float u = 1.0f - v - w;
  
  if (abs(u) > 1e-2) return new Vector(v, w, u);
  return new Vector(-1, 1, 1);
  
  //Vector s0 = new Vector(C.x - A.x, B.x - A.x, A.x - P.x);
  //Vector s1 = new Vector(C.y - A.y, B.y - A.y, A.y - P.y);
  //Vector u = s1.cross(s0);
  //if (abs(u.z) > 1e-2) // u.z should be an integer value, if it is zero, then ABC is degenerate
  //  return new Vector(1.f - (u.x + u.y) / u.z, u.y / u.z, u.x / u.z);
  //return new Vector(-1, 1, 1); // negative coordinates will be thrown away by the rasterizer
  
}

void fillTriangle(Triangle t, color col, float[] zbuffer)
{
  BBox bbox = BoundingBox(t);  
  Vector iter = new Vector(0, 0);
  for (iter.x = bbox.topLeft.x; iter.x <= bbox.botRight.x; ++iter.x) 
  {
    for (iter.y = bbox.topLeft.y; iter.y <= bbox.botRight.y; ++iter.y) 
    {
      Vector bc_screen = barycentric(t.p0, t.p1, t.p2, iter);
      if (bc_screen.x < 0 || bc_screen.y < 0 || bc_screen.z < 0) continue;
      iter.z = 0;
      iter.z += t.p0.z * bc_screen.x;
      iter.z += t.p1.z * bc_screen.y;
      iter.z += t.p2.z * bc_screen.z;
      int idx = int(iter.x) + int(iter.y * width);
      if (idx >= zbuffer.length) continue;
      if (zbuffer[idx] < iter.z) {
        if (inTriangle(t, iter)) {
          zbuffer[idx] = iter.z;
          set(int(iter.x), int(iter.y), col);
        }
      } 
    }
  }
}

ObjLoader test;
Vector[] points = new Vector[3];
Vector lightDir;

float[] zbuffer;
void clearout(float[] zbuf) {
  for (int i = 0; i < zbuf.length - 1; ++i)
    zbuf[i] = -Float.MAX_VALUE;
}

void setup()
{  
  size(750, 750);
  background(0);
  //noLoop();
  
  zbuffer = new float[width * height];
  clearout(zbuffer);
  
  lightDir = new Vector(0.2f, -0.3f, 3.f);
  lightDir = lightDir.normalize();
  
  test = new ObjLoader(loadStrings("african_head.obj"));
  println("done loading file");
  
  points[0] = new Vector(0, 0);
  points[1] = new Vector(0, 0);
  points[2] = new Vector(0, 0);
  
  for (Face t : test.faces) {
    for (int i = 0; i < 3; ++i) {
      Vector pt = test.points.get(t.indices[i] - 1);
      points[i].x = (pt.x + 1.0f) * (width / 2.0f);
      points[i].y = height - (pt.y + 1.0f) * (height / 2.0f);
      points[i].z = (pt.z + 1.0f) * (width / 2.0f);
    }
    Vector n = (points[2].sub(points[0])).cross(points[1].sub(points[0]));
    float intensity = n.dot(lightDir) * 0.1f;
    if (intensity > 0) {
      Triangle tr = new Triangle(points[0], points[1], points[2]);
      fillTriangle(tr, color(int(intensity * 255)), zbuffer);
    }
  }
}

void draw()
{
  lightDir.x = 3 * sin(millis() * .003f);
  lightDir.z = 3 * cos(millis() * .003f);
  lightDir.normalize();
  background(0);
  clearout(zbuffer);
  
  for (Face t : test.faces) {
    for (int i = 0; i < 3; ++i) {
      Vector pt = test.points.get(t.indices[i] - 1);
      points[i].x = int((pt.x + 1.0f) * (width / 2.0f));
      points[i].y = int(height - (pt.y + 1.0f) * (height / 2.0f));
      points[i].z = int((pt.z + 1.0f) * (width / 2.0f));
    }
    Vector n = ((points[2].sub(points[0])).cross(points[1].sub(points[0]))).normalize();
    float intensity = n.dot(lightDir);
    
    Triangle tr = new Triangle(points[0], points[1], points[2]);
    if (intensity > 0) {
      fillTriangle(tr, color(intensity * 64), zbuffer);
    }
  }
}