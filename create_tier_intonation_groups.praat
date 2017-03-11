#############################################################

#  create_tier_intonation_groups                                     			  		#

#  AUTHOR: Juan María Garrido Almiñana								#
#  VERSION: 1.0 (20/08/2012)										#

# Script to add intonation group segmentation to a TextGrid file.		 	#

# The script needs as input:
#	- a wav file with the input utterance signal						#
#	- its corresponding TextGrid file		 						#

# Wav and TextGrid files of the same utterance have to have the same name	#

# Input TextGrid flies must include four tiers containing:					#
#	- orthographic transcription (words) aligned with the signal			#
#	- phonetic transcription (SAMPA) aligned with the signal				#
#	- syllable segmentation										#

# The script adds to the input TextGrid file							#
# one tier containing the segmentation into intonation groups			#

# Arguments:
#	- name of the files											#
# 	- directory of the wav file										#
# 	- directory of the TextGrid file									#
#	- tier number for phonetic transcription							#
#	- tier number for word transcription							#
#	- tier number for syllable segmentation							#

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
	word Sound_file test.wav
	sentence Directory_sound .
	sentence Directory_textgrid .
	positive Tier_words 1
	positive Tier_transcription 2
	positive Tier_syllables 3
endform

nombre_completo_fichero_entrada$ = directory_sound$+"/"+sound_file$


# Intentamos leer el fichero de sonido, y el TextGrid asociado

if fileReadable (nombre_completo_fichero_entrada$)

	Read from file... 'nombre_completo_fichero_entrada$'
	nombre_sonido$ = selected$ ("Sound")
	sound = selected ("Sound")

	To Pitch... 0 75 600

	pitch = selected ("Pitch")

	select sound

	nombre_completo_fichero_textgrid$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"

	if fileReadable (nombre_completo_fichero_textgrid$)
		Read from file... 'nombre_completo_fichero_textgrid$'
		textgrid = selected ("TextGrid")

		#Creamos el TextGrid de grupos entonativos

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

			call EsSilencioCereproc 'etiqueta_intervalo_actual$'

			if es_silencio = 0

				if cont_intervalos < num_intervalos

					etiqueta_intervalo_siguiente$ = Get label of interval... 'tier_words' (cont_intervalos+1)
					call EsSilencioCereproc 'etiqueta_intervalo_siguiente$'

				else

					es_silencio = 1

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

				call EsSilencioCereproc 'etiqueta_intervalo_anterior$'

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
		plus sound
		plus pitch
		Remove

		# Guardamos la salida en un fichero

		select textgrid_salida
		nombre_completo_fichero_salida$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"
		Write to text file... 'nombre_completo_fichero_salida$'
		Remove
		
	else
		printline No se ha encontrado un fichero con el TextGrid.
		select sound
		plus pitch
		Remove
	endif


	
else

	printline Error al abrir el fichero.

endif


procedure EsSilencioCereproc etiqueta_tier$

#printline 'etiqueta_tier$'

if etiqueta_tier$ = "CPRCsp" or etiqueta_tier$ = "CPsil"

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
					call TipoSonido 'etiqueta_sonido_actual$'
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
						call TipoSonido 'etiqueta_sonido_actual$'
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
						call TipoSonido 'etiqueta_sonido_actual$'
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
			call TipoSonido 'etiqueta_sonido_actual$'
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
				call TipoSonido 'etiqueta_sonido_actual$'
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
					call TipoSonido 'etiqueta_sonido_actual$'
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


procedure TipoSonido etiqueta_sonido$

# printline Etiqueta sonido: 'etiqueta_sonido$'

if etiqueta_sonido$ = "..."

	tipo_sonido$ = "Silencio"

else

	if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "@_&quot" 

		tipo_sonido$ = "VocalTonica"

	else

		if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "@_%" 

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