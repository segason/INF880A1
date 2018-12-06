#pragma once

#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <cmath>

// http://lodev.org/lodepng/
#include "lodepng.h"

using namespace std;

typedef unsigned int uint;
typedef unsigned char uchar;

// image with one 8bit channel
struct Image {
	uint width, height;
	vector<uchar> pixels;
	Image(uint w, uint h) : width(w), height(h), pixels(w*h, 0) {};
	void set(uchar value, uint x, uint y) {
		if (x < 0 || x >= width || y < 0 || y >= height) { return; }
		pixels[width*y + x] = value;
	}
	uchar get(uint x, uint y) { return pixels[width*y + x]; }
	void write(string filename) {
		lodepng::encode(filename, pixels, width, height, LCT_GREY);
	}
};

double min(double a, double b) { return a <= b ? a : b; }
double max(double a, double b) { return a >= b ? a : b; }

struct Vector3 {
	double x, y, z;
	static Vector3 crossProduct(const Vector3& v1, const Vector3& v2) {
		double x = v1.y*v2.z - v2.y*v1.z;
		double y = v1.z*v2.x - v2.z*v1.x;
		double z = v1.x*v2.y - v2.x*v1.y;
		return{ x, y, z };
	}
	double norm() { return sqrt(x*x + y*y + z*z); }
	void normalize() {
		double abs = norm();
		if (abs > 0) { x /= abs; y /= abs; z /= abs; }
	}
};

// axis to project on
struct Axis {
	Vector3 x, y;

	Axis(Vector3 x, Vector3 y) : x(x), y(y) {};
	/*
	* from euler angles (using radians) : http://mathworld.wolfram.com/EulerAngles.html
	*/
	Axis(double theta = 0, double phi = 0, double psi = 0) {

		// coefficients for a rotation using euler angles
		double a11 = cos(psi)*cos(phi) - cos(theta)*sin(phi)*sin(psi);
		double a12 = cos(psi)*sin(phi) + cos(theta)*cos(phi)*sin(psi);
		double a13 = sin(psi)*sin(theta);
		double a21 = -sin(psi)*cos(phi) - cos(theta)*sin(phi)*cos(psi);
		double a22 = -sin(psi)*sin(phi) + cos(theta)*cos(phi)*cos(psi);
		double a23 = cos(psi)*sin(theta);

		x = { a11, a12, a13 }; x.normalize();
		y = { a21, a22, a23 }; y.normalize();
	}
};

const uint nbCameras = 20; // cameras per LightField
const uint nbFields = 10; // number of LightFields

