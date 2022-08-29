#!/usr/bin/env python
"""
topogen - tcp evaluation suite
by Cesar Marcondes (cmarcondes@ita.br)

Example: python topogen.py parking 5 0 1000 15 40 100 p2p 6

topology = parking
backbone size = 5
backbone outdegree = 0
backbone bandwidth = 1000 (1Gbps)
per-link propagation delay = 15 (ms average)
short-lived flows = 100
long-lived flows = 40
traffic pattern p2p or c/s = p2p
seeds = 6
"""

import argparse, os, random
from random import expovariate

used = []
hopcnt = 0
topology_f = None
flow_f = None

def printlink (i, j, bw, delay):
    aux = repr(i), repr(j), repr(bw) + "Mb", "%e"%(delay) + "ms"
    txt = ' '.join(str(e) for e in aux)
    #print(txt)
    topology_f.write(txt + os.linesep)

def printflow (snode, dnode, hopcount, shortflow):
    aux = repr(snode), repr(dnode), repr(hopcount), shortflow
    txt = ' '.join(str(e) for e in aux)
    #print(txt)
    flow_f.write(txt + os.linesep)

def createlink(i, j, bw, delay):
    used[i*arguments.nw_size + j] = delay
    used[j*arguments.nw_size + i] = delay
    printlink(i, j, bw, delay) 

def parking():
    for i in range(0, arguments.nw_size-1):
        rate = 1 / float(arguments.delay)
        delay = expovariate(rate)
        createlink(i, i+1, arguments.bw, delay)

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
    random.seed()
    delay = expovariate(rate)
    srcnd = arguments.nw_size + i * 2
    destnd = arguments.nw_size + i * 2 + 1
    printlink(srcnd, src, arguments.bw, delay)
    printlink(destnd, dest, arguments.bw, delay)
    print("counting flows {}".format(i))
    if (i<arguments.lflows):
        print("long flows counting flows {}".format(i))
        printflow (srcnd, destnd, hopcnt+2, 0)
    else:
        print("short flows counting flows {}".format(i))
        printflow (srcnd, destnd, hopcnt+2, 1)

def p2pflows():
    flows = arguments.sflows + arguments.lflows
    for i in range(0, flows):
        src = int(random.random() * arguments.nw_size)
        dest = int(random.random() * arguments.nw_size)
        while (src == dest):
            src = int(random.random() * arguments.nw_size)
            dest = int(random.random() * arguments.nw_size)
        counthops(src, dest)
        setuplinks(i, src, dest)

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

def main(arguments):
    global topology_f, flow_f
    random.seed()

    # create model files
    if not os.path.isdir("model"):
        os.mkdir("model")
    topology_f = open('model-topology', 'w')
    flow_f = open('model-flow', 'w')

    for i in range(0, (arguments.nw_size * arguments.nw_size)):
        used.append(0)

    if arguments.topology == "parking":
        parking()
    if arguments.traffic == "cs":
        csflows()
    else:
        p2pflows()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='tcp evaluation suite: topology generator')
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
    main(arguments)