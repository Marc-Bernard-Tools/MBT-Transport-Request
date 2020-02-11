************************************************************************
* /MBTOOLS/BC_CTS_OBJECT_LIST
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

REPORT /mbtools/bc_cts_object_list.

TYPE-POOLS: icons.

* Length of data element SEU_TEXT
CONSTANTS: c_max_len TYPE i VALUE 75.

*&---------------------------------------------------------------------*
*&      Global Types and Data (LSTRHTOP)
*&---------------------------------------------------------------------*
TYPES: tt_snodetext   LIKE snodetext    OCCURS 50.

TYPES: BEGIN OF  ts_hide_object,
         trkorr TYPE trwbo_s_e070-trkorr,
         as4pos TYPE trwbo_s_e071-as4pos,
       END OF    ts_hide_object.

TYPES: BEGIN OF gty_file_e071_link,
         si_rq_content TYPE si_rq_content,
         e071_ref      TYPE REF TO e071,
       END OF gty_file_e071_link,
       gty_file_e071_links TYPE STANDARD TABLE OF gty_file_e071_link.

TYPES: gty_ko100 TYPE STANDARD TABLE OF ko100.

DATA: gt_object_texts TYPE gty_ko100.

* Hierarchical levels/types
TYPES tv_node_type LIKE snodetext-type.
CONSTANTS:
  gc_node_first_line TYPE tv_node_type  VALUE 'TOPL',
  gc_node_sourcesys  TYPE tv_node_type  VALUE 'SRCS',
  gc_node_targetsys  TYPE tv_node_type  VALUE 'TARG',
  gc_node_status     TYPE tv_node_type  VALUE 'STAT',
  gc_node_function   TYPE tv_node_type  VALUE 'FUNC',
  gc_node_author     TYPE tv_node_type  VALUE 'AUTH',
  gc_node_project    TYPE tv_node_type  VALUE 'PRJC',
  gc_node_activity   TYPE tv_node_type  VALUE 'ACTI',
  gc_node_client     TYPE tv_node_type  VALUE 'MNDT',
  gc_node_request    TYPE tv_node_type  VALUE 'REQU',
  gc_node_taskcoll   TYPE tv_node_type  VALUE 'COLL',
  gc_node_task       TYPE tv_node_type  VALUE 'TASK',
  gc_node_objlist    TYPE tv_node_type  VALUE 'OLST',
  gc_node_objtyp     TYPE tv_node_type  VALUE 'OTYP',
  gc_node_object     TYPE tv_node_type  VALUE 'OBJE',
  gc_node_objkey     TYPE tv_node_type  VALUE 'OKEY',
  gc_node_objtab     TYPE tv_node_type  VALUE 'OTAB',
  gc_node_tabkey     TYPE tv_node_type  VALUE 'TKEY',
  gc_node_attrlist   TYPE tv_node_type  VALUE 'ALST',
  gc_node_attribute  TYPE tv_node_type  VALUE 'ATTR',
  gc_node_attrvalue  TYPE tv_node_type  VALUE 'AVAL'.

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT_LIST (LSTRHF01)
*&---------------------------------------------------------------------*
*&  Build the node table for the object list
*&---------------------------------------------------------------------*
FORM create_object_list
                    USING    pv_parent_level LIKE streenode-tlevel
                             pv_trkorr       TYPE trwbo_request-h-trkorr
                             pv_with_keys    TYPE c
                    CHANGING pt_e071         TYPE trwbo_t_e071
                             pt_e071k        TYPE trwbo_t_e071k
                             pt_e071k_str    TYPE trwbo_t_e071k_str
                             pt_nodes        TYPE tt_snodetext.

  DATA: lt_e071_file      TYPE trwbo_t_e071,
        ls_e071_ref       TYPE REF TO e071,
        ls_file_e071_link TYPE gty_file_e071_link,
        lt_file_e071_link TYPE gty_file_e071_links,
        ls_e071           TYPE trwbo_s_e071,
        ls_node           LIKE LINE OF pt_nodes,
        ls_object_text    LIKE ko100, "LINE OF gt_object_texts,
        lv_pgmid          TYPE trwbo_s_e071-pgmid,
        lv_object         TYPE trwbo_s_e071-object,
        lv_obj_name       TYPE trwbo_s_e071-obj_name,
        lv_activity       TYPE tractivity,
        lv_activity_text  TYPE cus_imgact-text,
        lv_length         TYPE i,
        lv_hide           TYPE ts_hide_object,
        lv_activity_level LIKE snodetext-tlevel,
        lv_header_level   LIKE snodetext-tlevel,
        lv_object_level   LIKE snodetext-tlevel,
        lv_nonabap_text   TYPE e071-obj_name,
        lv_physname       TYPE si_rq_content-physname,
        lv_application    TYPE si_rq_filecntrl-attribute_value.

