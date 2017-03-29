proc rayTriangleIntersect(r: Ray, v0, v1, v2: Vec3): float32 =
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

