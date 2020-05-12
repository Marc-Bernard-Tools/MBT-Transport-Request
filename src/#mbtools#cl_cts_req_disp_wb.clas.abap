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

    TYPE-POOLS icon .
    TYPE-POOLS swbm .

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CLASS-DATA:
      nt_object_list TYPE RANGE OF e071-object READ-ONLY .
    CONSTANTS c_as4pos TYPE ddposition VALUE '999999' ##NO_TEXT.

    CLASS-METHODS class_constructor .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-METHODS split_object
      IMPORTING
        !i_pgmid    TYPE e071-pgmid
        !i_object   TYPE e071-object
        !i_obj_name TYPE e071-obj_name
      EXPORTING
        !e_obj_type TYPE trobjtype
        !e_obj_name TYPE sobj_name
        !e_encl_obj TYPE sobj_name .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_WB IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    FIELD-SYMBOLS:
      <ls_e071>      TYPE trwbo_s_e071,
      <ls_e071k>     TYPE trwbo_s_e071k,
      <ls_e071k_str> TYPE trwbo_s_e071k_str.

    DATA:
      l_s_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      l_s_object   TYPE seu_objtxt,
      l_t_object   TYPE TABLE OF seu_objtxt,
      l_obj_name   TYPE trobj_name,
      l_clear      TYPE xsdboolean,
      l_text       TYPE string.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN nt_object_list.
      CLEAR l_s_object.

      CALL METHOD split_object
        EXPORTING
          i_pgmid    = <ls_e071>-pgmid
          i_object   = <ls_e071>-object
          i_obj_name = <ls_e071>-obj_name
        IMPORTING
          e_obj_type = l_s_object-object
          e_obj_name = l_s_object-obj_name
          e_encl_obj = l_s_object-encl_obj.

      COLLECT l_s_object INTO l_t_object.
    ENDLOOP.

    IF NOT l_t_object IS INITIAL.

      " RS_SHORTTEXT_GET has bug in buffer so we have to clear it every (until we get a fix)
      " Note: This workaround still does not fix all issues with this function but better than nothing
      l_clear = abap_true.

      CALL FUNCTION 'RS_SHORTTEXT_GET'
        EXPORTING
          clear_buffer = l_clear
        TABLES
          obj_tab      = l_t_object.

      LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN nt_object_list.
        CALL METHOD split_object
          EXPORTING
            i_pgmid    = <ls_e071>-pgmid
            i_object   = <ls_e071>-object
            i_obj_name = <ls_e071>-obj_name
          IMPORTING
            e_obj_type = l_s_object-object
            e_obj_name = l_s_object-obj_name
            e_encl_obj = l_s_object-encl_obj.

        READ TABLE l_t_object INTO l_s_object
          WITH KEY object   = l_s_object-object
                   obj_name = l_s_object-obj_name
                   encl_obj = l_s_object-encl_obj.
        IF sy-subrc = 0.
          CLEAR l_s_e071_txt.
          MOVE-CORRESPONDING <ls_e071> TO l_s_e071_txt.

          CALL METHOD get_object_icon
            EXPORTING
              i_object = <ls_e071>-object
            CHANGING
              r_icon   = l_s_e071_txt-icon.

          l_s_e071_txt-text = l_s_object-stext.
          l_s_e071_txt-name = <ls_e071>-obj_name.
          INSERT l_s_e071_txt INTO TABLE ct_e071_txt.
        ENDIF.

      ENDLOOP.

    ENDIF.

