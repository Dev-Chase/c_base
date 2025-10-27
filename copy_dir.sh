#!/bin/bash

echo "Where do you want the new project to be created (in relation to your cwd)" 

read entered_path 
mkdir $entered_path
mkdir $entered_path"/obj"
mkdir $entered_path"/bin"
cp -r "./include" $entered_path"/include"
cp -r "./lib" $entered_path"/lib"
cp -r "./src" $entered_path"/src"
cp -r "./include" $entered_path"/include"
cp "./Makefile" $entered_path"/"