*{   INSERT         M0NK900019                                        1
* Read texts of object list headings
  gt_object_texts = /mbtools/cl_objects=>get_object_texts( ).
*
*}   INSERT

  CLEAR pt_nodes.

  READ TABLE pt_e071 INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lv_pgmid    = '$%^&'."If we initialize with SPACE we'll fall over
    lv_object   = '$%^&'."empty e071 entries, so we init' with nonsense
    lv_activity = '$%^&'.

    SORT pt_e071 BY activity pgmid object obj_name.
*   hennrich - sort file objects by created date (the deployment sequence)
    lt_e071_file = pt_e071.
    DELETE pt_e071 WHERE pgmid  = 'R3TR'
                   AND   object = 'FILE'.
    DELETE lt_e071_file WHERE pgmid  <> 'R3TR'
                        OR    object <> 'FILE'.
    LOOP AT lt_e071_file REFERENCE INTO ls_e071_ref.
      SELECT SINGLE * FROM si_rq_content
                      INTO ls_file_e071_link-si_rq_content
                      WHERE id = ls_e071_ref->obj_name.
      IF sy-subrc = 0.
        ls_file_e071_link-e071_ref = ls_e071_ref.
        APPEND ls_file_e071_link TO lt_file_e071_link.
      ELSE.
        APPEND ls_e071_ref->* TO pt_e071.
      ENDIF.
    ENDLOOP.
    SORT lt_file_e071_link BY si_rq_content-created_at.
    LOOP AT lt_file_e071_link INTO ls_file_e071_link.
      APPEND ls_file_e071_link-e071_ref->* TO pt_e071.
    ENDLOOP.
*   hennrich - end
*{   INSERT         M0NK900019                                        2
*** Enhancement: BADI to get description of objects as alternativ to object names

    DATA:
      lr_badi      TYPE REF TO /mbtools/bc_cts_req_display,
      lt_txt       TYPE /mbtools/trwbo_t_e071_txt,
      lv_found     TYPE abap_bool,
      lv_objt_name TYPE trobj_name,
      lv_disp_name TYPE trobj_name.

    GET BADI lr_badi.

    IF lr_badi IS BOUND.
      CALL BADI lr_badi->get_object_descriptions
        EXPORTING
          it_e071     = pt_e071
        CHANGING
          ct_e071_txt = lt_txt.

      SORT lt_txt.
    ENDIF.
*
*}   INSERT

    LOOP AT pt_e071 INTO ls_e071.

      IF lv_activity <> ls_e071-activity.
        IF ls_e071-activity = space.
          lv_header_level   = pv_parent_level + 1.
          lv_object_level   = pv_parent_level + 2.
        ELSE.
          lv_activity_level = pv_parent_level + 1.
          lv_header_level   = pv_parent_level + 2.
          lv_object_level   = pv_parent_level + 3.

          PERFORM get_activity_text IN PROGRAM saplstrh
                                    USING ls_e071-activity
                                    CHANGING lv_activity_text.
          CLEAR ls_node.
          ls_node-tlength     = 20.
          ls_node-text        = TEXT-img.
          lv_length = strlen( ls_node-text ).
          ls_node-tlength     = lv_length + 1.
          ls_node-hotspot     = 'X'.

          IF lv_activity_text = space.
            ls_node-text1     = ls_e071-activity.
          ELSE.
            ls_node-text1     = lv_activity_text.
          ENDIF.
          ls_node-tlength1    = c_max_len.
          ls_node-tlevel      = lv_activity_level.
          ls_node-type        = gc_node_activity.
          ls_node-hide        = ls_e071-activity.
          ls_node-hotspot1    = 'X'.
          APPEND ls_node TO pt_nodes.
        ENDIF.
      ENDIF.