*   Table Content (TABU)
    IF it_e071k IS SUPPLIED.
      CLEAR l_t_object.

      LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN nt_object_list.
        CLEAR l_s_object.

        l_obj_name = <ls_e071k>-objname.

        CALL METHOD split_object
          EXPORTING
            i_pgmid    = <ls_e071k>-pgmid
            i_object   = <ls_e071k>-object
            i_obj_name = l_obj_name
          IMPORTING
            e_obj_type = l_s_object-object
            e_obj_name = l_s_object-obj_name
            e_encl_obj = l_s_object-encl_obj.

        COLLECT l_s_object INTO l_t_object.
      ENDLOOP.

      IF NOT l_t_object IS INITIAL.

        CALL FUNCTION 'RS_SHORTTEXT_GET'
          EXPORTING
            clear_buffer = l_clear
          TABLES
            obj_tab      = l_t_object.

        LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN nt_object_list.
          l_obj_name = <ls_e071k>-objname.

          CALL METHOD split_object
            EXPORTING
              i_pgmid    = <ls_e071k>-pgmid
              i_object   = <ls_e071k>-object
              i_obj_name = l_obj_name
            IMPORTING
              e_obj_type = l_s_object-object
              e_obj_name = l_s_object-obj_name
              e_encl_obj = l_s_object-encl_obj.

          READ TABLE l_t_object INTO l_s_object
            WITH KEY object   = l_s_object-object
                     obj_name = l_s_object-obj_name
                     encl_obj = l_s_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR l_s_e071_txt.
            MOVE-CORRESPONDING <ls_e071k> TO l_s_e071_txt.

            CALL METHOD get_object_icon
              EXPORTING
                i_object = <ls_e071k>-object
              CHANGING
                r_icon   = l_s_e071_txt-icon.

            l_s_e071_txt-text   = l_s_object-stext.
            l_s_e071_txt-name   = l_s_e071_txt-obj_name = <ls_e071k>-objname.
            l_s_e071_txt-as4pos = c_as4pos.
            COLLECT l_s_e071_txt INTO ct_e071_txt.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k

*   Table Strings (TABU)
    IF it_e071k_str IS SUPPLIED.
      CLEAR l_t_object.

      LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN nt_object_list.
        CLEAR l_s_object.

        l_obj_name = <ls_e071k_str>-objname.

        CALL METHOD split_object
          EXPORTING
            i_pgmid    = <ls_e071k_str>-pgmid
            i_object   = <ls_e071k_str>-object
            i_obj_name = l_obj_name
          IMPORTING
            e_obj_type = l_s_object-object
            e_obj_name = l_s_object-obj_name
            e_encl_obj = l_s_object-encl_obj.

        COLLECT l_s_object INTO l_t_object.
      ENDLOOP.

      IF NOT l_t_object IS INITIAL.

        CALL FUNCTION 'RS_SHORTTEXT_GET'
          EXPORTING
            clear_buffer = l_clear
          TABLES
            obj_tab      = l_t_object.

        LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN nt_object_list.
          l_obj_name = <ls_e071k_str>-objname.

          CALL METHOD split_object
            EXPORTING
              i_pgmid    = <ls_e071k_str>-pgmid
              i_object   = <ls_e071k_str>-object
              i_obj_name = l_obj_name
            IMPORTING
              e_obj_type = l_s_object-object
              e_obj_name = l_s_object-obj_name
              e_encl_obj = l_s_object-encl_obj.

          READ TABLE l_t_object INTO l_s_object
            WITH KEY object   = l_s_object-object
                     obj_name = l_s_object-obj_name
                     encl_obj = l_s_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR l_s_e071_txt.
            MOVE-CORRESPONDING <ls_e071k_str> TO l_s_e071_txt.

            CALL METHOD get_object_icon
              EXPORTING
                i_object = <ls_e071k_str>-object
              CHANGING
                r_icon   = l_s_e071_txt-icon.

            l_s_e071_txt-text   = l_s_object-stext.
            l_s_e071_txt-name   = l_s_e071_txt-obj_name = <ls_e071k_str>-objname.
            l_s_e071_txt-as4pos = c_as4pos.
            COLLECT l_s_e071_txt INTO ct_e071_txt.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k_str

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

