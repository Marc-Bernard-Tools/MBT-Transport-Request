************************************************************************
* /MBTOOLS/BC_CTS_REQ_DIFF
* MBT Transport Request
*
* This program is used to catch differences between standard coding and
* the MBT enhancement
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
REPORT /mbtools/cts_req_diff LINE-SIZE 250.

CONSTANTS:
  c_title    TYPE string VALUE /mbtools/cl_tool_bc_cts_req=>c_tool-title,
  c_max      TYPE i VALUE 200,
  c_lstrhtop TYPE progname VALUE 'LSTRHTOP',
  c_lstrhf01 TYPE progname VALUE 'LSTRHF01',
  c_mbtools  TYPE progname VALUE '/MBTOOLS/CTS_OBJECT_LIST'.

DATA:
  gv_line         TYPE i,
  gv_enh_line     TYPE i,
  gv_ignore_del   TYPE abap_bool,
  gv_code         TYPE abaptxt255,
  gt_lstrhtop     TYPE abaptxt255_tab,
  gt_lstrhf01     TYPE abaptxt255_tab,
  gt_mbtools      TYPE abaptxt255_tab,
  gt_std          TYPE abaptxt255_tab,
  gt_enh          TYPE abaptxt255_tab,
  gt_trdirtab_old TYPE TABLE OF trdir,
  gt_trdirtab_new TYPE TABLE OF trdir,
  gt_trdir_delta  TYPE TABLE OF xtrdir,
  gt_delta        TYPE vxabapt255_tab.

FIELD-SYMBOLS:
  <gs_code>     TYPE abaptxt255,
  <gs_code_enh> TYPE abaptxt255,
  <gs_delta>    TYPE vxabapt255.

DEFINE macro_begin.
  CONCATENATE '*** BEGIN OF' &1 '***' INTO gv_code SEPARATED BY space.
  APPEND gv_code TO &2.
  APPEND '' TO &2.
END-OF-DEFINITION.

DEFINE macro_end.
  CONCATENATE '*** END OF' &1 '***' INTO gv_code SEPARATED BY space.
  APPEND gv_code TO &2.
  APPEND '' TO &2.
END-OF-DEFINITION.

INITIALIZATION.

  IF /mbtools/cl_switches=>is_active( c_title ) = abap_false.
    MESSAGE e004(/mbtools/bc) WITH c_title.
    RETURN.
  ENDIF.

START-OF-SELECTION.

  READ REPORT c_lstrhtop INTO gt_lstrhtop.
  ASSERT sy-subrc = 0.

  READ REPORT c_lstrhf01 INTO gt_lstrhf01.
  ASSERT sy-subrc = 0.

  READ REPORT c_mbtools INTO gt_mbtools.
  ASSERT sy-subrc = 0.

  " Standard Code
  FIND REGEX '^\* internal tables' IN TABLE gt_lstrhtop
   MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    macro_begin c_lstrhtop gt_std.
    LOOP AT gt_lstrhtop ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_std.
      IF <gs_code> CP 'DATA gt_object_texts*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhtop gt_std.
  ENDIF.

  FIND REGEX '^FORM create_object_list' IN TABLE gt_lstrhf01
    MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    macro_begin c_lstrhf01 gt_std.
    LOOP AT gt_lstrhf01 ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_std.
      IF <gs_code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  FIND REGEX '^FORM create_key_list' IN TABLE gt_lstrhf01
    MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    LOOP AT gt_lstrhf01 ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_std.
      IF <gs_code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhf01 gt_std.
  ENDIF.

  " Enhanced Code
  FIND REGEX '^\* internal tables' IN TABLE gt_mbtools
    MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    macro_begin c_lstrhtop gt_enh.
    LOOP AT gt_mbtools ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_enh.
      IF <gs_code> CP 'DATA gt_object_texts*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhtop gt_enh.
  ENDIF.

  FIND REGEX '^FORM create_object_list' IN TABLE gt_mbtools
    MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    macro_begin c_lstrhf01 gt_enh.
    LOOP AT gt_mbtools ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_enh.
      IF <gs_code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  FIND REGEX '^FORM create_key_list' IN TABLE gt_mbtools
    MATCH LINE gv_line ##NO_TEXT.
  IF sy-subrc = 0.
    LOOP AT gt_mbtools ASSIGNING <gs_code> FROM gv_line.
      APPEND <gs_code> TO gt_enh.
      IF <gs_code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhf01 gt_enh.
  ENDIF.

  CALL FUNCTION 'SVRS_COMPUTE_DELTA_REPS'
    EXPORTING
      compare_mode            = 2
      ignore_case_differences = abap_true
    TABLES
      texttab_old             = gt_std
      texttab_new             = gt_enh
      trdirtab_old            = gt_trdirtab_old
      trdirtab_new            = gt_trdirtab_new
      trdir_delta             = gt_trdir_delta
      text_delta              = gt_delta.

  gv_ignore_del = abap_true.

  LOOP AT gt_std ASSIGNING <gs_code>.
    gv_enh_line = gv_enh_line + 1.
    gv_line = sy-tabix.
    READ TABLE gt_delta ASSIGNING <gs_delta> WITH KEY number = gv_line.
    IF sy-subrc = 0.
      IF <gs_delta>-vrsflag = 'U'.
        WRITE: / gv_line, '-', <gs_code>(c_max) COLOR COL_NEGATIVE INTENSIFIED OFF.
        READ TABLE gt_enh ASSIGNING <gs_code_enh> INDEX gv_enh_line.
        IF sy-subrc = 0.
          WRITE: / gv_line, '+', <gs_code_enh>(c_max) COLOR COL_POSITIVE INTENSIFIED OFF.
        ELSE.
          BREAK-POINT ID /mbtools/bc.
        ENDIF.
      ELSEIF <gs_delta>-vrsflag = 'I'.
        LOOP AT gt_delta ASSIGNING <gs_delta> WHERE number = gv_line.
          WRITE: / gv_line, '+', <gs_delta>-line(c_max) COLOR COL_POSITIVE INTENSIFIED OFF.
          gv_enh_line = gv_enh_line + 1.
        ENDLOOP.
      ELSEIF <gs_delta>-vrsflag = 'D'.
        IF gv_ignore_del = abap_false.
          WRITE: / gv_line, '-', <gs_code>(c_max) COLOR COL_TOTAL INTENSIFIED OFF.
        ENDIF.
        gv_enh_line = gv_enh_line - 1.
      ELSE.
        BREAK-POINT ID /mbtools/bc.
      ENDIF.
    ELSE.
      WRITE: / gv_line, ' ', <gs_code>(c_max) COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.
    IF <gs_code> CS '*** BEGIN OF LSTRHF01 ***'.
      gv_ignore_del = abap_false.
    ENDIF.
  ENDLOOP.
