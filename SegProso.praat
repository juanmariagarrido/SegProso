############################################################

#  SegProso                                           		
#  AUTHOR: Juan María Garrido Almiñana			
#  VERSION: 2.3 (4/6/2024)						
# Script to add prosodic segmentation to a TextGrid file. 

# The script needs as input:
#	- a wav file with the input utterance
#	- a TextGrid file

# Input TextGrid flies must include two tiers containing:
#	- orthographic transcription (words) aligned with the signal
#	- phonetic transcription, including stress and pause marks (IPA or SAMPA), aligned with the signal

# The script adds to every input TextGrid file	four tiers containing the segmentation into:
#	- syllables									
#	- stress groups								
#	- intonation groups							
#	- breath groups								

# Arguments:
#	1) wav file		
#	2) directory of the wav file				
# 	3) TextGrid file			
#	4) directory of the TextGrid file
#	5) Output directory				
# 	6) Number of tier containing orthographic transcription in the input TextGrid
# 	7) Number of tier containing phonetic transcription in the input TextGrid
#	8) Phonetic alphabet (IPA or SAMPA)

#  Copyright (C) 2012, 2024  Juan María Garrido Almiñana                       
#                                                                        
#    This program is free software: you can redistribute it and/or modify 
#    it under the terms of the GNU General Public License as published by 
#    the Free Software Foundation, either version 3 of the License, or    
#    (at your option) any later version.                                  
#                                                                         
#    This program is distributed in the hope that it will be useful,      
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.                         
#                                                                         
#    See http://www.gnu.org/licenses/ for more details.                   

############################################################


form Arguments
	sentence Wav_file file.wav
	sentence Wav_directory /Users/juanma/Desktop/tmp/input/
	sentence Textgrid_file file.TextGrid
	sentence Textgrid_directory /Users/juanma/Desktop/tmp/input/
	sentence Output_directory /Users/juanma/Desktop/tmp/output/
	positive Orthographic_transcription_tier 1
	positive Phonetic_transcription_tier 2
	choice Phonetic_alphabet: 2
		button SAMPA
		button IPA
endform

fichero_wav$ = wav_file$
directorio_wav$ = wav_directory$
fichero_textgrid$ = textgrid_file$
directorio_textgrid$ = textgrid_directory$
directorio_salida$ = output_directory$
tier_transcripcion_ortografica = orthographic_transcription_tier
tier_transcripcion_fonetica = phonetic_transcription_tier

if phonetic_alphabet = 1
	transcripcion$ = "SAMPA"
else 
	if phonetic_alphabet = 2
		transcripcion$ = "IPA"
	endif
endif

nombre_completo_fichero_entrada$ = directorio_wav$+"/"+fichero_wav$


# Intentamos leer el fichero de sonido, y el TextGrid asociado