*   See function RS_SHORTTEXT_GET
    CASE i_object.
      WHEN 'APPL'.
        r_icon = icon_package_application.
      WHEN 'BMED' OR swbm_c_type_proc_function.
        r_icon = icon_workflow_activity.
      WHEN 'BMPC' OR swbm_c_type_proc_process.
        r_icon = icon_workflow_process.
      WHEN 'CLAS' OR swbm_c_type_class OR 'SHMA' OR swbm_c_type_shared_obj_area
        OR 'CINC' OR 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        r_icon = icon_oo_class.
      WHEN 'COCO' OR swbm_c_type_control_composite.
        r_icon = icon_layout_control.
      WHEN 'DEVC' OR swbm_c_type_devclass OR 'DEVP'.
        r_icon = icon_package_standard.
      WHEN 'DIAL' OR swbm_c_type_dialog.
        r_icon = icon_wd_view.
      WHEN 'DOMA' OR 'DOMD' OR swbm_c_type_ddic_domain.
        r_icon = icon_database_table_ina.
      WHEN 'DSEL'.
        r_icon = icon_database_table.
      WHEN 'DTEL' OR 'DTED' OR swbm_c_type_ddic_dataelement.
        r_icon = icon_database_table_ina.
      WHEN 'DYNP' OR swbm_c_type_prg_dynpro.
        r_icon = icon_wd_view.
      WHEN 'ENQU' OR 'ENQD' OR swbm_c_type_ddic_enqueue.
        r_icon = icon_locked.
      WHEN 'FUNC' OR swbm_c_type_function.
        r_icon = icon_abap.
      WHEN 'FUGR' OR 'FUGT' OR swbm_c_type_function_pool.
        r_icon = icon_abap.
      WHEN 'GURL' OR swbm_c_type_url.
        r_icon = icon_url.
      WHEN 'IAMA' OR swbm_c_type_miniapp.
        r_icon = icon_htm.
      WHEN 'IASP' OR swbm_c_type_service.
        r_icon = icon_htm.
      WHEN 'IATU' OR swbm_c_type_w3_template.
        r_icon = icon_htm.
      WHEN 'IAMU' OR swbm_c_type_w3_mime.
        r_icon = icon_bmp.
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        r_icon = icon_htm.
      WHEN 'INTF' OR swbm_c_type_interface.
        r_icon = icon_oo_interface.
      WHEN 'MCOB' OR swbm_c_type_ddic_matchcode OR 'MCOD'.
        r_icon = icon_value_help.
      WHEN 'MCID'.
        r_icon = icon_value_help.
      WHEN 'MESS' OR swbm_c_type_message.
        r_icon = icon_message_type.
      WHEN 'METH' OR swbm_c_type_cls_mtd_impl.
        r_icon = icon_oo_class_method.
      WHEN 'MSAG' OR swbm_c_type_message_id OR 'MSAD'.
        r_icon = icon_message_type.
      WHEN 'PARA' OR swbm_c_type_parameter_id.
        r_icon = icon_parameter.
      WHEN 'PDAC' OR swbm_c_type_wf_role.
        r_icon = icon_role.
      WHEN 'PDTS' OR swbm_c_type_wf_task.
        r_icon = icon_workflow_activity.
      WHEN 'PDWS' OR swbm_c_type_wf_workflow.
        r_icon = icon_workflow.
      WHEN 'PINF' OR swbm_c_type_package_interface OR 'PIFA' OR 'PIFH'.
        r_icon = icon_package_dynamic.
      WHEN 'PROG' OR 'REPS' OR swbm_c_type_prg_source OR swbm_c_type_prg_include.
        r_icon = icon_abap.
      WHEN 'REPT'.
        r_icon = icon_text_ina.
      WHEN 'SCAT' OR swbm_c_type_testcase.
        r_icon = icon_test.
      WHEN 'SOBJ' OR swbm_c_type_bor_objtype.
        r_icon = icon_businav_objects.
      WHEN 'SHI3' OR 'U'.
        r_icon = icon_context_menu.
      WHEN 'SHLP' OR 'SHLD' OR swbm_c_type_ddic_searchhelp OR 'SHLX'.
        r_icon = icon_value_help.
      WHEN 'SLDB' OR swbm_c_type_logical_database.
        r_icon = icon_database_table.
      WHEN 'SMOD'.
        r_icon = icon_modification_overview.
      WHEN 'CMOD'.
        r_icon = icon_modification_create.
      WHEN 'SUSO' OR swbm_c_type_auth_object.
        r_icon = icon_locked.
      WHEN 'SQLT' OR swbm_c_type_ddic_pool_cluster OR 'SQLD' OR 'SQTT'.
        r_icon = icon_database_table.
      WHEN 'SXSD' OR swbm_c_type_badi_def.
        r_icon = icon_abap.
      WHEN 'SXCI' OR swbm_c_type_badi_imp.
        r_icon = icon_abap.
      WHEN 'CUAD' OR swbm_c_type_cua_status.
        r_icon = icon_wd_toolbar.
      WHEN swbm_c_type_cua_title.
        r_icon = icon_wd_toolbar_caption.
      WHEN 'TABL' OR 'TABD' OR swbm_c_type_ddic_db_table OR swbm_c_type_ddic_structure OR swbm_c_type_prg_table OR 'TABT' OR 'INDX'.
        r_icon = icon_database_table.
      WHEN 'TRAN' OR swbm_c_type_transaction.
        r_icon = icon_execute_object.
      WHEN 'TTYP' OR 'TTYD' OR swbm_c_type_ddic_tabletype OR 'TTYX'.
        r_icon = icon_view_table.
      WHEN 'TYPE' OR swbm_c_type_ddic_typepool.
        r_icon = icon_database_table_ina.
      WHEN 'UDMO' OR swbm_c_type_datamodel.
        r_icon = icon_businav_datamodel.
      WHEN 'UENO' OR swbm_c_type_entity.
        r_icon = icon_businav_entity.
      WHEN 'VARI'.
        r_icon = icon_abap.
      WHEN 'VIEW' OR 'VIED' OR swbm_c_type_ddic_view OR 'VDAT' OR 'VIET'.
        r_icon = icon_database_table_ina.
      WHEN 'XSLT' OR swbm_c_type_xslt_file.
        r_icon = icon_xml_doc.
      WHEN 'WTAG' OR swbm_c_type_o2_taglibrary.
        r_icon = icon_htt.
      WHEN 'WTHM' OR swbm_c_type_o2_theme.
        r_icon = icon_htt.
      WHEN 'WAPA' OR swbm_c_type_o2_application OR 'WAPD'.
        r_icon = icon_wd_application.
      WHEN 'WAPP' OR swbm_c_type_o2_page.
        r_icon = icon_wd_view.
