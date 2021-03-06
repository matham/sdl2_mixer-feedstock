# Written by Daniel Schreij (dschreij@gmail.com) on 1 Nov 2016
# This procedure is configured to work in an Anaconda build environment (contiuum.io)
# In this environment, it should be called like 
# 
#    %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=Release ..
# 
# to be correctly configured
# 
# This file is intended to be used for Windows only! For other platforms, the supplied makefiles work very well.


set(PROJECT_NAME "SDL2_mixer")
project(${PROJECT_NAME})
CMAKE_MINIMUM_REQUIRED(VERSION 3.0.0)

include(GenerateExportHeader)

set(IS_LIBRARY true)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)
set(LIBRARIES_TO_LINK )

# General source files
set(SDL2_MIXER_SOURCE_FILES
	dynamic_flac.c
	dynamic_fluidsynth.c
	dynamic_mod.c
	dynamic_modplug.c
	dynamic_mp3.c
	dynamic_ogg.c
	effect_position.c
	effect_stereoreverse.c
	effects_internal.c
	fluidsynth.c
	load_aiff.c
	load_flac.c
	load_mp3.c
	load_ogg.c
	load_voc.c
	mixer.c
	music.c
	music_cmd.c
	music_flac.c
	music_mad.c
	music_mod.c
	music_modplug.c
	music_ogg.c
	wavestream.c
)