if fileReadable (nombre_completo_fichero_entrada$)

	Read from file... 'nombre_completo_fichero_entrada$'
	nombre_sonido$ = selected$ ("Sound")
	sound = selected ("Sound")

	nombre_completo_fichero_textgrid$ = directorio_textgrid$+"/"+fichero_textgrid$

	if fileReadable (nombre_completo_fichero_textgrid$)

		printline Processing 'nombre_completo_fichero_textgrid$'...


		Read from file... 'nombre_completo_fichero_textgrid$'
		textgrid = selected ("TextGrid")

		if transcripcion$ = "SAMPA"

			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """a" "a_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """a~" "a~_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """A" "A_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """2" "2_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """9" "9_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """9~" "9~_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """e" "e_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """e~" "e~_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """E" "E_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """i" "i_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """y" "y_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """o" "o_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """o~" "o~_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """O" "O_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """u" "u_&quot" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 """@" "@_&quot" Literals

		endif

		num_tiers = Get number of tiers


		#printline Creamos un tier con las silabas para el fichero 'nombre_completo_fichero_textgrid$'. 
		call crea_tier_silabas sound textgrid tier_transcripcion_fonetica tier_transcripcion_ortografica 'transcripcion$'

		#printline Creamos un tier con los grupos fonicos para el fichero 'nombre_completo_fichero_textgrid$'. 
		#call crea_tier_grupos_fonicos sound textgrid tier_transcripcion_fonetica+1
		call crea_tier_grupos_fonicos sound textgrid num_tiers+1

		#printline Creamos un tier con los grupos entonativos para el fichero 'nombre_completo_fichero_textgrid$'. 
		#call crea_tier_grupos_entonativos sound textgrid tier_transcripcion_ortografica tier_transcripcion_fonetica tier_transcripcion_fonetica+1
		call crea_tier_grupos_entonativos sound textgrid tier_transcripcion_ortografica tier_transcripcion_fonetica num_tiers+1

		#printline Creamos un tier con los grupos acentuales para el fichero 'nombre_completo_fichero_textgrid$'. 
		#call crea_tier_grupos_acentuales sound textgrid tier_transcripcion_fonetica+1 tier_transcripcion_fonetica+2
		call crea_tier_grupos_acentuales sound textgrid num_tiers+1 num_tiers+2


		if transcripcion$ = "SAMPA"

			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "a_&quot" """a" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "a~_&quot" """a~" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "A_&quot" """A" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "2_&quot" """2" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "9_&quot" """9" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "9~_&quot" """9~" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "e_&quot" """e" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "e~_&quot" """e~" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "E_&quot" """E" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "i_&quot" """i" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "y_&quot" """y" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "o_&quot" """o" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "o~_&quot" """o~" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "O_&quot" """O" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "u_&quot" """u" Literals
			Replace interval text... 'tier_transcripcion_fonetica' 0 0 "@_&quot" """@" Literals

		endif

		# Guardamos la salida en un fichero

		select textgrid
		nombre_completo_fichero_salida$ = directorio_salida$+"/"+fichero_textgrid$
		Write to text file... 'nombre_completo_fichero_salida$'
		plus sound
		Remove

		printline SegProso completed


	else
		printline File 'nombre_completo_fichero_textgrid$' not found
		select sound
		Remove
	endif

else

	printline File 'nombre_completo_fichero_entrada$' not found

endif

procedure crea_tier_silabas sound textgrid tier_transcripcion_fonetica tier_transcripcion_ortografica transcripcion$

		tier_transcription = tier_transcripcion_fonetica
		tier_words = tier_transcripcion_ortografica
		phonetic_alphabet$ = transcripcion$
		#printline 'phonetic_alphabet$'

		#Creamos el TextGrid de silabas

		select sound

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

				#printline Numero intervalo: 'cont_intervalos'
				#printline Sonido actual: 'etiqueta_intervalo_actual$'
				#printline Alfabeto: 'phonetic_alphabet$'

				call TipoSonido 'etiqueta_intervalo_actual$' 'phonetic_alphabet$'
				tipo_sonido_actual$ = tipo_sonido$

				#printline Tipo sonido actual: 'tipo_sonido_actual$'

				
				if tipo_sonido_actual$ = "Silencio"
					#printline "Es silencio"
					final_silaba = 1
					etiqueta_silaba$= "P"
					
				endif

				if  cont_intervalos <=  (num_intervalos-1)
					etiqueta_intervalo_posterior1$ = Get label of interval... 'tier_transcription' (cont_intervalos+1)
					call TipoSonido 'etiqueta_intervalo_posterior1$' 'phonetic_alphabet$'
					tipo_sonido_posterior1$	= tipo_sonido$
				else
					tipo_sonido_posterior1$ = "Silencio"
				endif

				#printline Tipo sonido posterior 1: 'tipo_sonido_posterior1$'

				if cont_intervalos <= (num_intervalos-2)
					etiqueta_intervalo_posterior2$ = Get label of interval... 'tier_transcription' (cont_intervalos+2)
					call TipoSonido 'etiqueta_intervalo_posterior2$' 'phonetic_alphabet$'
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

										if transcripcion$ = "SAMPA"

											if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

												if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

													final_silaba = 1

												endif

											endif


											if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

												if etiqueta_intervalo_posterior2$ = "r"

													final_silaba = 1

												endif

											endif

										elsif transcripcion$ = "IPA"

											if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "β" or etiqueta_intervalo_posterior1$ = "β̞" or etiqueta_intervalo_posterior1$ = "ɣ" or etiqueta_intervalo_posterior1$ = "ɣ̞" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

												if etiqueta_intervalo_posterior2$ = "ɾ" or etiqueta_intervalo_posterior2$ = "l"

													final_silaba = 1

												endif

											endif


											if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "d̪" or etiqueta_intervalo_posterior1$ = "ð" or etiqueta_intervalo_posterior1$ = "ð̞" or etiqueta_intervalo_posterior1$ = "t" or etiqueta_intervalo_posterior1$ = "t̪"

												if etiqueta_intervalo_posterior2$ = "ɾ"

													final_silaba = 1

												endif

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

							if transcripcion$ = "SAMPA"

								if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

									if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

										final_silaba = 1

									endif

								endif


								if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

									if etiqueta_intervalo_posterior2$ = "r"

										final_silaba = 1

									endif

								endif

							elsif transcripcion$ = "IPA"

								if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "β" or etiqueta_intervalo_posterior1$ = "β̞" or etiqueta_intervalo_posterior1$ = "ɣ" or etiqueta_intervalo_posterior1$ = "ɣ̞" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

									if etiqueta_intervalo_posterior2$ = "ɾ" or etiqueta_intervalo_posterior2$ = "l"

										final_silaba = 1

									endif

								endif


								if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "d̪" or etiqueta_intervalo_posterior1$ = "ð" or etiqueta_intervalo_posterior1$ = "ð̞" or etiqueta_intervalo_posterior1$ = "t" or etiqueta_intervalo_posterior1$ = "t̪"

									if etiqueta_intervalo_posterior2$ = "ɾ"

										final_silaba = 1

									endif

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

					if (cont_palabras < num_palabras) or ((cont_palabras = num_palabras) and (cont_intervalos < num_intervalos))
						Insert boundary... 1 'tiempo_final_silaba'
					endif

					contador_silabas = contador_silabas+1

					#printline contador_silabas: 'contador_silabas'

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
		Remove

		# Guardamos la salida en un fichero

		select textgrid_salida
		textgrid = 	textgrid_salida

endproc


procedure TipoSonido etiqueta_sonido$ alphabet$

#printline Etiqueta sonido: 'etiqueta_sonido$'
#printline Alfabeto: 'alphabet$'
tipo_sonido$ = "Desconocido"

if alphabet$ = "SAMPA"

	if etiqueta_sonido$ = "..." or etiqueta_sonido$ = "_" or etiqueta_sonido$ = "#" or etiqueta_sonido$ = ""

		tipo_sonido$ = "Silencio"

	else

		#if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "@_&quot" or etiqueta_sonido$ = "6_&quot" or etiqueta_sonido$ = "U_&quot" or etiqueta_sonido$ = "i~_&quot" or etiqueta_sonido$ = "e~_&quot" or etiqueta_sonido$ = "6~_&quot" or etiqueta_sonido$ = "o~_&quot" or etiqueta_sonido$ = "u~_&quot" or etiqueta_sonido$ = "I_&quot"

		if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "A_&quot" or etiqueta_sonido$ = "2_&quot" or etiqueta_sonido$ = "9_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "y_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "a~_&quot" or etiqueta_sonido$ = "9~_&quot" or etiqueta_sonido$ = "e~_&quot" or etiqueta_sonido$ = "o~_&quot" or etiqueta_sonido$ = "@_&quot" or etiqueta_sonido$ = """a" or etiqueta_sonido$ = """A" or etiqueta_sonido$ = """2" or etiqueta_sonido$ = """9" or etiqueta_sonido$ = """e" or etiqueta_sonido$ = """E" or etiqueta_sonido$ = """i" or etiqueta_sonido$ = """y" or etiqueta_sonido$ = """o" or etiqueta_sonido$ = """O" or etiqueta_sonido$ = """u" or etiqueta_sonido$ = """a~" or etiqueta_sonido$ = """9~" or etiqueta_sonido$ = """e~" or etiqueta_sonido$ = """o~" or etiqueta_sonido$ = """@"

			tipo_sonido$ = "VocalTonica"

		else

			#if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "@_%" or etiqueta_sonido$ = "a_&#37" or etiqueta_sonido$ = "e_&#37" or etiqueta_sonido$ = "E_&#37" or etiqueta_sonido$ = "i_&#37" or etiqueta_sonido$ = "o_&#37" or etiqueta_sonido$ = "O_&#37" or etiqueta_sonido$ = "u_&#37" or etiqueta_sonido$ = "@_&#37" or etiqueta_sonido$ = "6_&#37" or etiqueta_sonido$ = "U_&#37" or etiqueta_sonido$ = "i~_&#37" or etiqueta_sonido$ = "e~_&#37" or etiqueta_sonido$ = "6~_&#37" or etiqueta_sonido$ = "o~_&#37" or etiqueta_sonido$ = "u~_&#37" or etiqueta_sonido$ = "I_&#37"

			if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "A_%" or etiqueta_sonido$ = "2_%" or etiqueta_sonido$ = "9_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "y_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "a~_%" or etiqueta_sonido$ = "9~_%" or etiqueta_sonido$ = "e~_%" or etiqueta_sonido$ = "o~_%" or etiqueta_sonido$ = "@_%"

				tipo_sonido$ = "VocalTonica2"

			else

				#if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "E" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "O" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "@" or etiqueta_sonido$ = "6" or etiqueta_sonido$ = "U" or etiqueta_sonido$ = "i~" or etiqueta_sonido$ = "e~" or etiqueta_sonido$ = "6~" or etiqueta_sonido$ = "o~" or etiqueta_sonido$ = "u~" or etiqueta_sonido$ = "I"

				if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "A" or etiqueta_sonido$ = "2" or etiqueta_sonido$ = "9" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "E" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "y" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "O" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "a~" or etiqueta_sonido$ = "9~" or etiqueta_sonido$ = "e~" or etiqueta_sonido$ = "o~" or etiqueta_sonido$ = "@"

					tipo_sonido$ = "VocalAtona"

				else
			
					if etiqueta_sonido$ = "w" or etiqueta_sonido$ = "j" or etiqueta_sonido$ = "H" or etiqueta_sonido$ = "j~" or etiqueta_sonido$ = "w~"

						tipo_sonido$ = "Semivocal"

					else

						tipo_sonido$ = "Consonante"

					endif

				endif

			endif

		endif

	endif
	
