############################################################

#  create_tier_syllables                                          			  			#

#  AUTHOR: Juan María Garrido Almiñana								#
#  VERSION: 1.0 (20/08/2012)										#

# Script to add syllable segmentation to a TextGrid file.		 			#

# The script needs as input:
#	- a wav file with the input utterance signal						#
#	- its corresponding TextGrid file		 						#

# Wav and TextGrid files of the same utterance have to have the same name	#

# Input TextGrid flies must include two tiers containing:					#
#	- orthographic transcription (words) aligned with the signal			#
#	- phonetic transcription (SAMPA) aligned with the signal				#

# The script adds to every input TextGrid file							#
# one tier containing the segmentation into syllables					#

# Arguments:
#	- name of the files											#
# 	- directory of the wav file										#
# 	- directory of the wav file										#
#	- tier number for phonetic transcription							#
#	- tier number for word transcription							#

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
	positive Tier_transcription 2
	positive Tier_words 1
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


		#Creamos el TextGrid de silabas

		duracion = Get duration
		Create TextGrid... 0.0 duracion "Syllables"
		textgrid_silabas = selected ("TextGrid")

		# Empezamos a marcar las sílabas. Ahora mismo se intenta seguir el criterio de agrupacion en silabas del Segre.

		select textgrid

		num_palabras = Get number of intervals... tier_words

		final_silaba = 0
		hay_nucleo = 0
		contador_silabas = 0
		etiqueta_silaba$= ""

		for cont_palabras from 1 to num_palabras

			select textgrid
			tiempo_inicio_palabra = Get start point... 'tier_words' cont_palabras
			tiempo_final_palabra = Get end point... 'tier_words' cont_palabras

			etiqueta_palabra_actual$ = Get label of interval... 'tier_words' cont_palabras
			#printline Palabra actual: 'etiqueta_palabra_actual$'

			Extract part... tiempo_inicio_palabra tiempo_final_palabra  yes
			textgrid_palabra = selected ("TextGrid")
			select textgrid_palabra

			num_intervalos = Get number of intervals... tier_transcription


			for cont_intervalos from 1 to num_intervalos

				etiqueta_intervalo_actual$ = Get label of interval... 'tier_transcription' cont_intervalos
				call TipoSonido 'etiqueta_intervalo_actual$'
				tipo_sonido_actual$ = tipo_sonido$

				#printline Numero intervalo: 'cont_intervalos'
				#printline Sonido actual: 'etiqueta_intervalo_actual$'
				#printline Tipo sonido actual: 'tipo_sonido_actual$'
				
				if tipo_sonido_actual$ = "Silencio"
					
					final_silaba = 1
					etiqueta_silaba$= "P"
					
				endif

				if  cont_intervalos <=  (num_intervalos-1)
					etiqueta_intervalo_posterior1$ = Get label of interval... 'tier_transcription' (cont_intervalos+1)
					call TipoSonido 'etiqueta_intervalo_posterior1$'
					tipo_sonido_posterior1$	= tipo_sonido$
				else
					tipo_sonido_posterior1$ = "Silencio"
				endif

				#printline Tipo sonido posterior 1: 'tipo_sonido_posterior1$'

				if cont_intervalos <= (num_intervalos-2)
					etiqueta_intervalo_posterior2$ = Get label of interval... 'tier_transcription' (cont_intervalos+2)
					call TipoSonido 'etiqueta_intervalo_posterior2$'
					tipo_sonido_posterior2$ = tipo_sonido$
				else

					tipo_sonido_posterior2$ = "Silencio"

				endif

				#printline Tipo sonido posterior 2: 'tipo_sonido_posterior2$'

				if tipo_sonido_actual$ = "VocalTonica" or tipo_sonido_actual$ = "VocalAtona" or tipo_sonido_actual$ = "VocalTonica2"

					hay_nucleo = 1

					if tipo_sonido_actual$ = "VocalTonica"

						etiqueta_silaba$= "T"

					endif

					if tipo_sonido_posterior1$ = "Silencio"

						final_silaba = 1

					endif

					if tipo_sonido_posterior1$ = "VocalTonica" or tipo_sonido_posterior1$ = "VocalAtona" or tipo_sonido_posterior1$ = "VocalTonica2"

						final_silaba = 1

					else

						if tipo_sonido_posterior1$ = "Consonante" or tipo_sonido_posterior1$ = "Semivocal"

							if tipo_sonido_posterior1$ = "Consonante"


								if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalAtona" or tipo_sonido_posterior2$ = "VocalTonica2" or tipo_sonido_posterior2$ = "Semivocal"

									final_silaba = 1

								else

									if tipo_sonido_posterior2$ = "Consonante"

										if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f"

											if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

												final_silaba = 1

											endif

										endif


										if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

											if etiqueta_intervalo_posterior2$ = "r"

												final_silaba = 1

											endif

										endif

									endif

								endif

							endif

							if tipo_sonido_posterior1$ = "Semivocal"

								if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalTonica2"

									final_silaba = 1

								endif

							endif

						endif

					endif

				endif


				if tipo_sonido_actual$ = "Consonante" or tipo_sonido_actual$ = "Semivocal"


					if tipo_sonido_posterior1$ = "Silencio"

						final_silaba = 1

					endif

					if tipo_sonido_posterior1$ = "Consonante" and hay_nucleo = 1


						if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalAtona" or tipo_sonido_posterior2$ = "VocalTonica2" or tipo_sonido_posterior2$ = "Semivocal"

							final_silaba = 1

						endif

						if tipo_sonido_posterior2$ = "Consonante"

							if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f"

								if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

									final_silaba = 1

								endif

							endif


							if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

								if etiqueta_intervalo_posterior2$ = "r"

									final_silaba = 1

								endif

							endif

						endif


					endif

					if tipo_sonido_actual$ = "Semivocal" and tipo_sonido_posterior1$ = "Semivocal" and tipo_sonido_posterior2$ = "VocalTonica" and hay_nucleo = 1

						final_silaba = 1

					endif


				endif

				if final_silaba = 1

					#printline Hay final silaba
					tiempo_final_silaba = Get end point... 'tier_transcription' cont_intervalos
					inicio_silaba = 1

					select textgrid_silabas

					if cont_palabras < num_palabras
						Insert boundary... 1 'tiempo_final_silaba'
					endif

					contador_silabas = contador_silabas+1

					Set interval text... 1 contador_silabas 'etiqueta_silaba$'
					
					select textgrid_palabra

					final_silaba = 0
					etiqueta_silaba$= ""
					hay_nucleo = 0

					
				endif


			endfor

			select textgrid_palabra
			Remove

		endfor


		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_silabas'
		Merge
		Rename... 'name$'
		numero_tiers = Get number of tiers
		Duplicate tier... numero_tiers 3 Syllables
		Remove tier... numero_tiers+1

		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_silabas'
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


procedure TipoSonido etiqueta_sonido$

# printline Etiqueta sonido: 'etiqueta_sonido$'

if etiqueta_sonido$ = "..."

	tipo_sonido$ = "Silencio"

else

	if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "@_&quot" 

		tipo_sonido$ = "VocalTonica"

	else

		if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "@_%" or etiqueta_sonido$ = "a_&#37" or etiqueta_sonido$ = "e_&#37" or etiqueta_sonido$ = "E_&#37" or etiqueta_sonido$ = "i_&#37" or etiqueta_sonido$ = "o_&#37" or etiqueta_sonido$ = "O_&#37" or etiqueta_sonido$ = "u_&#37" or etiqueta_sonido$ = "@_&#37" 

			tipo_sonido$ = "VocalTonica2"

		else

			if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "E" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "O" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "@" 

				tipo_sonido$ = "VocalAtona"

			else
		
				if etiqueta_sonido$ = "w" or etiqueta_sonido$ = "j"

					tipo_sonido$ = "Semivocal"

				else

					tipo_sonido$ = "Consonante"

				endif

			endif

		endif

	endif

endif

# printline Tipo sonido: 'tipo_sonido$'

endproc