*     Move comments completely into lv_obj_name, so that the
*     text can be found in gt_object_texts and that the comment is
*     displayed completely in the object list
      IF ls_e071-pgmid(1) EQ '*'.
        ls_e071-pgmid  = '*'.
        ls_e071-object = space.
        lv_obj_name(4)   = ls_e071-pgmid.
        lv_obj_name+5(4) = ls_e071-object.
        lv_obj_name+10   = ls_e071-obj_name.
      ELSE.
        lv_obj_name      = ls_e071-obj_name.
      ENDIF.

      IF lv_activity <> ls_e071-activity
      OR lv_pgmid    <> ls_e071-pgmid
      OR lv_object   <> ls_e071-object .
        lv_activity = ls_e071-activity.
        lv_pgmid    = ls_e071-pgmid.
        lv_object   = ls_e071-object.
*       Insert new object type description
        CLEAR ls_node.
        IF lv_pgmid = 'LANG'.
          READ TABLE gt_object_texts INTO ls_object_text
                                     WITH KEY object = lv_object.
          IF sy-subrc = 0.
            CONCATENATE TEXT-trl ls_object_text-text
                        INTO ls_node-text1 SEPARATED BY ' '.
            CONDENSE ls_node-text1.
          ELSE.
            ls_node-text1  = 'No text exists'(ktv).
          ENDIF.
        ELSE.
          READ TABLE gt_object_texts INTO ls_object_text
                                     WITH KEY pgmid  = lv_pgmid
                                              object = lv_object
                                     BINARY SEARCH.
          IF sy-subrc EQ 0.
            ls_node-text1  = ls_object_text-text.
          ELSE.
            ls_node-text1  = 'No text exists'(ktv).
          ENDIF.
        ENDIF.
        ls_node-tlength1  = c_max_len.
        ls_node-name(4)   = ls_e071-pgmid.
        ls_node-name+4(4) = ls_e071-object. "Only for refreshing
        ls_node-tlevel    = lv_header_level.
        ls_node-type      = gc_node_objtyp.
*       ls_node-color     = pv_node_color.
        ls_node-hide      = ls_node-name.
        APPEND ls_node TO pt_nodes.
      ENDIF.
*{   INSERT         M0NK900019                                        3
*
      PERFORM get_object_and_display_name
        USING lt_txt ls_e071-trkorr ls_e071-as4pos
              ls_e071-pgmid ls_e071-object ls_e071-obj_name
        CHANGING lv_found lv_objt_name lv_disp_name.
*
*}   INSERT

*     Insert object
      CLEAR ls_node.
      ls_node-name     = lv_obj_name.
*{   REPLACE        M0NK900019                                        3
*\      ls_node-text     = lv_obj_name.
*\      ls_node-tlength  = c_max_len.
*
      IF lv_found = abap_true.
        ls_node-text     = lv_objt_name.
        ls_node-tlength  = c_max_len.
        ls_node-text1    = lv_disp_name.
        ls_node-tlength1 = c_max_len.
      ELSE.
        ls_node-text     = lv_obj_name.
        ls_node-tlength  = c_max_len.
      ENDIF.
*
*}   REPLACE
      ls_node-tlevel   = lv_object_level.
      ls_node-type     = gc_node_object.
      IF ls_e071-lang <> space.
        WRITE ls_e071-lang TO ls_node-name.
        ls_node-nlength = 2.
      ENDIF.
      lv_hide-trkorr   = pv_trkorr.
      lv_hide-as4pos   = ls_e071-as4pos.
      ls_node-hide     = lv_hide.

*& head of pt_nodes
      IF ls_e071-objfunc = 'K' AND pv_with_keys <> 'X'.
        ls_node-force_plus = 'X'.
      ENDIF.