else

	if alphabet$ = "IPA"

		if etiqueta_sonido$ = "||" or etiqueta_sonido$ = "|" or etiqueta_sonido$ = "" or etiqueta_sonido$ = "‖" or etiqueta_sonido$ = "#"
		
			tipo_sonido$ = "Silencio"

		else


			if etiqueta_sonido$ = "\'1a" or etiqueta_sonido$ = "\'1\as" or etiqueta_sonido$ = "\'1\o/" or etiqueta_sonido$ = "\'1\oe" or etiqueta_sonido$ = "\'1e" or etiqueta_sonido$ = "\'1\ef" or etiqueta_sonido$ = "\'1i" or etiqueta_sonido$ = "\'1y" or etiqueta_sonido$ = "\'1o" or etiqueta_sonido$ = "\'1\ot" or etiqueta_sonido$ = "\'1u" or etiqueta_sonido$ = "\'1a\~^" or etiqueta_sonido$ = "\'1\oe\~^" or etiqueta_sonido$ = "\'1e\~^" or etiqueta_sonido$ = "\'1o\~^" or etiqueta_sonido$ = "\'1\sw"

				tipo_sonido$ = "VocalTonica"

			else


				if etiqueta_sonido$ = "\'2a" or etiqueta_sonido$ = "\'2\as" or etiqueta_sonido$ = "\'2\o/" or etiqueta_sonido$ = "\'2\oe" or etiqueta_sonido$ = "\'2e" or etiqueta_sonido$ = "\'2\ef" or etiqueta_sonido$ = "\'2i" or etiqueta_sonido$ = "\'2y" or etiqueta_sonido$ = "\'2o" or etiqueta_sonido$ = "\'2\ot" or etiqueta_sonido$ = "\'2u" or etiqueta_sonido$ = "\'2a\~^" or etiqueta_sonido$ = "\'2\oe\~^" or etiqueta_sonido$ = "\'2e\~^" or etiqueta_sonido$ = "\'2o\~^" or etiqueta_sonido$ = "\'2\sw"

					tipo_sonido$ = "VocalTonica2"

				else

					if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "\as" or etiqueta_sonido$ = "\o/" or etiqueta_sonido$ = "\oe" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "\ef" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "y" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "\ot" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "a\~^" or etiqueta_sonido$ = "\oe\~^" or etiqueta_sonido$ = "e\~^" or etiqueta_sonido$ = "o\~^" or etiqueta_sonido$ = "\sw"

						tipo_sonido$ = "VocalAtona"

					else
				
						if etiqueta_sonido$ = "w" or etiqueta_sonido$ = "j" or etiqueta_sonido$ = "\ht" or etiqueta_sonido$ = "j\~^" or etiqueta_sonido$ = "w\~^" or etiqueta_sonido$ = "i̯" or etiqueta_sonido$ = "u̯"

							tipo_sonido$ = "Semivocal"

						else

							tipo_sonido$ = "Consonante"

						endif

					endif

				endif

			endif

		endif

	else
	
		printline Alfabeto no reconocido

	endif
			
