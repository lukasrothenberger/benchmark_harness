/**
 * bicg.c: This file is part of the PolyBench/C 3.2 test suite.
 *
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

/* Include polybench common header. */
#include <polybench.h>

/* Include benchmark-specific header. */
/* Default data type is double, default size is 4000. */
#include "bicg.h"


/* Array initialization. */
static
void init_array (int nx, int ny,
		 DATA_TYPE POLYBENCH_1D(A,NX*NY,nx*ny),
		 DATA_TYPE POLYBENCH_1D(r,NX,nx),
		 DATA_TYPE POLYBENCH_1D(p,NY,ny))
{
  int i, j;

  for (i = 0; i < ny; i++)
    p[i] = i * M_PI;
  for (i = 0; i < nx; i++) {
    r[i] = i * M_PI;
    for (j = 0; j < ny; j++)
      A[i*nx+j] = ((DATA_TYPE) i*(j+1))/nx;
  }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int nx, int ny,
		 DATA_TYPE POLYBENCH_1D(s,NY,ny),
		 DATA_TYPE POLYBENCH_1D(q,NX,nx))

{
  int i;

  for (i = 0; i < ny; i++) {
    fprintf (stderr, DATA_PRINTF_MODIFIER, s[i]);
    if (i % 20 == 0) fprintf (stderr, "\n");
  }
  for (i = 0; i < nx; i++) {
    fprintf (stderr, DATA_PRINTF_MODIFIER, q[i]);
    if (i % 20 == 0) fprintf (stderr, "\n");
  }
  fprintf (stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_bicg(int nx, int ny,
		 DATA_TYPE POLYBENCH_1D(A,NX*NY,nx*ny),
		 DATA_TYPE POLYBENCH_1D(s,NY,ny),
		 DATA_TYPE POLYBENCH_1D(q,NX,nx),
		 DATA_TYPE POLYBENCH_1D(p,NY,ny),
		 DATA_TYPE POLYBENCH_1D(r,NX,nx))
{
  int i, j;

  for (i = 0; i < _PB_NY; i++)
    s[i] = 0;
  #pragma omp target enter data map(to:q[0:nx]) device(1)
  #pragma omp target enter data map(to:p[0:ny]) device(1)
  #pragma omp target enter data map(to:j) device(1)
  #pragma omp target enter data map(to:A[0:nx*ny]) device(1)
  #pragma omp target enter data map(to:nx) device(1)
  #pragma omp target enter data map(to:ny) device(1)
  #pragma omp target enter data map(to:r[0:nx]) device(1)
  #pragma omp target enter data map(to:s[0:ny]) device(1)
  #pragma omp target enter data map(to:i) device(1)
  #pragma omp target teams distribute parallel for device(1) private(i,j) shared(A,nx,ny,p,q,r,s) 
  for (i = 0; i < _PB_NX; i++)
    {
      q[i] = 0;
      for (j = 0; j < _PB_NY; j++)
	{
	  s[j] = s[j] + r[i] * A[i*nx+j];
	  q[i] = q[i] + A[i*nx+j] * p[j];
	}
    }

#pragma omp target exit data map(from:q[0:nx]) device(1)
#pragma omp target exit data map(delete:p[0:ny]) device(1)
#pragma omp target exit data map(delete:j) device(1)
#pragma omp target exit data map(delete:A[0:nx*ny]) device(1)
#pragma omp target exit data map(delete:nx) device(1)
#pragma omp target exit data map(delete:ny) device(1)
#pragma omp target exit data map(delete:r[0:nx]) device(1)
#pragma omp target exit data map(from:s[0:ny]) device(1)
#pragma omp target exit data map(delete:i) device(1)
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int nx = NX;
  int ny = NY;

  /* Variable declaration/allocation. */
  POLYBENCH_1D_ARRAY_DECL(A, DATA_TYPE, NX*NY, nx*ny);
  POLYBENCH_1D_ARRAY_DECL(s, DATA_TYPE, NY, ny);
  POLYBENCH_1D_ARRAY_DECL(q, DATA_TYPE, NX, nx);
  POLYBENCH_1D_ARRAY_DECL(p, DATA_TYPE, NY, ny);
  POLYBENCH_1D_ARRAY_DECL(r, DATA_TYPE, NX, nx);

  /* Initialize array(s). */
  init_array (nx, ny,
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(r),
	      POLYBENCH_ARRAY(p));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_bicg (nx, ny,
	       POLYBENCH_ARRAY(A),
	       POLYBENCH_ARRAY(s),
	       POLYBENCH_ARRAY(q),
	       POLYBENCH_ARRAY(p),
	       POLYBENCH_ARRAY(r));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(nx, ny, POLYBENCH_ARRAY(s), POLYBENCH_ARRAY(q)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(s);
  POLYBENCH_FREE_ARRAY(q);
  POLYBENCH_FREE_ARRAY(p);
  POLYBENCH_FREE_ARRAY(r);

  return 0;
}
