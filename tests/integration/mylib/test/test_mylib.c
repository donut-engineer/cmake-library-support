#include "mylib/mylib.h"

/* Plain-C test driver for the C consumer build. Returns non-zero on failure so
   CTest reports it; uses explicit checks (not assert) so it works under NDEBUG. */
int main(void) {
    if (mylib_add(1, 2) != 3) return 1;
    if (mylib_add(-1, 1) != 0) return 1;
    if (mylib_add(0, 0) != 0) return 1;
    if (mylib_add(-5, -3) != -8) return 1;

    if (mylib_subtract(5, 3) != 2) return 1;
    if (mylib_subtract(0, 0) != 0) return 1;
    if (mylib_subtract(-1, -1) != 0) return 1;
    if (mylib_subtract(1, 5) != -4) return 1;

    return 0;
}