endif

#printline Tipo sonido: 'tipo_sonido$'

endproc

procedure crea_tier_grupos_fonicos sound textgrid tier_syllables


		#Creamos el TextGrid de grupos fonicos

		select sound

		duracion = Get duration
		Create TextGrid... 0.0 duracion "IntonationGroups"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier con los grupos fonicos

		select textgrid

		num_intervalos = Get number of intervals... tier_syllables

		grupo_inicial = 0
		contador_grupos = 1
		etiqueta_intervalo_actual$ = ""
		etiqueta_intervalo_anterior$ = ""

		for cont_intervalos from 1 to num_intervalos

			etiqueta_intervalo_anterior$ = etiqueta_intervalo_actual$
			etiqueta_intervalo_actual$ = Get label of interval... 'tier_syllables' cont_intervalos

			#printline Etiqueta intervalo actual: 'etiqueta_intervalo_actual$'

			if etiqueta_intervalo_actual$ = "P"

				grupo_inicial = 1
				tiempo_inicial_pausa = Get starting point... 'tier_syllables' cont_intervalos
				tiempo_final_pausa = Get end point... 'tier_syllables' cont_intervalos
	
				#printline Tiempo inicial pausa: 'tiempo_inicial_pausa'
				#printline Tiempo final pausa: 'tiempo_final_pausa'
	
				select textgrid_grupos
		
				if cont_intervalos > 1 and etiqueta_intervalo_anterior$ <> "P"
					Insert boundary... 1 'tiempo_inicial_pausa'
					contador_grupos = contador_grupos+1					
				endif


				Set interval text... 1 contador_grupos P

				if cont_intervalos < num_intervalos
					Insert boundary... 1 'tiempo_final_pausa'
					contador_grupos = contador_grupos+1
				endif

				select textgrid


			endif


		endfor
		

		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_grupos'
		Merge
		Rename... 'name$'
		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_grupos'
		Remove

		textgrid = textgrid_salida

