#include "MeshRenderer.h"
#include <time.h>

void testTriangle();

int main(int argc, char* argv[]) {

	uint size = 256;

	if (argc < 3) {
		cout << "console line arguments are : " << endl;
		cout << "mesh.obj output.png <imageSize=" << size << ">" << endl;
	}
	else {
		Mesh mesh(argv[1]);
		if (argc > 3) { size = stoi(argv[3]); }
		mesh.compute(size).write(argv[2]);
	}
}