*    WHEN 'WDYN' OR swbm_c_type_wdy_component.
*      r_icon = icon_wd_component.
*    WHEN 'WDYA' OR swbm_c_type_wdy_application.
*      r_icon = icon_wd_application.
      WHEN 'WEBI' OR swbm_c_type_virt_interface.
        r_icon = icon_interface.
      WHEN 'ENHO' OR swbm_c_type_enhancement.
        r_icon = icon_activity_group.
      WHEN 'ENHC' OR swbm_c_type_enh_composite.
        r_icon = icon_wd_tree_node.
      WHEN 'ENHS' OR swbm_c_type_enh_spot.
        r_icon = icon_mc_contentindicator.
      WHEN 'ENSC' OR swbm_c_type_enh_spot_comp.
        r_icon = icon_wd_controller.
      WHEN 'SFPI' OR swbm_c_type_formobject_intf.
        r_icon = icon_view_form.
      WHEN 'SFPF' OR swbm_c_type_formobject_form.
        r_icon = icon_view_form.
*    WHEN 'WDCA' OR swbm_c_type_wdy_appl_config  .
*      r_icon = icon_wd_application.
*    WHEN 'WDCC' OR swbm_c_type_wdy_comp_config .
*      r_icon = icon_wd_component.
      WHEN 'COAS' OR swbm_c_type_cool_aspect.