endproc

procedure crea_tier_grupos_entonativos sound textgrid tier_words tier_transcription tier_syllables

		select sound

		To Pitch... 0 75 600

		pitch = selected ("Pitch")

		#Creamos el TextGrid de grupos entonativos

		select sound

		duracion = Get duration
		Create TextGrid... 0.0 duracion "IntonationalPhrase"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier con los grupos entonativos

		select textgrid

		num_intervalos = Get number of intervals... 'tier_words'
		#printline Numero intervalos: 'num_intervalos'

		grupo_inicial = 0
		contador_grupos = 1
		etiqueta_intervalo_actual$ = ""
		etiqueta_intervalo_anterior$ = ""

		for cont_intervalos from 1 to num_intervalos

			#printline Numero intervalos: 'num_intervalos'
			#printline Contador intervalos: 'cont_intervalos'
			#printline Palabra: 'etiqueta_intervalo_actual$'

			etiqueta_intervalo_anterior$ = etiqueta_intervalo_actual$
			etiqueta_intervalo_actual$ = Get label of interval... 'tier_words' 'cont_intervalos'

			call EsSilencioOrtografico 'etiqueta_intervalo_actual$'
			#call EsSilencioSampa 'etiqueta_intervalo_actual$'
			#call EsSilencioMelAn 'etiqueta_intervalo_actual$'
			
			if es_silencio = 0

				if cont_intervalos < num_intervalos

					etiqueta_intervalo_siguiente$ = Get label of interval... 'tier_words' (cont_intervalos+1)
					call EsSilencioOrtografico 'etiqueta_intervalo_siguiente$'
					#call EsSilencioSampa 'etiqueta_intervalo_actual$'
					#call EsSilencioMelAn 'etiqueta_intervalo_actual$'

				else

					es_silencio = 1
					#printline Es el silencio final

				endif


				if es_silencio = 0

					call EsPalabraTonica cont_intervalos

					if es_palabra_tonica = 1

						call CalculaDifTonicaPostonica cont_intervalos
							
						call CalculaDifTonicas cont_intervalos

						if (diferencia_tonica_postonica > umbral_tonica_postonica) or (diferencia_tonicas > umbral_tonicas)

							#printline Hemos detectado un limite...

							tiempo_limite = Get end point... 'tier_words' 'cont_intervalos'

							if cont_intervalos < num_intervalos

								select textgrid_grupos
								Insert boundary... 1 'tiempo_limite'
								contador_grupos = contador_grupos+1
								select textgrid

							endif

						endif

					endif
				endif


			else

				tiempo_inicio_pausa = Get starting point... 'tier_words' cont_intervalos
				tiempo_final_pausa = Get end point... 'tier_words' cont_intervalos

				select textgrid_grupos

				call EsSilencioOrtografico 'etiqueta_intervalo_anterior$'
				#call EsSilencioSampa 'etiqueta_intervalo_actual$'
				#call EsSilencioMelAn 'etiqueta_intervalo_actual$'

				if cont_intervalos > 1 and es_silencio = 0
					Insert boundary... 1 'tiempo_inicio_pausa'
					contador_grupos = contador_grupos+1
				endif

				Set interval text... 1 contador_grupos P

				if cont_intervalos < num_intervalos
					Insert boundary... 1 'tiempo_final_pausa'
					contador_grupos = contador_grupos+1
				endif
				
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
		Duplicate tier... numero_tiers 4 IntonationalPhrase
		Remove tier... numero_tiers+1

		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_grupos'
		plus pitch
		Remove

		select textgrid_salida
		textgrid = textgrid_salida
		

