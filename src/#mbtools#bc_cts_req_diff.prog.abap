************************************************************************
* /MBTOOLS/BC_CTS_REQ_DIFF
* MBT Request Display
*
* This program is used to catch differences between standard coding and
* the MBT enhancement
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

REPORT /mbtools/bc_cts_req_diff LINE-SIZE 250.

CONSTANTS:
  c_max      TYPE i VALUE 200,
  c_lstrhtop TYPE progname VALUE 'LSTRHTOP',
  c_lstrhf01 TYPE progname VALUE 'LSTRHF01',
  c_mbtools  TYPE progname VALUE '/MBTOOLS/BC_CTS_OBJECT_LIST'.

DATA:
  g_line          TYPE i,
  g_enh_line      TYPE i,
  g_ignore_del    TYPE abap_bool,
  g_code          TYPE abaptxt255,
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
  <code>     TYPE abaptxt255,
  <code_enh> TYPE abaptxt255,
  <delta>    TYPE vxabapt255.

DEFINE macro_begin.
  CONCATENATE '*** BEGIN OF' &1 '***' INTO g_code SEPARATED BY space.
  APPEND g_code TO &2.
  APPEND '' TO &2.
END-OF-DEFINITION.

DEFINE macro_end.
  CONCATENATE '*** END OF' &1 '***' INTO g_code SEPARATED BY space.
  APPEND g_code TO &2.
  APPEND '' TO &2.
END-OF-DEFINITION.

START-OF-SELECTION.

  READ REPORT c_lstrhtop INTO gt_lstrhtop.
  ASSERT sy-subrc = 0.

  READ REPORT c_lstrhf01 INTO gt_lstrhf01.
  ASSERT sy-subrc = 0.

  READ REPORT c_mbtools INTO gt_mbtools.
  ASSERT sy-subrc = 0.

  " Standard Code
  FIND REGEX '^\* internal tables' IN TABLE gt_lstrhtop MATCH LINE g_line.
  IF sy-subrc = 0.
    macro_begin c_lstrhtop gt_std.
    LOOP AT gt_lstrhtop ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_std.
      IF <code> CP 'DATA gt_object_texts*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhtop gt_std.
  ENDIF.

  FIND REGEX '^FORM create_object_list' IN TABLE gt_lstrhf01 MATCH LINE g_line.
  IF sy-subrc = 0.
    macro_begin c_lstrhf01 gt_std.
    LOOP AT gt_lstrhf01 ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_std.
      IF <code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  FIND REGEX '^FORM create_key_list' IN TABLE gt_lstrhf01 MATCH LINE g_line.
  IF sy-subrc = 0.
    LOOP AT gt_lstrhf01 ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_std.
      IF <code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhf01 gt_std.
  ENDIF.

  " Enhanced Code
  FIND REGEX '^\* internal tables' IN TABLE gt_mbtools MATCH LINE g_line.
  IF sy-subrc = 0.
    macro_begin c_lstrhtop gt_enh.
    LOOP AT gt_mbtools ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_enh.
      IF <code> CP 'DATA gt_object_texts*'.
        EXIT.
      ENDIF.
    ENDLOOP.
    macro_end c_lstrhtop gt_enh.
  ENDIF.

  FIND REGEX '^FORM create_object_list' IN TABLE gt_mbtools MATCH LINE g_line.
  IF sy-subrc = 0.
    macro_begin c_lstrhf01 gt_enh.
    LOOP AT gt_mbtools ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_enh.
      IF <code> CP 'ENDFORM.*'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  FIND REGEX '^FORM create_key_list' IN TABLE gt_mbtools MATCH LINE g_line.
  IF sy-subrc = 0.
    LOOP AT gt_mbtools ASSIGNING <code> FROM g_line.
      APPEND <code> TO gt_enh.
      IF <code> CP 'ENDFORM.*'.
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

  g_ignore_del = abap_true.

  LOOP AT gt_std ASSIGNING <code>.
    g_enh_line = g_enh_line + 1.
    g_line = sy-tabix.
    READ TABLE gt_delta ASSIGNING <delta> WITH KEY number = g_line.
    IF sy-subrc = 0.
      IF <delta>-vrsflag = 'U'.
        WRITE: / g_line, '-', <code>(c_max) COLOR COL_NEGATIVE INTENSIFIED OFF.
        READ TABLE gt_enh ASSIGNING <code_enh> INDEX g_enh_line.
        IF sy-subrc = 0.
          WRITE: / g_line, '+', <code_enh>(c_max) COLOR COL_POSITIVE INTENSIFIED OFF.
        ELSE.
          BREAK-POINT.
        ENDIF.
      ELSEIF <delta>-vrsflag = 'I'.
        LOOP AT gt_delta ASSIGNING <delta> WHERE number = g_line.
          WRITE: / g_line, '+', <delta>-line(c_max) COLOR COL_POSITIVE INTENSIFIED OFF.
          g_enh_line = g_enh_line + 1.
        ENDLOOP.
      ELSEIF <delta>-vrsflag = 'D'.
        IF g_ignore_del = abap_false.
          WRITE: / g_line, '-', <code>(c_max) COLOR COL_TOTAL INTENSIFIED OFF.
        ENDIF.
        g_enh_line = g_enh_line - 1.
      ELSE.
        BREAK-POINT.
      ENDIF.
    ELSE.
      WRITE: / g_line, ' ', <code>(c_max) COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.
    IF <code> CS '*** BEGIN OF LSTRHF01 ***'.
      g_ignore_del = abap_false.
    ENDIF.
  ENDLOOP.
