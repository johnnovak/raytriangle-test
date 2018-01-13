import std.stdio;
import std.math;
import core.time;
import std.random;

auto rnd = Random();

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

pragma(inline, true) Vec3 sub(Vec3 a, Vec3 b)
{
	return Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
}

pragma(inline, true) float dot(Vec3 a, Vec3 b)
{
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

pragma(inline, true) float len(Vec3 v)
{
	return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

pragma(inline, true) Vec3 normalize(Vec3 v)
{
	float l = len(v);
	return Vec3(v.x / l, v.y / l, v.z / l);
}

pragma(inline, true) Vec3 cross(Vec3 a, Vec3 b)
{
	return Vec3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

/* Ray-triangle intersection routine */

pragma(inline, true) float rayTriangleIntersect(Ray r, Vec3 v0, Vec3 v1, Vec3 v2)
{
	Vec3 v0v1 = sub(v1, v0);
	Vec3 v0v2 = sub(v2, v0);

	Vec3 pvec = cross(r.dir, v0v2);

	float det = dot(v0v1, pvec);

	if (det < 0.000001)
		return -float.infinity;

	float invDet = 1.0 / det;

	Vec3 tvec = sub(r.orig, v0);

	float u = dot(tvec, pvec) * invDet;

	if (u < 0 || u > 1)
		return -float.infinity;

	Vec3 qvec = cross(tvec, v0v1);

	float v = dot(r.dir, qvec) * invDet;

	if (v < 0 || u + v > 1)
		return -float.infinity;

	return dot(v0v2, qvec) * invDet;
}

/* Test data generation */

Vec3[] allocTriangles(int numTriangles)
{
	return new Vec3[numTriangles * 3];
}

pragma(inline, true) Vec3 randomSphere()
{
	double r1 = uniform(0.0, 1.0, rnd); //cast(float)(rand() / RAND_MAX);
	double r2 = uniform(0.0, 1.0, rnd); //cast(float)(rand() / RAND_MAX);
	double lat = acos(2 * r1 - 1) - PI / 2;
	double lon = 2 * PI * r2;

	return Vec3(cast(float)(cos(lat) * cos(lon)),
			cast(float)(cos(lat) * sin(lon)), cast(float) sin(lat));
}

Vec3[] generateRandomTriangles(int numTriangles)
{
	Vec3[] vertices = allocTriangles(numTriangles);

	for (int i = 0; i < numTriangles; ++i)
	{
		vertices[i * 3 + 0] = randomSphere();
		vertices[i * 3 + 1] = randomSphere();
		vertices[i * 3 + 2] = randomSphere();
	}

	return vertices;
}

int main()
{
	const int NUM_RAYS = 1000;
	const int NUM_TRIANGLES = 100 * 1000;

	Vec3[] vertices = generateRandomTriangles(NUM_TRIANGLES);
	const int numVertices = NUM_TRIANGLES * 3;

	int numHit = 0;
	int numMiss = 0;

	Ray r;

	MonoTime tStart = MonoTime.currTime;

	for (int i = 0; i < NUM_RAYS; ++i)
	{
		r.orig = randomSphere();
		Vec3 p1 = randomSphere();
		r.dir = normalize(sub(p1, r.orig));

		for (int j = 0; j < numVertices / 3; ++j)
		{
			float t = rayTriangleIntersect(r, vertices[j * 3 + 0],
					vertices[j * 3 + 1], vertices[j * 3 + 2]);
			t >= 0 ? ++numHit : ++numMiss;
		}
	}

	MonoTime tEnd = MonoTime.currTime;

	Duration elapsed = tEnd - tStart;
	double tTotal = (elapsed.total!"msecs") / 1000.0;

	int numTests = NUM_RAYS * NUM_TRIANGLES;
	float hitPerc = (cast(float) numHit / numTests) * 100.0f;
	float missPerc = (cast(float) numMiss / numTests) * 100.0f;
	float mTestsPerSecond = (numTests / tTotal) / 1_000_000.0f;

	writefln("Total intersection tests:   %10d", numTests);
	writefln("  Hits:\t\t\t    %10d (%5.2f%%)", numHit, hitPerc);
	writefln("  Misses:\t\t    %10d (%5.2f%%)", numMiss, missPerc);
	writefln("");
	writefln("Total time:\t\t\t%6.2f seconds", tTotal);
	writefln("Millions of tests per second:\t%6.2f", mTestsPerSecond);

	return 0;
}