struct Triangle {
	uint v1, v2, v3;
	/*
	* the image goes from -1 to 1
	* [0;0] is the center of the image
	* uses http://www.sunshine2k.de/coding/java/TriangleRasterization/TriangleRasterization.html#algo1
	* HACK : does not crop the triangle, hence out of bounds coordinates would lead to infinite loops !
	* TODO : debug horizontal infinite lines
	*/
private:
	// arguments are pixel coordinates
	void fillBottomFlatTriangle(Image& im, double v1x, double v1y, double v2x, double v2y, double v3x, double v3y) {

		double invslope1 = (v2x - v1x) / (v2y - v1y);
		double invslope2 = (v3x - v1x) / (v3y - v1y);

		double curx1 = v1x;
		double curx2 = v1x;

		for (int scanlineY = (int)v1y; scanlineY <= v2y; scanlineY++)
		{
			int start = (int)min(curx1, curx2);
			int end = (int)max(curx1, curx2);
			for (int x = (int)start; x <= end; x++) {
				im.set(255, x, scanlineY);
			}
			curx1 += invslope1;
			curx2 += invslope2;
		}
	}
	void fillTopFlatTriangle(Image& im, double v1x, double v1y, double v2x, double v2y, double v3x, double v3y) {

		double invslope1 = (v3x - v1x) / (v3y - v1y);
		double invslope2 = (v3x - v2x) / (v3y - v2y);

		double curx1 = v3x;
		double curx2 = v3x;

		for (int scanlineY = (int)v3y; scanlineY > v1y; scanlineY--)
		{
			curx1 -= invslope1;
			curx2 -= invslope2;
			int start = (int)min(curx1, curx2); // TODO : do this only once
			int end = (int)max(curx1, curx2);
			for (int x = (int)start; x <= end; x++) {
				im.set(255, x, scanlineY);
			}
		}
	}
public:
	void draw(Image& im, const vector<double>& vertices) {

		// at first sort the three vertices by y-coordinate ascending so v1 is the topmost vertice
		double v1y = vertices[2 * v1 + 1], v2y = vertices[2 * v2 + 1], v3y = vertices[2 * v3 + 1];
		uint top, mid, bot; // top means lowest y
		if (v1y <= v2y && v1y <= v3y) {
			top = v1;
			if (v2y <= v3y) { mid = v2; bot = v3; }
			else { mid = v3; bot = v2; }
		}
		else if (v2y <= v1y && v2y <= v3y) {
			top = v2;
			if (v1y <= v3y) { mid = v1; bot = v3; }
			else { mid = v3; bot = v1; }
		}
		else {
			top = v3;
			if (v1y <= v2y) { mid = v1; bot = v2; }
			else{ mid = v2; bot = v1; }
		}

		v1 = top; v2 = mid; v3 = bot;
		// TODO : cast (int) ?
		double v1x = (int)vertices[2 * v1 + 0], v2x = (int)vertices[2 * v2 + 0], v3x = (int)vertices[2 * v3 + 0];
		v1y = (int)vertices[2 * v1 + 1], v2y = (int)vertices[2 * v2 + 1], v3y = (int)vertices[2 * v3 + 1];

		// here we know that v1.y <= v2.y <= v3.y
		// check for trivial case of bottom-flat triangle
		if (v2y == v3y) {
			fillBottomFlatTriangle(im, v1x, v1y, v2x, v2y, v3x, v3y);
		}
		// check for trivial case of top-flat triangle
		if (v1y == v2y) {
			fillTopFlatTriangle(im, v1x, v1y, v2x, v2y, v3x, v3y);
		}
		else {
			// general case - split the triangle in a topflat and bottom-flat one
			double v4x = (int)(v1x + ((double)(v2y - v1y) / (double)(v3y - v1y)) * (v3x - v1x));
			double v4y = v2y;
			fillBottomFlatTriangle(im, v1x, v1y, v2x, v2y, v4x, v4y);
			fillTopFlatTriangle(im, v2x, v2y, v4x, v4y, v3x, v3y);
		}
	}
};

