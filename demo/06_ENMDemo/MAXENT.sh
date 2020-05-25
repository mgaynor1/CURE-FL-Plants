# ENM using MAXENT in command line 
## ML Gaynor
## 2020-03-22

for f in ./csv/*.csv; do f=$(sed 's/.csv//g' <<< $f)
echo ${f}
mkdir data/${f}_model
java -mx2000m -jar maxent.jar nowarnings noprefixes responsecurves jackknife "outputdirectory=./data/${f}_model" "samplesfile=./csv/${f}.csv" "projectionlayers=./data/NeededPresentLayers/projection" "environmentallayers=./data/NeededPresentLayers/${f}" randomseed noaskoverwrite randomtestpoints=25 replicates=10 replicatetype=bootstrap noextrapolate maximumiterations=5000 allowpartialdata autorun
done