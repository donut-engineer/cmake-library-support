#include "mylib/mylib.h"
#include <gtest/gtest.h>

TEST(MylibTest, Add) {
    EXPECT_EQ(mylib_add(1, 2), 3);
    EXPECT_EQ(mylib_add(-1, 1), 0);
    EXPECT_EQ(mylib_add(0, 0), 0);
    EXPECT_EQ(mylib_add(-5, -3), -8);
}

TEST(MylibTest, Subtract) {
    EXPECT_EQ(mylib_subtract(5, 3), 2);
    EXPECT_EQ(mylib_subtract(0, 0), 0);
    EXPECT_EQ(mylib_subtract(-1, -1), 0);
    EXPECT_EQ(mylib_subtract(1, 5), -4);
}
