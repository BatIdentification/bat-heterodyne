#!/bin/bash

# hetrodyne - A script to mix an audio file with a higher frequency in order to produce the hetrodyne effect

usage()
{
  echo "usage: hetrodyne -i file -n file | [-h]"
}

#Command vars
input=
noise=
output="output.wav"

#MAIN

while [ "$1" != "" ]; do
  case $1 in
      -i | --input )      shift
                          input=$1
                          ;;
      -n | --noise )      shift
                          noise=$1
                          ;;
      -o | --output )     shift
                          output=$1
                          ;;
      -h | --help )       usage
                          exit
                          ;;
      * )                 usage
                          exit 1
    esac
    shift
done

if [ $input == "" ];
then
  echo "No input file specified"
  usage
  exit 1
fi

if [ $noise == "" ];
then
  echo "No noise profile specified"
  usage
  exit 1
fi

sox $input -t wav - gain -n -0.9 | sox -t wav - -t wav - noisered $noise 0.06 | sox -m -t wav -v 1 - -v 1 32k.wav -v 1 32k.wav $output
