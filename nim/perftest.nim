import math, random, times
import vecmath

proc rayTriangleIntersect*(r: Ray, v0, v1, v2: Vec3): float =
  let
    v0v1 = v1 - v0
    v0v2 = v2 - v0
    pvec = r.dir.cross(v0v2)
    det = v0v1.dot(pvec)

  if det < 0.000001:
    return NegInf

  let
    invDet = 1 / det
    tvec = r.orig - v0
    u = tvec.dot(pvec) * invDet

  if u < 0 or u > 1:
    return NegInf

  let
    qvec = tvec.cross(v0v1)
    v = r.dir.dot(qvec) * invDet

  if v < 0 or u + v > 1:
    return NegInf

  result = v0v2.dot(qvec) * invDet


proc randomSphere(): Vec3 =
  let
    r1 = random(1.0)
    r2 = random(1.0)
    lat = arccos(2*r1 - 1) - PI/2
    lon = 2*PI * r2

  result = vec3(cos(lat) * cos(lon),
                cos(lat) * sin(lon),
                sin(lat))


when isMainModule:
  randomize()

  let
    v1 = vec3(-2.0, -1.0, -5.0)
    v2 = vec3( 2.0, -1.0, -5.0)
    v3 = vec3( 0.0,  1.0, -5.0)

  let
    r = Ray(orig: vec3(0.0, 0.0, 0.0), dir: vec3(0.0, 0.0, -1.0))

  let tStart = epochTime()

  let N = 100_000_000
  var t = 0.0

  for i in 0..<N:
    t = rayTriangleIntersect(r, v1, v2, v3)

  let tTotal = epochTime() - tStart

  echo t

  echo "Total time: " & $tTotal & "s"
  echo "Millions of intersections per second: " & $(N.float / tTotal / 1_000_000)

