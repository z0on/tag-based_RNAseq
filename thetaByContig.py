#!/usr/bin/python

# GNU GPL blah blah
# Nate Pope (nspope at utexas dot edu)

from sys import stdin, stdout, stderr, argv, exit
from math import sqrt
import argparse
import numpy

parser = argparse.ArgumentParser(description = "Calculate theta estimates, Tajima's D, and (optionally) other\nneutrality statistics for each contig. Required input (read from stdin)\nis the per-site theta estimates output by ANGSD's subprogram\n'thetaStat print'.", 
        epilog="# e.g., calculate theta, Tajima's D, and Fay's H\n$ANGSD_PATH/misc/thetaStat print my.thetas.idx | python thetaByContig.py -n 10 -H\n ",
        formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument("--chrom", "-n", type=int, required=True, help="Number of haploid sequences (required)")
parser.add_argument("--fuliD", "-D", action="store_true", help="Calculate Fu & Li's D")
parser.add_argument("--fuliF", "-F", action="store_true", help="Calculate Fu & Li's F")
parser.add_argument("--fayH", "-H", action="store_true", help="Calculate Fay's H")
parser.add_argument("--zengE", "-E", action="store_true", help="Calculate Zeng's E")
if len(argv) == 1:
    parser.print_help(stderr)
    exit(1)
arg = parser.parse_args()

class Tajima:
    def __init__(self, N):
        self.a1 = numpy.sum(1./numpy.arange(1., N-1))
        self.a2 = numpy.sum(1./(numpy.arange(1., N-1)**2))
        self.b1 = (N+1.)/(3.*(N-1.))
        self.b2 = 2.*(N**2+N+3.)/(9.*N*(N-1.))
        self.c1 = self.b1 - 1./self.a1
        self.c2 = self.b2 - (N+2.)/(self.a1*N) + self.a2/(self.a1**2)
        self.e1 = self.c1/self.a1
        self.e2 = self.c2/(self.a1**2+self.a2)
    def D(self, Watterson, Pairwise):
        S = self.a1 * Watterson
        if S == 0.:
            return (0.)
        else:
            return ((Pairwise - Watterson)/sqrt(self.e1*S + self.e2*S*(S-1.)))

class FuLi:
    def __init__(self, N):
        self.a1 = numpy.sum(1./numpy.arange(1., N-1))
        self.a2 = numpy.sum(1./(numpy.arange(1., N-1)**2))
        self.cn = (2.*N*self.a1-4.*(N-1.)) / ((N-1.)*(N-2.))
        self.vd = 1. + (self.a1**2)/(self.a2+self.a1**2) * (self.cn-(N+1.)/(1.*(N-1)))
        self.ud = self.a1 - 1. - self.vd
        self.vf = (self.cn + 2.*(N**2 + N + 3.)/(9.*N*(N-1.)) - 2./(N-1.)) / (self.a1**2 + self.a2)
        self.uf = (1. + (N+1.)/(3.*(N-1.))-4.*(N+1.)/((N-1)**2)*(self.a1 + 1./N - 2.*N/(N+1)))/self.a1 - self.vf
    def D(self, Watterson, thetaSingleton):
        S = self.a1 * Watterson
        L = self.a1 * thetaSingleton
        if S == 0.:
            return (0.)
        else:
            return ((S - L)/sqrt(S*self.ud + (S**2)*self.vd))
    def F(self, Watterson, thetaSingleton, Pairwise):
        S = self.a1 * Watterson
        if S == 0.:
            return (0.)
        else:
            return ((Pairwise - thetaSingleton)/sqrt(S*self.uf + (S**2)*self.vf))

class Fay:
    def __init__(self, N):
        self.a1 = numpy.sum(1./numpy.arange(1., N-1))
        self.a2 = numpy.sum(1./(numpy.arange(1., N-1)**2))
        self.h1 = (N - 2.)/(6.*(N-1.))
        self.h2 = (18.*(N**2)*(3.*N+2)*(self.a2 + 1./(N**2)) - (88.*(N**3) + 9.*(N**2) - 13.*N + 6.))/(9.*N*(N-1.)*(N-1.))
    def H(self, Watterson, thetaH, Pairwise):
        S = self.a1 * Watterson
        if S == 0.:
            return (0.)
        else:
            return ((Pairwise - thetaH)/sqrt(S*self.h1 + (S**2)*self.h2))

class Zeng:
    def __init__(self, N):
        self.a1 = numpy.sum(1./numpy.arange(1., N-1))
        self.a2 = numpy.sum(1./(numpy.arange(1., N-1)**2))
        self.e1 = N / (2. * (N - 1.)) - 1./self.a1
        self.e2 = self.a2/(self.a1**2) + 2.*((N/(N-1.))**2)*self.a2 - 2.*(N*self.a2-N+1.)/((N-1.)*self.a1) - (3.*N+1.)/(N-1.)
    def E(self, Watterson, thetaL):
        S = self.a1 * Watterson
        if S == 0.:
            return (0.)
        else:
            return ((thetaL - Watterson) / sqrt(S*self.e1 + (S**2)*self.e2))

tajima = Tajima(arg.chrom)
fuli   = FuLi(arg.chrom)
fay    = Fay(arg.chrom)
zeng   = Zeng(arg.chrom)

stdout.write("#Chromo\tWatterson\tPairwise\tthetaSingleton\tthetaH\tthetaL\tTajimaD")
if arg.fuliD:
    stdout.write("\tFuLiD")
if arg.fuliF:
    stdout.write("\tFuLiF")
if arg.fayH:
    stdout.write("\tFayH")
if arg.zengE:
    stdout.write("\tZengE")
stdout.write("\n")

thetas = numpy.zeros([5])
last_ch = "supercalafragalisticexpialadocious"
contig = 0

for line in stdin:
    if line[0] == "#":
        continue
    line = line.split()
    if len(line) != 7:
        stderr.write("Line length incorrect: check input\n")
        exit(1)
    ch, po, th = [line[0], line[1], line[2:]]
    if last_ch != ch:
        contig += 1
        if contig > 1:
            stdout.write(last_ch + "\t" + "\t".join([str(x) for x in thetas]))
            stdout.write("\t" + str(tajima.D(thetas[0], thetas[1])))
            if arg.fuliD:
                stdout.write("\t" + str(fuli.D(thetas[0], thetas[2])))
            if arg.fuliF:
                stdout.write("\t" + str(fuli.F(thetas[0], thetas[2], thetas[1])))
            if arg.fayH:
                stdout.write("\t" + str(fay.H(thetas[0], thetas[3], thetas[1])))
            if arg.zengE:
                stdout.write("\t" + str(zeng.E(thetas[0], thetas[4])))
            stdout.write("\n")
        thetas *= 0.
    thetas += numpy.exp(numpy.array(th, "float"))
    last_ch = ch

stdout.write(last_ch + "\t" + "\t".join([str(x) for x in thetas]))
stdout.write("\t" + str(tajima.D(thetas[0], thetas[1])))
if arg.fuliD:
    stdout.write("\t" + str(fuli.D(thetas[0], thetas[2])))
if arg.fuliF:
    stdout.write("\t" + str(fuli.F(thetas[0], thetas[2], thetas[1])))
if arg.fayH:
    stdout.write("\t" + str(fay.H(thetas[0], thetas[3], thetas[1])))
if arg.zengE:
    stdout.write("\t" + str(zeng.E(thetas[0], thetas[4])))
stdout.write("\n")

stdout.close()
