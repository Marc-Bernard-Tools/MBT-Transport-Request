************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISPLAY
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_display DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apack_manifest .
    INTERFACES /mbtools/if_manifest .

    CONSTANTS:
      c_version     TYPE string VALUE '1.0.0' ##NO_TEXT,
      c_title       TYPE string VALUE 'MBT Transport Request' ##NO_TEXT,
      c_description TYPE string VALUE 'The Ultimate Enhancement for Displaying Transport Requests in SAP GUI' ##NO_TEXT,
      c_bundle_id   TYPE i VALUE 1,
      c_download_id TYPE i VALUE 4411.

    METHODS constructor .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: mo_tool TYPE REF TO /mbtools/cl_tools.

    ALIASES apack_manifest
      FOR if_apack_manifest~descriptor .
    ALIASES mbt_manifest
      FOR /mbtools/if_manifest~descriptor .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISPLAY IMPLEMENTATION.


  METHOD constructor.
    CREATE OBJECT mo_tool EXPORTING io_tool = me.

    apack_manifest = mo_tool->apack_manifest.
    mbt_manifest   = mo_tool->mbt_manifest.
  ENDMETHOD.
ENDCLASS.
