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

    INTERFACES zif_apack_manifest .
    INTERFACES /mbtools/if_manifest .

    CONSTANTS c_version TYPE string VALUE '1.0.0' ##NO_TEXT.
    CONSTANTS c_name TYPE string VALUE 'MBT_Transport_Request_Display' ##NO_TEXT.

    METHODS constructor .
  PROTECTED SECTION.
  PRIVATE SECTION.

    ALIASES apack_manifest
      FOR zif_apack_manifest~descriptor .
    ALIASES mbt_manifest
      FOR /mbtools/if_manifest~descriptor .
ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISPLAY IMPLEMENTATION.


  METHOD constructor.
*   APACK
    apack_manifest = VALUE #(
      group_id    = 'github.com/mbtools'
      artifact_id = 'mbt-bc-cts-req'
      version     = c_version
      git_url     = 'https://github.com/mbtools/mbt-bc-cts-req.git'
    ).
*   MBT
    mbt_manifest = VALUE #(
      id          = 2
      name        = c_name
      version     = c_version
      description = 'Enhancement for Display for Transport Requests'
      mbt_url     = 'https://marcbernardtools.com/tool/mbt-transport-request-display/'
      namespace   = '/MBTOOLS/'
      package     = '/MBTOOLS/BC_CTS_REQ'
    ).
  ENDMETHOD.
ENDCLASS.
