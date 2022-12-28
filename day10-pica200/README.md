Day 10 was solved using a geometry shader for the PICA200, the GPU used in the Nintendo 3DS. The code was run, as I'm sure you can guess if you've read the previous days, on my New 2DS XL: [output.jpg](output.jpg). A couple notes about this one:

- I had to cheat a bit to make this work; I preprocessed the input file on the CPU slightly, simply tokenizing the instructions and converting arguments to `addx` into floats. I feel a bit bad for doing this, but I couldn't think of any sane way to pass the raw input file to the GPU.
- This GPU has nothing like a compute shader and can only output to the framebuffer, so the only way I could get the answer for part 1 back to the CPU was by encoding it as a color then reading the framebuffer memory on the CPU. So, that ugly orange color you see in the background of the top screen is actually the answer for part 1.
- I swear didn't know what part 2 was going to be when I decided to do this one with a GPU. It just happened to line up really nicely.