* TODO
      WHEN 'COSM' OR swbm_c_type_cool_service_mod.
* TODO
      WHEN 'ACID' OR swbm_c_type_activation_id.
        r_icon = icon_check.
      WHEN 'ECTC' OR swbm_c_type_ecatt_test_config.
        r_icon = icon_test.
      WHEN 'ECTD' OR swbm_c_type_ecatt_test_data.
        r_icon = icon_test.
      WHEN 'ECSD' OR swbm_c_type_ecatt_system_data.
        r_icon = icon_test.
      WHEN 'ECSC' OR swbm_c_type_ecatt_test_script.
        r_icon = icon_test.
      WHEN 'AUTH' OR 'SUSC'.
        r_icon = icon_locked.
*     Additional objects
      WHEN 'XPRA' OR 'PRAG'.
        r_icon = icon_abap.
      WHEN 'LDBA' OR swbm_c_type_logical_database.
        r_icon = icon_database_table.
      WHEN 'DDLS' OR swbm_c_type_ddic_ddl_source.
        r_icon = icon_abap.
      WHEN 'DCLS' OR 'Q0R'.
        r_icon = icon_locked.
      WHEN 'SAMC' OR 'SAPC'.
        r_icon = icon_short_message.
      WHEN 'TABU'.
        r_icon = icon_list.
      WHEN 'SPRX'.
        r_icon = icon_url.
      WHEN OTHERS.
        r_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA ls_object_list LIKE LINE OF nt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'APPL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BMED'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_proc_function.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BMPC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_proc_process.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CLAS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_class.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SHMA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_shared_obj_area.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CINC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CLSD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CPRI'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CPRO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CPUB'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CPAK'. "NEW: class parts
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MAPP'. "NEW: class parts
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'COCO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_control_composite.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DEVC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DEVP'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_devclass.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DIAL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_dialog.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DOMA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DOMD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_domain.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DSEL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DTEL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DTED'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_dataelement.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DYNP'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_prg_dynpro.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENQU'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENQD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_enqueue.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'FUNC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_function.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'FUGR'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'FUGT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_function_pool.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'GURL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_url.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'IAMA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_miniapp.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'IASP'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_service.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'IATU'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_w3_template.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'IAMU'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_w3_mime.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'IARP'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_w3_resource.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'INTF'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_interface.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MCOB'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MCOD'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_matchcode.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MCID'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MESS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_message.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'METH'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_cls_mtd_impl.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MSAG'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'MSAD'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_message_id.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PARA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_parameter_id.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PDAC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_wf_role.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PDTS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_wf_task.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PDWS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_wf_workflow.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PINF'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PIFA'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PIFH'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_package_interface.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PROG'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'REPS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_prg_source.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_prg_include.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'REPT'. "NEW: Report texts
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SCAT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_testcase.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SOBJ'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_bor_objtype.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SHI3'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'U'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SHLP'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SHLD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SHLX'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_searchhelp.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SLDB'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_logical_database.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SMOD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CMOD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SUSO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_auth_object.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SQLT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SQLD'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SQTT'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_pool_cluster.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SXSD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_badi_def.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SXCI'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_badi_imp.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'CUAD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_cua_status.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_cua_title.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TABL'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TABD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_db_table.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_structure.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_prg_table.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TABU'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'VDAT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TABT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TRAN'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_transaction.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TTYP'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TTYD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TTYX'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_tabletype.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'TYPE'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_typepool.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'UDMO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_datamodel.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'UENO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_entity.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'VARI'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'VIEW'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'VIED'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'VIET'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_view.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'XSLT'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_xslt_file.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WTAG'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_o2_taglibrary.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WTHM'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_o2_theme.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WAPA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WAPD'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WAPP'. "LIMU mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_o2_application.
    APPEND ls_object_list TO nt_object_list.