// paste here the results of the computeLightFields("../data/cameras/") function
vector<Axis> lightFields = {

	{ { 0.871091, -0.201179, -0.448027 }, { 0, -0.912251, 0.409631 } }, { { 0.982247, 0.110263, 0.151765 }, { 0, -0.809019, 0.587783 } }, { { 0.794654, 0, 0.607063 }, { 0, -1, 0 } }, { { 0.982247, -0.110263, 0.151765 }, { 0, -0.809019, -0.587783 } }, { { 0.871091, 0.201179, -0.448027 }, { 0, -0.912251, -0.409631 } }, { { 0.60706, 0.755763, -0.245562 }, { 0, -0.309017, -0.951057 } }, { { 0.187585, 0, 0.982248 }, { -0, 1, 0 } }, { { 0.60706, -0.755763, -0.245562 }, { 0, -0.309017, 0.951057 } }, { { 0.952821, -0.297591, 0.0597592 }, { -0, 0.19688, 0.980428 } }, { { 0.952821, 0.297591, 0.0597592 }, { 0, -0.19688, 0.980428 } }, { { 0.60706, 0.755763, -0.245562 }, { -0, 0.309017, 0.951057 } }, { { 0.187585, 0, 0.982248 }, { 0, -1, 0 } }, { { 0.60706, -0.755763, -0.245562 }, { 0, 0.309017, -0.951057 } }, { { 0.952821, -0.297591, 0.0597592 }, { 0, -0.19688, -0.980428 } }, { { 0.952821, 0.297591, 0.0597592 }, { 0, 0.19688, -0.980428 } }, { { 0.794654, 0, 0.607063 }, { -0, 1, 0 } }, { { 0.982247, -0.110263, 0.151765 }, { -0, 0.809019, 0.587783 } }, { { 0.871091, 0.201179, -0.448027 }, { -0, 0.912251, 0.409631 } }, { { 0.871091, -0.201179, -0.448027 }, { 0, 0.912251, -0.409631 } }, { { 0.982247, 0.110263, 0.151765 }, { 0, 0.809019, -0.587783 } },
	{ { 0.755105, -0.55944, -0.341823 }, { 0, -0.521386, 0.853321 } }, { { 0.999421, -0.0227387, -0.0253154 }, { 0, -0.743954, 0.668231 } }, { { 0.994726, 0.0014387, 0.102558 }, { 0, -0.999902, 0.0140268 } }, { { 0.900627, 0.199617, -0.386037 }, { 0, -0.888272, -0.459318 } }, { { 0.429283, 0.0506564, -0.901748 }, { 0, -0.998426, -0.0560873 } }, { { 0.369198, 0.716134, 0.592322 }, { 0, 0.63735, -0.770574 } }, { { 0.716125, -0.21732, 0.663278 }, { -0, 0.950292, 0.311359 } }, { { 0.848755, -0.496556, 0.181787 }, { -0, 0.343782, 0.939049 } }, { { 0.98524, 0.158953, -0.0635227 }, { -0, 0.371096, 0.928594 } }, { { 0.878928, 0.453145, 0.148814 }, { 0, -0.312009, 0.950079 } }, { { 0.369198, 0.716134, 0.592322 }, { 0, -0.63735, 0.770574 } }, { { 0.716125, -0.21732, 0.663278 }, { 0, -0.950292, -0.311359 } }, { { 0.848755, -0.496556, 0.181787 }, { 0, -0.343782, -0.939049 } }, { { 0.98524, 0.158953, -0.0635227 }, { 0, -0.371096, -0.928594 } }, { { 0.878928, 0.453145, 0.148814 }, { 0, 0.312009, -0.950079 } }, { { 0.994726, 0.0014387, 0.102558 }, { 0, 0.999902, -0.0140268 } }, { { 0.900627, 0.199617, -0.386037 }, { -0, 0.888272, 0.459318 } }, { { 0.429283, 0.0506564, -0.901748 }, { -0, 0.998426, 0.0560873 } }, { { 0.755105, -0.55944, -0.341823 }, { 0, 0.521386, -0.853321 } }, { { 0.999421, -0.0227387, -0.0253154 }, { 0, 0.743954, -0.668231 } },
	{ { 0.968713, 0.08719, 0.232363 }, { 0, -0.936258, 0.351314 } }, { { 0.556868, 0.31426, 0.768856 }, { 0, -0.925662, 0.378352 } }, { { 0.575048, -0.677501, 0.458598 }, { 0, -0.560551, -0.82812 } }, { { 0.973665, -0.180557, 0.1392 }, { 0, -0.610565, -0.791966 } }, { { 0.99225, 0.0333705, -0.119695 }, { 0, -0.963265, -0.268554 } }, { { 0.656858, 0.189462, -0.729823 }, { 0, -0.967917, -0.251271 } }, { { 0.637098, -0.610259, -0.470839 }, { 0, -0.610858, 0.79174 } }, { { 0.988473, -0.125097, -0.0852769 }, { 0, -0.563263, 0.826278 } }, { { 0.982912, 0.183825, -0.00958098 }, { -0, 0.0520494, 0.998645 } }, { { 0.61184, 0.784744, -0.0991417 }, { -0, 0.12534, 0.992114 } }, { { 0.656858, 0.189462, -0.729823 }, { -0, 0.967917, 0.251271 } }, { { 0.637098, -0.610259, -0.470839 }, { 0, 0.610858, -0.79174 } }, { { 0.988473, -0.125097, -0.0852769 }, { 0, 0.563263, -0.826278 } }, { { 0.982912, 0.183825, -0.00958098 }, { 0, -0.0520494, -0.998645 } }, { { 0.61184, 0.784744, -0.0991417 }, { 0, -0.12534, -0.992114 } }, { { 0.575048, -0.677501, 0.458598 }, { -0, 0.560551, 0.82812 } }, { { 0.973665, -0.180557, 0.1392 }, { -0, 0.610565, 0.791966 } }, { { 0.99225, 0.0333705, -0.119695 }, { -0, 0.963265, 0.268554 } }, { { 0.968713, 0.08719, 0.232363 }, { 0, 0.936258, -0.351314 } }, { { 0.556868, 0.31426, 0.768856 }, { 0, 0.925662, -0.378352 } },
	{ { 0.99727, -0.0167926, -0.071904 }, { 0, -0.973796, 0.227422 } }, { { 0.945143, 0.244359, 0.216781 }, { 0, -0.663633, 0.748058 } }, { { 0.486706, 0.650169, 0.583435 }, { 0, -0.667878, 0.744271 } }, { { 0.584937, -0.459065, 0.668662 }, { 0, -0.82441, -0.565993 } }, { { 0.974231, -0.0960308, 0.20409 }, { 0, -0.904838, -0.425755 } }, { { 0.972502, 0.19714, -0.123998 }, { 0, -0.532422, -0.846479 } }, { { 0.578599, 0.611843, -0.539325 }, { 0, -0.661251, -0.750164 } }, { { 0.696748, -0.221233, -0.682348 }, { 0, -0.951251, 0.308417 } }, { { 0.699624, -0.702395, -0.131028 }, { 0, -0.183381, 0.983042 } }, { { 0.997596, -0.0689078, -0.00738601 }, { 0, -0.106576, 0.994305 } }, { { 0.972502, 0.19714, -0.123998 }, { -0, 0.532422, 0.846479 } }, { { 0.578599, 0.611843, -0.539325 }, { -0, 0.661251, 0.750164 } }, { { 0.696748, -0.221233, -0.682348 }, { 0, 0.951251, -0.308417 } }, { { 0.699624, -0.702395, -0.131028 }, { 0, 0.183381, -0.983042 } }, { { 0.997596, -0.0689078, -0.00738601 }, { 0, 0.106576, -0.994305 } }, { { 0.486706, 0.650169, 0.583435 }, { 0, 0.667878, -0.744271 } }, { { 0.584937, -0.459065, 0.668662 }, { -0, 0.82441, 0.565993 } }, { { 0.974231, -0.0960308, 0.20409 }, { -0, 0.904838, 0.425755 } }, { { 0.99727, -0.0167926, -0.071904 }, { 0, 0.973796, -0.227422 } }, { { 0.945143, 0.244359, 0.216781 }, { 0, 0.663633, -0.748058 } },
	{ { 0.999236, -0.0137196, -0.0365878 }, { 0, -0.936336, 0.351104 } }, { { 0.814551, 0.372015, 0.445097 }, { 0, -0.767288, 0.641303 } }, { { 0.432826, -0.171966, 0.884923 }, { 0, -0.981637, -0.19076 } }, { { 0.876756, -0.344473, 0.335614 }, { 0, -0.697837, -0.716256 } }, { { 0.994951, 0.036326, -0.0935541 }, { 0, -0.932194, -0.36196 } }, { { 0.74571, 0.471859, -0.470388 }, { 0, -0.706002, -0.70821 } }, { { 0.29746, -0.253609, -0.920435 }, { 0, -0.964074, 0.265633 } }, { { 0.82364, -0.428437, -0.371562 }, { 0, -0.655182, 0.755471 } }, { { 0.961649, -0.274247, 0.00448591 }, { -0, 0.016355, 0.999866 } }, { { 0.900563, 0.434358, 0.0178725 }, { 0, -0.0411121, 0.999155 } }, { { 0.74571, 0.471859, -0.470388 }, { -0, 0.706002, 0.70821 } }, { { 0.29746, -0.253609, -0.920435 }, { 0, 0.964074, -0.265633 } }, { { 0.82364, -0.428437, -0.371562 }, { 0, 0.655182, -0.755471 } }, { { 0.961649, -0.274247, 0.00448591 }, { 0, -0.016355, -0.999866 } }, { { 0.900563, 0.434358, 0.0178725 }, { 0, 0.0411121, -0.999155 } }, { { 0.432826, -0.171966, 0.884923 }, { -0, 0.981637, 0.19076 } }, { { 0.876756, -0.344473, 0.335614 }, { -0, 0.697837, 0.716256 } }, { { 0.994951, 0.036326, -0.0935541 }, { -0, 0.932194, 0.36196 } }, { { 0.999236, -0.0137196, -0.0365878 }, { 0, 0.936336, -0.351104 } }, { { 0.814551, 0.372015, 0.445097 }, { 0, 0.767288, -0.641303 } },
	{ { 0.91444, 0.0556205, -0.400882 }, { 0, -0.990512, -0.137429 } }, { { 0.966456, 0.0364274, 0.254236 }, { 0, -0.989891, 0.141833 } }, { { 0.713005, -0.315359, 0.626237 }, { 0, -0.893146, -0.449768 } }, { { 0.949354, -0.286738, 0.128486 }, { 0, -0.40892, -0.91257 } }, { { 0.929326, 0.29635, -0.220295 }, { 0, -0.596584, -0.802551 } }, { { 0.677868, 0.732826, 0.0588262 }, { 0, 0.0800157, -0.996794 } }, { { 0.0800053, 0.152023, 0.985134 }, { 0, 0.988302, -0.152512 } }, { { 0.609794, -0.425962, -0.668362 }, { 0, -0.843295, 0.53745 } }, { { 0.928753, -0.347531, -0.128995 }, { 0, -0.347979, 0.937502 } }, { { 0.960621, 0.217771, 0.172576 }, { 0, -0.621089, 0.78374 } }, { { 0.677868, 0.732826, 0.0588262 }, { 0, -0.0800157, 0.996794 } }, { { 0.0800053, 0.152023, 0.985134 }, { 0, -0.988302, 0.152512 } }, { { 0.609794, -0.425962, -0.668362 }, { 0, 0.843295, -0.53745 } }, { { 0.928753, -0.347531, -0.128995 }, { 0, 0.347979, -0.937502 } }, { { 0.960621, 0.217771, 0.172576 }, { 0, 0.621089, -0.78374 } }, { { 0.713005, -0.315359, 0.626237 }, { -0, 0.893146, 0.449768 } }, { { 0.949354, -0.286738, 0.128486 }, { -0, 0.40892, 0.91257 } }, { { 0.929326, 0.29635, -0.220295 }, { -0, 0.596584, 0.802551 } }, { { 0.91444, 0.0556205, -0.400882 }, { -0, 0.990512, 0.137429 } }, { { 0.966456, 0.0364274, 0.254236 }, { 0, 0.989891, -0.141833 } },
	{ { 0.815136, -0.0907035, -0.572125 }, { 0, -0.987665, 0.156582 } }, { { 0.998849, -0.0290066, -0.0382064 }, { 0, -0.796465, 0.604684 } }, { { 0.82221, 0.170169, 0.543152 }, { 0, -0.954263, 0.298969 } }, { { 0.907846, -0.208721, 0.363665 }, { 0, -0.867304, -0.497779 } }, { { 0.956883, 0.159356, -0.242861 }, { 0, -0.836081, -0.548606 } }, { { 0.871966, 0.476977, -0.110307 }, { 0, -0.225315, -0.974286 } }, { { 0.432989, 0.82768, 0.357025 }, { 0, 0.396079, -0.918216 } }, { { 0.290615, -0.679401, -0.673763 }, { 0, -0.704155, 0.710047 } }, { { 0.752239, -0.640605, 0.154151 }, { -0, 0.233955, 0.972247 } }, { { 0.995267, -0.0954051, -0.0184743 }, { 0, -0.190109, 0.981763 } }, { { 0.871966, 0.476977, -0.110307 }, { -0, 0.225315, 0.974286 } }, { { 0.432989, 0.82768, 0.357025 }, { 0, -0.396079, 0.918216 } }, { { 0.290615, -0.679401, -0.673763 }, { 0, 0.704155, -0.710047 } }, { { 0.752239, -0.640605, 0.154151 }, { 0, -0.233955, -0.972247 } }, { { 0.995267, -0.0954051, -0.0184743 }, { 0, 0.190109, -0.981763 } }, { { 0.82221, 0.170169, 0.543152 }, { 0, 0.954263, -0.298969 } }, { { 0.907846, -0.208721, 0.363665 }, { -0, 0.867304, 0.497779 } }, { { 0.956883, 0.159356, -0.242861 }, { -0, 0.836081, 0.548606 } }, { { 0.815136, -0.0907035, -0.572125 }, { 0, 0.987665, -0.156582 } }, { { 0.998849, -0.0290066, -0.0382064 }, { 0, 0.796465, -0.604684 } },
	{ { 0.969019, 0.00501759, -0.246936 }, { 0, -0.999794, -0.0203152 } }, { { 0.887407, -0.0279289, 0.46014 }, { 0, -0.998163, -0.0605851 } }, { { 0.793254, -0.480899, 0.373476 }, { 0, -0.613371, -0.789795 } }, { { 0.999971, 0.00726586, -0.00247879 }, { 0, -0.322884, -0.946439 } }, { { 0.843811, 0.363381, -0.394888 }, { 0, -0.735853, -0.677141 } }, { { 0.326209, 0.902775, -0.280332 }, { 0, -0.296554, -0.955016 } }, { { 0.418512, -0.869637, -0.261876 }, { 0, -0.288343, 0.957527 } }, { { 0.879101, -0.31507, -0.357647 }, { 0, -0.750359, 0.661031 } }, { { 0.995994, 0.082447, 0.0346109 }, { 0, -0.387072, 0.922049 } }, { { 0.743354, 0.4733, 0.472665 }, { 0, -0.706632, 0.707581 } }, { { 0.326209, 0.902775, -0.280332 }, { -0, 0.296554, 0.955016 } }, { { 0.418512, -0.869637, -0.261876 }, { 0, 0.288343, -0.957527 } }, { { 0.879101, -0.31507, -0.357647 }, { 0, 0.750359, -0.661031 } }, { { 0.995994, 0.082447, 0.0346109 }, { 0, 0.387072, -0.922049 } }, { { 0.743354, 0.4733, 0.472665 }, { 0, 0.706632, -0.707581 } }, { { 0.793254, -0.480899, 0.373476 }, { -0, 0.613371, 0.789795 } }, { { 0.999971, 0.00726586, -0.00247879 }, { -0, 0.322884, 0.946439 } }, { { 0.843811, 0.363381, -0.394888 }, { -0, 0.735853, 0.677141 } }, { { 0.969019, 0.00501759, -0.246936 }, { -0, 0.999794, 0.0203152 } }, { { 0.887407, -0.0279289, 0.46014 }, { -0, 0.998163, 0.0605851 } },
	{ { 0.971437, -0.192482, -0.138783 }, { 0, -0.584848, 0.811143 } }, { { 0.888113, 0.406467, 0.21457 }, { 0, -0.466836, 0.884344 } }, { { 0.676937, 0.187846, 0.711667 }, { 0, -0.966885, 0.255211 } }, { { 0.977713, -0.043653, 0.205359 }, { 0, -0.978145, -0.207924 } }, { { 0.920131, -0.0752991, -0.384302 }, { 0, -0.98134, 0.192281 } }, { { 0.529493, 0.30289, -0.792398 }, { 0, -0.934086, -0.357049 } }, { { 0.216593, -0.882539, 0.417388 }, { -0, 0.427536, 0.903998 } }, { { 0.80102, -0.597599, 0.035237 }, { -0, 0.058862, 0.998266 } }, { { 0.992153, -0.10135, 0.073211 }, { -0, 0.585562, 0.810627 } }, { { 0.848612, 0.495885, -0.184269 }, { -0, 0.348324, 0.937374 } }, { { 0.529493, 0.30289, -0.792398 }, { -0, 0.934086, 0.357049 } }, { { 0.216593, -0.882539, 0.417388 }, { 0, -0.427536, -0.903998 } }, { { 0.80102, -0.597599, 0.035237 }, { 0, -0.058862, -0.998266 } }, { { 0.992153, -0.10135, 0.073211 }, { 0, -0.585562, -0.810627 } }, { { 0.848612, 0.495885, -0.184269 }, { 0, -0.348324, -0.937374 } }, { { 0.676937, 0.187846, 0.711667 }, { 0, 0.966885, -0.255211 } }, { { 0.977713, -0.043653, 0.205359 }, { -0, 0.978145, 0.207924 } }, { { 0.920131, -0.0752991, -0.384302 }, { 0, 0.98134, -0.192281 } }, { { 0.971437, -0.192482, -0.138783 }, { 0, 0.584848, -0.811143 } }, { { 0.888113, 0.406467, 0.21457 }, { 0, 0.466836, -0.884344 } },
	{ { 0.952766, -0.165629, -0.254564 }, { 0, -0.838199, 0.545365 } }, { { 0.914314, 0.193141, 0.355988 }, { 0, -0.878967, 0.476883 } }, { { 0.8387, -0.171292, 0.516954 }, { 0, -0.949247, -0.314532 } }, { { 0.996965, 0.0478492, -0.0614156 }, { 0, -0.788845, -0.614593 } }, { { 0.798396, 0.0969612, -0.594274 }, { 0, -0.98695, -0.16103 } }, { { 0.262807, 0.713494, -0.649507 }, { 0, -0.67317, -0.739488 } }, { { 0.4548, -0.809059, 0.372264 }, { -0, 0.417995, 0.908449 } }, { { 0.876178, -0.470009, -0.106783 }, { 0, -0.221547, 0.97515 } }, { { 0.993185, 0.114737, -0.0204701 }, { -0, 0.175636, 0.984455 } }, { { 0.747074, 0.639913, 0.179979 }, { 0, -0.270751, 0.962649 } }, { { 0.262807, 0.713494, -0.649507 }, { -0, 0.67317, 0.739488 } }, { { 0.4548, -0.809059, 0.372264 }, { 0, -0.417995, -0.908449 } }, { { 0.876178, -0.470009, -0.106783 }, { 0, 0.221547, -0.97515 } }, { { 0.993185, 0.114737, -0.0204701 }, { 0, -0.175636, -0.984455 } }, { { 0.747074, 0.639913, 0.179979 }, { 0, 0.270751, -0.962649 } }, { { 0.8387, -0.171292, 0.516954 }, { -0, 0.949247, 0.314532 } }, { { 0.996965, 0.0478492, -0.0614156 }, { -0, 0.788845, 0.614593 } }, { { 0.798396, 0.0969612, -0.594274 }, { -0, 0.98695, 0.16103 } }, { { 0.952766, -0.165629, -0.254564 }, { 0, 0.838199, -0.545365 } }, { { 0.914314, 0.193141, 0.355988 }, { 0, 0.878967, -0.476883 } },

};

