************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_WB
* MBT Request Display
*
* (c) MBT 2019 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_wb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS swbm .

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CONSTANTS c_as4pos TYPE ddposition VALUE '999999' ##NO_TEXT.
    CLASS-DATA:
      gt_object_list TYPE RANGE OF e071-object READ-ONLY .

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-METHODS split_object
      IMPORTING
        !iv_pgmid    TYPE e071-pgmid
        !iv_object   TYPE e071-object
        !iv_obj_name TYPE e071-obj_name
      EXPORTING
        !ev_obj_type TYPE trobjtype
        !ev_obj_name TYPE sobj_name
        !ev_encl_obj TYPE sobj_name .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_WB IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      ls_object   TYPE seu_objtxt,
      lt_object   TYPE TABLE OF seu_objtxt,
      lv_obj_name TYPE trobj_name,
      lv_clear    TYPE xsdboolean,
      lv_text     TYPE string.

    FIELD-SYMBOLS:
      <ls_e071>      TYPE trwbo_s_e071,
      <ls_e071k>     TYPE trwbo_s_e071k,
      <ls_e071k_str> TYPE trwbo_s_e071k_str.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_object.

      CALL METHOD split_object
        EXPORTING
          iv_pgmid    = <ls_e071>-pgmid
          iv_object   = <ls_e071>-object
          iv_obj_name = <ls_e071>-obj_name
        IMPORTING
          ev_obj_type = ls_object-object
          ev_obj_name = ls_object-obj_name
          ev_encl_obj = ls_object-encl_obj.

      COLLECT ls_object INTO lt_object.
    ENDLOOP.

    IF NOT lt_object IS INITIAL.

      " RS_SHORTTEXT_GET has bug in buffer so we have to clear it every time (until we get a fix)
      " Note: This workaround still does not fix all issues with this function but better than nothing
      lv_clear = abap_true.

      CALL FUNCTION 'RS_SHORTTEXT_GET'
        EXPORTING
          clear_buffer = lv_clear
        TABLES
          obj_tab      = lt_object.

      LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
        CALL METHOD split_object
          EXPORTING
            iv_pgmid    = <ls_e071>-pgmid
            iv_object   = <ls_e071>-object
            iv_obj_name = <ls_e071>-obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj.

        READ TABLE lt_object INTO ls_object
          WITH KEY object   = ls_object-object
                   obj_name = ls_object-obj_name
                   encl_obj = ls_object-encl_obj.
        IF sy-subrc = 0.
          CLEAR ls_e071_txt.
          MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

          CALL METHOD get_object_icon
            EXPORTING
              iv_object = <ls_e071>-object
            CHANGING
              rv_icon   = ls_e071_txt-icon.

          ls_e071_txt-text = ls_object-stext.
          ls_e071_txt-name = <ls_e071>-obj_name.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        ENDIF.

      ENDLOOP.

    ENDIF.

*   Table Content (TABU)
    IF it_e071k IS SUPPLIED.
      CLEAR lt_object.

      LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN gt_object_list.
        CLEAR ls_object.

        lv_obj_name = <ls_e071k>-objname.

        CALL METHOD split_object
          EXPORTING
            iv_pgmid    = <ls_e071k>-pgmid
            iv_object   = <ls_e071k>-object
            iv_obj_name = lv_obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj.

        COLLECT ls_object INTO lt_object.
      ENDLOOP.

      IF NOT lt_object IS INITIAL.

        lv_clear = abap_true. "see above

        CALL FUNCTION 'RS_SHORTTEXT_GET'
          EXPORTING
            clear_buffer = lv_clear
          TABLES
            obj_tab      = lt_object.

        LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN gt_object_list.
          lv_obj_name = <ls_e071k>-objname.

          CALL METHOD split_object
            EXPORTING
              iv_pgmid    = <ls_e071k>-pgmid
              iv_object   = <ls_e071k>-object
              iv_obj_name = lv_obj_name
            IMPORTING
              ev_obj_type = ls_object-object
              ev_obj_name = ls_object-obj_name
              ev_encl_obj = ls_object-encl_obj.

          READ TABLE lt_object INTO ls_object
            WITH KEY object   = ls_object-object
                     obj_name = ls_object-obj_name
                     encl_obj = ls_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR ls_e071_txt.
            MOVE-CORRESPONDING <ls_e071k> TO ls_e071_txt.

            CALL METHOD get_object_icon
              EXPORTING
                iv_object = <ls_e071k>-object
              CHANGING
                rv_icon   = ls_e071_txt-icon.

            ls_e071_txt-text   = ls_object-stext.
            ls_e071_txt-name   = ls_e071_txt-obj_name = <ls_e071k>-objname.
            ls_e071_txt-as4pos = c_as4pos.
            COLLECT ls_e071_txt INTO ct_e071_txt.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k

