#!/bin/bash

cat *.rte > traceroute.dot
dot -Tpdf traceroute.dot -o route.pdf 
echo "Fini !"
