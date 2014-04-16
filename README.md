Generate Stripped Program with Dynamic Profiling
================================================

This project is my experiment to generate a stripped program with dynamic profiling.
Namely, to profile hot code path and strip out code that never uses. This obviously
will generate incorrect program, but idea is that given statistically significant tests,
can we generate "correct" program for most cases, and this "correct" program will
significantly smaller than the original always correct one?

This implementation as provided now is a proof-of-concept.

Use
---

You need to have LLVM install, and check to see if you have llvm-config in your /bin path.

In this proof-of-concept, I provided a demo app in ./tests called gcd.c. First, go to ./tests

	./irgen.sh

This command will generate LLVM intermediate representation, thus, ./tests/gcd.ll file.

Go back to ./ directory, and:

	make

This, hopefully will generate ./sdtri binary, with this binary, and ./tests/gcd.ll file,
you can generate instrumented source code:

	./sdtri c tests/gcd.ll tests/gcd.sdt.bc

This will generate LLVM Bitcode file named ./tests/gcd.sdt.bc, go to ./tests directory again,
and:

	./compile-conv.sh

This will generate binary ./gcd, and you can run:

	./gcd 10 4

This will output the greatest common denominator: gcd 2, also, an instrumented output generated in
/tmp/sdt.out, which will be used implicitly later.

Now, we have instrumented output, LLVM intermediate representation, the stripped down program
can be generated, go back to ./ directory, and:

	./sdtri v tests/gcd.ll tests/gcd.v.bc

This will generate stripped down version of original program, how do we know it is stripped down?

	llvm-dis tests/gcd.v.bc -o tests/gcd.v.ll

Comparing the lines of code for tests/gcd.v.ll and tests/gcd.ll, you can see tets/gcd.v.ll has less
lines of code.

Now, to compile the stripped down program, go to ./tests directory:

	./compile.sh

This will generate ./tests/gcd-v file, which is the stripped down version of the original program.
You can see the output:

	./gcd-v 10 4

Well, it is still correct. But how about other cases?

	./gcd-v 14 35

Again, it outputs 7, which is the same as original gcd program. Pretty good. But it will break down
in case:

	./gcd-v 0 12

Oops, now while the original program will gives 0, the stripped down version will stuck in a infinite loop.
