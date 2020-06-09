#!/bin/bash
set -e

zola="zola"

hash zola 2>/dev/null || zola=zola.exe
$zola build

rsync -aqr --delete public/ root@0xadd1e.me:/srv/blog
