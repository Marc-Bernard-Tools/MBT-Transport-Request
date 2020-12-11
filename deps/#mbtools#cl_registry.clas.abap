CLASS /mbtools/cl_registry DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_keyval,
        key   TYPE string,
        value TYPE string,
      END OF ty_keyval .
    TYPES:
      ty_keyvals TYPE SORTED TABLE OF ty_keyval WITH UNIQUE KEY key .
    TYPES:
      BEGIN OF ty_keyobj,
        key   TYPE string,
        value TYPE REF TO /mbtools/cl_registry,
      END OF ty_keyobj .
    TYPES:
      ty_keyobjs TYPE SORTED TABLE OF ty_keyobj WITH UNIQUE KEY key .

    CONSTANTS c_version TYPE string VALUE '1.2.0' ##NO_TEXT.
    CONSTANTS c_name TYPE string VALUE 'MBT_Registry' ##NO_TEXT.
    CONSTANTS c_registry_root TYPE indx_srtfd VALUE 'MARC_BERNARD_TOOLS' ##NO_TEXT.
    DATA mt_sub_entries TYPE ty_keyvals READ-ONLY .
    DATA mt_values TYPE ty_keyvals READ-ONLY .
    DATA mv_internal_key TYPE indx_srtfd READ-ONLY .
    DATA mv_parent_key TYPE indx_srtfd READ-ONLY .
    DATA mv_entry_id TYPE string READ-ONLY .                     "User-friendly ID of the subnode
    DATA ms_regs TYPE /mbtools/if_definitions=>ty_regs READ-ONLY .

    METHODS constructor
      IMPORTING
        !ig_internal_key TYPE any
      RAISING
        /mbtools/cx_exception .
    METHODS reload
      RAISING
        /mbtools/cx_exception .
    METHODS save
      RAISING
        /mbtools/cx_exception .
    METHODS get_parent
      RETURNING
        VALUE(ro_parent) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    METHODS create_by_path
      IMPORTING
        !iv_path        TYPE string
      RETURNING
        VALUE(ro_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    METHODS get_subentry
      IMPORTING
        !iv_key         TYPE clike
      RETURNING
        VALUE(ro_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    METHODS add_subentry
      IMPORTING
        !iv_key         TYPE clike
      RETURNING
        VALUE(ro_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    METHODS remove_subentry
      IMPORTING
        !iv_key TYPE clike
      RAISING
        /mbtools/cx_exception .
    METHODS remove_subentries
      RAISING
        /mbtools/cx_exception .
    METHODS copy_subentry
      IMPORTING
        !iv_source_key         TYPE clike
        !iv_target_key         TYPE clike
      RETURNING
        VALUE(ro_target_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    METHODS get_subentry_keys
      RETURNING
        VALUE(rt_keys) TYPE string_table .
    METHODS get_subentries
      RETURNING
        VALUE(rt_sub_entries) TYPE ty_keyobjs
      RAISING
        /mbtools/cx_exception .
    METHODS get_value_keys
      RETURNING
        VALUE(rt_keys) TYPE string_table .
    METHODS get_values
      RETURNING
        VALUE(rt_values) TYPE ty_keyvals .
    METHODS set_values
      IMPORTING
        !it_values TYPE ty_keyvals
      RAISING
        /mbtools/cx_exception .
    METHODS get_value
      IMPORTING
        !iv_key         TYPE clike
      RETURNING
        VALUE(rv_value) TYPE string .
    METHODS set_value
      IMPORTING
        !iv_key   TYPE clike
        !iv_value TYPE any OPTIONAL
      RAISING
        /mbtools/cx_exception .
    METHODS delete_value
      IMPORTING
        !iv_key TYPE clike
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS get_entry_by_internal_key
      IMPORTING
        !iv_key         TYPE any
      RETURNING
        VALUE(ro_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS get_root
      RETURNING
        VALUE(ro_root) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS truncate .
    METHODS export
      IMPORTING
        !iv_internal_keys TYPE abap_bool DEFAULT abap_false
        !iv_table         TYPE abap_bool DEFAULT abap_false
      CHANGING
        !ct_file          TYPE string_table
      RAISING
        /mbtools/cx_exception .
    METHODS get_subentry_by_path
      IMPORTING
        !iv_path        TYPE string
      RETURNING
        VALUE(ro_entry) TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception .
  PROTECTED SECTION.

    CLASS-DATA gt_registry_entries TYPE ty_keyobjs .
    DATA mv_deleted TYPE abap_bool .

    METHODS set_optimistic_lock
      RAISING
        /mbtools/cx_exception.
    METHODS promote_lock
      RAISING
        /mbtools/cx_exception.
    METHODS release_lock .
    METHODS copy_subentry_deep
      IMPORTING
        !io_source TYPE REF TO /mbtools/cl_registry
        !io_target TYPE REF TO /mbtools/cl_registry
      RAISING
        /mbtools/cx_exception.

    METHODS delete
      RAISING
        /mbtools/cx_exception.

ENDCLASS.
CLASS /mbtools/cl_registry IMPLEMENTATION.
  METHOD add_subentry.
  ENDMETHOD.
  METHOD constructor.
  ENDMETHOD.
  METHOD copy_subentry.
  ENDMETHOD.
  METHOD copy_subentry_deep.
  ENDMETHOD.
  METHOD create_by_path.
  ENDMETHOD.
  METHOD delete.
  ENDMETHOD.
  METHOD delete_value.
  ENDMETHOD.
  METHOD export.
  ENDMETHOD.
  METHOD get_entry_by_internal_key.
  ENDMETHOD.
  METHOD get_parent.
  ENDMETHOD.
  METHOD get_root.
  ENDMETHOD.
  METHOD get_subentries.
  ENDMETHOD.
  METHOD get_subentry.
  ENDMETHOD.
  METHOD get_subentry_by_path.
  ENDMETHOD.
  METHOD get_subentry_keys.
  ENDMETHOD.
  METHOD get_value.
  ENDMETHOD.
  METHOD get_values.
  ENDMETHOD.
  METHOD get_value_keys.
  ENDMETHOD.
  METHOD promote_lock.
  ENDMETHOD.
  METHOD release_lock.
  ENDMETHOD.
  METHOD reload.
  ENDMETHOD.
  METHOD remove_subentries.
  ENDMETHOD.
  METHOD remove_subentry.
  ENDMETHOD.
  METHOD save.
  ENDMETHOD.
  METHOD set_optimistic_lock.
  ENDMETHOD.
  METHOD set_value.
  ENDMETHOD.
  METHOD set_values.
  ENDMETHOD.
  METHOD truncate.
  ENDMETHOD.
ENDCLASS.