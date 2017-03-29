import math, random

randomize()

proc randomSphere(): Vec3 =
  let
    r1 = random(1.0)
    r2 = random(1.0)
    lat = arccos(2*r1 - 1) - PI/2
    lon = 2*PI * r2

  result = vec3(cos(lat) * cos(lon),
                cos(lat) * sin(lon),
                sin(lat))

proc generateRandomTriangles(numTriangles: int): seq[Vec3] =
  result = newSeq[Vec3](numTriangles * 3)

  for i in 0..<numTriangles:
    result[i*3 + 0] = randomSphere()
    result[i*3 + 1] = randomSphere()
    result[i*3 + 2] = randomSphere()

