// Run with: javac Ray.java Vec3.java PerfTest.java && java -cp . PerfTest

import static java.lang.Float.NEGATIVE_INFINITY;
import static java.lang.Math.*;
import static java.lang.System.currentTimeMillis;


class PerfTest {

  static float rayTriangleIntersect(Ray r, Vec3 v0, Vec3 v1, Vec3 v2) {
    Vec3 v0v1 = v1.sub(v0);
    Vec3 v0v2 = v2.sub(v0);
    Vec3 pvec = r.dir.cross(v0v2);
    float det = v0v1.dot(pvec);

    if (det < 0.000001)
      return NEGATIVE_INFINITY;

    float invDet = (float) (1.0 / det);
    Vec3 tvec = r.orig.sub(v0);
    float u = tvec.dot(pvec) * invDet;

    if (u < 0 || u > 1)
      return NEGATIVE_INFINITY;

    Vec3 qvec = tvec.cross(v0v1);
    float v = r.dir.dot(qvec) * invDet;

    if (v < 0 || u + v > 1)
      return NEGATIVE_INFINITY;

    return (float) (v0v2.dot(qvec) * invDet);
  }

  static Vec3 randomVertex() {
    return new Vec3((float) (random() * 2.0 - 1.0),
                    (float) (random() * 2.0 - 1.0),
                    (float) (random() * 2.0 - 1.0));
  }

  static Vec3[] generateRandomTriangles(int numTriangles) {
    Vec3[] vertices = new Vec3[numTriangles * 3];

    for (int i = 0; i < numTriangles; ++i) {
      vertices[i*3 + 0] = randomVertex();
      vertices[i*3 + 1] = randomVertex();
      vertices[i*3 + 2] = randomVertex();
    }

    return vertices;
  }

  static Vec3 randomSphere() {
    double r1 = random();
    double r2 = random();
    double lat = acos(2*r1 - 1) - PI/2;
    double lon = 2*PI * r2;

    return new Vec3((float) (cos(lat) * cos(lon)),
                    (float) (cos(lat) * sin(lon)),
                    (float) (sin(lat)));
  }


  final static int NUM_RAYS = 100;
  final static int NUM_TRIANGLES = 1000 * 1000;

  public static void main(String[] args) {

    Vec3[] vertices = generateRandomTriangles(NUM_TRIANGLES);
    int numVertices = NUM_TRIANGLES * 3;

    int numHit = 0;
    int numMiss = 0;

    Ray r = new Ray();

    long tStart = currentTimeMillis();

    for (int i = 0; i < NUM_RAYS; ++i) {
      r.orig = randomSphere();
      r.dir = randomSphere().sub(r.orig).normalize();

      for (int j = 0; j < numVertices / 3; ++j) {
        float t = rayTriangleIntersect(r,
                                        vertices[j*3 + 0],
                                        vertices[j*3 + 1],
                                        vertices[j*3 + 2]);
        if (t >= 0) {
          ++numHit;
        } else {
          ++numMiss;
        }
      }
    }

    long tEnd = currentTimeMillis();

    double tTotal = (tEnd - tStart) / 1000.0;

    int numTests = NUM_RAYS * NUM_TRIANGLES;
    double hitPerc  = ((float) numHit  / numTests) * 100.0;
    double missPerc = ((float) numMiss / numTests) * 100.0;
    double mTestsPerSecond = (float) numTests / tTotal / 1000000.0;

    System.out.printf("Total intersection tests:  %,11d\n", numTests);
    System.out.printf("  Hits:\t\t\t   %,11d (%5.2f%%)\n", numHit, hitPerc);
    System.out.printf("  Misses:\t\t   %,11d (%5.2f%%)\n", numMiss, missPerc);
    System.out.printf("\n");
    System.out.printf("  Total time:\t\t\t  %6.2f seconds\n", tTotal);
    System.out.printf("  Millions of tests per second:\t  %6.2f\n", mTestsPerSecond);
  }

}

