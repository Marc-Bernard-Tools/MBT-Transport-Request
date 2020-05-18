************************************************************************
* /MBTOOLS/BC_CTS_REQ_TEST
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

REPORT /mbtools/bc_cts_req_test LINE-SIZE 255.

TABLES:
  seometarel, objh.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS:
  so_class FOR seometarel-clsname DEFAULT '/MBTOOLS/CL_CTS_REQ_DISP_WB',
  so_obj   FOR objh-objectname.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS:
  p_sort AS CHECKBOX DEFAULT 'X',
  p_all  TYPE c NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
PARAMETERS:
  p_none  RADIOBUTTON GROUP g1,
  p_badi  RADIOBUTTON GROUP g1,
  p_objs  RADIOBUTTON GROUP g1 DEFAULT 'X',
  p_count TYPE i DEFAULT 5.
SELECTION-SCREEN END OF BLOCK b3.

TYPES:
  gty_list       TYPE RANGE OF trobjtype.

DATA:
  g_class        TYPE seoclsname,
  gt_classes     TYPE TABLE OF seoclsname,
  gt_abapgit     TYPE TABLE OF seoclsname,
  gt_no_enh      TYPE TABLE OF seoclsname,
  gr_class       TYPE REF TO object,
  g_len          TYPE i,
  g_ok           TYPE i,
  g_warn         TYPE i,
  g_error        TYPE i,
  g_text         TYPE ddtext,
  g_icon         TYPE icon_d,
  g_type         TYPE seu_stype,
  g_pgmid        TYPE pgmid,
  g_object       TYPE trobjtype,
  g_obj_type     TYPE trobjtype,
  gt_objects     TYPE TABLE OF trobjtype,
  gs_object_text TYPE ko100,
  gt_object_text TYPE TABLE OF ko100,
  gs_object_list TYPE LINE OF gty_list,
  gt_object_list TYPE gty_list,
  gs_e071        TYPE trwbo_s_e071,
  gt_e071        TYPE trwbo_t_e071,
  gs_e071_txt    TYPE /mbtools/trwbo_s_e071_txt,
  gt_e071_txt    TYPE /mbtools/trwbo_t_e071_txt.

FIELD-SYMBOLS:
  <version>     TYPE string,
  <object_list> TYPE gty_list.

