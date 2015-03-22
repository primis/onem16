# Introduction #

This is a guide on how to install and run onem16 on your computer.


# Compiling The Source #

First, we have a few requirements:
  * You'll need a copy of the Netwide Assembler (NASM)
  * Knowledge on how to use it
  * Luck
Ok, now that we have that down, here we go:
Step 1: Download the current source code from the source tab of this site
Step 2: Open a Command Processor (cmd on windows, or a terminal on UNIX-Like Computer)
Step 3: Navigate to the folder (CD works wonders!)
Step 4: Type "nasm kernel.asm -o kernel.bin"
This should assemble the kernel and create a new binary called kernel.bin.

# Booting the kernel #
You can skip straight to here if you want to use the kernel.bin already in the SVN.
There are a few more requirements here:
  * A bootable drive (we use USB drives, floppy also works, not CD though)
  * Syslinux (Our bootloader of choice)
> > _You can also chainload in grub, but we haven't attempted this yet_

Ok, so, what you'll want to do is install syslinux on your bootable drive (or on an image is your using an emulator)
Next, you're gonna want to put the kernel.bin in the root of that drive
Finally, Reboot!
If you don't put a config file, thats ok! at the prompt your just going to type "kernel.bin" and it will boot

# Side Note #
Not all BIOS's support USB booting, and even if your computer does, your USB drive might not. Only some USB devices have the circuitry to emulate a Hard Drive or Floppy built in. If they don't it won't boot.

On Top of that, we don't have an image file in the SVN, why? because it would be too much trouble to update with each revision. To keep things simple, we just keep a binary. If you feel like we need an image, don't worry, we'll have one when we reach enough functionality.

And last thought: Make sure your BIOS has the boot device enabled, you don't know how much frustration you can encounter from an incorrectly set boot order.