endproc


procedure EsSilencioOrtografico etiqueta_tier$

#printline 'etiqueta_tier$'

if etiqueta_tier$ = "CPRCsp" or etiqueta_tier$ = "CPsil" or etiqueta_tier$ = "_" or etiqueta_tier$ = "" or etiqueta_tier$ = "<pause>" or etiqueta_tier$ = "." or etiqueta_tier$ = ".." or etiqueta_tier$ = "..." or etiqueta_tier$ = "[...]" or etiqueta_tier$ = "[pause]" or etiqueta_tier$ = "P" or etiqueta_tier$ = "<sil>" or etiqueta_tier$ = "<silence>" or etiqueta_tier$ = "/"

	es_silencio = 1

else

	es_silencio = 0

endif

endproc

procedure EsSilencioSampa etiqueta_tier$

#printline 'etiqueta_tier$'

if etiqueta_tier$ = "..." or etiqueta_tier$ = "_" or etiqueta_tier$ = "#" or etiqueta_tier$ = ""

	es_silencio = 1

else

	es_silencio = 0

endif

endproc

procedure EsSilencioMelAn etiqueta_tier$

#printline 'etiqueta_tier$'

if etiqueta_tier$ = "P"

	es_silencio = 1

else

	es_silencio = 0

endif

endproc

procedure EsSilencioIPA etiqueta_tier$

#printline 'etiqueta_tier$'

if etiqueta_tier$ = "||" or etiqueta_tier$ = "|" or etiqueta_tier$ = "" or etiqueta_tier$ = "‖" or etiqueta_tier$ = "#" or etiqueta_tier$ = ""

	es_silencio = 1

else

	es_silencio = 0

endif

endproc

procedure EsPalabraTonica num_intervalo_tier

	#printline Entro en EsPalabraTonica
	#printline 'etiqueta_intervalo_actual$'

	es_palabra_tonica = 0

	tiempo_inicio_palabra = Get starting point... 'tier_words' num_intervalo_tier
	tiempo_final_palabra = Get end point... 'tier_words' num_intervalo_tier

	Extract part... tiempo_inicio_palabra tiempo_final_palabra 1 yes

	textGrid_palabra = selected ("TextGrid")

	num_silabas_palabra = Get number of intervals... tier_syllables

	for cont_silabas from 1 to num_silabas_palabra

		etiqueta_silaba$ = ""
		etiqueta_silaba$ = Get label of interval... 'tier_syllables' cont_silabas
		if etiqueta_silaba$ = "T"
			es_palabra_tonica = 1		
		endif
		
	endfor

	Remove
	select textgrid
	
	#printline Etiqueta silaba: 'etiqueta_silaba$'
	#printline Es palabra tonica: 'es_palabra_tonica'

endproc

