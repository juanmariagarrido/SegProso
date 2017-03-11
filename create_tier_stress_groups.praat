#############################################################

#  create_tier_stress_groups                                     			  		#

#  AUTHOR: Juan María Garrido Almiñana								#
#  VERSION: 1.0 (20/08/2012)										#

# Script to add stress group segmentation to a TextGrid file.		 		#

# The script needs as input:
#	- a wav file with the input utterance signal						#
#	- its corresponding TextGrid file		 						#

# Wav and TextGrid files of the same utterance have to have the same name	#

# Input TextGrid flies must include two tiers containing:					#
#	- syllable segmentation										#
#	- intonation unit segmentation								#

# The script adds to the input TextGrid file							#
# one tier containing the segmentation into stress groups				#

# Arguments:
#	- name of the files											#
# 	- directory of the wav file										#
# 	- directory of the wav file										#
#	- tier number for syllable segmentation							#
#	- tier number for intonation unit segmentation					#

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


form Parameters
	word Sound_file ifm_n1001_001.wav
	sentence Directory_sound /Users/juan/Desktop/prueba_silabas/
	sentence Directory_textgrid /Users/juan/Desktop/prueba_silabas/
	positive Tier_syllables 3
	positive Tier_intonation_units 5
endform

nombre_completo_fichero_entrada$ = directory_sound$+"/"+sound_file$


# Intentamos leer el fichero de sonido, y el TextGrid asociado

if fileReadable (nombre_completo_fichero_entrada$)

	Read from file... 'nombre_completo_fichero_entrada$'
	nombre_sonido$ = selected$ ("Sound")
	sound = selected ("Sound")

	nombre_completo_fichero_textgrid$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"

	if fileReadable (nombre_completo_fichero_textgrid$)
		Read from file... 'nombre_completo_fichero_textgrid$'
		textgrid = selected ("TextGrid")


		#Creamos el TextGrid de grupos acentuales

		duracion = Get duration
		Create TextGrid... 0.0 duracion "StressGroups"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier con los grupos acentuales

		select textgrid

		num_intervalos = Get number of intervals... tier_syllables

		grupo_inicial = 0
		contador_grupos = 1
		etiqueta_intervalo_actual$ = ""
		etiqueta_intervalo_anterior$ = ""
		etiqueta_intervalo_siguiente$ = ""

		for cont_intervalos from 1 to num_intervalos

			etiqueta_intervalo_anterior$ = etiqueta_intervalo_actual$
			etiqueta_intervalo_actual$ = Get label of interval... 'tier_syllables' cont_intervalos
			
			if cont_intervalos < num_intervalos
				etiqueta_intervalo_siguiente$ = Get label of interval... 'tier_syllables' (cont_intervalos+1)
			else
				etiqueta_intervalo_siguiente$ = ""
			endif

			#printline Grupo inicial: 'grupo_inicial'
			#printline Etiqueta intervalo actual: 'etiqueta_intervalo_actual$'
			#printline Etiqueta intervalo siguiente: 'etiqueta_intervalo_siguiente$'

			tiempo_inicial_silaba = Get starting point... 'tier_syllables' cont_intervalos
			tiempo_final_silaba = Get end point... 'tier_syllables' cont_intervalos

			#printline Tiempo inicial silaba: 'tiempo_inicial_silaba'
			#printline Tiempo final silaba: 'tiempo_final_silaba'

			unidad_entonativa_silaba = Get interval at time... 'tier_intonation_units' tiempo_final_silaba
			tiempo_inicio_unidad_entonativa = Get start point... 'tier_intonation_units' unidad_entonativa_silaba
			#printline Tiempo inicio unidad entonativa: 'tiempo_inicio_unidad_entonativa'

			if etiqueta_intervalo_actual$ = "P"

				grupo_inicial = 1
	
				select textgrid_grupos
		

				if cont_intervalos > 1 and etiqueta_intervalo_anterior$ <> "P"
					Insert boundary... 1 'tiempo_inicial_silaba'
					contador_grupos = contador_grupos+1					
				endif

				Set interval text... 1 contador_grupos P

				if cont_intervalos < num_intervalos
					Insert boundary... 1 'tiempo_final_silaba'
					contador_grupos = contador_grupos+1
				endif
				
				select textgrid

			else

				if etiqueta_intervalo_actual$ = "T"

					if grupo_inicial = 0

						select textgrid_grupos

						if cont_intervalos > 1
							Insert boundary... 1 'tiempo_inicial_silaba'
							contador_grupos = contador_grupos+1
						endif
			
						select textgrid
					else

						grupo_inicial = 0

					endif
				
				endif

			endif

			if tiempo_final_silaba = tiempo_inicio_unidad_entonativa

					select textgrid_grupos

					if (cont_intervalos < num_intervalos) and (etiqueta_intervalo_siguiente$ <> "P") and (etiqueta_intervalo_actual$ <> "P")
						Insert boundary... 1 'tiempo_final_silaba'
						contador_grupos = contador_grupos+1
					endif

					grupo_inicial = 1

					select textgrid			

			endif




		endfor
		

		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_grupos'
		Merge
		Rename... 'name$'
		numero_tiers = Get number of tiers
		Duplicate tier... numero_tiers 4 StressGroups
		Remove tier... numero_tiers+1

		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_grupos'
		plus sound
		Remove

		# Guardamos la salida en un fichero

		select textgrid_salida
		nombre_completo_fichero_salida$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"
		Write to text file... 'nombre_completo_fichero_salida$'
		Remove
		
	else
		printline No se ha encontrado un fichero con el TextGrid.
		select sound
		Remove
	endif


	
else

	printline Error al abrir el fichero.

endif

