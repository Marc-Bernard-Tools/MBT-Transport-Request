************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_CTS
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_cts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class /MBTOOLS/CL_CTS_REQ_DISP_CTS
*"* do not include other source files here!!!
  PUBLIC SECTION.
    TYPE-POOLS icon .

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CLASS-DATA:
      nt_object_list TYPE RANGE OF e071-object READ-ONLY .

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.
*"* protected components of class /MBTOOLS/CL_CTS_REQ_DISP_CTS
*"* do not include other source files here!!!
  PRIVATE SECTION.
ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_CTS IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    FIELD-SYMBOLS:
      <ls_e071>       TYPE trwbo_s_e071.

    DATA:
      l_s_e071_txt    TYPE /mbtools/trwbo_s_e071_txt,
      l_s_object_text TYPE ko100,
      l_t_object_text TYPE TABLE OF ko100.

    CALL FUNCTION 'TR_OBJECT_TABLE'
      TABLES
        wt_object_text = l_t_object_text.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN nt_object_list.
      CLEAR l_s_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO l_s_e071_txt.

      CALL METHOD get_object_icon
        EXPORTING
          i_object = <ls_e071>-object
        CHANGING
          r_icon   = l_s_e071_txt-icon.

      CASE <ls_e071>-object.
        WHEN 'MERG' OR 'RELE'. " Comment: Object List Included, Comment Entry: Released
          SELECT SINGLE as4text FROM e07t INTO l_s_e071_txt-text
            WHERE trkorr = <ls_e071>-obj_name(10) AND langu = sy-langu.
          IF sy-subrc <> 0.
            l_s_e071_txt-text = <ls_e071>-obj_name.
          ENDIF.
          l_s_e071_txt-name = <ls_e071>-obj_name.
        WHEN 'ADIR'. " Object Directory Entry
          READ TABLE l_t_object_text INTO l_s_object_text
            WITH KEY pgmid = <ls_e071>-obj_name(4) object = <ls_e071>-obj_name+4(4).
          IF sy-subrc = 0.
            l_s_e071_txt-text = l_s_object_text-text.
          ELSE.
            l_s_e071_txt-text = 'No description'.
          ENDIF.
          CONCATENATE <ls_e071>-obj_name(4) <ls_e071>-obj_name+4(4) <ls_e071>-obj_name+8
            INTO l_s_e071_txt-name SEPARATED BY space.
        WHEN OTHERS.
          l_s_e071_txt-text = <ls_e071>-obj_name.
          l_s_e071_txt-name = <ls_e071>-obj_name.
      ENDCASE.

      INSERT l_s_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE i_object.
      WHEN 'MERG'. " Comment: Object List Included
        r_icon = icon_include_objects.
      WHEN 'PERF'. " Perforce Changelist
        r_icon = icon_modified_object.
      WHEN 'RELE'. " Comment Entry: Released
        r_icon = icon_release.
      WHEN 'ADIR'. " Object Directory Entry
        r_icon = icon_detail.
      WHEN OTHERS.
        r_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA ls_object_list LIKE LINE OF nt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'MERG'. " Comment: Object List Included
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'PERF'. " Perforce Changelist
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'RELE'. " Comment Entry: Released
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'ADIR'. " Object Directory Entry
    APPEND ls_object_list TO nt_object_list.

  ENDMETHOD.
ENDCLASS.
