
#
# add_stk_module(module)
#
# Add a new python STK module
#
function(add_stk_module modname)
  add_cython_target(${modname} CXX)
  add_library(${modname} MODULE ${modname})

  target_compile_features(${modname} PRIVATE cxx_std_11)
  target_compile_options(${modname} PRIVATE
    $<$<CXX_COMPILER_ID:AppleClang,Clang>:-Wno-deprecated-declarations>
    )
  set_target_properties(${modname} PROPERTIES CXX_EXTENSIONS OFF)

  target_include_directories(${modname} SYSTEM
    PRIVATE
    ${STK_INCLUDE_DIRS}
    ${STK_TPL_INCLUDE_DIRS}
    ${NumPy_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${MPI_CXX_INCLUDE_PATH}
    )
  target_link_libraries(${modname}
    ${STK_LIBRARIES}
    ${STK_TPL_LIBRARIES}
    ${MPI_CXX_LIBRARIES})
  python_extension_module(${modname})

  install(TARGETS ${modname} LIBRARY DESTINATION ${STK_MODULE_LOCATION})
endfunction()
