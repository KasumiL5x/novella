# Novella
> An authoring framework for interactive storytelling.

[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/macos/)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Twitter](https://img.shields.io/badge/twitter-@KasumiL5x-blue.svg?style=flat)](http://twitter.com/KasumiL5x)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/KasumiL5x/novella/raw/master/LICENSE)

Novella is a model and framework for authoring interactive narrative experiences.  It is developed by Daniel Green as part of his PhD project at Bournemouth University, UK.

## Status
_A heavily refined version of the model and interface is sporadically in development._
This project is currently in **periodic** development.  Development priority changes during the PhD, as this tool is not a main contribution to the thesis.

## Installation
This part is to come.

## Research
This project is part of a PhD on narrative models and authoring systems at Bournemouth University in the UK.  The following literature has been published alongside this project.

(NHT '18) Novella: A Proposition for Game-Based Storytelling

## Development setup
Novella is built with Swift 5.0 targeting the latest version of macOS.  Carthage package manager is used for external libraries.

##### Carthage
Open a terminal in the folder containing `cartfile.resolved` and bootstrap Carthage by running:
```sh
carthage bootstrap --platform macos
```

##### Xcode
After Carthage has finished cloning and building the dependencies, the project should build in Xcode.  Open the project file `Novella.xcodeproj` and build the project.

## Meta

Daniel Green – [@KasumiL5x](https://twitter.com/kasumil5x) – dgreen@bournemouth.ac.uk

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/KasumiL5x](https://github.com/KasumiL5x)
