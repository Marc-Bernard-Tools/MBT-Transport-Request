************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISPLAY
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
class /MBTOOLS/CL_CTS_REQ_DISPLAY definition
  public
  final
  create public .

public section.

  interfaces ZIF_APACK_MANIFEST .
  interfaces /MBTOOLS/IF_MANIFEST .

  constants C_VERSION type STRING value '1.0.0' ##NO_TEXT.
  constants C_NAME type STRING value 'MBT_Transport_Request_Display' ##NO_TEXT.

  methods CONSTRUCTOR .
  PROTECTED SECTION.
private section.

  aliases APACK_MANIFEST
    for ZIF_APACK_MANIFEST~DESCRIPTOR .
  aliases MBT_MANIFEST
    for /MBTOOLS/IF_MANIFEST~DESCRIPTOR .
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