file(GLOB SDL2_MIXER_INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

## Try to find SDL2 libraries
# SDL.h
FIND_PATH(SDL2_INCLUDE_DIRS
    SDL.h
    PATH_SUFFIXES include/SDL2 include
)

# SDL2.lib
FIND_LIBRARY(SDL2_LIBRARIES
    NAMES SDL2
    PATH_SUFFIXES lib64 lib lib/x64 lib/x86
)

if(SDL2_LIBRARIES-NOTFOUND)
	message(FATAL_ERROR "SDL2 libraries could not be located." )
else()
	message(STATUS "Found SDL2: ${SDL2_LIBRARIES}")
endif()

include_directories(${SDL2_MIXER_INCLUDE_FILES} ${SDL2_INCLUDE_DIRS})

set(SDLMIXER_SUPPORT_WAV_MUSIC ON CACHE BOOL "Support for WAV music")
set(SDLMIXER_SUPPORT_MID_MUSIC ON CACHE BOOL "Support for MIDI music")
	set(SDLMIXER_SUPPORT_MID_MUSIC_TIMIDITY ON CACHE BOOL "Support for MIDI over TIMIDITI music")
	set(SDLMIXER_SUPPORT_MID_MUSIC_FLUIDSYNTH OFF CACHE BOOL "Support for MIDI over FluidSynth music")
	set(SDLMIXER_SUPPORT_MID_MUSIC_NATIVE ON CACHE BOOL "Support for native MIDI music")
set(SDLMIXER_SUPPORT_OGG_MUSIC ON CACHE BOOL "Support for OggVorbis music")
set(SDLMIXER_SUPPORT_MP3_MUSIC ON CACHE BOOL "Support for MP3 music")
set(SDLMIXER_SUPPORT_MP3_MAD_MUSIC ON CACHE BOOL "Support for MP3 MAD music")
set(SDLMIXER_SUPPORT_FLAC_MUSIC ON CACHE BOOL "Support for FLAC music")

if(SDLMIXER_SUPPORT_WAV_MUSIC)
	add_definitions(-DWAV_MUSIC)
endif()

if(SDLMIXER_SUPPORT_MID_MUSIC)
	add_definitions(-DMID_MUSIC)

	if(SDLMIXER_SUPPORT_MID_MUSIC_TIMIDITY)
		add_definitions(-DUSE_TIMIDITY_MIDI)

		include_directories("${CMAKE_CURRENT_SOURCE_DIR}/timidity")
		include_directories("${SDLMIXER_SOURCE_DIR}/timidity")
		set(SDLMIXER_TIMIDITY_SRC
			timidity/common.c
			timidity/ctrlmode.c
			timidity/filter.c
			timidity/instrum.c
			timidity/mix.c
			timidity/output.c
			timidity/playmidi.c
			timidity/readmidi.c
			timidity/resample.c
			timidity/sdl_a.c
			timidity/sdl_c.c
			timidity/tables.c
			timidity/timidity.c
		)
		list(APPEND SDLMIXER_ADDITIONAL_SRC ${SDLMIXER_TIMIDITY_SRC})
	endif()
	if(SDLMIXER_SUPPORT_MID_MUSIC_FLUIDSYNTH)
		add_definitions(-DUSE_FLUIDSYNTH_MIDI)
	endif()
	if(SDLMIXER_SUPPORT_MID_MUSIC_NATIVE)
		add_definitions(-DUSE_NATIVE_MIDI)
		include_directories("${CMAKE_CURRENT_SOURCE_DIR}/native_midi")
		set(SDLMIXER_NATIVEMIDI_SRC
			native_midi/native_midi_common.c
		)
		list(APPEND SDLMIXER_NATIVEMIDI_SRC native_midi/native_midi_win32.c)
		list(APPEND LIBRARIES_TO_LINK winmm.lib)	
		list(APPEND SDLMIXER_ADDITIONAL_SRC ${SDLMIXER_NATIVEMIDI_SRC})
	endif()
endif()

# Create target library specs
add_library(${PROJECT_NAME} SHARED ${SDL2_MIXER_SOURCE_FILES} ${SDLMIXER_ADDITIONAL_SRC})

if(SDLMIXER_SUPPORT_OGG_MUSIC)
	add_definitions(-DOGG_MUSIC)
	
	FIND_PATH(OGG_INCLUDE_DIR
	    ogg.h
	    PATH_SUFFIXES include/ogg
	)
	FIND_LIBRARY(OGG_LIBRARIES
	    NAMES ogg libogg
	    PATH_SUFFIXES lib
	)

	if(SDL2_LIBRARIES-NOTFOUND)
		message(FATAL_ERROR "OGG libraries could not be located." )
	else()
		message(STATUS "Found OGG: ${OGG_LIBRARIES}")
	endif()


	include_directories(${OGG_INCLUDE_DIR})
	list(APPEND LIBRARIES_TO_LINK ${OGG_LIBRARIES})

	FIND_PATH(VORBIS_INCLUDE_DIR
	    vorbisenc.h
	    PATH_SUFFIXES include/vorbis
	)
	FIND_LIBRARY(VORBIS_LIBRARIES
	    NAMES libvorbis vorbis
	    PATH_SUFFIXES lib
	)

	FIND_LIBRARY(VORBISFILE_LIBRARIES
		NAMES libvorbisfile vorbisfile
	    PATH_SUFFIXES lib
	)

	include_directories(${VORBIS_INCLUDE_DIR})
	list(APPEND LIBRARIES_TO_LINK ${VORBIS_LIBRARIES} ${VORBISFILE_LIBRARIES})
endif()

if(SDLMIXER_SUPPORT_MP3_MUSIC)
	add_definitions(-DMP3_MUSIC)

	FIND_PATH(SMPEG_INCLUDE_DIR
	    smpeg.h
	    PATH_SUFFIXES include include/smpeg include/smpeg2 include/SDL2
	)

	FIND_LIBRARY(SMPEG_LIBRARIES
	    NAMES smpeg smpeg2 smpeg32
	    PATH_SUFFIXES lib
	)

	include_directories(${SMPEG_INCLUDE_DIR})
	target_link_libraries(${PROJECT_NAME} ${SMPEG_LIBRARIES})
endif()

if(SDLMIXER_SUPPORT_MP3_MAD_MUSIC)
	add_definitions(-DMP3_MAD_MUSIC)

	if (("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86_64|AMD64"))
		add_definitions(-DFPM_64BIT)
	elseif (("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86"))
		add_definitions(-DFPM_INTEL)
	else()
		message("Unknown architecture: ${CMAKE_SYSTEM_PROCESSOR}")
	endif()

	FIND_PATH(MAD_INCLUDE_DIR
	    mad.h
	    PATH_SUFFIXES include/libmad include
	)
	FIND_LIBRARY(MAD_LIBRARIES
	    NAMES libmad
	    PATH_SUFFIXES lib
	)
	include_directories(${MAD_INCLUDE_DIR})
	list(APPEND LIBRARIES_TO_LINK ${MAD_LIBRARIES})
endif()

if(SDLMIXER_SUPPORT_FLAC_MUSIC)
	add_definitions(-DFLAC_MUSIC)

	FIND_PATH(FLAC_INCLUDE_DIR
	    all.h
	    PATH_SUFFIXES include/FLAC include
	)
	FIND_LIBRARY(FLAC_LIBRARIES
	    NAMES libFLAC
	    PATH_SUFFIXES lib
	)

	include_directories(${FLAC_INCLUDE_DIR})
	list(APPEND LIBRARIES_TO_LINK ${FLAC_LIBRARIES})
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES DEFINE_SYMBOL "DLL_EXPORT")
target_link_libraries(${PROJECT_NAME} ${SDL2_LIBRARIES} ${LIBRARIES_TO_LINK})

##### Installation targets #####
install(TARGETS ${PROJECT_NAME}
  LIBRARY DESTINATION "lib${LIB_SUFFIX}"
  ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
  RUNTIME DESTINATION bin)

# Copy .h files to include dir.
install(FILES ${SDL2_MIXER_INCLUDE_FILES} DESTINATION include/SDL2)