START-OF-SELECTION.

  gt_object_text = /mbtools/cl_sap=>get_object_texts( ).

  " All classes that implement the BAdI
  SELECT DISTINCT clsname FROM seometarel INTO TABLE gt_classes
    WHERE clsname IN so_class AND refclsname = '/MBTOOLS/IF_CTS_REQ_DISPLAY'
    ORDER BY clsname.

  " All classes provided by abapGit
  SELECT DISTINCT clsname FROM seoclass INTO TABLE gt_abapgit
    WHERE clsname LIKE 'ZCL_ABAPGIT_OBJECT_%'
    ORDER BY clsname.

  gt_no_enh = gt_abapgit.

  LOOP AT gt_classes INTO g_class.
    WRITE: / 'Class:', AT 15 g_class.
    SKIP.

    CREATE OBJECT gr_class TYPE (g_class).

    " Get list of supported objects
    ASSIGN gr_class->('NT_OBJECT_LIST') TO <object_list>.
    CHECK sy-subrc = 0.

    gt_object_list = <object_list>.

    IF p_sort = abap_true.
      SORT gt_object_list.
    ENDIF.

    LOOP AT gt_object_list INTO gs_object_list WHERE low IN so_obj.
      g_object = gs_object_list-low.

      IF p_all IS INITIAL AND strlen( g_object ) < 4.
        CONTINUE.
      ENDIF.

      READ TABLE gt_object_text INTO gs_object_text
        WITH KEY object = g_object. " transport objects
      IF sy-subrc = 0.
        g_pgmid = gs_object_text-pgmid.
      ELSE.
        g_pgmid = '----'.
      ENDIF.

      WRITE: / 'Object:', AT 15 g_pgmid COLOR COL_NORMAL, g_object COLOR COL_NORMAL.

      " Icon
      CALL METHOD gr_class->('GET_OBJECT_ICON')
        EXPORTING
          i_object = g_object
        CHANGING
          r_icon   = g_icon.

      WRITE: AT 30 g_icon AS ICON, space.

      " abapGit Support
      CONCATENATE 'ZCL_ABAPGIT_OBJECT_' g_object INTO g_text.

      READ TABLE gt_abapgit TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = g_text.
      IF sy-subrc = 0.
        WRITE: 'Yes' COLOR COL_POSITIVE INTENSIFIED OFF.
        DELETE gt_no_enh WHERE table_line = g_text.
      ELSE.
        IF g_pgmid = 'R3TR'.
          WRITE: 'No ' COLOR COL_NORMAL INTENSIFIED OFF.
        ELSE.
          WRITE: '---'.
        ENDIF.
      ENDIF.

      " Text
      CLEAR g_text.

      READ TABLE gt_object_text INTO gs_object_text
        WITH KEY object = g_object. " transport objects
      IF sy-subrc = 0.
        g_text = gs_object_text-text.
      ELSE.
        SELECT SINGLE type FROM euobj INTO g_type
          WHERE id = g_object. " workbench objects
        IF sy-subrc = 0.
          SELECT SINGLE stext FROM wbobjtypt INTO g_text
            WHERE type = g_type AND spras = sy-langu.
        ELSE.
          SELECT SINGLE stext FROM wbobjtypt INTO g_text
            WHERE type = g_object AND spras = sy-langu.
        ENDIF.
      ENDIF.

      WRITE: AT 50 g_text, AT 121 space.

      IF g_class = '/MBTOOLS/CL_CTS_REQ_DISP_WB'.
        PERFORM get_object_type USING g_pgmid g_object CHANGING g_obj_type.

        IF g_object = g_obj_type.
          WRITE: 'Same' COLOR COL_POSITIVE, g_obj_type.
        ELSE.
          WRITE: 'Diff' COLOR COL_TOTAL, g_obj_type COLOR COL_TOTAL.
        ENDIF.

        PERFORM get_object_type_ext USING g_object CHANGING g_obj_type.

        IF g_object = g_obj_type.
          WRITE: 'Same' COLOR COL_POSITIVE, g_obj_type.
        ELSE.
          WRITE: 'Diff' COLOR COL_TOTAL, g_obj_type COLOR COL_TOTAL.
        ENDIF.
      ENDIF.

      IF p_badi = abap_true.

        " Check for icon
        IF g_icon IS INITIAL OR g_icon = icon_dummy.
          WRITE: 'Missing icon' COLOR COL_TOTAL.
        ENDIF.

        " Check for text
        g_len = strlen( g_object ).
        IF g_text IS INITIAL.
          IF g_len < 4.
            WRITE: 'Missing text' COLOR COL_NORMAL INTENSIFIED OFF.
          ELSE.
            WRITE: 'Missing text' COLOR COL_TOTAL.
          ENDIF.
        ENDIF.

        " Check for duplicates
        READ TABLE gt_objects TRANSPORTING NO FIELDS
          WITH KEY table_line = g_object.
        IF sy-subrc = 0.
          WRITE: 'Already defined above' COLOR COL_NEGATIVE.
        ELSE.
          INSERT g_object INTO TABLE gt_objects.
        ENDIF.

      ELSEIF p_objs = abap_true.

        SKIP.

        " Get one (random) test object
        CLEAR sy-subrc.

        IF g_pgmid = 'R3TR'.
          SELECT pgmid object obj_name FROM tadir INTO CORRESPONDING FIELDS OF TABLE gt_e071 UP TO p_count ROWS
            WHERE pgmid = 'R3TR' AND object = g_object AND obj_name BETWEEN 'A' AND 'ZZZ' AND delflag = ''.
        ENDIF.

        IF g_pgmid = 'LIMU' OR sy-subrc <> 0.
          SELECT pgmid object obj_name FROM e071 INTO CORRESPONDING FIELDS OF TABLE gt_e071 UP TO p_count ROWS
            WHERE pgmid = g_pgmid AND object = g_object AND obj_name BETWEEN 'A' AND 'ZZZ' AND objfunc = ''.
          IF sy-subrc <> 0.
            SELECT pgmid object obj_name FROM e071 INTO CORRESPONDING FIELDS OF TABLE gt_e071 UP TO p_count ROWS
              WHERE pgmid = g_pgmid AND object = g_object AND objfunc = ''.
            IF sy-subrc <> 0.
              SELECT pgmid object obj_name FROM e071 INTO CORRESPONDING FIELDS OF TABLE gt_e071 UP TO p_count ROWS
                WHERE pgmid = g_pgmid AND object = g_object.
            ENDIF.
          ENDIF.
        ENDIF.

        IF sy-subrc = 0.
          " Do BAdI call for one object
          CLEAR: gt_e071_txt.

          CALL METHOD gr_class->('GET_OBJECT_DESCRIPTIONS')
            EXPORTING
              it_e071     = gt_e071
            CHANGING
              ct_e071_txt = gt_e071_txt.

          LOOP AT gt_e071 INTO gs_e071.
            READ TABLE gt_e071_txt INTO gs_e071_txt WITH KEY
              pgmid    = gs_e071-pgmid
              object   = gs_e071-object
              obj_name = gs_e071-obj_name.
            IF sy-subrc = 0.
              IF gs_e071_txt-icon IS INITIAL.
                gs_e071_txt-icon = icon_dummy.
              ENDIF.
              WRITE: gs_e071_txt-icon.
              IF gs_e071_txt-text IS INITIAL.
                gs_e071_txt-text = '(' && 'Text not found' && ')'.
                WRITE: gs_e071_txt-text COLOR COL_NEGATIVE.
                ADD 1 TO g_error.
              ELSE.
                WRITE: gs_e071_txt-text COLOR COL_POSITIVE.
                ADD 1 TO g_ok.
              ENDIF.
              IF gs_e071-obj_name = gs_e071_txt-obj_name.
                gs_e071_txt-obj_name = '[' && gs_e071_txt-obj_name && ']'.
                CONDENSE gs_e071_txt-obj_name NO-GAPS.
                WRITE: gs_e071_txt-obj_name COLOR COL_NORMAL INTENSIFIED ON.
              ELSE.
                gs_e071_txt-obj_name = '[' && gs_e071_txt-obj_name && ']'.
                CONDENSE gs_e071_txt-obj_name NO-GAPS.
                WRITE: gs_e071_txt-obj_name COLOR COL_NORMAL INTENSIFIED OFF.
              ENDIF.
            ELSE.
              WRITE: g_icon AS ICON, 'No text found' COLOR COL_NEGATIVE.
              ADD 1 TO g_warn.
            ENDIF.
            SKIP.
          ENDLOOP.
        ELSE.
          WRITE: g_icon AS ICON, 'No test object found' COLOR COL_TOTAL.
          ADD 1 TO g_warn.
        ENDIF.

        SKIP.

      ENDIF.

    ENDLOOP.

    ULINE.
    WRITE: / 'Result:', g_ok COLOR COL_POSITIVE, g_warn COLOR COL_TOTAL, g_error COLOR COL_NEGATIVE.
    ULINE.
  ENDLOOP.

  CHECK so_class IS INITIAL AND so_obj IS INITIAL.

  WRITE: / 'Objects supported by abapGit but not by MBT Transport Request'.
  SKIP.

  LOOP AT gt_no_enh INTO g_class.
    CHECK strlen( g_class ) = 23.

    g_object = g_class+19(4).

    CHECK g_object IN so_obj.

    READ TABLE gt_object_text INTO gs_object_text
      WITH KEY object = g_object. " transport objects
    IF sy-subrc = 0.
      WRITE: / 'Object:', AT 15 gs_object_text-pgmid COLOR COL_NORMAL, g_object COLOR COL_NORMAL.
      g_text = gs_object_text-text.
      WRITE: AT 50 g_text.
    ELSE.
      WRITE: / 'Object:', AT 15 '----' COLOR COL_NORMAL, g_object COLOR COL_NORMAL.
      g_text = 'Not a transport object'.
      WRITE: AT 50 g_text COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.

  ENDLOOP.
  IF sy-subrc <> 0.
    WRITE: / 'None' COLOR COL_POSITIVE.
  ENDIF.

