************************************************************************
* /MBTOOLS/BC_CTS_REQ_TEST
* MBT Transport Request
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
REPORT /mbtools/cts_req_test LINE-SIZE 255.

TABLES:
  seometarel, objh.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS:
  s_class FOR seometarel-clsname, " DEFAULT '/MBTOOLS/CL_CTS_REQ_DISP_WB',
  s_obj   FOR objh-objectname.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS:
  p_all  TYPE c NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
PARAMETERS:
  p_none  RADIOBUTTON GROUP g1 DEFAULT 'X',
  p_badi  RADIOBUTTON GROUP g1,
  p_git   RADIOBUTTON GROUP g1,
  p_objs  RADIOBUTTON GROUP g1,
  p_count TYPE i DEFAULT 5.
SELECTION-SCREEN END OF BLOCK b3.

TYPES:
  ty_list        TYPE RANGE OF trobjtype.

DATA:
  gv_class       TYPE seoclsname,
  gt_classes     TYPE TABLE OF seoclsname,
  gt_abapgit     TYPE TABLE OF seoclsname,
  gt_no_enh      TYPE TABLE OF seoclsname,
  gr_class       TYPE REF TO object,
  gv_len         TYPE i,
  gv_count       TYPE i,
  gv_ok          TYPE i,
  gv_warn        TYPE i,
  gv_error       TYPE i,
  gv_text        TYPE ddtext,
  gv_icon        TYPE icon_d,
  gv_type        TYPE seu_stype,
  gv_pgmid       TYPE pgmid,
  gv_object      TYPE trobjtype,
  gv_obj_type    TYPE trobjtype,
  gt_objects     TYPE TABLE OF trobjtype,
  gs_object_text TYPE ko100,
  gt_object_text TYPE TABLE OF ko100,
  gs_object_list TYPE LINE OF ty_list,
  gr_object_list TYPE ty_list,
  gs_e071        TYPE trwbo_s_e071,
  gt_e071        TYPE trwbo_t_e071,
  gs_e071_txt    TYPE /mbtools/trwbo_s_e071_txt,
  gt_e071_txt    TYPE /mbtools/trwbo_t_e071_txt.

FIELD-SYMBOLS:
  <gr_object_list> TYPE ty_list.

