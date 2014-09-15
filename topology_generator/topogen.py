#!/usr/bin/env python

"""
topogen - tcp evaluation suite
by Cesar Marcondes (marcondes@dc.ufscar.br)
Example: python topogen.py parking 5 0 1000 15 0 40 p2p
"""

import sys, argparse, random, os
from random import expovariate
from numpy import average

parser = argparse.ArgumentParser(
    description='tcp evaluation suite: topology generator', version='1.0')
parser.add_argument('topology', action="store",
                    help='topology type, ie. parking')
parser.add_argument('nw_size', action="store",
                    help='network core size, ie. 5 bottleneck routers',
                    type=int)
parser.add_argument('degree', action="store",
                    help='network core outdegree', type=int)
parser.add_argument('bw', action="store",
                    help='core bandwidth capacity', type=int)
parser.add_argument('delay', action="store",
                    help='randomized per-link delay', type=int)
parser.add_argument('lflows', action="store",
                    help='long lived flows', type=int)
parser.add_argument('sflows', action="store",
                    help='short lived flows', type=int)
parser.add_argument('traffic', action="store",
                    help='traffic pattern (i.e. p2p or client/server)')

arguments = parser.parse_args()

#open files
topology_f = open('model-topology', 'w')
flow_f = open('model-flow', 'w')

random.seed()

# global variable used (vectorized adjancecy list)
used = []
hopcnt = 0

for i in range(0, (arguments.nw_size * arguments.nw_size)):
    used.append(0)

def printflow (snode, dnode, hopcount, shortflow):
    aux = repr(snode), repr(dnode), repr(hopcount), shortflow
    str1 = ' '.join(str(e) for e in aux)
    flow_f.write(str1 + os.linesep)

def printlink (i, j, bw, delay):
    aux = repr(i), repr(j), repr(bw) + "Mb", "%e"%(delay) + "ms"
    str1 = ' '.join(str(e) for e in aux)
    topology_f.write(str1 + os.linesep)

def createlink(i, j, bw, delay):
    global used
    used[i*arguments.nw_size + j] = delay
    used[j*arguments.nw_size + i] = delay
    printlink(i, j, bw, delay) 

'''
parking-lot network fuction
use pure random exponential variable to generate link delays
it could be possible in the future pass a random seed, using random.seed(n)
'''

def parking():
    for i in range(0, arguments.nw_size-1):
        rate = 1 / float(arguments.delay)
        delay = expovariate(rate)
        createlink(i, i+1, arguments.bw, delay)

##count hop count within a flow
def counthops(src, dest):
    global hopcnt, used
    hopcnt = 0
    visited = []
    for i in range(0, arguments.nw_size):
        visited.append(0)
    search = [src]
    while (len(search) > 0):
        hopcnt = hopcnt + 1
        next = []
        for j in search:
            for i in range(0, arguments.nw_size):
                if (used[j*arguments.nw_size + i] != 0) and (visited[i] == 0):
                    if (i == dest):
                        search = []
                    else:
                        visited[i] = 1
                        next.append(i)
        if (len(search) > 0):
            search = next
    
def setuplinks(i, src, dest):
    rate = 1 / float(arguments.delay)
    delay = expovariate(rate)
    srcnd = arguments.nw_size + i * 2
    destnd = arguments.nw_size + i * 2 + 1
    printlink(srcnd, src, arguments.bw, delay)
    delay = expovariate(rate) #second delay sample
    printlink(destnd, dest, arguments.bw, delay)
    if (i<arguments.lflows):
        printflow (srcnd, destnd, hopcnt, 0)
    else:
        printflow (srcnd, destnd, hopcnt, 1)

def csflows():
    flows = arguments.sflows + arguments.lflows
    for i in range(0, flows):
        src = int(random.random() * arguments.nw_size) % 10 * 10
        dest = int(random.random() * arguments.nw_size) % 10 * 10
        + int(random.random() * 9) + 1
        while (src == dest) or (arguments.topology == "random"):
            src = int(random.random() * arguments.nw_size) % 10 * 10
            dest = int(random.random() * arguments.nw_size) % 10 * 10
        counthops(src, dest)
        setuplinks(i, src, dest)
    
def p2pflows():
    flows = arguments.sflows + arguments.lflows
    for i in range(0, flows):
        src = int(random.random() * arguments.nw_size)
        dest = int(random.random() * arguments.nw_size)
        while (src == dest):
            src = int(random.random() * arguments.nw_size)
            dest = int(random.random() * arguments.nw_size)
        # count hops and setup links
        counthops(src, dest)
        setuplinks(i, src, dest)

if arguments.topology == "parking":
    parking()
if arguments.traffic == "cs":
    csflows()
if arguments.traffic == "p2p":
    p2pflows()