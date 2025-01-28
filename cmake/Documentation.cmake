macro(add_module_doc_target targetname target_source_dir category)

    set(VISTLE_DOCUMENTATION_WORKFLOW ${PROJECT_SOURCE_DIR}/tools/generateModuleInfo.vsl)
    set(DOC_COMMAND ${CMAKE_COMMAND} -E env VISTLE_DOCUMENTATION_TARGET=${targetname} VISTLE_DOCUMENTATION_DIR=${CMAKE_CURRENT_SOURCE_DIR}
                    VISTLE_DOCUMENTATION_BIN_DIR=${CMAKE_CURRENT_BINARY_DIR} VISTLE_DOCUMENTATION_CATEGORY=${category} vistle --batch ${VISTLE_DOCUMENTATION_WORKFLOW})

    set(OUTPUT_FILE ${PROJECT_SOURCE_DIR}/docs/source/modules/${category}/${targetname}.md)
    set(INPUT_FILE ${target_source_dir}/${targetname}.md)
    if(NOT EXISTS ${INPUT_FILE})
        set(INPUT_FILE)
    endif()

    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${DOC_COMMAND}
        DEPENDS #build if changes in:
                ${INPUT_FILE} #the custom documentation
                Vistle::${targetname} #the module's binary
                ${VISTLE_DOCUMENTATION_WORKFLOW} #the file that gets loaded by vistle to generate the documentation
                ${PROJECT_SOURCE_DIR}/tools/GenModInfo/genModInfo.py #dependency of VISTLE_DOCUMENTATION_WORKFLOW
                ${DOCUMENTATION_DEPENDENCIES} #custom dependencies set by the calling module
        COMMENT "Generating documentation for " ${targetname})

    add_custom_target(${targetname}_doc DEPENDS ${OUTPUT_FILE})
    add_dependencies(vistle_doc ${targetname}_doc)

    file(
        GLOB WORKFLOWS
        LIST_DIRECTORIES FALSE
        ${target_source_dir}/*.vsl)

    foreach(file ${WORKFLOWS})
        get_filename_component(workflow ${file} NAME_WLE)
        # generate_network_snapshot(${targetname} ${workflow})
        generate_snapshots(${targetname} ${workflow})
    endforeach()
endmacro()

macro(generate_network_snapshot targetname network_file)
    add_custom_command(
        #create a snapshot of the pipeline
        OUTPUT ${CMAKE_CURRENT_LIST_DIR}/${network_file}_workflow.png
        COMMAND vistle --snapshot ${CMAKE_CURRENT_LIST_DIR}/${network_file}_workflow.png ${CMAKE_CURRENT_LIST_DIR}/${network_file}.vsl
        DEPENDS ${CMAKE_CURRENT_LIST_DIR}/${VISTLE_DOCUMENTATION_WORKFLOW}.vsl targetname
        COMMENT "Generating network snapshot for " ${network_file}.vsl)

    # add_custom_target(${targetname}_${network_file}_workflow DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${network_file}_workflow.png)
    add_custom_target(${targetname}_${network_file}_workflow DEPENDS ${CMAKE_CURRENT_LIST_DIR}/${network_file}_workflow.png)
    add_dependencies(${targetname}_doc ${targetname}_${network_file}_workflow)
endmacro()

macro(generate_snapshots targetname network_file)
    if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/${network_file}.vwp
    )#if we have a viewpoint file we can generate an result image, only first viewpoint is considered, only first cover is considered
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_LIST_DIR}/${network_file}_result.png ${CMAKE_CURRENT_LIST_DIR}/${network_file}_workflow.png
            COMMAND
                ${CMAKE_COMMAND} -E env COCONFIG=${PROJECT_SOURCE_DIR}/doc/config.vistle.doc.xml VISTLE_DOC_IMAGE_NAME=${network_file}
                VISTLE_DOC_SOURCE_DIR=${CMAKE_CURRENT_LIST_DIR} VISTLE_DOC_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} vistle
                ${PROJECT_SOURCE_DIR}/doc/resultSnapShot.py
            DEPENDS ${CMAKE_CURRENT_LIST_DIR}/${network_file}.vsl ${CMAKE_CURRENT_LIST_DIR}/${network_file}.vwp ${targetname}
                    ${PROJECT_SOURCE_DIR}/doc/resultSnapShot.py
            COMMENT "Generating network and result snapshot for " ${network_file}.vsl)
        add_custom_target(${targetname}_${network_file}_result DEPENDS ${CMAKE_CURRENT_LIST_DIR}/${network_file}_result.png
                                                                       ${CMAKE_CURRENT_LIST_DIR}/${network_file}_workflow.png)
        add_dependencies(${targetname}_doc ${targetname}_${network_file}_result)
    else()
        message(
            WARNING "can not generate snapshots for "
                    ${targetname}
                    " "
                    ${network_file}
                    ": missing viewpoint file, make sure a viewpoint file named \""
                    ${network_file}
                    ".vwp\" exists!")
    endif()
endmacro()
