CLASS /mbtools/cl_screen DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS cndp .

    TYPES:
      ty_screen_field TYPE c LENGTH 83 .

    CLASS-DATA gv_copyright TYPE string READ-ONLY .
    CLASS-DATA gv_about TYPE string READ-ONLY .
    CLASS-DATA gv_documentation TYPE string READ-ONLY .
    CLASS-DATA gv_tool_page TYPE string READ-ONLY .
    CLASS-DATA gv_website_name TYPE string READ-ONLY .
    CLASS-DATA gv_website_domain TYPE string READ-ONLY .
    CLASS-DATA gv_terms TYPE string READ-ONLY .
    CLASS-DATA gv_version TYPE string READ-ONLY .

    CLASS-METHODS class_constructor .
    METHODS constructor
      IMPORTING
        !iv_title TYPE csequence .
    CLASS-METHODS factory
      IMPORTING
        !iv_title        TYPE csequence OPTIONAL
      RETURNING
        VALUE(ro_screen) TYPE REF TO /mbtools/cl_screen .
    METHODS init
      EXPORTING
        !ev_text      TYPE ty_screen_field
        !ev_about     TYPE ty_screen_field
        !ev_title     TYPE ty_screen_field
        !ev_version   TYPE ty_screen_field
        !ev_copyright TYPE ty_screen_field
        !ev_docu      TYPE ty_screen_field
        !ev_tool      TYPE ty_screen_field
        !ev_home      TYPE ty_screen_field .
    METHODS header
      IMPORTING
        VALUE(iv_icon)   TYPE icon_d
        VALUE(iv_text)   TYPE csequence OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE ty_screen_field .
    METHODS icon
      IMPORTING
        VALUE(iv_icon)   TYPE icon_d
        VALUE(iv_text)   TYPE csequence OPTIONAL
        VALUE(iv_quick)  TYPE csequence OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE ty_screen_field .
    METHODS logo
      IMPORTING
        VALUE(iv_show) TYPE abap_bool DEFAULT abap_true
        VALUE(iv_top)  TYPE i OPTIONAL
        VALUE(iv_left) TYPE i OPTIONAL .
    METHODS banner
      IMPORTING
        VALUE(iv_show) TYPE abap_bool DEFAULT abap_true
        VALUE(iv_top)  TYPE i DEFAULT 4
        VALUE(iv_left) TYPE i DEFAULT 20
          PREFERRED PARAMETER iv_show .
    METHODS ucomm
      IMPORTING
        VALUE(iv_ok_code) TYPE sy-ucomm .
    METHODS toolbar
      IMPORTING
        !iv_dynnr TYPE sy-dynnr
        !iv_cprog TYPE sy-cprog DEFAULT sy-cprog
        !iv_show  TYPE abap_bool DEFAULT abap_false .
  PROTECTED SECTION.
ENDCLASS.
CLASS /mbtools/cl_screen IMPLEMENTATION.
  METHOD header.
  ENDMETHOD.
  METHOD icon.
  ENDMETHOD.
  METHOD class_constructor.
  ENDMETHOD.
  METHOD logo.
  ENDMETHOD.
  METHOD banner.
  ENDMETHOD.
  METHOD init.
  ENDMETHOD.
  METHOD ucomm.
  ENDMETHOD.
  METHOD toolbar.
  ENDMETHOD.
  METHOD constructor.
  ENDMETHOD.
  METHOD factory.
  ENDMETHOD.
ENDCLASS.