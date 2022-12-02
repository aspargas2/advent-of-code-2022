As a fun challenge for this year's [advent of code](https://adventofcode.com/), I decided to try solving each day's challenge in assembly for a different architecture, and obtaining that day's solution by running the code on a physical processor of that architecture. For each day that I solve, I will be uploading my code and details of what device it was run on here.

To be honest, I haven't given too much thought to the detailed rules of this challenge, but to start with:
- I am loosely defining "different architecture" as "different first item in an LLVM target triple." This means I get to count armv4, v5, etc as all different architectures, which should make this significantly more possible for me.
- I will only allow myself to call into higher level or library code when it is necessary to communicate with the outside world, like to print some output or read the input file from somewhere.

As I get into actually doing this, I may add additional stipulations or exceptions as necessary.

I doubt anyone else is crazy ~~and masochistic~~ enough to attempt this challenge with me, but if you do, I would love to see what devices you end up running everything on. In any case, good luck and have fun with AoC this year!
