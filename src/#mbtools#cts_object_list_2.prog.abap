REPORT /mbtools/cts_object_list_2.
************************************************************************
* MBT Transport Request
*
* Callback routines for enhancement of function group STRV
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

TYPE-POOLS: icon.

*&---------------------------------------------------------------------*
*&      Global Types and Data (LSTRVTOP)
*&---------------------------------------------------------------------*

* internal tables
TYPES: tt_snodetext LIKE snodetext OCCURS 50.

START-OF-SELECTION.

  MESSAGE s003(/mbtools/bc).

*&---------------------------------------------------------------------*
*&      Form  CREATE_TREE (LSTRVF01)
*&---------------------------------------------------------------------*
FORM create_tree USING pt_nodes TYPE tt_snodetext.

  DATA:
    ls_e071      TYPE trwbo_s_e071,
    lt_e071      TYPE trwbo_t_e071,
    lr_badi      TYPE REF TO /mbtools/bc_cts_req_display,
    lt_txt       TYPE /mbtools/trwbo_t_e071_txt,
    lv_found     TYPE abap_bool,
    lv_objt_name TYPE trobj_name,
    lv_disp_name TYPE trobj_name.

  FIELD-SYMBOLS:
    <ls_node> TYPE LINE OF tt_snodetext.

  LOG-POINT ID /mbtools/bc
    SUBKEY /mbtools/cl_tool_bc_cts_req=>c_tool-title
    FIELDS sy-datum sy-uzeit sy-uname.

  LOOP AT pt_nodes ASSIGNING <ls_node> WHERE type = 'OBJE'.

    PERFORM get_object_from_node
      USING    sy-tabix <ls_node>
      CHANGING ls_e071.

    INSERT ls_e071 INTO TABLE lt_e071.

  ENDLOOP.

  SORT lt_e071.
  DELETE ADJACENT DUPLICATES FROM lt_e071.

  " Get object descriptions and icons via BAdI
  GET BADI lr_badi.

  IF lr_badi IS BOUND.
    CALL BADI lr_badi->get_object_descriptions
      EXPORTING
        it_e071     = lt_e071
      CHANGING
        ct_e071_txt = lt_txt.

    SORT lt_txt.
  ENDIF.

  LOOP AT pt_nodes ASSIGNING <ls_node> WHERE type = 'OBJE'.

    PERFORM get_object_from_node
      USING    sy-tabix <ls_node>
      CHANGING ls_e071.

    PERFORM get_object_and_display_name IN PROGRAM /mbtools/cts_object_list
      USING lt_txt ls_e071-trkorr ls_e071-as4pos
            ls_e071-pgmid ls_e071-object
            ls_e071-objfunc ls_e071-obj_name
            'Object deleted'(del)
      CHANGING lv_found lv_objt_name lv_disp_name.

    IF lv_found = abap_true.
      <ls_node>-text1    = |[{ <ls_node>-text } { <ls_node>-text1 } { <ls_node>-text2 }]|.
      <ls_node>-tlength1 = 55.                           "#EC NUMBER_OK
      <ls_node>-text     = lv_objt_name.
      <ls_node>-tlength  = 75.                           "#EC NUMBER_OK
      <ls_node>-text2    = ''.
      <ls_node>-tlength2 = 0.                            "#EC NUMBER_OK
    ENDIF.

  ENDLOOP.

ENDFORM.                               " CREATE_OBJECT_LIST

FORM get_object_from_node
  USING
    iv_tabix TYPE sy-tabix
    is_node  TYPE snodetext
  CHANGING
    cs_e071  TYPE e071.

  CLEAR cs_e071.
  cs_e071-trkorr   = sy-sysid && 'K900001'.
  cs_e071-as4pos   = iv_tabix.
  cs_e071-pgmid    = is_node-text.
  cs_e071-object   = is_node-text1.
  cs_e071-obj_name = is_node-text2.

ENDFORM.