START-OF-SELECTION.

  gt_object_text = /mbtools/cl_sap=>get_object_texts( ).

  " All classes that implement the BAdI
  SELECT DISTINCT clsname FROM seometarel INTO TABLE gt_classes
    WHERE clsname IN s_class AND refclsname = '/MBTOOLS/IF_CTS_REQ_DISPLAY'
    ORDER BY clsname.

  " All classes provided by abapGit
  SELECT DISTINCT clsname FROM seoclass INTO TABLE gt_abapgit
    WHERE clsname LIKE 'ZCL_ABAPGIT_OBJECT_%'
    ORDER BY clsname.

  gt_no_enh = gt_abapgit.

  LOOP AT gt_classes INTO gv_class.
    WRITE: / 'Class:'(001), AT 15 gv_class.
    SKIP.

    CLEAR: gv_ok, gv_warn, gv_error, gv_count.

    CREATE OBJECT gr_class TYPE (gv_class).

    " Get list of supported objects
    ASSIGN gr_class->('GT_OBJECT_LIST') TO <gr_object_list>.
    CHECK sy-subrc = 0.

    gr_object_list = <gr_object_list>.

    SORT gr_object_list.

    LOOP AT gr_object_list INTO gs_object_list WHERE low IN s_obj.
      gv_object = gs_object_list-low.

      IF p_all IS INITIAL AND strlen( gv_object ) < 4.
        CONTINUE.
      ENDIF.

      READ TABLE gt_object_text INTO gs_object_text
        WITH KEY object = gv_object. " transport objects
      IF sy-subrc = 0.
        gv_pgmid = gs_object_text-pgmid.
      ELSE.
        gv_pgmid = '----'.
      ENDIF.

      WRITE: / 'Object:'(002), AT 15 gv_pgmid COLOR COL_NORMAL,
        gv_object COLOR COL_NORMAL.

      " Icon
      CALL METHOD gr_class->('GET_OBJECT_ICON')
        EXPORTING
          iv_object = gv_object
        CHANGING
          cv_icon   = gv_icon.

      WRITE: AT 30 gv_icon AS ICON, space.

      " Text
      CLEAR gv_text.

      READ TABLE gt_object_text INTO gs_object_text
        WITH KEY object = gv_object. " transport objects
      IF sy-subrc = 0.
        gv_text = gs_object_text-text.
      ELSE.
        SELECT SINGLE type FROM euobj INTO gv_type
          WHERE id = gv_object. " workbench objects
        IF sy-subrc = 0.
          SELECT SINGLE stext FROM wbobjtypt INTO gv_text
            WHERE type = gv_type AND spras = sy-langu.
        ELSE.
          SELECT SINGLE stext FROM wbobjtypt INTO gv_text
            WHERE type = gv_object AND spras = sy-langu.
        ENDIF.
      ENDIF.

      WRITE: AT 50 gv_text, AT 121 space.

      CASE abap_true.

        WHEN p_badi.
          CLEAR gv_count.

          " Check for icon
          IF gv_icon IS INITIAL OR gv_icon = icon_dummy.
            WRITE: 'Missing icon'(003) COLOR COL_NEGATIVE.
            gv_error = gv_error + 1.
            gv_count = gv_count + 1.
          ENDIF.

          " Check for text
          gv_len = strlen( gv_object ).
          IF gv_text IS INITIAL.
            IF gv_len < 4.
              WRITE: 'Missing text'(004) COLOR COL_NORMAL INTENSIFIED OFF.
              gv_warn = gv_warn + 1.
            ELSE.
              WRITE: 'Missing text'(004) COLOR COL_NEGATIVE.
              gv_error = gv_error + 1.
            ENDIF.
            gv_count = gv_count + 1.
          ENDIF.

          " Check for duplicates
          READ TABLE gt_objects TRANSPORTING NO FIELDS
            WITH KEY table_line = gv_object.
          IF sy-subrc = 0.
            WRITE: 'Already defined above'(005) COLOR COL_NEGATIVE.
            gv_error = gv_error + 1.
            gv_count = gv_count + 1.
          ELSE.
            INSERT gv_object INTO TABLE gt_objects.
          ENDIF.

          IF gv_count = 0.
            gv_ok = gv_ok + 1.
          ENDIF.

        WHEN p_objs.

          " Check of WB objects
          IF gv_class = '/MBTOOLS/CL_CTS_REQ_DISP_WB'.
            WRITE: 'WB Mapping:'(021).

            PERFORM get_object_type USING gv_pgmid gv_object CHANGING gv_obj_type.

            IF gv_object = gv_obj_type.
              WRITE: 'Same'(007) COLOR COL_POSITIVE, gv_obj_type.
            ELSE.
              WRITE: 'Diff'(008) COLOR COL_TOTAL, gv_obj_type COLOR COL_TOTAL.
            ENDIF.

            WRITE: 'MBT Mapping:'(006).

            PERFORM get_object_type_ext USING gv_object CHANGING gv_obj_type.

            IF gv_object = gv_obj_type.
              WRITE: 'Same'(007) COLOR COL_POSITIVE, gv_obj_type.
            ELSE.
              WRITE: 'Diff'(008) COLOR COL_TOTAL, gv_obj_type COLOR COL_TOTAL.
            ENDIF.
          ENDIF.

          SKIP.

          " Get one (random) test object
          CLEAR sy-subrc.

          IF gv_pgmid = 'R3TR'.
            SELECT DISTINCT pgmid object obj_name FROM tadir
              INTO CORRESPONDING FIELDS OF TABLE gt_e071
              UP TO p_count ROWS
              WHERE pgmid = 'R3TR' AND object = gv_object
                AND obj_name BETWEEN 'A' AND 'ZZZ'
                AND delflag = '' ##TOO_MANY_ITAB_FIELDS.
          ENDIF.

          IF gv_pgmid = 'LIMU' OR sy-subrc <> 0.
            SELECT DISTINCT pgmid object obj_name FROM e071
              INTO CORRESPONDING FIELDS OF TABLE gt_e071
              UP TO p_count ROWS
              WHERE pgmid = gv_pgmid AND object = gv_object
                AND obj_name BETWEEN 'A' AND 'ZZZ'
                AND objfunc = '' ##TOO_MANY_ITAB_FIELDS.
            IF sy-subrc <> 0.
              SELECT DISTINCT pgmid object obj_name FROM e071
                INTO CORRESPONDING FIELDS OF TABLE gt_e071
                UP TO p_count ROWS
                WHERE pgmid = gv_pgmid AND object = gv_object
                  AND objfunc = '' ##TOO_MANY_ITAB_FIELDS.
            ENDIF.
            IF sy-subrc <> 0.
              SELECT DISTINCT pgmid object obj_name FROM e071
                INTO CORRESPONDING FIELDS OF TABLE gt_e071
                UP TO p_count ROWS
                WHERE pgmid = gv_pgmid
                  AND object = gv_object ##TOO_MANY_ITAB_FIELDS.
            ENDIF.
          ENDIF.

          IF sy-subrc = 0.
            " Do BAdI call for selected object
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
                  gs_e071_txt-text = '(' && 'Text not found'(020) && ')'.
                  WRITE: gs_e071_txt-text COLOR COL_NEGATIVE.
                  gv_error = gv_error + 1.
                ELSE.
                  WRITE: gs_e071_txt-text COLOR COL_POSITIVE.
                  gv_ok = gv_ok + 1.
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
                WRITE: gv_icon AS ICON, 'No text found'(009) COLOR COL_NEGATIVE.
                gv_warn = gv_warn + 1.
              ENDIF.
              SKIP.
            ENDLOOP.
          ELSE.
            WRITE: gv_icon AS ICON, 'No test object found'(010) COLOR COL_TOTAL.
            gv_warn = gv_warn + 1.
          ENDIF.

          SKIP.

        WHEN p_git.

          WRITE: 'abapGit:' ##NO_TEXT.

          gv_class = 'ZCL_ABAPGIT_OBJECT_' && gv_object.

          READ TABLE gt_abapgit TRANSPORTING NO FIELDS
            WITH TABLE KEY table_line = gv_class.
          IF sy-subrc = 0.
            WRITE: 'Yes'(011) COLOR COL_POSITIVE.
            gv_ok = gv_ok + 1.
            DELETE gt_no_enh WHERE table_line = gv_class.
          ELSEIF gv_pgmid = 'R3TR'.
            WRITE: 'No'(012) COLOR COL_TOTAL.
            gv_warn = gv_warn + 1.
          ELSE.
            WRITE: '---' COLOR COL_NORMAL.
            gv_ok = gv_ok + 1.
          ENDIF.

      ENDCASE.

    ENDLOOP.

    ULINE.
    WRITE: /
      'OK:'(013),       gv_ok COLOR COL_POSITIVE,
      'Warnings:'(014), gv_warn COLOR COL_TOTAL,
      'Errors:'(015),   gv_error COLOR COL_NEGATIVE.
    ULINE.
  ENDLOOP.

  CHECK s_class IS INITIAL AND s_obj IS INITIAL AND p_git = abap_true.

  WRITE: / 'Objects supported by abapGit but not by MBT Transport Request'(016).
  SKIP.

  LOOP AT gt_no_enh INTO gv_class.
    CHECK strlen( gv_class ) = 23.

    gv_object = gv_class+19(4).

    CHECK gv_object IN s_obj.

    READ TABLE gt_object_text INTO gs_object_text
      WITH KEY object = gv_object. " transport objects
    IF sy-subrc = 0.
      WRITE: / 'Object:'(017), AT 15 gs_object_text-pgmid COLOR COL_NORMAL,
        gv_object COLOR COL_NORMAL.
      gv_text = gs_object_text-text.
      WRITE: AT 50 gv_text.
    ELSE.
      WRITE: / 'Object:'(017), AT 15 '----' COLOR COL_NORMAL,
        gv_object COLOR COL_NORMAL.
      gv_text = 'Not a transport object'(018).
      WRITE: AT 50 gv_text COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.

  ENDLOOP.
  IF sy-subrc <> 0.
    WRITE: / 'None'(019) COLOR COL_POSITIVE.
  ENDIF.

