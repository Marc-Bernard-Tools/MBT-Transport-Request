CLASS /mbtools/cl_tool_bc_cts_req DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

************************************************************************
* MBT Transport Request
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

  PUBLIC SECTION.

    INTERFACES /mbtools/if_manifest .

    ALIASES mbt_manifest
      FOR /mbtools/if_manifest~descriptor .

    CONSTANTS:
      BEGIN OF c_tool,
        version     TYPE string VALUE '1.0.0' ##NO_TEXT,
        title       TYPE string VALUE 'MBT Transport Request' ##NO_TEXT,
        bundle_id   TYPE i VALUE 1,
        download_id TYPE i VALUE 4411,
        description TYPE string
        VALUE 'The ultimate enhancement for displaying transport requests in SAP GUI' ##NO_TEXT,
        has_launch  TYPE abap_bool VALUE abap_true,
      END OF c_tool.

    METHODS constructor .

    METHODS launch.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA mo_tool TYPE REF TO /mbtools/cl_tools .

ENDCLASS.



CLASS /MBTOOLS/CL_TOOL_BC_CTS_REQ IMPLEMENTATION.


  METHOD constructor.
    CREATE OBJECT mo_tool EXPORTING io_tool = me.
    mbt_manifest = mo_tool->mbt_manifest.
  ENDMETHOD.


  METHOD launch.
    /mbtools/cl_sap=>run_transaction( 'SE09' ).
  ENDMETHOD.
ENDCLASS.
