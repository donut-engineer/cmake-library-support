#include "mylib/mylib.hpp"
#include <gtest/gtest.h>

TEST(MylibTest, Add) {
    EXPECT_EQ(mylib::add(1, 2), 3);
    EXPECT_EQ(mylib::add(-1, 1), 0);
    EXPECT_EQ(mylib::add(0, 0), 0);
    EXPECT_EQ(mylib::add(-5, -3), -8);
}

TEST(MylibTest, Subtract) {
    EXPECT_EQ(mylib::subtract(5, 3), 2);
    EXPECT_EQ(mylib::subtract(0, 0), 0);
    EXPECT_EQ(mylib::subtract(-1, -1), 0);
    EXPECT_EQ(mylib::subtract(1, 5), -4);
}
