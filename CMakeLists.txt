cmake_minimum_required(VERSION 3.5)

project(flight)

# Suppress OpenGL deprecation warnings on macOS
if(APPLE)
    add_definitions(-DGL_SILENCE_DEPRECATION)
endif()


set (SRCS
	b747.c  
	color.c  
	draw_logo.c  
	f16.c   
	f18.c     
	graph.c   
	main.c   
	meters.c  
	p38.c   
	uflight.c
	c150.c  
	demo.c   
	f15.c        
	f16w.c  
	flight.c  
	irisgl.c  
	maths.c  
	object.c  
	p38w.c
)

set (HEADERS
	bitmap.h  
	demo.h      
	f16_points.h  
	graph.h   
	main.h   
	meters.h   
	p38.h         
	planes.h    
	sgilogo.h
	colors.h  
	f16_defs.h  
	flight.h      
	irisgl.h  
	maths.h  
	objects.h  
	p38_points.h
	uflight.h
	gamestruct.h
)

add_executable(flight ${SRCS} ${HEADERS})
target_link_libraries(flight m)

set (OpenGL_GL_PREFERENCE LEGACY)
find_package (OpenGL)
if (OpenGL_OpenGL_FOUND AND OPENGL_GLU_FOUND)
	
  	target_include_directories(flight PUBLIC ${OPENGL_INCLUDE_DIR})
  	target_link_libraries (flight ${OPENGL_LIBRARIES})
else ()
  	# Sinon, nous affichons un message
  	message(FATAL_ERROR "opengl and glu not found")
endif ()

# Recherche la dépendance externe
find_package (GLUT REQUIRED)
if (GLUT_FOUND)
	message(STATUS "add glut dependencies")
  	target_include_directories(flight PUBLIC ${GLUT_INCLUDE_DIRS})
  	target_link_libraries (flight ${GLUT_LIBRARIES})
else ()
  	message(FATAL_ERROR "glut not found")
endif ()

# macOS App Bundle and DMG targets
if(APPLE)
    set(APP_NAME "sgiflight")
    set(APP_BUNDLE_DIR "${CMAKE_BINARY_DIR}/${APP_NAME}.app")
    set(APP_CONTENTS_DIR "${APP_BUNDLE_DIR}/Contents")
    set(APP_MACOS_DIR "${APP_CONTENTS_DIR}/MacOS")
    set(APP_RESOURCES_DIR "${APP_CONTENTS_DIR}/Resources")

    # Custom target to create .app bundle
    add_custom_target(app
        COMMAND ${CMAKE_COMMAND} -E make_directory "${APP_CONTENTS_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${APP_MACOS_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${APP_RESOURCES_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:flight>" "${APP_MACOS_DIR}/"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Info.plist.in" "${APP_CONTENTS_DIR}/Info.plist"
        DEPENDS flight
        COMMENT "Creating macOS app bundle"
    )

    # Custom target to create DMG
    add_custom_target(dmg
        COMMAND ${CMAKE_COMMAND} -E remove -f "sgiflight.dmg"
        COMMAND hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE_DIR}" -ov -format UDZO "sgiflight.dmg"
        DEPENDS app
        COMMENT "Creating DMG file"
    )

    # Signed + notarized DMG (requires DEV_ID and NOTARY_PROFILE in .env or env)
    add_custom_target(release
        COMMAND ${CMAKE_SOURCE_DIR}/scripts/release.sh "${APP_NAME}" "${APP_BUNDLE_DIR}" "${CMAKE_BINARY_DIR}/sgiflight.dmg"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        DEPENDS app
        COMMENT "Signing and notarizing DMG"
    )
endif()

