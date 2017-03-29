import glm

type Ray = ref object
  dir, orig: Vec3[float32]

include "raytriangle.nim"

include "testgenglm.nim"
include "test.nim"