*   Table Strings (TABU)
    IF it_e071k_str IS SUPPLIED.
      CLEAR lt_object.

      LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN gt_object_list.
        CLEAR ls_object.

        lv_obj_name = <ls_e071k_str>-objname.

        CALL METHOD split_object
          EXPORTING
            iv_pgmid    = <ls_e071k_str>-pgmid
            iv_object   = <ls_e071k_str>-object
            iv_obj_name = lv_obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj.

        COLLECT ls_object INTO lt_object.
      ENDLOOP.

      IF NOT lt_object IS INITIAL.

        lv_clear = abap_true. "see above

        CALL FUNCTION 'RS_SHORTTEXT_GET'
          EXPORTING
            clear_buffer = lv_clear
          TABLES
            obj_tab      = lt_object.

        LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN gt_object_list.
          lv_obj_name = <ls_e071k_str>-objname.

          CALL METHOD split_object
            EXPORTING
              iv_pgmid    = <ls_e071k_str>-pgmid
              iv_object   = <ls_e071k_str>-object
              iv_obj_name = lv_obj_name
            IMPORTING
              ev_obj_type = ls_object-object
              ev_obj_name = ls_object-obj_name
              ev_encl_obj = ls_object-encl_obj.

          READ TABLE lt_object INTO ls_object
            WITH KEY object   = ls_object-object
                     obj_name = ls_object-obj_name
                     encl_obj = ls_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR ls_e071_txt.
            MOVE-CORRESPONDING <ls_e071k_str> TO ls_e071_txt.

            CALL METHOD get_object_icon
              EXPORTING
                iv_object = <ls_e071k_str>-object
              CHANGING
                rv_icon   = ls_e071_txt-icon.

            ls_e071_txt-text   = ls_object-stext.
            ls_e071_txt-name   = ls_e071_txt-obj_name = <ls_e071k_str>-objname.
            ls_e071_txt-as4pos = c_as4pos.
            COLLECT ls_e071_txt INTO ct_e071_txt.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k_str

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

