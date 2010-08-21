#!/bin/bash

rm -r dist/*
rm HaxeUmlGen.zip
cp -r haxelib.xml bin/* LICENSE README Utils.hx umlgen dist
cd dist
zip -r ../HaxeUmlGen.zip *
cd ..

