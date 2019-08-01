package main

import (
	"fmt"
	"math"
	"math/rand"
	"time"
)

const (
	N_RAYS      = 100
	N_TRIANGLES = 1000 * 1000
)

type Vec3 struct {
	X float32
	Y float32
	Z float32
}

func (v1 Vec3) Sub(v2 Vec3) Vec3 {
	return Vec3{
		X: v1.X - v2.X,
		Y: v1.Y - v2.Y,
		Z: v1.Z - v2.Z,
	}
}

func (v1 Vec3) Dot(v2 Vec3) float32 {
	return v1.X*v2.X + v1.Y*v2.Y + v1.Z*v2.Z
}

func (v1 Vec3) Cross(v2 Vec3) Vec3 {
	return Vec3{
		X: v1.Y*v2.Z - v1.Z*v2.Y,
		Y: v1.Z*v2.X - v1.X*v2.Z,
		Z: v1.X*v2.Y - v1.Y*v2.X,
	}
}

func (v1 Vec3) Length() float32 {
	return float32(math.Sqrt(float64(v1.X*v1.X + v1.Y*v1.Y + v1.Z*v1.Z)))
}

func (v1 Vec3) Normalize() Vec3 {
	l := v1.Length()
	return Vec3{
		X: v1.X / l,
		Y: v1.Y / l,
		Z: v1.Z / l,
	}
}

type Ray struct {
	Origin    Vec3
	Direction Vec3
}

func RayTriangleIntersect(r Ray, v0, v1, v2 Vec3) float32 {
	v0v1 := v1.Sub(v0)
	v0v2 := v2.Sub(v0)
	pvec := r.Direction.Cross(v0v2)

	det := v0v1.Dot(pvec)

	if det < 0.000001 {
		return float32(math.MinInt32)
	}

	invDet := 1.0 / det
	tvec := r.Origin.Sub(v0)
	u := tvec.Dot(pvec) * invDet

	if u < 0 || u > 1 {
		return float32(math.MinInt32)
	}

	qvec := tvec.Cross(v0v1)
	v := r.Direction.Dot(qvec) * invDet

	if v < 0 || u+v > 1 {
		return float32(math.MinInt32)
	}

	return v0v2.Dot(qvec) * invDet
}

func randomVertex() Vec3 {
	return Vec3{
		X: rand.Float32()*2.0 - 1.0,
		Y: rand.Float32()*2.0 - 1.0,
		Z: rand.Float32()*2.0 - 1.0,
	}
}

func randomSphere() Vec3 {
	r1 := rand.Float32()
	r2 := rand.Float32()
	lat := math.Acos(2*float64(r1-1)) - math.Pi/2
	lon := float64(2 * math.Pi * r2)

	return Vec3{
		X: float32(math.Cos(lat) * math.Cos(lon)),
		Y: float32(math.Cos(lat) * math.Sin(lon)),
		Z: float32(math.Sin(lat)),
	}
}

func generateRandomTriangles(n int) []Vec3 {
	vertices := make([]Vec3, n*3)

	for i := 0; i < n; i++ {
		vertices[i*3+0] = randomVertex()
		vertices[i*3+1] = randomVertex()
		vertices[i*3+2] = randomVertex()
	}

	return vertices
}

func main() {
	rand.Seed(0)

	vertices := generateRandomTriangles(N_TRIANGLES)
	nVertices := N_TRIANGLES * 3

	nHit := 0
	nMiss := 0

	r := Ray{}

	start := time.Now()

	for i := 0; i < N_RAYS; i++ {
		r.Origin = randomSphere()
		r.Direction = randomSphere().Sub(r.Origin).Normalize()

		for j := 0; j < int(nVertices/3); j++ {
			t := RayTriangleIntersect(r, vertices[j*3+0], vertices[j*3+1], vertices[j*3+2])

			if t >= 0 {
				nHit++
			} else {
				nMiss++
			}
		}
	}

	total := time.Since(start)

	nTests := N_RAYS * N_TRIANGLES
	hitPerc := (float32(nHit) / float32(nTests)) * 100
	missPerc := (float32(nMiss) / float32(nTests)) * 100
	mtestsPerSecond := float32(nTests) / float32(total.Seconds()) / 1000000

	fmt.Printf("Total intersection tests:\t %d\n", nTests)
	fmt.Printf("Hits:\t\t\t\t %d (%.2f)\n", nHit, hitPerc)
	fmt.Printf("Misses:\t\t\t\t %d (%.2f)\n\n", nMiss, missPerc)
	fmt.Printf("Total time:\t\t\t %.2f seconds\n", total.Seconds())
	fmt.Printf("Millions of tests per second:\t %6.2f\n", mtestsPerSecond)
}