*   See function RS_SHORTTEXT_GET
    CASE iv_object.
      WHEN 'APPL'.
        rv_icon = icon_package_application.
      WHEN 'BMED' OR swbm_c_type_proc_function.
        rv_icon = icon_workflow_activity.
      WHEN 'BMPC' OR swbm_c_type_proc_process.
        rv_icon = icon_workflow_process.
      WHEN 'CLAS' OR swbm_c_type_class OR 'SHMA' OR swbm_c_type_shared_obj_area
        OR 'CINC' OR 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        rv_icon = icon_oo_class.
      WHEN 'COCO' OR swbm_c_type_control_composite.
        rv_icon = icon_layout_control.
      WHEN 'DEVC' OR swbm_c_type_devclass OR 'DEVP'.
        rv_icon = icon_package_standard.
      WHEN 'DIAL' OR swbm_c_type_dialog.
        rv_icon = icon_wd_view.
      WHEN 'DOMA' OR 'DOMD' OR swbm_c_type_ddic_domain.
        rv_icon = icon_database_table_ina.
      WHEN 'DSEL'.
        rv_icon = icon_database_table.
      WHEN 'DTEL' OR 'DTED' OR swbm_c_type_ddic_dataelement.
        rv_icon = icon_database_table_ina.
      WHEN 'DYNP' OR swbm_c_type_prg_dynpro.
        rv_icon = icon_wd_view.
      WHEN 'ENQU' OR 'ENQD' OR swbm_c_type_ddic_enqueue.
        rv_icon = icon_locked.
      WHEN 'FUNC' OR swbm_c_type_function.
        rv_icon = icon_abap.
      WHEN 'FUGR' OR 'FUGT' OR swbm_c_type_function_pool.
        rv_icon = icon_abap.
      WHEN 'GURL' OR swbm_c_type_url.
        rv_icon = icon_url.
      WHEN 'IAMA' OR swbm_c_type_miniapp.
        rv_icon = icon_htm.
      WHEN 'IASP' OR swbm_c_type_service.
        rv_icon = icon_htm.
      WHEN 'IATU' OR swbm_c_type_w3_template.
        rv_icon = icon_htm.
      WHEN 'IAMU' OR swbm_c_type_w3_mime.
        rv_icon = icon_bmp.
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        rv_icon = icon_htm.
      WHEN 'INTF' OR swbm_c_type_interface.
        rv_icon = icon_oo_interface.
      WHEN 'MCOB' OR swbm_c_type_ddic_matchcode OR 'MCOD'.
        rv_icon = icon_value_help.
      WHEN 'MCID'.
        rv_icon = icon_value_help.
      WHEN 'MESS' OR swbm_c_type_message.
        rv_icon = icon_message_type.
      WHEN 'METH' OR swbm_c_type_cls_mtd_impl.
        rv_icon = icon_oo_class_method.
      WHEN 'MSAG' OR swbm_c_type_message_id OR 'MSAD'.
        rv_icon = icon_message_type.
      WHEN 'PARA' OR swbm_c_type_parameter_id.
        rv_icon = icon_parameter.
      WHEN 'PDAC' OR swbm_c_type_wf_role.
        rv_icon = icon_role.
      WHEN 'PDTS' OR swbm_c_type_wf_task.
        rv_icon = icon_workflow_activity.
      WHEN 'PDWS' OR swbm_c_type_wf_workflow.
        rv_icon = icon_workflow.
      WHEN 'PINF' OR swbm_c_type_package_interface OR 'PIFA' OR 'PIFH'.
        rv_icon = icon_package_dynamic.
      WHEN 'PROG' OR 'REPS' OR swbm_c_type_prg_source OR swbm_c_type_prg_include.
        rv_icon = icon_abap.
      WHEN 'REPT'.
        rv_icon = icon_text_ina.
      WHEN 'SCAT' OR swbm_c_type_testcase.
        rv_icon = icon_test.
      WHEN 'SOBJ' OR swbm_c_type_bor_objtype.
        rv_icon = icon_businav_objects.
      WHEN 'SHI3' OR 'U'.
        rv_icon = icon_context_menu.
      WHEN 'SHLP' OR 'SHLD' OR swbm_c_type_ddic_searchhelp OR 'SHLX'.
        rv_icon = icon_value_help.
      WHEN 'SLDB' OR swbm_c_type_logical_database.
        rv_icon = icon_database_table.
      WHEN 'SMOD'.
        rv_icon = icon_modification_overview.
      WHEN 'CMOD'.
        rv_icon = icon_modification_create.
      WHEN 'SUSO' OR swbm_c_type_auth_object.
        rv_icon = icon_locked.
      WHEN 'SQLT' OR swbm_c_type_ddic_pool_cluster OR 'SQLD' OR 'SQTT'.
        rv_icon = icon_database_table.
      WHEN 'SXSD' OR swbm_c_type_badi_def.
        rv_icon = icon_abap.
      WHEN 'SXCI' OR swbm_c_type_badi_imp.
        rv_icon = icon_abap.
      WHEN 'CUAD' OR swbm_c_type_cua_status.
        rv_icon = icon_wd_toolbar.
      WHEN swbm_c_type_cua_title.
        rv_icon = icon_wd_toolbar_caption.
      WHEN 'TABL' OR 'TABD' OR swbm_c_type_ddic_db_table OR swbm_c_type_ddic_structure
        OR swbm_c_type_prg_table OR 'TABT' OR 'INDX'.
        rv_icon = icon_database_table.
      WHEN 'TRAN' OR swbm_c_type_transaction.
        rv_icon = icon_execute_object.
      WHEN 'TTYP' OR 'TTYD' OR swbm_c_type_ddic_tabletype OR 'TTYX'.
        rv_icon = icon_view_table.
      WHEN 'TYPE' OR swbm_c_type_ddic_typepool.
        rv_icon = icon_database_table_ina.
      WHEN 'UDMO' OR swbm_c_type_datamodel.
        rv_icon = icon_businav_datamodel.
      WHEN 'UENO' OR swbm_c_type_entity.
        rv_icon = icon_businav_entity.
      WHEN 'VARI'.
        rv_icon = icon_abap.
      WHEN 'VIEW' OR 'VIED' OR swbm_c_type_ddic_view OR 'VDAT' OR 'VIET'.
        rv_icon = icon_database_table_ina.
      WHEN 'XSLT' OR swbm_c_type_xslt_file.
        rv_icon = icon_xml_doc.
      WHEN 'WTAG' OR swbm_c_type_o2_taglibrary.
        rv_icon = icon_htt.
      WHEN 'WTHM' OR swbm_c_type_o2_theme.
        rv_icon = icon_htt.
      WHEN 'WAPA' OR swbm_c_type_o2_application OR 'WAPD'.
        rv_icon = icon_wd_application.
      WHEN 'WAPP' OR swbm_c_type_o2_page.
        rv_icon = icon_wd_view.
        " 'WDYA' and swbm_c_type_wdy_application
        " 'WDYN' and swbm_c_type_wdy_component
        " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
      WHEN 'WEBI' OR swbm_c_type_virt_interface.
        rv_icon = icon_interface.
      WHEN 'ENHO' OR swbm_c_type_enhancement.
        rv_icon = icon_activity_group.
      WHEN 'ENHC' OR swbm_c_type_enh_composite.
        rv_icon = icon_wd_tree_node.
      WHEN 'ENHS' OR swbm_c_type_enh_spot.
        rv_icon = icon_mc_contentindicator.
      WHEN 'ENSC' OR swbm_c_type_enh_spot_comp.
        rv_icon = icon_wd_controller.
      WHEN 'SFPI' OR swbm_c_type_formobject_intf.
        rv_icon = icon_view_form.
      WHEN 'SFPF' OR swbm_c_type_formobject_form.
        rv_icon = icon_view_form.
        " 'WDCA' and swbm_c_type_wdy_appl_config
        " 'WDCC' and swbm_c_type_wdy_comp_config
        " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
      WHEN 'COAS' OR swbm_c_type_cool_aspect.
        rv_icon = icon_dummy ##TODO.
      WHEN 'COSM' OR swbm_c_type_cool_service_mod.
        rv_icon = icon_dummy ##TODO.
      WHEN 'ACID' OR swbm_c_type_activation_id.
        rv_icon = icon_check.
      WHEN 'ECTC' OR swbm_c_type_ecatt_test_config.
        rv_icon = icon_test.
      WHEN 'ECTD' OR swbm_c_type_ecatt_test_data.
        rv_icon = icon_test.
      WHEN 'ECSD' OR swbm_c_type_ecatt_system_data.
        rv_icon = icon_test.
      WHEN 'ECSC' OR swbm_c_type_ecatt_test_script.
        rv_icon = icon_test.
      WHEN 'AUTH' OR 'SUSC'.
        rv_icon = icon_locked.
