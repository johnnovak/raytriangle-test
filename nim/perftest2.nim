import math

type Vec3 = ref object
  x, y, z: float32

type Ray = ref object
  dir, orig: Vec3

proc vec3(x, y, z: float32): Vec3 =
  Vec3(x: x, y: y, z: z)

proc `-`(a, b: Vec3): Vec3 =
  result = vec3(a.x - b.x, a.y - b.y, a.z - b.z)

proc `*`(v: Vec3, s: float32): Vec3 =
  result = vec3(v.x * s, v.y * s, v.z * s)

proc dot(a, b: Vec3): float32 =
  result = a.x * b.x + a.y * b.y + a.z * b.z

proc cross(a, b: Vec3): Vec3 =
  result = vec3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x)

proc len*(v: Vec3): float32 =
  result = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

proc normalize*(v: Vec3): Vec3 =
  let len = v.len
  result = vec3(v.x / len, v.y / len, v.z / len)


include "raytriangle.nim"

include "testgen.nim"
include "test.nim"

