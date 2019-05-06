#!/bin/bash

# hetrodyne - A script to mix an audio file with a higher frequency in order to produce the hetrodyne effect

usage()
{
  echo "usage: hetrodyne -i file [-f] [-g] [-r] [-o] [-p] | [-h]"
}

#Command vars
input=
output="output.wav"
frequency=32000
gain=-0.9
rate=192000
play="false"

#MAIN

while [ "$1" != "" ]; do
  case $1 in
      -i | --input )      shift
                          input=$1
                          ;;
      -o | --output )     shift
                          output=$1
                          ;;
      -f | --frequency )  shift
                          frequency=$1
                          ;;
      -g | --gain)        shift
                          gain=$1
                          ;;
      -r | --rate)        shift
                          rate=$1
                          ;;
      -p | --play)        shift
                          play="true"
                          ;;
      -h | --help )       usage
                          exit
                          ;;
      * )                 usage
                          exit 1
    esac
    shift
done

if [ "$input" == "" ];
then
  echo "No input file specified"
  usage
  exit 1
fi

# if [ $noise == "" ];
# then
#   echo "No noise profile specified"
#   usage
#   exit 1
# fi

duration=$(soxi -D $input)

sox -V -r $rate -n -b 16 -c 2 /tmp/signal.wav synth $duration sin $frequency vol 5dB

if [ "$play" == "true" ]
then

  if ["$input" = "[Live]"]
  then
    arecord -r 192000 -c 2 -f S16_LE | sox - -t wav - sinc $(expr $frequency / 1000 - 5)k | sox -t wav - -t wav - gain -n $gain | sox -m -t wav -v 1 - -t wav -v 1 /tmp/signal.wav -t wav /dev/stdout | aplay -
  else
    sox $input -t wav - sinc $(expr $frequency / 1000 - 5)k | sox -t wav - -t wav - gain -n $gain | sox -m -t wav -v 1 - -t wav -v 1 /tmp/signal.wav -t wav /dev/stdout | aplay -
  fi
else
  sox $input -t wav - sinc $(expr $frequency / 1000 - 5)k | sox -t wav - -t wav - gain -n $gain | sox -m -t wav -v 1 - -t wav -v 1 /tmp/signal.wav $output
fi

rm /tmp/signal.wav

#What is important

#We use -m becuase that merges files
#We have to use -v 1 because that ensures that the volume dosn't decrease
