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
  constants C_TITLE type STRING value 'MBT Transport Request' ##NO_TEXT.
  constants C_DESCRIPTION type STRING value 'The Ultimate Enhancement for Displaying Transport Requests in SAP GUI' ##NO_TEXT.
  constants C_DOWNLOAD_ID type I value 4411 ##NO_TEXT.

  methods CONSTRUCTOR .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: mo_tool TYPE REF TO /mbtools/cl_tools.

    ALIASES apack_manifest
      FOR zif_apack_manifest~descriptor .
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
