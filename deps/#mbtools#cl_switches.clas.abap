CLASS /mbtools/cl_switches DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS class_constructor.
    CLASS-METHODS is_active
      IMPORTING
        !iv_title        TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool.
    CLASS-METHODS is_debug
      IMPORTING
        !iv_title        TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool.
    CLASS-METHODS is_trace
      IMPORTING
        !iv_title        TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool.
ENDCLASS.
CLASS /mbtools/cl_switches IMPLEMENTATION.
  METHOD is_active.
  ENDMETHOD.
  METHOD class_constructor.
  ENDMETHOD.
  METHOD is_debug.
  ENDMETHOD.
  METHOD is_trace.
  ENDMETHOD.
ENDCLASS.