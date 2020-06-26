************************************************************************
* /MBTOOLS/CL_TLOGO
* MBT TLOGO
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_tlogo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS class_constructor .
    CLASS-METHODS get_tlogo_from_tlogo_d
      IMPORTING
        !iv_tlogo_d     TYPE rstlogo
      RETURNING
        VALUE(rv_tlogo) TYPE rstlogo .
    CLASS-METHODS get_tlogo_icon
      IMPORTING
        !iv_tlogo      TYPE rstlogo
        !iv_tlogo_sub  TYPE csequence OPTIONAL
        !iv_icon       TYPE icon_d OPTIONAL
      RETURNING
        VALUE(rv_icon) TYPE icon_d .
    CLASS-METHODS get_tlogo_text
      IMPORTING
        !iv_tlogo      TYPE rstlogo
      RETURNING
        VALUE(rv_text) TYPE rstxtlg
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS get_object_text
      IMPORTING
        !iv_tlogo      TYPE rstlogo
        !iv_object     TYPE csequence
      RETURNING
        VALUE(rv_text) TYPE rstxtlg
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS get_tlogo_sub
      IMPORTING
        !iv_tlogo           TYPE rstlogo
        !iv_object          TYPE csequence
      RETURNING
        VALUE(rv_tlogo_sub) TYPE /mbtools/tlogo_sub
      RAISING
        /mbtools/cx_exception .
ENDCLASS.
CLASS /mbtools/cl_tlogo IMPLEMENTATION.
  METHOD get_object_text.
  ENDMETHOD.
  METHOD get_tlogo_icon.
  ENDMETHOD.
  METHOD get_tlogo_text.
  ENDMETHOD.
  METHOD class_constructor.
  ENDMETHOD.
  METHOD get_tlogo_from_tlogo_d.
  ENDMETHOD.
  METHOD get_tlogo_sub.
  ENDMETHOD.
ENDCLASS.