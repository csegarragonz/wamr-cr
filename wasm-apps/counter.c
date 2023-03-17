#include <stdio.h>
#include <unistd.h>

int __checkpoint();

int main(int argc, char** argv)
{
    int num_iter = 10;
    for (int i = 0; i < num_iter; i++) {
        fprintf(stdout, "Iteration %i/%i\n", i + 1, num_iter);

        sleep(1);

        if (i == 4) {
            __checkpoint();
        }
    }

    return 0;
}