*     Additional objects
      WHEN 'XPRA' OR 'PRAG'.
        rv_icon = icon_abap.
      WHEN 'LDBA' OR swbm_c_type_logical_database.
        rv_icon = icon_database_table.
      WHEN 'DDLS' OR swbm_c_type_ddic_ddl_source.
        rv_icon = icon_abap.
      WHEN 'DCLS' OR 'Q0R'.
        rv_icon = icon_locked.
      WHEN 'SAMC' OR 'SAPC'.
        rv_icon = icon_short_message.
      WHEN 'TABU'.
        rv_icon = icon_list.
      WHEN 'SPRX'.
        rv_icon = icon_url.
      WHEN OTHERS.
        rv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'APPL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_proc_function.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMPC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_proc_process.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CLAS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_class.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_shared_obj_area.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CINC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CLSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPRI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPRO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPUB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPAK'. "NEW: class parts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MAPP'. "NEW: class parts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'COCO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_control_composite.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DEVC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DEVP'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_devclass.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DIAL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_dialog.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOMD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_domain.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DSEL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DTEL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DTED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_dataelement.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DYNP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_dynpro.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENQU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENQD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_enqueue.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUNC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_function.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUGR'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUGT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_function_pool.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'GURL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_url.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IAMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_miniapp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IASP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_service.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IATU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_template.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IAMU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_mime.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IARP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_resource.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'INTF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCOB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCOD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_matchcode.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCID'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MESS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_message.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'METH'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cls_mtd_impl.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MSAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MSAD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_message_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PARA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_parameter_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDAC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_role.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDTS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_task.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDWS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_workflow.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PINF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PIFA'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PIFH'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_package_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PROG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'REPS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_source.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_include.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'REPT'. "NEW: Report texts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SCAT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_testcase.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOBJ'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_bor_objtype.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHI3'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'U'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLX'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_searchhelp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SLDB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_logical_database.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SMOD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CMOD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SUSO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_auth_object.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQLT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQLD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQTT'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_pool_cluster.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SXSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_badi_def.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SXCI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_badi_imp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUAD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cua_status.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cua_title.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_db_table.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_structure.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_table.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VDAT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TRAN'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_transaction.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYX'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_tabletype.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TYPE'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_typepool.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'UDMO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_datamodel.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'UENO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_entity.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VARI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VIEW'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VIED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VIET'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_view.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'XSLT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_xslt_file.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WTAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_taglibrary.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WTHM'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_theme.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPP'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_application.
    APPEND ls_object_list TO gt_object_list.
    " 'WDYA' and swbm_c_type_wdy_application
    " 'WDYN' and swbm_c_type_wdy_component
    " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
    ls_object_list-low = 'WEBI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_virt_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enhancement.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_composite.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENSC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot_comp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFPI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_formobject_intf.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFPF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_formobject_form.
    APPEND ls_object_list TO gt_object_list.
    " 'WDCA' and swbm_c_type_wdy_appl_config
    " 'WDCC' and swbm_c_type_wdy_comp_config
    " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
    ls_object_list-low = 'COAS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cool_aspect.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'COSM'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cool_service_mod.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ACID'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_activation_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECTC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_config.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECTD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_data.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_system_data.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECSC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_script.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AUT'. "wb mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AUTH'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SUSC'.
    APPEND ls_object_list TO gt_object_list.
