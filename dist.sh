#!/bin/bash

if [ -e dist ]; then
    rm -r dist/*
fi

if [ -e HaxeUmlGen.zip ]; then
    rm HaxeUmlGen.zip
fi

cp -r haxelib.json bin/* LICENSE README dist
cd src
cp -r umlgen ../dist
cd ../dist
zip -r ../HaxeUmlGen.zip *
cd ..