FORM get_object_type
  USING
    iv_pgmid TYPE tadir-pgmid
    iv_object TYPE tadir-object
  CHANGING
    lv_obj_type TYPE tadir-object.

  IF iv_object NE 'REPO' AND iv_object NE 'DYNP'
      AND    iv_object NE 'VARI' AND iv_object NE 'VARX'
      AND    iv_object NE 'MESS' AND iv_object NE 'METH'
      AND    iv_object NE 'WAPP' AND iv_object NE 'TABU'
      AND    iv_object NE 'INTD' AND iv_object NE 'WDYC'
      AND    iv_object NE 'WDYV' AND iv_object NE 'ADIR'.

    SELECT SINGLE id FROM euobjv INTO lv_obj_type
                                 WHERE id EQ iv_object.


    IF sy-subrc <> 0.
      DATA: l_global_type TYPE wbobjtype.
      DATA: l_wb_type TYPE seu_objtyp.
      CLEAR l_global_type.
      CLEAR lv_obj_type.
      cl_wb_object_type=>get_global_from_transport_type(
        EXPORTING
          p_transport_type  = iv_object
        IMPORTING
          p_global_type     = l_global_type
        EXCEPTIONS
          no_unique_mapping = 1
          OTHERS            = 2
      ).
      IF l_global_type IS NOT INITIAL.
        cl_wb_object_type=>get_internal_from_global_type(
          EXPORTING
            p_global_type   = l_global_type
          IMPORTING
            p_internal_type = l_wb_type
        ).
        lv_obj_type = l_wb_type.
      ENDIF.

    ENDIF.

  ELSE.
    IF     iv_pgmid  = 'LIMU'  AND  iv_object  =  'REPO'.
      lv_obj_type = 'PROG'.
    ELSEIF iv_pgmid  = 'LIMU'  AND  iv_object  =  'DYNP'.
      lv_obj_type = 'DYNP'.
    ELSEIF iv_pgmid  = 'LIMU' AND (   iv_object = 'VARI'
                                   OR iv_object = 'VARX' ) .
      lv_obj_type = 'PV'.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'MESS'.
      lv_obj_type = 'MESS'.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'METH'.
      lv_obj_type = 'METH'.
