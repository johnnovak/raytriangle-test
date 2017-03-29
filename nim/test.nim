import strutils, times

let NUM_RAYS = 100
let NUM_TRIANGLES = 1_000_000

let vertices = generateRandomTriangles(NUM_TRIANGLES)

var
  r = Ray()
  numHit = 0
  numMiss = 0

let tStart = epochTime()

for i in 0..<NUM_RAYS:
  r.orig = randomSphere()
  let p1 = randomSphere()
  r.dir = (p1 - r.orig).normalize

  for j in 0..<(vertices.len / 3).int:
    let t = rayTriangleIntersect(r, vertices[j*3 + 0],
                                    vertices[j*3 + 1],
                                    vertices[j*3 + 2])
    if t >= 0:
      numHit += 1
    else:
      numMiss += 1

let tTotal = epochTime() - tStart

let numTests = NUM_TRIANGLES * NUM_RAYS
let percHit  = numHit.float  / numTests.float * 100
let percMiss = numMiss.float / numTests.float * 100
let mTestsPerSecond = numTests.float / tTotal / 1_000_000

proc float2(f: float): string =
  formatFloat(f, format = ffDecimal, precision = 2)

proc sep(s: string): string =
  insertSep(s, ',')

proc perc(p: float): string =
  align(float2(p), 5) & "%"

echo "Total intersection tests:  " & align(sep($numTests), 10)
echo "  Hits:  \t\t    " & align(sep($numHit),   10) & " (" & perc(percHit)  & ")"
echo "  Misses:\t\t    " & align(sep($numMiss),  10) & " (" & perc(percMiss) & ")"
echo ""
echo "Total time:\t\t\t" & align(float2(tTotal), 6) & " seconds"
echo "Millions of tests per second:\t" & align(float2(mTestsPerSecond), 6)

