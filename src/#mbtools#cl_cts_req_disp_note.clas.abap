************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_NOTE
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_note DEFINITION
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



CLASS /MBTOOLS/CL_CTS_REQ_DISP_NOTE IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      ls_note     TYPE cwbntstxt.

    FIELD-SYMBOLS:
      <ls_e071> TYPE trwbo_s_e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

      CALL METHOD get_object_icon
        EXPORTING
          iv_object = <ls_e071>-object
        CHANGING
          rv_icon   = ls_e071_txt-icon.

      CASE <ls_e071>-object.
        WHEN 'NOTE'. " SAP Note
          SELECT * FROM cwbntstxt INTO ls_note
            WHERE numm = <ls_e071>-obj_name AND langu = sy-langu
            ORDER BY versno DESCENDING.
            EXIT.
          ENDSELECT.
          IF sy-subrc <> 0.
            SELECT * FROM cwbntstxt INTO ls_note
              WHERE numm = <ls_e071>-obj_name AND langu = 'EN'
              ORDER BY versno DESCENDING.
              EXIT.
            ENDSELECT.
            IF sy-subrc <> 0.
              SELECT * FROM cwbntstxt INTO ls_note
                WHERE numm = <ls_e071>-obj_name AND langu = 'DE'
                ORDER BY versno DESCENDING.
                EXIT.
              ENDSELECT.
            ENDIF.
          ENDIF.

          ls_e071_txt-text = ls_note-stext.
          ls_e071_txt-name = ls_note-numm.
          SHIFT ls_e071_txt-name LEFT DELETING LEADING '0'.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'CINS'. " Correction Instruction
          SELECT SINGLE numm FROM cwbntci INTO ls_note-numm
            WHERE ciinsta = <ls_e071>-obj_name(10)
              AND cipakid = <ls_e071>-obj_name+10(10)
              AND cialeid = <ls_e071>-obj_name+20(10).
          IF sy-subrc = 0.
            ls_e071_txt-text = ls_note-numm.
            SHIFT ls_e071_txt-text LEFT DELETING LEADING '0'.
            CONCATENATE 'SAP Note' ls_e071_txt-text INTO ls_e071_txt-text SEPARATED BY space.
          ELSE.
            ls_e071_txt-text = <ls_e071>-obj_name.
          ENDIF.
          ls_e071_txt-name = <ls_e071>-obj_name.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE iv_object.
      WHEN 'NOTE'. " SAP Note
        rv_icon = icon_object_list.
      WHEN 'CINS'. " Correction Instruction
        rv_icon = icon_object_list.
      WHEN OTHERS.
        rv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'NOTE'. " SAP Note
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CINS'. " Correction Instruction
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.
ENDCLASS.
