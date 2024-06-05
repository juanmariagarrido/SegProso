# SegProso

AUTHOR: Juan María Garrido Almiñana								
VERSION: 2.3 (4/06/2024)										

Script to add prosodic segmentation to a set of TextGrid files. 

The script needs as input:
- a directory containing the wav files of the input utterances
- a directory containing the TextGrid files

Wav and TextGrid files of the same utterance have to have the same name	

Input TextGrid flies must include two tiers containing:
- orthographic transcription (words) aligned with the signal
- phonetic transcription, including stress marks (IPA or SAMPA), aligned with the signal

The script adds to every input TextGrid file four tiers containing the segmentation into:						
- syllables												
- stress groups												
- intonation groups											
- breath groups																		

Arguments:
1) wav file		
2) directory of the wav file				
3) TextGrid file			
4) directory of the TextGrid file
5) Output directory				
6) Number of tier containing orthographic transcription in the input TextGrid
7) Number of tier containing phonetic transcription in the input TextGrid
8) Phonetic alphabet (IPA or SAMPA)								

Copyright (C) 2012, 2024  Juan María Garrido Almiñana                       	 		
                                                                       				 		
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.                                  				
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                         			
                                                                       						
See http://www.gnu.org/licenses/ for more details.         

