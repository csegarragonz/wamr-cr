#include <stdio.h>
#include <unistd.h>

extern int __checkpoint();

int main(int argc, char** argv)
{
    int num_iter = 10;
    for (int i = 0; i < num_iter; i++) {
        fprintf(stdout, "Iteration %i/%i\n", i + 1, num_iter);
        if (i == 4) {
            __checkpoint();
        }
    }

    return 0;
}
