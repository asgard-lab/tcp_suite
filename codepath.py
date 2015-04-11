#!/usr/bin/env python
"""
codepath - visualization and timestamping complete code paths
by Cesar Marcondes (marcondes@dc.ufscar.br)
Example: python codepath.py file.txt
"""

import sys, re, json
from graphviz import Digraph

# global variables
transitions = {}
previousstate = None
currentstate = None
functionpointers = []
bufferedstacks = {}

def graphtransitions():
  u = Digraph('unix', filename='unix.gv')
#  u.body.append('size="6,6"')
#  u.node_attr.update(color='lightblue2', style='filled')
  for (previousstate, currentstate) in transitions:
    x, y = transitions[(previousstate, currentstate)]
    if int(x) >= int(numberlines):
      u.edge(previousstate, currentstate, color='red', label='%s %s' % (x, y))
    else:
      u.edge(previousstate, currentstate, color='blue', label='%s %s' % (x, y))
  u.view()

def loadphase():
  linecounter = 1
  mycounter = 10000000
  f = open(filename, 'r')
  for line in f:
    match = re.search(r'.*\] ([0-9]*\.[0-9]*):.*\|\s*(.*)', line)
    if match:
      funcname = match.group(2)
    if functioname in funcname:
      functionpointers.append(linecounter)
      vectorlines = []
      vectorlines.append(line)
      bufferedstacks[linecounter] = vectorlines
    else:
      if functionpointers: 
        mycounter = functionpointers[-1]
      if linecounter >= mycounter and linecounter <= mycounter + int(numberlines):
        vectorlines = bufferedstacks[mycounter]
        vectorlines.append(line)
        bufferedstacks[mycounter] = vectorlines
    linecounter+=1
#    if linecounter == 20000:
#      break

def mainloop():
  for value in list(bufferedstacks.keys()):
    execute(value)
  graphtransitions()

def execute( value ):
  firstime = True
  linecounter = 1
  vectorlines = []

  # open file
  #f = open(filename, 'r')
  vectorlines = bufferedstacks[value]
  for line in vectorlines:

    # iperf-3501  [000] 84909.023052: funcgraph_entry:  0.050 us   | pick_next_task_idle();
    match = re.search(r'.*\] ([0-9]*\.[0-9]*):.*\|\s*(.*)', line)

    # If-statement after search() tests if it succeeded
    if match:
      timestamp = 1000000 * float(match.group(1))
      funcname = match.group(2)
     
    if firstime:
      firstime = False
      currentstate = funcname
      currenttime = timestamp
      #print line
    else:
      if "}" in funcname:
        continue;
      # transition is (previousstate, currentstate)
      # transition time is currenttime - previoustime
      previousstate = currentstate
      previoustime = currenttime
      currentstate = funcname
      currenttime = timestamp
      transitiontime = currenttime - previoustime
      
      if (previousstate, currentstate) in transitions.keys():
        cnttransitions, accumulatetime = transitions.get((previousstate, currentstate))
        #print('update transitions '),
        #print((previousstate, currentstate)),
        #print(cnttransitions)
        cnttransitions = cnttransitions + 1
        accumulatetime = accumulatetime + transitiontime
        transitions[(previousstate, currentstate)] = (cnttransitions, accumulatetime)
      else:
        transitions[(previousstate, currentstate)] = (1, transitiontime)
        #print('new transition '),
        #print((previousstate, currentstate)),
        #print(transitiontime)
      #print line
    linecounter+=1
    if linecounter == 100:
      break

if __name__ == '__main__':
  filename = sys.argv[1]
  functioname = sys.argv[2]
  numberlines = sys.argv[3]
  loadphase()
  #print functionpointers
  #print json.dumps(bufferedstacks, indent=1)
  mainloop()
  #run()
