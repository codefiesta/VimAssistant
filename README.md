![Build](https://github.com/codefiesta/VimAssistant/actions/workflows/swift.yml/badge.svg)
![Xcode 16.2+](https://img.shields.io/badge/Xcode-16.2%2B-gold.svg)
![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-tomato.svg)
![iOS 18.0+](https://img.shields.io/badge/iOS-18.0%2B-crimson.svg)
![visionOS 2.0+](https://img.shields.io/badge/visionOS-2.0%2B-magenta.svg)
![macOS 15.0+](https://img.shields.io/badge/macOS-15.0%2B-skyblue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-indigo.svg)](https://opensource.org/licenses/MIT)

# VimAssistant
VimAssistant is a AI powered productivity assistant to [VimKit](https://github.com/codefiesta/VimKit) that helps users complete tasks more efficiently.

## Overview
The VimAssistant package processes natural language (spoken or typed) to take action on a VIM model.

This package utilizes Speech Recognition to transcribe spoken text that gets sent to a CoreML LLM/LAM that will attempt to execute an action on the users behalf.

Some examples of actions include (but not limited to):

* `"Isolate all HVAC components."`
* `"Create a section box around level 1."`
* `"Hide all walls."`