*   See /MBTOOLS/CL_CTS_REQ_DISP_WDY
*   ls_object_list-low = 'WDYN'.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = swbm_c_type_wdy_component.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = 'WDYA'.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = swbm_c_type_wdy_application.
*   APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'WEBI'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_virt_interface.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENHO'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_enhancement.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENHC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_enh_composite.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENHS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ENSC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot_comp.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SFPI'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_formobject_intf.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SFPF'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_formobject_form.
    APPEND ls_object_list TO nt_object_list.
*   See /MBTOOLS/CL_CTS_REQ_DISP_WDY
*   ls_object_list-low = 'WDCA'.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = swbm_c_type_wdy_appl_config.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = 'WDCC'.
*   APPEND ls_object_list TO nt_object_list.
*   ls_object_list-low = swbm_c_type_wdy_comp_config.
*   APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'COAS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_cool_aspect.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'COSM'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_cool_service_mod.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ACID'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_activation_id.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ECTC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_config.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ECTD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_data.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ECSD'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_system_data.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ECSC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_script.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'AUT'. "wb mapping
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'AUTH'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SUSC'.
    APPEND ls_object_list TO nt_object_list.
*   Additional objects
    ls_object_list-low = 'LDBA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'XPRA'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'INDX'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DDLS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'DCLS'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = swbm_c_type_ddic_ddl_source.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PRAG'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SPRX'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SAMC'.
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SAPC'.
    APPEND ls_object_list TO nt_object_list.

  ENDMETHOD.


  METHOD split_object.

    DATA:
      l_name    TYPE e071-obj_name,
      l_length1 TYPE i,
      l_length2 TYPE i,
      l_msag    TYPE i,
      l_objlen  TYPE i.

    INCLUDE ttypleng.

*   Same logic as function module TR_OBJECT_JUMP_TO_TOOL
    IF     i_pgmid  = 'LIMU'  AND  i_object  =  'REPO'.
      e_obj_type = 'PROG'.
      e_obj_name = i_obj_name.
      e_encl_obj = space.
    ELSEIF i_pgmid  = 'LIMU'  AND  i_object  =  'DYNP'.
      e_obj_type = 'DYNP'.
      l_length1  = gc_prog + gc_dynp.      " new maximal length
      l_name     = i_obj_name(l_length1)." skip comments
      l_objlen   = strlen( l_name ).
      l_length2  = gc_prog_old + gc_dynp.  " former maximal length
      IF l_objlen > l_length2.     " new syntax
        e_obj_name = l_name+gc_prog(gc_dynp).
        e_encl_obj = l_name(gc_prog).
      ELSE.                          " old syntax
        e_obj_name = l_name+gc_prog_old(gc_dynp).
        e_encl_obj = l_name(gc_prog_old).
      ENDIF.
    ELSEIF i_pgmid  = 'LIMU' AND (   i_object = 'VARI'
                                  OR i_object = 'VARX' ) .
      e_obj_type = 'VARI'.
      l_length1  = gc_prog + gc_vari.      " new maximum length
      l_name     = i_obj_name(l_length1)." skip comments
      l_objlen   = strlen( l_name ).
      l_length2  = gc_prog_old + gc_vari.  " former maximum length
      IF l_objlen > l_length2.     " new syntax
        e_obj_name = l_name+gc_prog(gc_vari).
        e_encl_obj = l_name(gc_prog).
      ELSE.                          " old syntax
        e_obj_name = l_name+gc_prog_old(gc_vari).
        e_encl_obj = l_name(gc_prog_old).
      ENDIF.
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'MESS'.
      e_obj_type = 'MESS'.
      l_length1  = gc_msag + gc_mess.      " maximum length
      l_name     = i_obj_name(l_length1)." skip comments
      l_objlen   = strlen( l_name ).
      l_msag     = l_objlen - gc_mess.
      IF l_msag < 2.                " wrong syntax
