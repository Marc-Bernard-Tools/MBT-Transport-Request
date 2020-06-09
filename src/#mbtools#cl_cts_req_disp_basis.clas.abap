************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_BASIS
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_basis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CLASS-DATA:
      gt_object_list TYPE RANGE OF e071-object READ-ONLY .

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_BASIS IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      lv_len        TYPE i,
      lv_objectname TYPE objh-objectname,
      lv_objecttype TYPE objh-objecttype,
      ls_objt       TYPE objt,
      lv_objt       TYPE c,
      lv_obj_type   TYPE trobjtype,
      lv_obj_name   TYPE sobj_name,
      ls_e071_txt   TYPE /mbtools/trwbo_s_e071_txt.

    FIELD-SYMBOLS:
      <ls_e071> TYPE trwbo_s_e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

      ls_e071_txt-icon = get_object_icon( <ls_e071>-object ).

      ls_e071_txt-name = <ls_e071>-obj_name.

      CASE <ls_e071>-object.
        WHEN 'SICF'. " ICF Service
          SELECT SINGLE icf_docu FROM icfdocu INTO ls_e071_txt-text
            WHERE icf_name   = <ls_e071>-obj_name(15)
              AND icfparguid = <ls_e071>-obj_name+15(25)
              AND icf_langu  = sy-langu.
        WHEN 'TOBJ'. " Transport object
          lv_len = strlen( <ls_e071>-obj_name ) - 1.
          lv_objectname = <ls_e071>-obj_name(lv_len).
          lv_objecttype = <ls_e071>-obj_name+lv_len(1).

          CALL FUNCTION 'CTO_OBJECT_GET_DDIC_TEXT'
            EXPORTING
              iv_objectname        = lv_objectname
              iv_objecttype        = lv_objecttype
              iv_language          = sy-langu
            IMPORTING
              es_objt              = ls_objt
              ev_objt_doesnt_exist = lv_objt.

          IF lv_objt IS INITIAL.
            ls_e071_txt-text = ls_objt-ddtext.
          ELSE.
            SELECT SINGLE ddtext FROM objt INTO ls_e071_txt-text
              WHERE language   = sy-langu
                AND objectname = lv_objectname
                AND objecttype = lv_objecttype.
          ENDIF.
        WHEN 'DOCU'. " Documentation
          ls_e071_txt-text = ls_e071_txt-name.
        WHEN 'DOCT'. " General Text
          ls_e071_txt-text = ls_e071_txt-name.
        WHEN 'DOCV'. " Documentation (Independent)
          ls_e071_txt-text = ls_e071_txt-name.
        WHEN 'NSPC'. " Namespace
          SELECT SINGLE descriptn FROM trnspacett INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND namespace = <ls_e071>-obj_name.
        WHEN 'CDAT'. " View Cluster Maintenance: Data
          lv_objectname = <ls_e071>-obj_name.
          lv_objecttype = <ls_e071>-object(1).

          CALL FUNCTION 'CTO_OBJECT_GET_DDIC_TEXT'
            EXPORTING
              iv_objectname        = lv_objectname
              iv_objecttype        = lv_objecttype
              iv_language          = sy-langu
            IMPORTING
              es_objt              = ls_objt
              ev_objt_doesnt_exist = lv_objt.

          IF lv_objt IS INITIAL.
            ls_e071_txt-text = ls_objt-ddtext.
          ENDIF.
        WHEN 'TDAT'. " Customizing: Table Contents
          SELECT SINGLE ddtext FROM objt INTO ls_e071_txt-text
            WHERE language   = sy-langu
              AND objectname = <ls_e071>-obj_name
              AND objecttype = 'T'.
        WHEN 'STCS'. " Task List
          SELECT SINGLE descr FROM stc_scn_hdr_t INTO ls_e071_txt-text
            WHERE langu       = sy-langu
              AND scenario_id = <ls_e071>-obj_name.
        WHEN 'BMFR'. " Application component
          SELECT SINGLE name FROM df14t INTO ls_e071_txt-text
            WHERE langu    = sy-langu
              AND addon    = ''
              AND fctr_id  = <ls_e071>-obj_name
              AND as4local = 'A'.
        WHEN 'AOBJ'. " Archiving object
          SELECT SINGLE objtext FROM arch_txt INTO ls_e071_txt-text
            WHERE langu  = sy-langu
              AND object = <ls_e071>-obj_name.
        WHEN 'AVAS'. " Classification
          SELECT SINGLE trobjtype sobj_name FROM cls_assignment
            INTO (lv_obj_type, lv_obj_name)
            WHERE guid = <ls_e071>-obj_name.
          IF sy-subrc = 0.
            CONCATENATE lv_obj_type lv_obj_name INTO ls_e071_txt-text
              SEPARATED BY space.
          ENDIF.
        WHEN 'SFBF'. " Business Function
          SELECT SINGLE name80 FROM sfw_bft INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND bfunction = <ls_e071>-obj_name.
        WHEN 'SFBS'. " Business Set
          SELECT SINGLE name80 FROM sfw_bst INTO ls_e071_txt-text
            WHERE spras = sy-langu
              AND bset  = <ls_e071>-obj_name.
        WHEN 'SFSW'. " Switch
          SELECT SINGLE name80 FROM sfw_switcht INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND switch_id = <ls_e071>-obj_name.
        WHEN 'WGRP'. " Object Type Group
          SELECT SINGLE group_name FROM objtypegroups_t INTO ls_e071_txt-text
            WHERE language      = sy-langu
              AND objtype_group = <ls_e071>-obj_name
              AND ai_version    = 'A'.
        WHEN 'CUS0'. " IMG Activity
          SELECT SINGLE text FROM cus_imgact INTO ls_e071_txt-text
            WHERE spras    = sy-langu
              AND activity = <ls_e071>-obj_name.
        WHEN 'CUS1'. " Customizing Activity
          SELECT SINGLE text FROM cus_actt INTO ls_e071_txt-text
            WHERE spras  = sy-langu
              AND act_id = <ls_e071>-obj_name.
        WHEN 'CUS2'. " Customizing Attributes
          SELECT SINGLE text FROM cus_atrt INTO ls_e071_txt-text
            WHERE spras   = sy-langu
              AND attr_id = <ls_e071>-obj_name.
      ENDCASE.

      INSERT ls_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE iv_object.
      WHEN 'SICF'. " ICF Service
        rv_icon = icon_wf_reserve_workitem.
      WHEN 'TOBJ'. " Transport object
        rv_icon = icon_transport.
      WHEN 'DOCU'. " Documentation
        rv_icon = icon_document.
      WHEN 'DOCT'. " General Text
        rv_icon = icon_display_text.
      WHEN 'DOCV'. " Documentation (Independent)
        rv_icon = icon_document.
      WHEN 'NSPC'. " Namespace
        rv_icon = icon_abc.
      WHEN 'CDAT'. " View Cluster Maintenance: Data
        rv_icon = icon_database_table_ina.
      WHEN 'TDAT'. " Customizing: Table Contents
        rv_icon = icon_table_settings.
      WHEN 'STCS'. " Task List
        rv_icon = icon_view_list.
      WHEN 'BMFR'. " Application component
        rv_icon = icon_display_tree.
      WHEN 'AOBJ'. " Archiving object
        rv_icon = icon_viewer_optical_archive.
      WHEN 'AVAS'. " Classification
        rv_icon = icon_class_connection_space.
      WHEN 'SFBF'. " Business Function
        rv_icon = icon_activity_group.
      WHEN 'SFBS'. " Business Set
        rv_icon = icon_composite_activitygroup.
      WHEN 'SFSW'. " Switch
        rv_icon = icon_business_area.
      WHEN 'WGRP'. " Object Type Group
        rv_icon = icon_object_list.
      WHEN 'CUS0'. " IMG Activity
        rv_icon = icon_display_text.
      WHEN 'CUS1'. " Customizing Activity
        rv_icon = icon_display_text.
      WHEN 'CUS2'. " Customizing Attributes
        rv_icon = icon_display_text.
      WHEN OTHERS.
        rv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'SICF'. " ICF Service
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TOBJ'. " Transport object
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCU'. " Documentation
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCT'. " General Text
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCV'. " Documentation (Independent)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'NSPC'. " Namespace
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CDAT'. " View Cluster Maintenance: Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TDAT'. " Customizing: Table Contents
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'STCS'. " Task List
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMFR'. " Application component
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AOBJ'. " Archiving object
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AVAS'. " Classification
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFBF'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFBS'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFSW'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WGRP'. " Object Type Group
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS0'. " IMG Activity
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS1'. " Customizing Activity
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS2'. " Customizing Attributes
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.
ENDCLASS.