*&***** NON-ABAP-OBJECT: text = application + file name*******
      IF ls_e071-pgmid = 'R3TR' AND  ls_e071-object = 'FILE'  .
*       get application
        SELECT SINGLE attribute_value
                      FROM si_rq_filecntrl INTO lv_application
                      WHERE id             = ls_e071-obj_name
                        AND attribute_name = 'APPLICATION'.
*       get file name
        SELECT SINGLE physname FROM si_rq_content INTO lv_physname
                               WHERE id = ls_e071-obj_name.
        CONCATENATE lv_application lv_physname INTO ls_node-text
                    SEPARATED BY ':'.
      ENDIF.

      APPEND ls_node TO pt_nodes.

*& unter noten of pt_nodes
      IF ls_e071-objfunc = 'K' AND pv_with_keys = 'X'.
        PERFORM create_key_list USING    'X'
                                         lv_object_level
                                         ls_e071-as4pos
                                         pt_e071
                                         pt_e071k
                                         pt_e071k_str
                                CHANGING pt_nodes.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_KEY_LIST (LSTRHF01)
*&---------------------------------------------------------------------*
*&  Build the node table for the key list
*&---------------------------------------------------------------------*
FORM create_key_list USING    pv_keep_nodes   TYPE c
                              pv_object_level TYPE streenode-tlevel
                              pv_as4pos       TYPE e071-as4pos
                              pt_e071         TYPE trwbo_t_e071
                              pt_e071k        TYPE trwbo_t_e071k
                              pt_e071k_str    TYPE trwbo_t_e071k_str
                     CHANGING pt_nodes        TYPE tt_snodetext.

  DATA: ls_e071                TYPE trwbo_s_e071,
        ls_e071k               TYPE trwbo_s_e071k,
        lt_e071k               TYPE trwbo_t_e071k,
        ls_e071k_str           TYPE trwbo_s_e071k_str,
        lt_e071k_str           TYPE trwbo_t_e071k_str,
        ls_node                LIKE LINE OF pt_nodes,
        lv_use_two_levels_only TYPE c.

  IF pv_keep_nodes IS INITIAL.
    CLEAR pt_nodes.
  ENDIF.

  READ TABLE pt_e071 INTO ls_e071
                     WITH KEY as4pos = pv_as4pos.
  IF sy-subrc = 0
  AND ls_e071-objfunc = 'K'.
*{   INSERT         M0NK900019                                        4
*
    DATA:
      lr_badi      TYPE REF TO /mbtools/bc_cts_req_display,
      lt_txt       TYPE /mbtools/trwbo_t_e071_txt,
      lv_found     TYPE abap_bool,
      lv_objt_name TYPE trobj_name,
      lv_disp_name TYPE trobj_name.

    GET BADI lr_badi.

    IF lr_badi IS BOUND.
      CALL BADI lr_badi->get_object_descriptions
        EXPORTING
          it_e071      = pt_e071
          it_e071k     = pt_e071k
          it_e071k_str = pt_e071k_str
        CHANGING
          ct_e071_txt  = lt_txt.

      SORT lt_txt.
    ENDIF.
*
*}   INSERT
*   TABU entries usually have only keys for one table
*   but this is not necessarily true.
    CLEAR lv_use_two_levels_only.
    IF ls_e071-object = 'TABU'.
      lv_use_two_levels_only = 'X'.
      LOOP AT pt_e071k TRANSPORTING NO FIELDS
                       WHERE pgmid      =  ls_e071-pgmid
                       AND   mastertype =  ls_e071-object
                       AND   mastername =  ls_e071-obj_name
                       AND   activity   =  ls_e071-activity
                       AND   lang       =  ls_e071-lang
                       AND   objname    <> ls_e071-obj_name.
        lv_use_two_levels_only = ' '.
        EXIT.
      ENDLOOP.
      LOOP AT pt_e071k_str TRANSPORTING NO FIELDS
                       WHERE pgmid      =  ls_e071-pgmid
                       AND   mastertype =  ls_e071-object
                       AND   mastername =  ls_e071-obj_name
                       AND   activity   =  ls_e071-activity
                       AND   lang       =  ls_e071-lang
                       AND   objname    <> ls_e071-obj_name.
        lv_use_two_levels_only = ' '.
        EXIT.
      ENDLOOP.
    ENDIF.
    IF lv_use_two_levels_only = 'X'.
      LOOP AT pt_e071k INTO  ls_e071k
                       WHERE pgmid      = ls_e071-pgmid
                       AND   mastertype = ls_e071-object
                       AND   mastername = ls_e071-obj_name
                       AND   activity   = ls_e071-activity
                       AND   lang       = ls_e071-lang.
        CLEAR ls_node.
        ls_node-text2    = ls_e071k-tabkey.
        ls_node-tlength2 = c_max_len.
        ls_node-tlevel   = pv_object_level + 1.
        ls_node-type     = gc_node_objkey.
        APPEND ls_node TO pt_nodes.
      ENDLOOP.
      LOOP AT pt_e071k_str INTO ls_e071k_str
                       WHERE pgmid      = ls_e071-pgmid
                       AND   mastertype = ls_e071-object
                       AND   mastername = ls_e071-obj_name
                       AND   activity   = ls_e071-activity
                       AND   lang       = ls_e071-lang.
        CLEAR ls_node.
        ls_node-text2    = ls_e071k_str-tabkey.
        ls_node-tlength2 = c_max_len.
        ls_node-tlevel   = pv_object_level + 1.
        ls_node-type     = gc_node_objkey.
        APPEND ls_node TO pt_nodes.
      ENDLOOP.
    ELSE.