struct Mesh {

	vector<double> vertices = vector<double>();
	vector<Triangle> triangles = vector<Triangle>();

	// the input mesh must be triangulated
	Mesh(string filename) {

		ifstream input;
		input.open(filename);
		if (!input.is_open()) { cerr << "ERROR, cannot open " << filename.c_str() << endl; exit(2); }
		string line;
		while (getline(input, line)) {
			switch (line[0])
			{
			case 'v': {
				char v;
				double x, y, z;
				stringstream ss(line);
				ss >> v >> x >> y >> z;
				vertices.push_back(x);
				vertices.push_back(y);
				vertices.push_back(z);
				break;
			}

			case 'f': {
				char f;
				string s;
				// in wavefront .obj, vertex indexes start at 1, not 0 !
				uint a, b, c, d = -1;
				stringstream ss(line);
				ss >> f >> a;
				getline(ss, s, ' ');
				ss >> b;
				getline(ss, s, ' ');
				ss >> c;
				getline(ss, s, ' ');
				ss >> d;
				triangles.push_back(Triangle{ a - 1, b - 1, c - 1 });
				if (d != -1) { triangles.push_back(Triangle{ a - 1, c - 1, d - 1 }); }
			}
			}
		}
		input.close();
	}

	// center and scale
	void normalize() {

		// centering
		double minX = INFINITY, maxX = -INFINITY;
		double minY = INFINITY, maxY = -INFINITY;
		double minZ = INFINITY, maxZ = -INFINITY;
		for (uint i = 0; i < vertices.size(); i += 3) {
			double x = vertices[i + 0], y = vertices[i + 1], z = vertices[i + 2];
			minX = min(minX, x); maxX = max(maxX, x);
			minY = min(minY, y); maxY = max(maxY, y);
			minZ = min(minZ, z); maxZ = max(maxZ, z);
		}
		double offX = (maxX + minX) / 2;
		double offY = (maxY + minY) / 2;
		double offZ = (maxZ + minZ) / 2;
		for (uint i = 0; i < vertices.size(); i += 3) {
			vertices[i + 0] -= offX;
			vertices[i + 1] -= offY;
			vertices[i + 2] -= offZ;
		}

		// scaling
		double maxRadius = -INFINITY;
		for (uint i = 0; i < vertices.size(); i += 3) {
			double x = vertices[i + 0], y = vertices[i + 1], z = vertices[i + 2];
			maxRadius = max(maxRadius, sqrt(x*x + y*y + z*z));
		}
		if (maxRadius <= 0) { cerr << "ERROR : no vertices, or infinitly small" << endl; return; }
		for (uint i = 0; i < vertices.size(); i += 3) {
			vertices[i + 0] /= maxRadius;
			vertices[i + 1] /= maxRadius;
			vertices[i + 2] /= maxRadius;
		}
	}

