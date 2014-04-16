#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

unsigned int *sdt_conv_c; // temp coverage counter
unsigned int sdt_conv_size = 0; // size

#define KM_MAX_LINEFREQ (4096)

void sdt_conv_init(unsigned int lnsiz)
{
	sdt_conv_c = (unsigned int*)calloc(lnsiz, sizeof(unsigned int));
	sdt_conv_size = lnsiz;
}

void sdt_conv_for(unsigned int lnno)
{
	if (lnno >= sdt_conv_size)
		return;
	if (sdt_conv_c[lnno] < KM_MAX_LINEFREQ)
		++sdt_conv_c[lnno];
}

void sdt_conv_close()
{
	// output first
	int i;
	FILE* out = fopen("/tmp/sdt.0.out", "w+");
	fprintf(out, "%u\n", sdt_conv_size);
	for (i = 0; i < sdt_conv_size; i++)
		fprintf(out, "%u\n", sdt_conv_c[i]);
	fsync(fileno(out));
	fclose(out);
	rename("/tmp/sdt.0.out", "/tmp/sdt.out");
	free(sdt_conv_c);
}
