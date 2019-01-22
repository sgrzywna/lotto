# lotto

Experiments with small 32-bits ELF that can generate random numbers.

The main goal was to create possible small but functional Linux ELF executable.

There are two variations:

* [lotto_urandom.asm](lotto_urandom.asm) that reads random numbers from `/dev/urandom`

* and [lotto_prng.asm](lotto_prng.asm) with simple pseudo random number generator

For build details see comments at the top of the files.

On my test machine results are:

* 4640 bytes from the [lotto_prng.asm](lotto_prng.asm)

* 4644 bytes from the [lotto_urandom.asm](lotto_urandom.asm)