	void render(Image& im, const Axis& axis) {

		uint nbVert = vertices.size() / 3;
		vector<double> projection(2 * nbVert);
		int size = min(im.width, im.height);
		for (int i = 0; i < nbVert; i++) {
			double x = vertices[3 * i + 0];
			double y = vertices[3 * i + 1];
			double z = vertices[3 * i + 2];
			double x_proj = axis.x.x *x + axis.x.y * y + axis.x.z * z;
			double y_proj = axis.y.x * x + axis.y.y * y + axis.y.z * z;
			// project from [-1;1] to [0;size]
			projection[2 * i + 0] = size * (x_proj + 1) / 2;
			projection[2 * i + 1] = size * (y_proj + 1) / 2;
		}
		for (auto& tri : triangles) {
			tri.draw(im, projection);
		}
	}

	Image compute(uint size) {
		normalize();
		Image result = Image(size*nbCameras, size*nbFields);
		for (uint field = 0; field < nbFields; field++) {
			for (uint camera = 0; camera < nbCameras; camera++) {
				Image im = Image(size, size);
				render(im, lightFields[field*nbCameras + camera]);
				// pasting the pixels to the result
				for (uint x = 0; x < size; x++) {
					for (uint y = 0; y < size; y++) {
						result.set(im.get(x, y), camera*size + x, field*size + y);
					}
				}
			}
		}
		return result;
	}
};

