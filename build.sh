#!/usr/bin/env sh
export PATH=$PATH:../cc65-snapshot-win32/bin
export GAME=DoubleDragonSNES
set -e

cd "$(dirname "$0")"

mkdir -p out
ca65 ./src/main.asm -o ./out/main.o -g
ld65 -C ./src/hirom.cfg -o ./out/$GAME.sfc ./out/main.o
