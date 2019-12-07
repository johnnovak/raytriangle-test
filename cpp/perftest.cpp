// Compile with: gcc -std=c++11 -lm -O3 -ffast-math -o perftest perftest.cpp

#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>


/* Vector maths */

struct Vec3
{
  float x;
  float y;
  float z;
};

struct Ray
{
  Vec3 orig;
  Vec3 dir;
};

Vec3 sub(Vec3 a, Vec3 b)
{
  return {a.x - b.x, a.y - b.y, a.z - b.z};
}

float dot(Vec3 a, Vec3 b)
{
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

float len(Vec3 v)
{
  return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vec3 normalize(Vec3 v)
{
  float l = len(v);
  return { v.x / l, v.y / l, v.z / l };
}

Vec3 cross(Vec3 a, Vec3 b)
{
  return {
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  };
}


/* Ray-triangle intersection routine */

float rayTriangleIntersect(Ray *r, Vec3 *v0, Vec3 *v1, Vec3 *v2)
{
  Vec3 v0v1 = sub(*v1, *v0);
  Vec3 v0v2 = sub(*v2, *v0);

  Vec3 pvec = cross(r->dir, v0v2);

  float det = dot(v0v1, pvec);

  bool mask1 = (det >= 0.000001);

  float invDet = 1.0 / det;

  Vec3 tvec = sub(r->orig, *v0);

  float u = dot(tvec, pvec) * invDet;

  bool mask2 = (u >= 0) & (u <= 1);

  Vec3 qvec = cross(tvec, v0v1);

  float v = dot(r->dir, qvec) * invDet;

  bool mask3 = (v >= 0) & ((u + v) <= 1);

  bool all_masks = mask1 & mask2 & mask3;

  float result = dot(v0v2, qvec) * invDet;

  return all_masks ? result : -INFINITY;
}


/* Test data generation */

Vec3 *allocTriangles(int numTriangles)
{
  return (Vec3 *) malloc(sizeof(Vec3) * numTriangles * 3);
}

Vec3 randomSphere()
{
  double r1 = (float) rand() / RAND_MAX;
  double r2 = (float) rand() / RAND_MAX;
  double lat = acos(2*r1 - 1) - M_PI/2;
  double lon = 2*M_PI * r2;

  return {
    (float) (cos(lat) * cos(lon)),
    (float) (cos(lat) * sin(lon)),
    (float) sin(lat)
  };
}

Vec3 *generateRandomTriangles(int numTriangles)
{
  Vec3 *vertices = allocTriangles(numTriangles);

  for (int i = 0; i < numTriangles; ++i)
  {
    vertices[i*3 + 0] = randomSphere();
    vertices[i*3 + 1] = randomSphere();
    vertices[i*3 + 2] = randomSphere();
  }

  return vertices;
}


long ellapsedMs(struct timeval t0, struct timeval t1)
{
  return 1000 * (t1.tv_sec  - t0.tv_sec) +
                (t1.tv_usec - t0.tv_usec) / 1000;
}

int main()
{
  const int NUM_RAYS = 1000;
  const int NUM_TRIANGLES = 100 * 1000;

  srand(time(NULL));

  Vec3 *vertices = generateRandomTriangles(NUM_TRIANGLES);
  const int numVertices = NUM_TRIANGLES * 3;

  int numHit = 0;
  int numMiss = 0;

  Ray r;

  struct timeval tStart;
  gettimeofday(&tStart, 0);

  for (int i = 0; i < NUM_RAYS; ++i)
  {
    r.orig = randomSphere();
    Vec3 p1 = randomSphere();
    r.dir  = normalize((sub(p1, r.orig)));

    for (int j = 0; j < numVertices / 3; ++j)
    {
      float t = rayTriangleIntersect(&r,
                                     &vertices[j*3 + 0],
                                     &vertices[j*3 + 1],
                                     &vertices[j*3 + 2]);
      t >= 0 ? ++numHit : ++numMiss;
    }
  }

  struct timeval tEnd;
  gettimeofday(&tEnd, 0);

  double tTotal = (float) ellapsedMs(tStart, tEnd) / 1000.0;

  int numTests = NUM_RAYS * NUM_TRIANGLES;
  float hitPerc  = ((float) numHit  / numTests) * 100.0f;
  float missPerc = ((float) numMiss / numTests) * 100.0f;
  float mTestsPerSecond = (float) numTests / tTotal / 1000000.0f;

  setlocale(LC_NUMERIC, "");

  printf("Total intersection tests:  %'10i\n", numTests);
  printf("  Hits:\t\t\t    %'10i (%5.2f%%)\n", numHit, hitPerc);
  printf("  Misses:\t\t    %'10i (%5.2f%%)\n", numMiss, missPerc);
  printf("\n");
  printf("Total time:\t\t\t%6.2f seconds\n", tTotal);
  printf("Millions of tests per second:\t%6.2f\n", mTestsPerSecond);
}

