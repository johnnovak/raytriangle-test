function Vec3(x, y, z) {
  this.x = x;
  this.y = y;
  this.z = z;
}

Vec3.prototype.sub = function(v) {
  return new Vec3(this.x - v.x,
                  this.y - v.y,
                  this.z - v.z);
}

Vec3.prototype.dot = function(v) {
  return this.x * v.x +
         this.y * v.y +
         this.z * v.z;
}

Vec3.prototype.cross = function(v) {
  return new Vec3(
      this.y * v.z - this.z * v.y,
      this.z * v.x - this.x * v.z,
      this.x * v.y - this.y * v.x
  );
}

Vec3.prototype.length = function(v) {
  return Math.sqrt(this.x * this.x +
                   this.y * this.y +
                   this.z * this.z);
}

Vec3.prototype.normalize = function(v) {
  var len = this.length();
  return new Vec3(
      this.x / len,
      this.y / len,
      this.z / len
  );
}


function Ray(orig, dir) {
  this.orig = orig;
  this.dir = dir;
}


function rayTriangleIntersect(r, v0, v1, v2) {
  var
    v0v1 = v1.sub(v0),
    v0v2 = v2.sub(v0),
    pvec = r.dir.cross(v0v2);

  var det = v0v1.dot(pvec);

  if (det < 0.000001)
    return Number.NEGATIVE_INFINITY;

  var
    invDet = 1.0 / det,
    tvec = r.orig.sub(v0),
    u = tvec.dot(pvec) * invDet;

  if (u < 0 || u > 1)
    return Number.NEGATIVE_INFINITY;

  var
    qvec = tvec.cross(v0v1),
    v = r.dir.dot(qvec) * invDet;

  if (v < 0 || u + v > 1)
    return Number.NEGATIVE_INFINITY;

  return v0v2.dot(qvec) * invDet;
}


function randomVertex() {
  return new Vec3(Math.random() * 2.0 - 1.0,
                  Math.random() * 2.0 - 1.0,
                  Math.random() * 2.0 - 1.0);
}

function generateRandomTriangles(numTriangles) {
  var vertices = new Array(numTriangles * 3);

  for (var i = 0; i < numTriangles; ++i) {
    vertices[i*3 + 0] = randomVertex();
    vertices[i*3 + 1] = randomVertex();
    vertices[i*3 + 2] = randomVertex();
  }

  return vertices;
}

function randomSphere() { 
  var
    r1 = Math.random(),
    r2 = Math.random(),
    lat = Math.acos(2*r1 - 1) - Math.PI/2,
    lon = 2*Math.PI * r2;

  return new Vec3(Math.cos(lat) * Math.cos(lon),
                  Math.cos(lat) * Math.sin(lon),
                  Math.sin(lat));
}


const
  NUM_RAYS = 100,
  NUM_TRIANGLES = 1000 * 1000;

var
  vertices = generateRandomTriangles(NUM_TRIANGLES),
  numVertices = NUM_TRIANGLES * 3;

var
  numHit = 0,
  numMiss = 0;

var r = new Ray();

var tStart = process.hrtime();
// For browser testing
//var tStart = performance.now();

for (var i = 0; i < NUM_RAYS; ++i) {
  r.orig = randomSphere();
  r.dir = randomSphere().sub(r.orig).normalize();

  for (var j = 0; j < numVertices / 3; ++j) {
    var t = rayTriangleIntersect(r, vertices[j*3 + 0],
                                    vertices[j*3 + 1],
                                    vertices[j*3 + 2]);
    if (t >= 0) {
      ++numHit;
    } else {
      ++numMiss;
    }
  }
}

var
  tEnd = process.hrtime(tStart),
  tTotal = tEnd[0] + tEnd[1] / 1000 / 1000000
  // For browser testing
  //tTotal = (performance.now() - tStart) / 1000

console.log(tTotal)

var
  numTests = NUM_RAYS * NUM_TRIANGLES,
  hitPerc  = (numHit  / numTests) * 100,
  missPerc = (numMiss / numTests) * 100,
  mTestsPerSecond = numTests / tTotal / 1000000;

console.log('Total intersection tests:  %d', numTests);
console.log('  Hits:\t\t\t   %d (%d%)', numHit, hitPerc.toFixed(2));
console.log('  Misses:\t\t   %d (%d%)', numMiss, missPerc.toFixed(2));
console.log('');
console.log('  Total time:\t\t\t  %d seconds', tTotal.toFixed(2));
console.log('  Millions of tests per second:\t  %d', mTestsPerSecond.toFixed(2));

// For browser testing
//console.log(mTestsPerSecond);

