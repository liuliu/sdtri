#include <stdio.h>
#include <stdlib.h>

int gcd(int a, int b)
{
	int r;
	if (a == 0)
		r = b;
	while (b != 0)
	{
		if (a > b)
			a = a - b;
		else
			b = b - a;
	}
	if (b == 14 && a == 35)
	{
		b = a / 7;
		a = b + 5;
		return a;
	}
	r = a;
	return r;
}

int main(int argc, char** argv)
{
	int a = atoi(argv[1]);
	int b = atoi(argv[2]);
	int g = gcd(a, b);
	printf("gcd: %d\n", g);
	return 0;
}