*         PERFORM get_object_description  USING    i_pgmid
*                                                  i_object
*                                         CHANGING l_text.
*         MESSAGE e197(tk)  WITH  l_text i_pgmid i_object
*                                 RAISING jump_not_possible.
      ENDIF.
      e_obj_name = l_name+l_msag(gc_mess).
      e_encl_obj = l_name(l_msag).
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'METH'.
      e_obj_type = 'METH'.
      l_name = i_obj_name+gc_clas(gc_meth).
*     Inherited methods?
      IF l_name CS '~'.
        SPLIT l_name AT '~' INTO e_encl_obj e_obj_name.
      ELSE.
        e_obj_name = l_name.
        e_encl_obj = i_obj_name(gc_clas).
      ENDIF.
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'INTD'.
      e_obj_type = 'INTF' .
      e_obj_name = i_obj_name .
      e_encl_obj = ' ' .
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'WDYC'.
      e_obj_type = 'WDYC'.
      e_obj_name = i_obj_name+gc_wdyn(gc_wdyc).
      e_encl_obj = i_obj_name(gc_wdyn).
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'WDYV'.
      e_obj_type = 'WDYV'.
      e_obj_name = i_obj_name+gc_wdyn(gc_wdyv).
      e_encl_obj = i_obj_name(gc_wdyn).
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'WAPP'.
      e_obj_type = 'WAPP'.
      e_obj_name = i_obj_name+gc_wapa(gc_wapp).
      e_encl_obj = i_obj_name(gc_wapa).
*    ELSEIF i_pgmid = 'R3TR'  AND  i_object = 'TABU'.
*      e_obj_type = 'DT'.
*      e_obj_name = i_obj_name.
    ELSEIF i_pgmid = 'LIMU'  AND  i_object = 'ADIR'.
      e_obj_type = i_obj_name+4(4).
      e_obj_name = i_obj_name+8.
    ELSE.
      e_obj_type = i_object.
      e_obj_name = i_obj_name.
      e_encl_obj = space.
    ENDIF.

*   Map some object types
    CASE i_object.
      WHEN 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        e_obj_type = 'CLAS'.
      WHEN 'CINC'.
        IF e_obj_name+30(2) = 'CC'.
          e_obj_type = 'CLAS'.
          SPLIT e_obj_name(30) AT '=' INTO e_obj_name l_name.
        ELSE.
          e_obj_type = 'PROG'.
        ENDIF.
      WHEN 'REPS' OR 'REPT'.
        IF e_obj_name+30(2) = 'CP'.
          e_obj_type = 'CLAS'.
          SPLIT e_obj_name(30) AT '=' INTO e_obj_name l_name.
        ELSE.
          e_obj_type = 'PROG'.
        ENDIF.
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
        e_obj_type = 'PROG'.
      WHEN 'XPRA'.
        e_obj_type = 'PROG'.
      WHEN 'INDX'.
        e_obj_type = 'TABL'.
        e_obj_name = e_obj_name(10).
      WHEN 'LDBA'.
        e_obj_type = swbm_c_type_logical_database.
      WHEN 'DSEL'.
        e_obj_type = swbm_c_type_logical_database.
        e_obj_name = e_obj_name+3(20).
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        e_obj_type = 'IASP'.
        e_obj_name = e_obj_name(14).
      WHEN 'IATU' OR swbm_c_type_w3_template.
        e_obj_name = e_obj_name+20(*).
        e_encl_obj = e_obj_name(20).
      WHEN 'SPRX'.
        e_obj_type = e_obj_name(4).
        e_obj_name = e_obj_name+4(*).
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
*        e_obj_name = e_obj_name(30). "appl
*        e_encl_obj = e_obj_name+30(*). "page
      WHEN 'SQLD' OR 'SQTT'.
        e_obj_type = 'SQLT'.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