*& 'INTD' Object use same Edititor like 'INTF' .
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'INTD'.
      lv_obj_type = 'INTF' .
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WDYC'.
      lv_obj_type = 'WDYC'.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WDYV'.
      lv_obj_type = 'WDYV'.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WAPP'.
      lv_obj_type = 'WAPP'.
    ELSEIF iv_pgmid = 'R3TR'  AND  iv_object = 'TABU'.
      lv_obj_type = 'DT'.
    ENDIF.
  ENDIF.
ENDFORM.

FORM get_object_type_ext
  USING
    iv_object TYPE tadir-object
  CHANGING
    e_obj_type TYPE tadir-object.

  e_obj_type = iv_object.

* Map some object types
  CASE iv_object.
    WHEN 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
      e_obj_type = 'CLAS'.
    WHEN 'CINC'.
      e_obj_type = 'CL/P'.
    WHEN 'REPS' OR 'REPT'.
      e_obj_type = 'CL/P'.
    WHEN 'TABU' OR 'TABT'.
      e_obj_type = 'TABL'.
    WHEN 'VDAT' OR 'CDAT' OR 'VIET'.
      e_obj_type = 'VIEW'.
    WHEN 'SHLD' OR 'SHLX'.
      e_obj_type = 'SHLP'.
    WHEN 'TTYX'.
      e_obj_type = 'TTYP'.
    WHEN 'TYPD'.
      e_obj_type = 'TYPE'.
    WHEN 'CUAD'.
      e_obj_type = swbm_c_type_cua_status.
    WHEN 'XPRA'.
      e_obj_type = 'PROG'.
    WHEN 'INDX'.
      e_obj_type = 'TABL'.
    WHEN 'LDBA'.
      e_obj_type = swbm_c_type_logical_database.
    WHEN 'DSEL'.
      e_obj_type = swbm_c_type_logical_database.
    WHEN 'IARP' OR swbm_c_type_w3_resource.
      e_obj_type = 'IASP'.
    WHEN 'IATU' OR swbm_c_type_w3_template.
    WHEN 'SPRX'.
      e_obj_type = 'DE/T'.
    WHEN 'DDLS'.
      e_obj_type = swbm_c_type_ddic_ddl_source.
    WHEN 'DCLS'.
      e_obj_type = 'Q0R'.
    WHEN 'DEVP'.
      e_obj_type = 'DEVC'.
    WHEN 'PIFA' OR 'PIFH'.
      e_obj_type = 'PINF'.
    WHEN 'MCOD'.
      e_obj_type = 'MCOB'.
    WHEN 'MSAD'.
      e_obj_type = 'MSAG'.
    WHEN 'WAPD'.
      e_obj_type = 'WAPA'.
    WHEN 'WAPP'.
*        TODO: Test if it works with or without this and implement workaround if necesssary (table O2PAGDIRT)
*        e_obj_type = 'WAPA'.
*        e_obj_name = i_obj_name(30). "appl
*        e_encl_obj = i_obj_name+30(*). "page
    WHEN 'SQLD' OR 'SQTT'.
      e_obj_type = 'SQLT'.
  ENDCASE.

ENDFORM.