FORM get_object_type
  USING
    iv_pgmid    TYPE tadir-pgmid
    iv_object   TYPE tadir-object
  CHANGING
    cv_obj_type TYPE tadir-object.

  DATA: lv_global_type TYPE wbobjtype.
  DATA: lv_wb_type TYPE seu_objtyp.

  IF    iv_object <> 'REPO' AND iv_object <> 'DYNP'
    AND iv_object <> 'VARI' AND iv_object <> 'VARX'
    AND iv_object <> 'MESS' AND iv_object <> 'METH'
    AND iv_object <> 'WAPP' AND iv_object <> 'TABU'
    AND iv_object <> 'INTD' AND iv_object <> 'WDYC'
    AND iv_object <> 'WDYV' AND iv_object <> 'ADIR'.

    SELECT SINGLE id FROM euobjv INTO cv_obj_type WHERE id = iv_object.

    IF sy-subrc <> 0.
      CLEAR lv_global_type.
      CLEAR cv_obj_type.
      cl_wb_object_type=>get_global_from_transport_type(
        EXPORTING
          p_transport_type  = iv_object
        IMPORTING
          p_global_type     = lv_global_type
        EXCEPTIONS
          no_unique_mapping = 1
          OTHERS            = 2 ).
      IF sy-subrc = 0 AND lv_global_type IS NOT INITIAL.
        cl_wb_object_type=>get_internal_from_global_type(
          EXPORTING
            p_global_type   = lv_global_type
          IMPORTING
            p_internal_type = lv_wb_type ).
        cv_obj_type = lv_wb_type.
      ENDIF.
    ENDIF.

  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'REPO'.
    cv_obj_type = 'PROG'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'DYNP'.
    cv_obj_type = 'DYNP'.
  ELSEIF iv_pgmid = 'LIMU' AND ( iv_object = 'VARI' OR iv_object = 'VARX' ).
    cv_obj_type = 'PV'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'MESS'.
    cv_obj_type = 'MESS'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'METH'.
    cv_obj_type = 'METH'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'INTD'.
    " INTD uses same editor as INTF
    cv_obj_type = 'INTF'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'WDYC'.
    cv_obj_type = 'WDYC'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'WDYV'.
    cv_obj_type = 'WDYV'.
  ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'WAPP'.
    cv_obj_type = 'WAPP'.
  ELSEIF iv_pgmid = 'R3TR' AND iv_object = 'TABU'.
    cv_obj_type = 'DT'.
  ENDIF.

