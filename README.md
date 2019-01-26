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

```bash
support@debian:~/workspace/lotto$ ls -l
total 40
-rw-r--r-- 1 support support 1074 Jan 26 06:53 LICENSE
-rw-r--r-- 1 support support  565 Jan 26 06:53 README.md
-rwxr-xr-x 1 support support 4640 Jan 26 06:54 lotto_prng
-rw-r--r-- 1 support support 3365 Jan 26 06:53 lotto_prng.asm
-rw-r--r-- 1 support support 1104 Jan 26 06:54 lotto_prng.o
-rwxr-xr-x 1 support support 4644 Jan 26 06:55 lotto_urandom
-rw-r--r-- 1 support support 2576 Jan 26 06:53 lotto_urandom.asm
-rw-r--r-- 1 support support 1056 Jan 26 06:55 lotto_urandom.o
support@debian:~/workspace/lotto$ ./lotto_urandom
46
10
49
36
10
33
support@debian:~/workspace/lotto$ ./lotto_prng
38
7
1
31
12
4
```