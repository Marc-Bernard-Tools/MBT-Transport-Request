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

    CONSTANTS c_version TYPE string VALUE '1.0.0' ##NO_TEXT.
    CONSTANTS c_title TYPE string VALUE 'MBT Transport Request' ##NO_TEXT.
    CONSTANTS c_description TYPE string VALUE 'The Ultimate Enhancement for Displaying Transport Requests in SAP GUI' ##NO_TEXT.
    CONSTANTS c_download_id TYPE i VALUE 4411.

    METHODS constructor .

  PROTECTED SECTION.

  PRIVATE SECTION.

    ALIASES apack_manifest
      FOR if_apack_manifest~descriptor .
    ALIASES mbt_manifest
      FOR /mbtools/if_manifest~descriptor .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISPLAY IMPLEMENTATION.


  METHOD constructor.
    apack_manifest = /mbtools/cl_tools=>build_apack_manifest( me ).
    mbt_manifest = /mbtools/cl_tools=>build_mbt_manifest( me ).
  ENDMETHOD.
ENDCLASS.