*   Additional objects
    ls_object_list-low = 'LDBA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'XPRA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'INDX'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DDLS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DCLS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_ddl_source.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PRAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SPRX'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SAMC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SAPC'.
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.


  METHOD split_object.

    DATA:
      lv_name    TYPE e071-obj_name,
      lv_length1 TYPE i,
      lv_length2 TYPE i,
      lv_msag    TYPE i,
      lv_objlen  TYPE i.

    INCLUDE /mbtools/cts_req_typeleng.

*   Same logic as function module TR_OBJECT_JUMP_TO_TOOL
    IF     iv_pgmid  = 'LIMU'  AND  iv_object  =  'REPO'.
      ev_obj_type = 'PROG'.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ELSEIF iv_pgmid  = 'LIMU'  AND  iv_object  =  'DYNP'.
      ev_obj_type = 'DYNP'.
      lv_length1  = gc_prog + gc_dynp.      " new maximal length
      lv_name     = iv_obj_name(lv_length1)." skip comments
      lv_objlen   = strlen( lv_name ).
      lv_length2  = gc_prog_old + gc_dynp.  " former maximal length
      IF lv_objlen > lv_length2.     " new syntax
        ev_obj_name = lv_name+gc_prog(gc_dynp).
        ev_encl_obj = lv_name(gc_prog).
      ELSE.                          " old syntax
        ev_obj_name = lv_name+gc_prog_old(gc_dynp).
        ev_encl_obj = lv_name(gc_prog_old).
      ENDIF.
    ELSEIF iv_pgmid  = 'LIMU' AND (   iv_object = 'VARI'
                                  OR iv_object = 'VARX' ).
      ev_obj_type = 'VARI'.
      lv_length1  = gc_prog + gc_vari.      " new maximum length
      lv_name     = iv_obj_name(lv_length1)." skip comments
      lv_objlen   = strlen( lv_name ).
      lv_length2  = gc_prog_old + gc_vari.  " former maximum length
      IF lv_objlen > lv_length2.     " new syntax
        ev_obj_name = lv_name+gc_prog(gc_vari).
        ev_encl_obj = lv_name(gc_prog).
      ELSE.                          " old syntax
        ev_obj_name = lv_name+gc_prog_old(gc_vari).
        ev_encl_obj = lv_name(gc_prog_old).
      ENDIF.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'MESS'.
      ev_obj_type = 'MESS'.
      lv_length1  = gc_msag + gc_mess.      " maximum length
      lv_name     = iv_obj_name(lv_length1)." skip comments
      lv_objlen   = strlen( lv_name ).
      lv_msag     = lv_objlen - gc_mess.
      ev_obj_name = lv_name+lv_msag(gc_mess).
      ev_encl_obj = lv_name(lv_msag).
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'METH'.
      ev_obj_type = 'METH'.
      lv_name = iv_obj_name+gc_clas(gc_meth).
