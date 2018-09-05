# itex2MML converter
itex2MML (by Jacques Distler) non-official mirror repository

## Introduction

This program  converts itex, a dialect of LaTeX, to MathML.
A summary of the LaTeX syntax supported in itex can be found here :
[itex Commands](https://golem.ph.utexas.edu/~distler/blog/itex2MMLcommands.html)

The source repository for the original itex2MML project may be found at [https://golem.ph.utexas.edu/~distler/code/itexToMML](https://golem.ph.utexas.edu/~distler/code/itexToMML)

## Compilation
The source code is in the `itex-src` directory.
It should compile on most platforms by simply typing

```bash
make
sudo make install
```

The resulting itex2MML binary is a stream filter.
It takes text with embedded itex equations on STDIN, converts the itex equations to MathML, and outputs the resulting text on STDOUT.

## WIMS_MATHML
On a dedicated branch, you will find a fork of this itex2MML, called "wims_mathml", adding some functionalities like js zooming on MathMl formulas...

## Licence

Itex2MML is Open Source software, released under a triple license: GPL, MPL and LGPL.
