import static java.lang.Math.*;


public class Vec3 {

    public float x;
    public float y;
    public float z;

    public Vec3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vec3 sub(Vec3 v) {
        return new Vec3(this.x - v.x,
                        this.y - v.y,
                        this.z - v.z);
    }

    public float dot(Vec3 v) {
      return this.x * v.x +
             this.y * v.y +
             this.z * v.z;
    }

    public Vec3 cross(Vec3 v) {
        return new Vec3(
            this.y * v.z - this.z * v.y,
            this.z * v.x - this.x * v.z,
            this.x * v.y - this.y * v.x
        );
    }

    public float length() {
        return (float) sqrt(x*x + y*y + z*z);
    }

    public Vec3 normalize() {
        float len = length();
        return new Vec3(x/len, y/len, z/len);
    }

    public String toString() {
        return "[" + x + ", " + y + ", " + z + "]";
    }

};
