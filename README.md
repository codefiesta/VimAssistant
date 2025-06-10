![Build](https://github.com/codefiesta/VimAssistant/actions/workflows/swift.yml/badge.svg)
![Xcode 16.4+](https://img.shields.io/badge/Xcode-16.4%2B-gold.svg)
![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-tomato.svg)
![iOS 18.0+](https://img.shields.io/badge/iOS-18.0%2B-crimson.svg)
![visionOS 2.0+](https://img.shields.io/badge/visionOS-2.0%2B-magenta.svg)
![macOS 15.0+](https://img.shields.io/badge/macOS-15.0%2B-skyblue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-indigo.svg)](https://opensource.org/licenses/MIT)

# VimAssistant
VimAssistant is a AI powered productivity assistant to [VimKit](https://github.com/codefiesta/VimKit) that helps users complete tasks more efficiently.
<img width="590" alt="assistant" src="https://github.com/user-attachments/assets/ae438be8-b39c-435d-be0c-365443f4fe4e" />

## Overview
The VimAssistant package processes natural language (spoken or typed) to take action on a VIM model.

This package utilizes Speech Recognition to transcribe spoken text that gets sent to a CoreML LLM/LAM that will attempt to execute an action on the users behalf.

Some examples of categorized actions include (but not limited to):

* **ISOLATE**: "Isolate furniture", "Only show me the network jacks", "Filter everything but the curtain panels"
* **HIDE**: "Conceal all ceiling systems", "Hide air terminals", "Remove all walls"
* **QUANTIFY**: "Count all doors", "What are the total number of access doors?", "How many transformers are there?"

### Label Scheme
The base model was created with the OntoNotes 5.0 NER annotations which includes:

* **CARDINAL**: Cardinal numbers (e.g., 1, 2, 3).
* **DATE**: Dates (e.g., May 8, 2025).
* **EVENT**: Names of events (e.g., World Series).
* **FAC**: Buildings or facilities (e.g., White House).
* **GPE**: Geo-political entities (e.g., United States).
* **LANGUAGE**: Names of languages (e.g., English).
* **LAW**: Legal names (e.g., The Constitution).
* **LOC**: Represents locations (e.g., "New York City").
* **MONEY**: Indicates monetary values (e.g., "100 dollars").
* **NORP**: Represents national or political or religious groups (e.g., "Democrats", "the Catholic Church").
* **ORDINAL**: Denotes ordinal numbers (e.g., "first", "second", "10th").
* **ORG**: Represents organizations (e.g., "Google", "Microsoft").
* **PERCENT**: Denotes percentages (e.g., "10%", "20%").
* **PERSON**: Individual names (e.g., Barack Obama).
* **PRODUCT**: Represents products (e.g., "iPhone", "MacBook").
* **QUANTITY**: Indicates measurements or quantities (e.g., "10 kilograms").
* **TIME**: Times (e.g., 10:00 AM).
* **WORK\_OF\_ART**: Names of works of art (e.g., "Hamlet").

The trained model provides Construction NER annotations:

* **CON\_BIM\_CATG**: BIM Category - a high-level classification for families and elements, grouping them based on their functional type.
* **CON\_BIM\_FAML**: BIM Family - a collection of elements that share common properties, behaviors, and physical characteristics.
* **CON\_BIM\_TYPE**: BIM Type - a specific instantiation of a family that defines a unique set of parameters, essentially a variation within a family. Think of it as a specific size, material, or configuration of a particular family, such as a 3' x 6' door within a door family.
* **CON\_BIM\_INST**: BIM Instance - a single, unique occurrence of a family type placed within a model.
* **CON\_BIM\_LEVL**: BIM Level - a horizontal  plane used to define the vertical position of elements like walls, floors, and ceilings.
* **CON\_BIM\_VIEW**: BIM View - represents a specific way of looking at the model, whether it's a 2D plan, elevation, section, or 3D view.


| Component | Labels |
| -------- | ------- |
| named entities  | CARDINAL, DATE, EVENT, FAC, GPE, LANGUAGE, LAW, LOC, MONEY, NORP, ORDINAL, ORG, PERCENT, PERSON, PRODUCT, QUANTITY, TIME, WORK\_OF\_ART, CON\_BIM\_CATG, CON\_BIM\_FAML, CON\_BIM\_TYPE, CON\_BIM\_INST, CON\_BIM\_LEVL, CON\_BIM\_VIEW |
| categories | ISOLATE, HIDE, QUANTIFY, ZOOM\_IN, ZOOM\_OUT, PAN\_LEFT, PAN\_RIGHT, PAN\_UP, PAN\_DOWN, LOOK\_LEFT, LOOK\_RIGHT, LOOK\_UP, LOOK\_DOWN |
