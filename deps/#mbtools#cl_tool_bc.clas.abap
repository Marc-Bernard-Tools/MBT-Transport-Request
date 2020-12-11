CLASS /mbtools/cl_tool_bc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.

    INTERFACES /mbtools/if_manifest .

    ALIASES mbt_manifest
      FOR /mbtools/if_manifest~descriptor .

    CONSTANTS:
      BEGIN OF c_tool,
        version     TYPE string VALUE '1.0.0' ##NO_TEXT,
        title       TYPE string VALUE 'MBT Base' ##NO_TEXT,
        description TYPE string VALUE 'Foundation for Marc Bernard Tools' ##NO_TEXT,
        bundle_id   TYPE i VALUE 0,
        download_id TYPE i VALUE 4873,
      END OF c_tool.

    METHODS constructor .
ENDCLASS.
CLASS /mbtools/cl_tool_bc IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.
ENDCLASS.