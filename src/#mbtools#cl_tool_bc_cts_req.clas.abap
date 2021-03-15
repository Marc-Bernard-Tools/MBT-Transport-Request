CLASS /mbtools/cl_tool_bc_cts_req DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* MBT Transport Request
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

  PUBLIC SECTION.

    INTERFACES /mbtools/if_tool.

    CONSTANTS:
      BEGIN OF c_tool,
        version      TYPE string VALUE '1.0.2' ##NO_TEXT,
        title        TYPE string VALUE 'MBT Transport Request' ##NO_TEXT,
        bundle_id    TYPE i VALUE 1,
        download_id  TYPE i VALUE 4411,
        description  TYPE string
        VALUE 'The Ultimate Enhancement for Displaying Transport Requests in SAP GUI' ##NO_TEXT,
        has_launch   TYPE abap_bool VALUE abap_true,
        mbt_command  TYPE string VALUE 'TRANSPORT',
        mbt_shortcut TYPE string VALUE 'TR',
      END OF c_tool.

    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_tool TYPE REF TO /mbtools/cl_tools.

ENDCLASS.



CLASS /mbtools/cl_tool_bc_cts_req IMPLEMENTATION.


  METHOD /mbtools/if_tool~launch.
    /mbtools/cl_sap=>run_transaction( 'SE09' ).
  ENDMETHOD.


  METHOD constructor.
    CREATE OBJECT mo_tool EXPORTING io_tool = me.
    /mbtools/if_tool~ms_manifest = mo_tool->ms_manifest.
  ENDMETHOD.
ENDCLASS.
