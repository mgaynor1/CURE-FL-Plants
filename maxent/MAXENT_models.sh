#!/bin/bash

for f in ./csv/*.csv; do f=$(sed 's/.csv//g' <<< $f);
f=$(sed 's|[./]||g' <<< $f)
echo ${f}
pwd=`pwd`

mkdir ${pwd}/data/models/present/${f}_model
java -mx2000m -jar maxent.jar nowarnings noprefixes responsecurves jackknife "outputdirectory=${pwd}/data/models/present/${f}_model" "samplesfile=${pwd}/csv/${f}.csv" "projectionlayers=${pwd}/data/climatic_layers/projection/current" "environmentallayers=${pwd}/data/climatic_layers/training/${f}" randomseed noaskoverwrite randomtestpoints=25 replicates=10 replicatetype=bootstrap noextrapolate maximumiterations=5000 allowpartialdata autorun

mkdir ${pwd}/data/models/50years/${f}_model
java -mx2000m -jar maxent.jar nowarnings noprefixes responsecurves jackknife "outputdirectory=${pwd}/data/models/50years/${f}_model" "samplesfile=${pwd}/csv/${f}.csv" "projectionlayers=${pwd}/data/climatic_layers/projection/CCSM4_rcp26_50" "environmentallayers=${pwd}/data/climatic_layers/training/${f}" randomseed noaskoverwrite randomtestpoints=25 replicates=10 replicatetype=bootstrap noextrapolate maximumiterations=5000 allowpartialdata autorun

mkdir ${pwd}/data/models/70years/${f}_model
java -mx2000m -jar maxent.jar nowarnings noprefixes responsecurves jackknife "outputdirectory=${pwd}/data/models/70years/${f}_model" "samplesfile=${pwd}/csv/${f}.csv" "projectionlayers=${pwd}/data/climatic_layers/projection/CCSM4_rcp26_70" "environmentallayers=${pwd}/data/climatic_layers/training/${f}" randomseed noaskoverwrite randomtestpoints=25 replicates=10 replicatetype=bootstrap noextrapolate maximumiterations=5000 allowpartialdata autorun

done
