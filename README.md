# n-body in x86-64 assembly

This is the [n-body problem](https://benchmarksgame.alioth.debian.org/u64q/nbody-description.html) from [The Computer Language Benchmarks Game](https://benchmarksgame.alioth.debian.org/) site, written in x86-64 assembly.

It's not ready, I only wrote it as a learning experience.

It's ~1.9x slower than the optimized C version, optimizations still missing include:

* Using SIMD instructions. (`movapd`, `addpd`, `subpd`, `rsqrtps`, etc)
* Calculating `dx`, `dy`, and `dz`, magnitude, velocity, and final position each in their own loop to improve cache coherence and to calculate multiple bodies at the same time.
* Use `rsqrtps` with two Newton's method steps.

### Build steps

    nasm -felf64 nbody.asm && gcc -no-pie nbody.o -o nbody

### Running it

    ./nbody <number here>

(If you don't pass it a number it will segfault :))
