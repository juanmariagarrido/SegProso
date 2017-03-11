############################################################

#  SegProso                                           			  					#

#  AUTHOR: Juan María Garrido Almiñana								#
#  VERSION: 1.0 (20/08/2012)										#

# Script to add prosodic segmentation to a set of TextGrid files. 			#

# The script needs as input:
#	- a directory containing the wav files of the input utterances			#
#	- a directory containing the TextGrid files 						#

# Wav and TextGrid files of the same utterance have to have the same name	#

# Input TextGrid flies must include two tiers containing:					#
#	- orthographic transcription (words) aligned with the signal (tier 1)		#
#	- phonetic transcription (SAMPA) aligned with the signal (tier 2)		#

# The script adds to every input TextGrid file							#
# four tiers containing the segmentation into:							#
#	- syllables												#
#	- stress groups												#
#	- intonation groups											#
#	- breath groups											#

# It makes calls to four auxiliary scripts, included in this distribution:		#
#	- create_tier_breath_groups.praat								#
#	- create_tier_syllables.praat									#
#	- create_tier_intonation_groups.praat							#
#	- create_tier_stress_groups.praat								#

# Arguments:
#	- directory of the wav files									#
# 	- directory of the TextGrid files								#
#	- directory of the auxiliary scripts								#

#  Copyright (C) 2012  Juan María Garrido Almiñana                       	 		#
#                                                                        				 		#
#    This program is free software: you can redistribute it and/or modify 	#
#    it under the terms of the GNU General Public License as published by 	#
#    the Free Software Foundation, either version 3 of the License, or    		#
#    (at your option) any later version.                                  				#
#                                                                         						#
#    This program is distributed in the hope that it will be useful,      		#
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       	#
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       #
#    GNU General Public License for more details.                         			#
#                                                                         						#
#    See http://www.gnu.org/licenses/ for more details.                   		#

############################################################


form Argumentos
	sentence Directorio_wav /Users/juan/Desktop/prueba_silabas/
	sentence Directorio_textgrid /Users/juan/Desktop/prueba_silabas/
	sentence Directorio_scripts .
endform

Create Strings as file list... lista_ficheros 'directorio_wav$'/*.wav
objeto_lista = selected ("Strings")


numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings lista_ficheros
	fichero$ = Get string... ifile

	directorio_script_creacion_tiers$ = directorio_scripts$+"/"
	printline Creamos un tier con las silabas para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'create_tier_syllables.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 2 1
	printline Creamos un tier con los grupos fonicos para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'create_tier_breath_groups.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 3
	printline Creamos un tier con los grupos entonativos para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'create_tier_intonation_groups.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 1 2 3
	printline Creamos un tier con los grupos acentuales para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'create_tier_stress_groups.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 3 4

endfor

select objeto_lista
Remove