*     Inherited methods?
      IF lv_name CS '~'.
        SPLIT lv_name AT '~' INTO ev_encl_obj ev_obj_name.
      ELSE.
        ev_obj_name = lv_name.
        ev_encl_obj = iv_obj_name(gc_clas).
      ENDIF.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'INTD'.
      ev_obj_type = 'INTF'.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WDYC'.
      ev_obj_type = 'WDYC'.
      ev_obj_name = iv_obj_name+gc_wdyn(gc_wdyc).
      ev_encl_obj = iv_obj_name(gc_wdyn).
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WDYV'.
      ev_obj_type = 'WDYV'.
      ev_obj_name = iv_obj_name+gc_wdyn(gc_wdyv).
      ev_encl_obj = iv_obj_name(gc_wdyn).
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'WAPP'.
      ev_obj_type = 'WAPP'.
      ev_obj_name = iv_obj_name+gc_wapa(gc_wapp).
      ev_encl_obj = iv_obj_name(gc_wapa).
    ELSEIF iv_pgmid = 'LIMU'  AND  iv_object = 'ADIR'.
      ev_obj_type = iv_obj_name+4(4).
      ev_obj_name = iv_obj_name+8.
    ELSE.
      ev_obj_type = iv_object.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ENDIF.

*   Map some object types
    CASE iv_object.
      WHEN 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        ev_obj_type = 'CLAS'.
      WHEN 'CINC'.
        IF ev_obj_name+30(2) = 'CC'.
          ev_obj_type = 'CLAS'.
          SPLIT ev_obj_name(30) AT '=' INTO ev_obj_name lv_name.
        ELSE.
          ev_obj_type = 'PROG'.
        ENDIF.
      WHEN 'REPS' OR 'REPT'.
        IF ev_obj_name+30(2) = 'CP'.
          ev_obj_type = 'CLAS'.
          SPLIT ev_obj_name(30) AT '=' INTO ev_obj_name lv_name.
        ELSE.
          ev_obj_type = 'PROG'.
        ENDIF.
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
        ev_obj_type = 'PROG'.
      WHEN 'XPRA'.
        ev_obj_type = 'PROG'.
      WHEN 'INDX'.
        ev_obj_type = 'TABL'.
        ev_obj_name = ev_obj_name(10).
      WHEN 'LDBA'.
        ev_obj_type = swbm_c_type_logical_database.
      WHEN 'DSEL'.
        ev_obj_type = swbm_c_type_logical_database.
        ev_obj_name = ev_obj_name+3(20).
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        ev_obj_type = 'IASP'.
        ev_obj_name = ev_obj_name(14).
      WHEN 'IATU' OR swbm_c_type_w3_template.
        ev_obj_name = ev_obj_name+20(*).
        ev_encl_obj = ev_obj_name(20).
      WHEN 'SPRX'.
        ev_obj_type = ev_obj_name(4).
        ev_obj_name = ev_obj_name+4(*).
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
*       Test if it works with or without this and implement workaround if necesssary (table O2PAGDIRT)
*       ev_obj_type = 'WAPA'.
*       ev_obj_name = ev_obj_name(30). "appl
*       ev_encl_obj = ev_obj_name+30(*). "page
      WHEN 'SQLD' OR 'SQTT'.
        ev_obj_type = 'SQLT'.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