ENDFORM.

FORM get_object_type_ext
  USING
    iv_object   TYPE tadir-object
  CHANGING
    ev_obj_type TYPE tadir-object.

  ev_obj_type = iv_object.

  " Map some object types
  CASE iv_object.
    WHEN 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
      ev_obj_type = 'CLAS'.
    WHEN 'CINC'.
      ev_obj_type = 'CL/P'.
    WHEN 'REPS' OR 'REPT'.
      ev_obj_type = 'CL/P'.
    WHEN 'TABU' OR 'TABT'.
      ev_obj_type = 'TABL'.
    WHEN 'VDAT' OR 'CDAT' OR 'VIET'.
      ev_obj_type = 'VIEW'.
    WHEN 'SHLD' OR 'SHLX'.
      ev_obj_type = 'SHLP'.
    WHEN 'TTYX'.
      ev_obj_type = 'TTYP'.
    WHEN 'TYPD'.
      ev_obj_type = 'TYPE'.
    WHEN 'CUAD'.
      ev_obj_type = swbm_c_type_cua_status.
    WHEN 'XPRA'.
      ev_obj_type = 'PROG'.
    WHEN 'INDX'.
      ev_obj_type = 'TABL'.
    WHEN 'LDBA'.
      ev_obj_type = swbm_c_type_logical_database.
    WHEN 'DSEL'.
      ev_obj_type = swbm_c_type_logical_database.
    WHEN 'IARP' OR swbm_c_type_w3_resource.
      ev_obj_type = 'IASP'.
    WHEN 'IATU' OR swbm_c_type_w3_template.
    WHEN 'SPRX'.
      ev_obj_type = 'DE/T'.
    WHEN 'DDLS'.
      ev_obj_type = swbm_c_type_ddic_ddl_source.
    WHEN 'DCLS'.
      ev_obj_type = 'Q0R'.
    WHEN 'DEVP'.
      ev_obj_type = 'DEVC'.
    WHEN 'PIFA' OR 'PIFH'.
      ev_obj_type = 'PINF'.
    WHEN 'MCOD'.
      ev_obj_type = 'MCOB'.
    WHEN 'MSAD'.
      ev_obj_type = 'MSAG'.
    WHEN 'WAPD'.
      ev_obj_type = 'WAPA'.
    WHEN 'WAPP' ##TODO.
*     Test if it works with or without this and implement workaround if necesssary (table O2PAGDIRT)
*     ev_obj_type = 'WAPA'.
*     ev_obj_name = iv_obj_name(30). "appl
*     ev_encl_obj = iv_obj_name+30(*). "page
    WHEN 'SQLD' OR 'SQTT'.
      ev_obj_type = 'SQLT'.
  ENDCASE.

ENDFORM.