*     For view data we want to create an additional level
*     With this, we should ensure proper sorting
      CLEAR lt_e071k.
      LOOP AT pt_e071k INTO  ls_e071k
                       WHERE pgmid      = ls_e071-pgmid
                       AND   mastertype = ls_e071-object
                       AND   mastername = ls_e071-obj_name
                       AND   activity   = ls_e071-activity
                       AND   lang       = ls_e071-lang.
        APPEND ls_e071k TO lt_e071k.
      ENDLOOP.
      SORT lt_e071k BY object objname tabkey.
      LOOP AT lt_e071k INTO  ls_e071k.
        AT NEW objname.
*{   INSERT         M0NK900019                                        5
*
          PERFORM get_object_and_display_name
            USING lt_txt ls_e071k-trkorr /mbtools/cl_cts_req_disp_wb=>c_as4pos
                  ls_e071k-pgmid ls_e071k-object ls_e071k-objname
            CHANGING lv_found lv_objt_name lv_disp_name.
*
*}   INSERT
          CLEAR ls_node.
          ls_node-name     = ls_e071k-objname.
*{   REPLACE        M0NK900019                                        3
*\          ls_node-text1    = ls_e071k-objname.
*\          ls_node-tlength1 = 30.
          IF lv_found = abap_true.
            ls_node-text     = lv_objt_name.
            ls_node-tlength  = c_max_len.
            ls_node-text1    = lv_disp_name.
            ls_node-tlength1 = c_max_len.
          ELSE.
            ls_node-text1    = ls_e071k-objname.
            ls_node-tlength1 = 30.
          ENDIF.
*
*}   REPLACE
          ls_node-tlevel   = pv_object_level + 1.
          ls_node-type     = gc_node_objtab.
          APPEND ls_node TO pt_nodes.
        ENDAT.

        CLEAR ls_node.
        ls_node-text2    = ls_e071k-tabkey.
        ls_node-tlength2  = c_max_len.
        ls_node-tlevel   = pv_object_level + 2.
        ls_node-type     = gc_node_tabkey.
        APPEND ls_node TO pt_nodes.
      ENDLOOP.
*     Stringkey
      CLEAR lt_e071k_str.
      LOOP AT pt_e071k_str INTO ls_e071k_str
                       WHERE pgmid      = ls_e071-pgmid
                       AND   mastertype = ls_e071-object
                       AND   mastername = ls_e071-obj_name
                       AND   activity   = ls_e071-activity
                       AND   lang       = ls_e071-lang.
        APPEND ls_e071k_str TO lt_e071k_str.
      ENDLOOP.
      SORT lt_e071k_str BY object objname tabkey.
      LOOP AT lt_e071k_str INTO ls_e071k_str.
        AT NEW objname.