procedure CalculaDifTonicaPostonica num_intervalo_tier

	#printline CalculaDifTonicaPostonica
	#printline Palabra: 'etiqueta_intervalo_actual$'

	diferencia_tonica_postonica = 0
	umbral_tonica_postonica = 0
	f0_tonica = 0
	f0_postonica = 0
	
	tiempo_inicio_palabra = Get starting point... 'tier_words' num_intervalo_tier
	tiempo_final_palabra = Get end point... 'tier_words' num_intervalo_tier

	Extract part... tiempo_inicio_palabra tiempo_final_palabra 1 yes

	textGrid_palabra = selected ("TextGrid")

	num_silabas_palabra = Get number of intervals... tier_syllables

	if num_silabas_palabra > 1

		for cont_silabas from 1 to num_silabas_palabra

			etiqueta_silaba$ = ""
			etiqueta_silaba$ = Get label of interval... 'tier_syllables' cont_silabas
			if etiqueta_silaba$ = "T"
				silaba_tonica = cont_silabas

				if silaba_tonica < num_silabas_palabra
					silaba_postonica = num_silabas_palabra
				else
					silaba_postonica = silaba_tonica
				endif

				tiempo_inicio_silaba = Get starting point... 'tier_syllables' silaba_tonica
				tiempo_final_silaba = Get end point... 'tier_syllables' silaba_tonica
				
				Extract part... tiempo_inicio_silaba tiempo_final_silaba 1 yes
				textgrid_silaba = selected ("TextGrid")

				num_sonidos_silaba = Get number of intervals... tier_transcription

				for cont_sonidos from 1 to num_sonidos_silaba

					etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
					call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
					if tipo_sonido$ = "VocalTonica"

						tiempo_inicio_vocal = Get starting point... 'tier_transcription' cont_sonidos
						tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

						centro_vocal = tiempo_inicio_vocal + ((tiempo_final_vocal-tiempo_inicio_vocal)/2)

						select pitch

						f0_tonica = Get value at time... centro_vocal Hertz Linear

						select textgrid_silaba

					endif

				endfor
			
				if silaba_tonica <> silaba_postonica

					Remove
					select textGrid_palabra	

					tiempo_inicio_silaba = Get starting point... 'tier_syllables' silaba_postonica
					tiempo_final_silaba = Get end point... 'tier_syllables' silaba_postonica
				
					Extract part... tiempo_inicio_silaba tiempo_final_silaba 1 yes
					textgrid_silaba = selected ("TextGrid")

					num_sonidos_silaba = Get number of intervals... tier_transcription


					for cont_sonidos from 1 to num_sonidos_silaba

						etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
						call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
						if tipo_sonido$ = "VocalAtona"

							tiempo_inicio_vocal = Get starting point... 'tier_transcription' cont_sonidos
							tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

							centro_vocal = tiempo_inicio_vocal + ((tiempo_final_vocal-tiempo_inicio_vocal)/2)

							select pitch

							f0_postonica = Get value at time... centro_vocal Hertz Linear

							select textgrid_silaba

						endif

					endfor


				else

					select textgrid_silaba

					num_sonidos_silaba = Get number of intervals... tier_transcription

					for cont_sonidos from 1 to num_sonidos_silaba

						etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
						call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
						if tipo_sonido$ = "VocalTonica"

							tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

							select pitch

							f0_postonica = Get value at time... tiempo_final_vocal Hertz Linear

							select textgrid_silaba

						endif

					endfor
				endif

				Remove
				select textGrid_palabra


			endif
		
		endfor

	else

		num_sonidos_silaba = Get number of intervals... tier_transcription

		for cont_sonidos from 1 to num_sonidos_silaba

			etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
			call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
			if tipo_sonido$ = "VocalTonica"

				tiempo_inicio_vocal = Get starting point... 'tier_transcription' cont_sonidos
				tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

				centro_vocal = tiempo_inicio_vocal + ((tiempo_final_vocal-tiempo_inicio_vocal)/2)

				select pitch

				f0_tonica = Get value at time... centro_vocal Hertz Linear
				f0_postonica = Get value at time... tiempo_final_vocal Hertz Linear

				select textGrid_palabra

			endif

		endfor


	endif


	umbral_tonica_postonica = (f0_tonica * 5) / 100
	diferencia_tonica_postonica = f0_postonica - f0_tonica

	#printline Umbral: 'umbral_tonica_postonica'
	#printline Diferencia tonica postonica: 'diferencia_tonica_postonica'
	#printline F0 tonica: 'f0_tonica'
	#printline F0 postonica: 'f0_postonica'

	Remove
	select textgrid
	


endproc