/*
* This function is only executed at compilation time
* It computes all the axis for each of the LightField camera systems :
* 20 axis per dodecahedron, and 10 dodecahedrons with different rotation offsets
* @folder must contain the 10 dodecahedrons meshes (12_%i.OBJ)
* return array contains all the lightFields [ lightFieldId * nbCameras + cameraId ]
*/
void computeLightFields(string folder) {

	vector<Axis> lightFields(nbCameras*nbFields);
	for (int field = 0; field < nbFields; field++) {
		stringstream filename;
		filename << folder << "12_" << field << ".OBJ";
		Mesh dodecahedron = Mesh(filename.str());
		for (int camera = 0; camera < nbCameras; camera++) {
			double* vert = &dodecahedron.vertices[3 * camera];

			Vector3 x = { 1, 0, 0 }; // TODO : use neighbors instead of horizontal vector
			Vector3 normal = { vert[0], vert[1], vert[2] };
			Vector3 y = Vector3::crossProduct(x, normal);
			if (y.norm() == 0) { y = Vector3::crossProduct({ 0, 1, 0 }, normal); }
			y.normalize();
			x = Vector3::crossProduct(normal, y); x.normalize();
			uint cameraIndex = field * nbCameras + camera;
			lightFields[cameraIndex].x = x;
			lightFields[cameraIndex].y = y;
		}
	}
	for (int field = 0; field < nbFields; field++) {
		for (int camera = 0; camera < nbCameras; camera++) {
			Axis& axis = lightFields[field*nbCameras + camera];
			cout << "{";
			cout << "{" << axis.x.x << ", " << axis.x.y << ", " << axis.x.z << "},";
			cout << "{" << axis.y.x << ", " << axis.y.y << ", " << axis.y.z << "}";
			cout << "},";
		}
		cout << endl;
	}
}