*{   INSERT         M0NK900019                                        6
*
          PERFORM get_object_and_display_name
            USING lt_txt ls_e071k_str-trkorr /mbtools/cl_cts_req_disp_wb=>c_as4pos
                  ls_e071k_str-pgmid ls_e071k_str-object ls_e071k_str-objname
            CHANGING lv_found lv_objt_name lv_disp_name.
*
*}   INSERT
          CLEAR ls_node.
          ls_node-name     = ls_e071k_str-objname.
*{   REPLACE        M0NK900019                                        4
*\          ls_node-text1    = ls_e071k_str-objname.
*\          ls_node-tlength1 = 30.
          IF lv_found = abap_true.
            ls_node-text     = lv_objt_name.
            ls_node-tlength  = c_max_len.
            ls_node-text1    = lv_disp_name.
            ls_node-tlength1 = c_max_len.
          ELSE.
            ls_node-text1    = ls_e071k_str-objname.
            ls_node-tlength1 = 30.
          ENDIF.
*
*}   REPLACE
          ls_node-tlevel   = pv_object_level + 1.
          ls_node-type     = gc_node_objtab.
          APPEND ls_node TO pt_nodes.
        ENDAT.

        CLEAR ls_node.
        ls_node-text2    = ls_e071k_str-tabkey.
        ls_node-tlength2 = c_max_len.
        ls_node-tlevel   = pv_object_level + 2.
        ls_node-type     = gc_node_tabkey.
        APPEND ls_node TO pt_nodes.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                               " CREATE_KEY_LIST

*{   INSERT         M0NK900019                                        7
*
FORM get_object_and_display_name
  USING
    it_txt       TYPE /mbtools/trwbo_t_e071_txt
    iv_trkorr    TYPE e071-trkorr
    iv_as4pos    TYPE e071-as4pos
    iv_pgmid     TYPE e071-pgmid
    iv_object    TYPE e071-object
    VALUE(iv_obj_name) TYPE csequence
  CHANGING
    rv_found     TYPE abap_bool
    rv_obj_name  TYPE trobj_name
    rv_disp_name TYPE trobj_name.

  DATA:
    ls_txt     TYPE /mbtools/trwbo_s_e071_txt,
    lv_deleted TYPE tadir-delflag,
    lv_more    TYPE i.

  READ TABLE it_txt INTO ls_txt WITH KEY
    trkorr   = iv_trkorr
    as4pos   = iv_as4pos
    pgmid    = iv_pgmid
    object   = iv_object
    obj_name = iv_obj_name
    BINARY SEARCH.
  IF sy-subrc = 0.
    rv_found = abap_true.

*   Check if object has been deleted already
    SELECT SINGLE delflag FROM tadir INTO lv_deleted
      WHERE pgmid    = iv_pgmid
        AND object   = iv_object
        AND obj_name = iv_obj_name.
    IF sy-subrc = 0 AND lv_deleted = abap_true.
      ls_txt-icon = icon_delete.
      ls_txt-text = 'To be deleted in target system'(del).
    ENDIF.

*   Set fallback icon and text
    IF ls_txt-icon IS INITIAL.
      ls_txt-icon = icon_dummy.
    ENDIF.
    IF ls_txt-text IS INITIAL.
      ls_txt-text = 'No text exists'(ktv).
    ENDIF.
    CONCATENATE ls_txt-icon ls_txt-text INTO rv_obj_name SEPARATED BY space.

*   End texts that are too long with ellipsis
    lv_more = strlen( rv_obj_name ).
    IF lv_more > c_max_len.
      CONCATENATE rv_obj_name(73) '…]' INTO rv_obj_name.
    ENDIF.

    CONCATENATE '[' ls_txt-name ']' INTO rv_disp_name.

    lv_more = strlen( rv_disp_name ).
    IF lv_more > c_max_len.
      CONCATENATE rv_disp_name(73) '…]' INTO rv_disp_name.
    ENDIF.
  ELSE.
    rv_found = abap_false.
  ENDIF.

ENDFORM.
*
*}   INSERT