procedure CalculaDifTonicas num_intervalo_tier

	#printline CalculaDifTonicas
	#printline Palabra: 'etiqueta_intervalo_actual$'

	diferencia_tonicas = 0
	umbral_tonicas = 0
	f0_tonica_antes = 0
	f0_tonica_despues = 0
	
	tiempo_inicio_palabra = Get starting point... 'tier_words' num_intervalo_tier
	tiempo_final_palabra = Get end point... 'tier_words' num_intervalo_tier

	Extract part... tiempo_inicio_palabra tiempo_final_palabra 1 yes

	textgrid_palabra = selected ("TextGrid")

	num_silabas_palabra = Get number of intervals... tier_syllables

	for cont_silabas from 1 to num_silabas_palabra

		etiqueta_silaba$ = ""
		etiqueta_silaba$ = Get label of interval... 'tier_syllables' cont_silabas
		if etiqueta_silaba$ = "T"
			silaba_tonica = cont_silabas

			tiempo_inicio_silaba = Get starting point... 'tier_syllables' silaba_tonica
			tiempo_final_silaba = Get end point... 'tier_syllables' silaba_tonica
				
			Extract part... tiempo_inicio_silaba tiempo_final_silaba 1 yes
			textgrid_silaba = selected ("TextGrid")

			num_sonidos_silaba = Get number of intervals... tier_transcription

			for cont_sonidos from 1 to num_sonidos_silaba

				etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
				call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
				if tipo_sonido$ = "VocalTonica"

					tiempo_inicio_vocal = Get starting point... 'tier_transcription' cont_sonidos
					tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

					centro_vocal = tiempo_inicio_vocal + ((tiempo_final_vocal-tiempo_inicio_vocal)/2)

					select pitch

					f0_tonica_antes = Get value at time... centro_vocal Hertz Linear

					select textgrid_silaba

				endif

			endfor

			Remove
			select textgrid_palabra

		endif
		
	endfor

	Remove
	select textgrid

	contador_palabras_tier = num_intervalo_tier+1
	he_encontrado_otra_tonica =0

	while he_encontrado_otra_tonica =0 and contador_palabras_tier < num_intervalos
		call EsPalabraTonica (contador_palabras_tier)
		if es_palabra_tonica = 1
			he_encontrado_otra_tonica = 1
		else
			contador_palabras_tier = contador_palabras_tier + 1
		endif
	endwhile


	if he_encontrado_otra_tonica = 1

		tiempo_inicio_palabra = Get starting point... 'tier_words' (num_intervalo_tier+1)
		tiempo_final_palabra = Get end point... 'tier_words' (num_intervalo_tier+1)

		Extract part... tiempo_inicio_palabra tiempo_final_palabra 1 yes

		textgrid_palabra = selected ("TextGrid")

		num_silabas_palabra = Get number of intervals... tier_syllables

		for cont_silabas from 1 to num_silabas_palabra

			etiqueta_silaba$ = ""
			etiqueta_silaba$ = Get label of interval... 'tier_syllables' cont_silabas
			if etiqueta_silaba$ = "T"
				silaba_tonica = cont_silabas

				tiempo_inicio_silaba = Get starting point... 'tier_syllables' silaba_tonica
				tiempo_final_silaba = Get end point... 'tier_syllables' silaba_tonica
				
				Extract part... tiempo_inicio_silaba tiempo_final_silaba 1 yes
				textgrid_silaba = selected ("TextGrid")

				num_sonidos_silaba = Get number of intervals... 'tier_transcription'

				for cont_sonidos from 1 to num_sonidos_silaba

					etiqueta_sonido_actual$ = Get label of interval... 'tier_transcription' cont_sonidos
					call TipoSonido 'etiqueta_sonido_actual$' 'phonetic_alphabet$'
					if tipo_sonido$ = "VocalTonica"

						tiempo_inicio_vocal = Get starting point... 'tier_transcription' cont_sonidos
						tiempo_final_vocal = Get end point... 'tier_transcription' cont_sonidos

						centro_vocal = tiempo_inicio_vocal + ((tiempo_final_vocal-tiempo_inicio_vocal)/2)

						select pitch

						f0_tonica_despues = Get value at time... centro_vocal Hertz Linear

						select textgrid_silaba

					endif

				endfor

				Remove
				select textgrid_palabra

			endif
		
		endfor

		Remove
		select textgrid


		umbral_tonicas = (f0_tonica_antes * 5) / 100
		diferencia_tonicas = f0_tonica_despues - f0_tonica_antes

	endif

	#printline Umbral: 'umbral_tonicas'
	#printline Diferencia tonicas: 'diferencia_tonicas'
	#printline F0 tonica antes: 'f0_tonica_antes'
	#printline F0 tonica despues: 'f0_tonica_despues'


endproc

procedure crea_tier_grupos_acentuales sound textgrid tier_syllabes tier_intonation_units

		#Creamos el TextGrid de grupos acentuales

		select sound

		duracion = Get duration
		Create TextGrid... 0.0 duracion "StressGroups"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier con los grupos acentuales

		select textgrid

		num_intervalos = Get number of intervals... tier_syllables
		#printline Num intervalos: 'num_intervalos'

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

			#printline 'unidad_entonativa_silaba'
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
		Remove

		select textgrid_salida
		textgrid = textgrid_salida

endproc


